import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/models/order_model.dart';
import '../data/models/order_summary_model.dart';
import '../services/transaction_service.dart';
import '../modules/merchant/widgets/reject_order_dialog.dart';
import 'base_order_controller.dart';
import '../data/models/paginated_order_response.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class MerchantOrderController extends BaseOrderController {
  final TransactionService _transactionService;
  final _logger = Logger();

  MerchantOrderController({
    required TransactionService transactionService,
  }) : _transactionService = transactionService;

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final orders = <OrderModel>[].obs;
  final orderCounts = <String, int>{}.obs;
  final stats = Rx<OrderStatsModel?>(null);
  final hasMore = false.obs;
  final currentPage = 1.obs;
  final selectedStatus = RxString('ALL');
  final isLoadingMore = false.obs;
  final autoApprove = false.obs;
  final loadingOrders = <String, bool>{}.obs;
  final dateRange = Rx<DateTimeRange?>(null);
  final searchQuery = ''.obs;

  // Helper method to convert UI status to API status
  String? _getApiStatus(String uiStatus) {
    if (uiStatus == 'ALL') return null;
    return uiStatus;
  }

  // Computed properties with proper filtering
  List<OrderModel> get filteredOrders {
    if (selectedStatus.value == 'ALL') {
      return orders;
    }
    return orders
        .where((order) => order.orderStatus == selectedStatus.value)
        .toList();
  }

  // Order counts by status
  int getOrderCount(String status) {
    if (status == 'ALL') {
      // ALL = hanya status aktif (WAITING + PROCESSING + READY)
      // Match dengan backend query yang exclude COMPLETED/CANCELED
      return (stats.value?.statusCounts[OrderModel.STATUS_WAITING_APPROVAL] ??
              0) +
          (stats.value?.statusCounts[OrderModel.STATUS_PROCESSING] ?? 0) +
          (stats.value?.statusCounts[OrderModel.STATUS_READY_FOR_PICKUP] ?? 0);
    }
    return stats.value?.statusCounts[_getApiStatus(status) ?? ''] ?? 0;
  }

  void _updateOrderCounts(PaginatedOrderResponse response) {
    if (kDebugMode) {
      print('Status counts: ${response.stats.statusCounts}');
    }
    stats.value = response.stats;
    orderCounts.value = {
      OrderModel.STATUS_WAITING_APPROVAL:
          response.stats.statusCounts[OrderModel.STATUS_WAITING_APPROVAL] ?? 0,
      OrderModel.STATUS_PROCESSING:
          response.stats.statusCounts[OrderModel.STATUS_PROCESSING] ?? 0,
      OrderModel.STATUS_READY_FOR_PICKUP:
          response.stats.statusCounts[OrderModel.STATUS_READY_FOR_PICKUP] ?? 0,
      OrderModel.STATUS_COMPLETED:
          response.stats.statusCounts[OrderModel.STATUS_COMPLETED] ?? 0,
      OrderModel.STATUS_CANCELED:
          response.stats.statusCounts[OrderModel.STATUS_CANCELED] ?? 0,
    };
    if (kDebugMode) {
      print('Updated order counts: $orderCounts');
    }
  }

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = OrderModel.STATUS_WAITING_APPROVAL;
    _initialLoad();
    _startPeriodicRefresh();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'];

      if (type == 'new_order') {
        // Efficient: Fetch only the new order instead of pulling all orders
        _handleNewOrderNotification(message);
      } else if (type == 'order_ready') {
        refreshOrders();
        Get.snackbar(
          message.notification?.title ?? 'Pesanan Siap',
          message.notification?.body ?? 'Pesanan telah siap untuk diambil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else if (type == 'courier_heading_to_merchant') {
        // Kurir sudah terima order dan sedang menuju toko
        refreshOrders();
        Get.snackbar(
          '🛵 Kurir Sedang Menuju',
          message.notification?.body ??
              'Kurir sedang dalam perjalanan ke toko Anda. Segera siapkan pesanan!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
      } else if (type == 'courier_arrived_at_merchant') {
        // Kurir sudah tiba di merchant
        refreshOrders();
        Get.snackbar(
          '📦 Kurir Sudah Tiba!',
          message.notification?.body ??
              'Kurir sudah tiba di toko Anda. Serahkan pesanan ke kurir.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          margin: const EdgeInsets.all(8),
        );
      } else if (type == 'order_picked_up') {
        // Kurir sudah ambil pesanan
        refreshOrders();
        Get.snackbar(
          '✅ Pesanan Diambil',
          message.notification?.body ?? 'Pesanan telah diambil oleh kurir.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else if (type == 'order_completed') {
        // Order selesai diantarkan
        refreshOrders();
        Get.snackbar(
          '🎉 Pesanan Selesai',
          message.notification?.body ?? 'Pesanan berhasil sampai ke customer.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  /// Handle new order notification efficiently - fetch only the new order
  Future<void> _handleNewOrderNotification(RemoteMessage message) async {
    try {
      final orderId = message.data['order_id'];
      if (orderId == null) {
        print('No order_id in notification data');
        return;
      }

      // Convert to int for proper comparison (avoid string vs int mismatch)
      final orderIdInt = int.tryParse(orderId.toString());
      if (orderIdInt == null) {
        print('Invalid order_id format: $orderId');
        return;
      }

      print('Received new order notification for order: $orderIdInt');

      // Check if order already exists in local list (compare as integers)
      final existingOrderIndex = orders.indexWhere((o) => o.id == orderIdInt);

      if (existingOrderIndex != -1) {
        // Order already exists, no need to fetch
        print(
            'Order $orderIdInt already exists in local list at index $existingOrderIndex');
      } else {
        // Fetch only the new order from server
        print('Fetching new order $orderIdInt from server...');
        final newOrder = await _transactionService.getOrderById(orderIdInt);

        if (newOrder != null) {
          // Add to beginning of list (newest first)
          orders.insert(0, newOrder);

          // Update status counts
          final currentCount = orderCounts[newOrder.orderStatus] ?? 0;
          orderCounts[newOrder.orderStatus] = currentCount + 1;

          print('New order added to list: ${newOrder.id}');
        } else {
          print('Failed to fetch new order $orderIdInt');
        }
      }

      // Show notification to user
      Get.snackbar(
        message.notification?.title ?? 'Pesanan Baru',
        message.notification?.body ??
            'Anda memiliki pesanan baru yang perlu dikonfirmasi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error handling new order notification: $e');
    }
  }

  void _startPeriodicRefresh() {
    Future.delayed(Duration(seconds: 30), () {
      if (Get.currentRoute.contains('merchant_order')) {
        refreshOrders();
        _startPeriodicRefresh();
      }
    });
  }

  @override
  Future<void> fetchOrderSummary() async {
    try {
      final response = await _transactionService.getOrders(
        page: 1,
        status: _getApiStatus(selectedStatus.value),
      );
      _updateOrderCounts(response);
    } catch (e) {
      _logger.e('Error fetching order summary: $e');
    }
  }

  Future<void> _initialLoad() async {
    try {
      hasError.value = false;
      errorMessage.value = '';

      final response = await _transactionService.getOrders(
        page: currentPage.value,
        status: _getApiStatus(selectedStatus.value),
      );

      orders.value = response.orders;
      hasMore.value = response.hasMore;
      _updateOrderCounts(response);

      if (autoApprove.value) {
        final newOrders = response.orders.where(
            (order) => order.orderStatus == OrderModel.STATUS_WAITING_APPROVAL);
        for (final order in newOrders) {
          approveTransaction(order.id);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load orders: $e';
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders(refresh: true);
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      orders.clear();
    }

    if (isLoading.value && !refresh) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _transactionService.getOrders(
        page: currentPage.value,
        status: _getApiStatus(selectedStatus.value),
      );

      if (currentPage.value == 1) {
        orders.value = response.orders;
      } else {
        orders.addAll(response.orders);
      }

      hasMore.value = response.hasMore;
      _updateOrderCounts(response);

      if (autoApprove.value) {
        final newOrders = response.orders.where(
            (order) => order.orderStatus == OrderModel.STATUS_WAITING_APPROVAL);
        for (final order in newOrders) {
          approveTransaction(order.id);
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load more orders: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _transactionService.getOrders(
        page: currentPage.value,
        status: _getApiStatus(selectedStatus.value),
        startDate: dateRange.value?.start.toIso8601String(),
        endDate: dateRange.value?.end.toIso8601String(),
        search: searchQuery.value,
      );

      orders.addAll(response.orders);
      hasMore.value = response.hasMore;
      _updateOrderCounts(response);
    } catch (e) {
      _logger.e('Error loading more orders: $e');
      currentPage.value--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  void filterOrders(String status) {
    if (selectedStatus.value != status) {
      if (kDebugMode) {
        print('🔵 Filter changed: $status');
        print('   API status will be: ${_getApiStatus(status)}');
      }

      selectedStatus.value = status;
      orders.clear();
      currentPage.value = 1;
      loadOrders(refresh: true).then((_) {
        if (kDebugMode) {
          print('✅ After loading orders:');
          print('   Selected status: ${selectedStatus.value}');
          print('   Orders count: ${orders.length}');
          print(
              '   Orders: ${orders.map((o) => '${o.id} (${o.orderStatus})').toList()}');
          print('   Filtered orders count: ${filteredOrders.length}');
        }
      });
    }
  }

  void toggleAutoApprove() {
    autoApprove.value = !autoApprove.value;
    Get.snackbar(
      'Auto Approve',
      autoApprove.value
          ? 'Auto approve diaktifkan'
          : 'Auto approve dinonaktifkan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: autoApprove.value ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
  }

  @override
  Future<void> approveTransaction(dynamic orderId) async {
    try {
      loadingOrders[orderId.toString()] = true;

      await _transactionService.approveOrder(orderId);

      // Remove from current list (karena status sudah berubah dari WAITING_APPROVAL ke PROCESSING)
      orders.removeWhere((o) => o.id == orderId);

      // Update counts - kurangi WAITING_APPROVAL, tambah PROCESSING
      final waitingCount = orderCounts[OrderModel.STATUS_WAITING_APPROVAL] ?? 0;
      orderCounts[OrderModel.STATUS_WAITING_APPROVAL] =
          math.max(0, waitingCount - 1);

      final processingCount = orderCounts[OrderModel.STATUS_PROCESSING] ?? 0;
      orderCounts[OrderModel.STATUS_PROCESSING] = processingCount + 1;

      // Refresh stats
      await fetchOrderSummary();

      // Refresh UI - notify listeners
      update();

      // Show success notification
      Get.snackbar(
        '✅ Order Disetujui',
        'Order #$orderId sekarang ada di tab "Diproses"',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      _logger.e('Error approving order: $e');
      Get.snackbar(
        '❌ Error',
        'Gagal menyetujui order #$orderId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingOrders.remove(orderId.toString());
    }
  }

  @override
  void showRejectDialog(dynamic orderId) {
    Get.dialog(
      RejectOrderDialog(
        onSubmit: (reason) {
          rejectTransaction(orderId, reason: reason);
        },
      ),
    );
  }

  @override
  Future<void> rejectTransaction(dynamic orderId, {String? reason}) async {
    try {
      loadingOrders[orderId.toString()] = true;

      await _transactionService.rejectOrder(orderId, reason: reason);

      // Remove from current list (karena status sudah berubah ke CANCELED)
      orders.removeWhere((o) => o.id == orderId);

      // Update counts - kurangi WAITING_APPROVAL
      final waitingCount = orderCounts[OrderModel.STATUS_WAITING_APPROVAL] ?? 0;
      orderCounts[OrderModel.STATUS_WAITING_APPROVAL] =
          math.max(0, waitingCount - 1);

      // Note: CANCELED tidak ditampilkan di tab, jadi tidak perlu ditambah

      // Refresh stats
      await fetchOrderSummary();

      // Refresh UI
      update();

      Get.snackbar(
        'Order Ditolak',
        'Order #$orderId telah ditolak',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _logger.e('Error rejecting order: $e');
      Get.snackbar(
        '❌ Error',
        'Gagal menolak order #$orderId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingOrders.remove(orderId.toString());
    }
  }

  @override
  Future<void> markOrderReady(dynamic orderId) async {
    try {
      loadingOrders[orderId.toString()] = true;

      await _transactionService.markOrderReady(orderId);

      // Remove from current list (karena status sudah berubah dari PROCESSING ke READY_FOR_PICKUP)
      orders.removeWhere((o) => o.id == orderId);

      // Update counts - kurangi PROCESSING, tambah READY_FOR_PICKUP
      final processingCount = orderCounts[OrderModel.STATUS_PROCESSING] ?? 0;
      orderCounts[OrderModel.STATUS_PROCESSING] =
          math.max(0, processingCount - 1);

      final readyCount = orderCounts[OrderModel.STATUS_READY_FOR_PICKUP] ?? 0;
      orderCounts[OrderModel.STATUS_READY_FOR_PICKUP] = readyCount + 1;

      // Refresh stats
      await fetchOrderSummary();

      // Refresh UI
      update();

      Get.snackbar(
        '✅ Siap Diambil',
        'Order #$orderId siap diambil kurir',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _logger.e('Error marking order ready: $e');
      Get.snackbar(
        '❌ Error',
        'Gagal menandai order #$orderId siap diambil',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingOrders.remove(orderId.toString());
    }
  }

  Future<void> markAsReadyForPickup(dynamic orderId) => markOrderReady(orderId);

  Future<void> markOrderPickedUp(dynamic orderId) async {
    try {
      loadingOrders[orderId.toString()] = true;

      await _transactionService.markOrderPickedUp(orderId);

      // Remove from current list (karena status sudah berubah dari READY_FOR_PICKUP ke PICKED_UP)
      orders.removeWhere((o) => o.id == orderId);

      // Update counts - kurangi READY_FOR_PICKUP
      final readyCount = orderCounts[OrderModel.STATUS_READY_FOR_PICKUP] ?? 0;
      orderCounts[OrderModel.STATUS_READY_FOR_PICKUP] = math.max(0, readyCount - 1);

      // Refresh stats
      await fetchOrderSummary();

      // Refresh UI
      update();

      Get.snackbar(
        '✅ Pesanan Diambil',
        'Order #$orderId telah diambil oleh kurir',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _logger.e('Error marking order as picked up: $e');
      Get.snackbar(
        '❌ Error',
        'Gagal menandai order #$orderId sebagai diambil',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingOrders.remove(orderId.toString());
    }
  }
}
