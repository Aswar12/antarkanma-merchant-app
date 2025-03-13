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
    return orders.where((order) => order.orderStatus == selectedStatus.value).toList();
  }

  // Order counts by status
  int getOrderCount(String status) {
    if (status == 'ALL') {
      // Sum of all other statuses
      return (stats.value?.statusCounts['WAITING_APPROVAL'] ?? 0) +
             (stats.value?.statusCounts['PROCESSING'] ?? 0) +
             (stats.value?.statusCounts['READY_FOR_PICKUP'] ?? 0) +
             (stats.value?.statusCounts['PICKED_UP'] ?? 0) +
             (stats.value?.statusCounts['COMPLETED'] ?? 0) +
             (stats.value?.statusCounts['CANCELED'] ?? 0);
    }
    return stats.value?.statusCounts[_getApiStatus(status) ?? ''] ?? 0;
  }

  void _updateOrderCounts(PaginatedOrderResponse response) {
    if (kDebugMode) {
      print('Status counts: ${response.stats.statusCounts}');
    }
    stats.value = response.stats;
    orderCounts.value = {
      'WAITING_APPROVAL': response.stats.statusCounts['WAITING_APPROVAL'] ?? 0,
      'PROCESSING': response.stats.statusCounts['PROCESSING'] ?? 0,
      'READY_FOR_PICKUP': response.stats.statusCounts['READY_FOR_PICKUP'] ?? 0,
      'PICKED_UP': response.stats.statusCounts['PICKED_UP'] ?? 0,
      'COMPLETED': response.stats.statusCounts['COMPLETED'] ?? 0,
      'CANCELED': response.stats.statusCounts['CANCELED'] ?? 0,
    };
    if (kDebugMode) {
      print('Updated order counts: $orderCounts');
    }
  }

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = 'WAITING_APPROVAL';
    _initialLoad();
    _startPeriodicRefresh();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'order_ready') {
        // Refresh orders when receiving order_ready notification
        refreshOrders();
        
        // Show notification to user
        Get.snackbar(
          message.notification?.title ?? 'Pesanan Siap',
          message.notification?.body ?? 'Pesanan telah siap untuk diambil',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    });
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
        final newOrders = response.orders
            .where((order) => order.orderStatus == 'WAITING_APPROVAL');
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
        final newOrders = response.orders
            .where((order) => order.orderStatus == 'WAITING_APPROVAL');
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
        print('Switching to status: $status');
        print('API status will be: ${_getApiStatus(status)}');
      }
      selectedStatus.value = status;
      orders.clear();
      currentPage.value = 1;
      loadOrders(refresh: true).then((_) {
        if (kDebugMode) {
          print('After loading orders:');
          print('Selected status: ${selectedStatus.value}');
          print('Orders count: ${orders.length}');
          print('Orders statuses: ${orders.map((o) => '${o.id}: ${o.orderStatus}').toList()}');
          print('Filtered orders count: ${filteredOrders.length}');
          print('Filtered orders: ${filteredOrders.map((o) => '${o.id}: ${o.orderStatus}').toList()}');
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
      await loadOrders(refresh: true);
      Get.snackbar(
        'Success',
        'Order #$orderId has been approved',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to approve order #$orderId',
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
      await loadOrders(refresh: true);
      Get.snackbar(
        'Success',
        'Order #$orderId has been rejected',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject order #$orderId',
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
      await loadOrders(refresh: true);
      Get.snackbar(
        'Success',
        'Order #$orderId is ready for pickup',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark order #$orderId as ready',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      loadingOrders.remove(orderId.toString());
    }
  }

  Future<void> markAsReadyForPickup(dynamic orderId) => markOrderReady(orderId);
}
