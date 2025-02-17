import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/services/transaction_service.dart';
import 'package:antarkanma_merchant/app/data/enums/order_item_status.dart';
import 'package:flutter/foundation.dart';

class MerchantOrderController extends GetxController {
  final AuthService _authService;
  final StorageService _storageService;
  final MerchantService _merchantService;
  late final TransactionService _transactionService;

  MerchantOrderController({
    required AuthService authService,
    required MerchantService merchantService,
    required StorageService storageService,
  })  : _authService = authService,
        _merchantService = merchantService,
        _storageService = storageService {
    try {
      _transactionService = Get.find<TransactionService>();
      debugPrint('\n=== MerchantOrderController Debug ===');
      debugPrint(
          'TransactionService found with instance ID: ${_transactionService.hashCode}');
    } catch (e) {
      debugPrint('Failed to find TransactionService, creating new instance');
      _transactionService = Get.put(TransactionService());
    }
  }

  // Observable variables
  final RxList<TransactionModel> orders = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentFilter = OrderItemStatus.waitingApproval.value.obs; // Default to WAITING_APPROVAL
  final RxInt currentPage = 1.obs;
  final RxDouble totalAmount = 0.0.obs;

  // Order statistics
  final RxMap<String, int> orderStats = <String, int>{
    OrderItemStatus.waitingApproval.value: 0, // Orders requiring merchant approval
    OrderItemStatus.processing.value: 0,      // Orders being prepared
    OrderItemStatus.ready.value: 0,           // Orders ready for pickup
    OrderItemStatus.pickedUp.value: 0,        // Orders picked up by courier
    OrderItemStatus.completed.value: 0,       // Delivered orders
    OrderItemStatus.canceled.value: 0,        // Rejected/canceled orders
  }.obs;

  // Computed list of filtered orders
  List<TransactionModel> get filteredOrders {
    debugPrint('\n=== Filtering Orders ===');
    debugPrint('Current Filter: ${currentFilter.value}');
    
    var filteredList = currentFilter.value == 'all'
        ? List<TransactionModel>.from(orders)
        : orders.where((order) => 
            (order.order?.orderStatus ?? order.status).toUpperCase() == currentFilter.value.toUpperCase()
          ).toList();
    
    // Sort by ID in ascending order (newest first)
    filteredList.sort((a, b) {
      int aId = int.tryParse(a.id.toString()) ?? 0;
      int bId = int.tryParse(b.id.toString()) ?? 0;
      return bId.compareTo(aId); // Reverse order for newest first
    });
    
    debugPrint('Filtered Orders Count: ${filteredList.length}');
    return filteredList;
  }

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<String?> getMerchantId() async {
    try {
      final merchant = await _merchantService.getMerchant();
      if (merchant == null || merchant.id == null) {
        throw Exception('Merchant not found');
      }
      return merchant.id.toString();
    } catch (e) {
      debugPrint('Error getting merchant ID: $e');
      return null;
    }
  }

  Future<void> fetchOrders() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage('');      
      final mId = await getMerchantId();
      if (mId == null) {
        throw Exception('Merchant ID not found');
      }

      debugPrint('\n=== Fetching Merchant Orders ===');
      debugPrint('Merchant ID: $mId');
      debugPrint('Current Filter: ${currentFilter.value}');
      debugPrint('Current Page: ${currentPage.value}');

      final response = await _transactionService.getTransactionsByMerchant(
        mId,
        page: currentPage.value,
        limit: 10,
        status: currentFilter.value == 'all' ? null : currentFilter.value,
      );

      if (response != null) {
        final transactionsData = response['transactions'];
        if (transactionsData != null) {
          final List<dynamic> data = transactionsData['data'] ?? [];
          debugPrint('Received ${data.length} orders');

          final newOrders =
              data.map((json) => TransactionModel.fromJson(json)).toList();

          // Filter out PENDING orders (not yet approved by courier)
          final filteredOrders = newOrders.where((order) {
            final status = (order.order?.orderStatus ?? order.status).toUpperCase();
            return status != OrderItemStatus.pending.value;
          }).toList();

          if (currentPage.value == 1) {
            orders.clear();
          }

          orders.addAll(filteredOrders);

          // Update pagination info
          final pagination = transactionsData['pagination'];
          hasMore.value = pagination != null &&
              pagination['current_page'] < pagination['last_page'];

          // Update order statistics from response
          final Map<String, int>? statusCounts =
              response['status_counts'] as Map<String, int>?;
          if (statusCounts != null) {
            debugPrint('\n=== Updating Order Stats ===');
            orderStats.value =
                Map<String, int>.from(orderStats); // Create a new map
            statusCounts.forEach((key, value) {
              if (orderStats.containsKey(key)) {
                orderStats[key] = value;
                debugPrint('$key: $value');
              }
            });
          }

          // Update total amount
          final statistics = response['statistics'];
          if (statistics != null && statistics['total_revenue'] != null) {
            totalAmount.value = (statistics['total_revenue'] as num).toDouble();
          }

          debugPrint('Orders updated successfully');
        }
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void filterOrders(String status) {
    debugPrint('\n=== Filtering Orders ===');
    debugPrint('Filter Status: $status');
    currentFilter.value = status;
    debugPrint('Filtered Orders Count: ${filteredOrders.length}');
  }

  Future<void> refreshOrders() async {
    debugPrint('\n=== Refreshing Orders ===');
    currentPage.value = 1;
    hasMore.value = true;
    await fetchOrders();
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value) return;
    debugPrint('\n=== Loading More Orders ===');
    debugPrint('Current Page: ${currentPage.value}');
    currentPage.value++;
    await fetchOrders();
  }

  bool canProcessOrder(String status) {
    final upperStatus = status.toUpperCase();
    // Only allow processing of orders in WAITING_APPROVAL status
    return upperStatus == OrderItemStatus.waitingApproval.value;
  }

  bool canMarkAsReady(String status) {
    final upperStatus = status.toUpperCase();
    // Only allow marking as ready for orders in PROCESSING status
    return upperStatus == OrderItemStatus.processing.value;
  }

  Future<void> markAsReadyForPickup(String orderId) async {
    try {
      debugPrint('\n=== Marking Order as Ready for Pickup ===');
      debugPrint('Order ID: $orderId');

      final success = await _transactionService.markOrderReady(orderId);

      if (success) {
        Get.snackbar(
          'Success',
          'Order marked as ready for pickup. Courier will be notified.',
          snackPosition: SnackPosition.BOTTOM,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        await refreshOrders();
      } else {
        throw Exception('Failed to mark order as ready for pickup');
      }
    } catch (e) {
      debugPrint('Error marking order as ready for pickup: $e');
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> processOrder(String orderId) async {
    try {
      debugPrint('\n=== Processing Order ===');
      debugPrint('Order ID: $orderId');

      final success = await _transactionService.approveOrder(orderId);

      if (success) {
        Get.snackbar(
          'Success',
          'Order approved. Please prepare the order.',
          snackPosition: SnackPosition.BOTTOM,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        await refreshOrders();
      } else {
        throw Exception('Failed to process order');
      }
    } catch (e) {
      debugPrint('Error processing order: $e');
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> rejectOrder(String orderId, String? reason) async {
    try {
      debugPrint('\n=== Rejecting Order ===');
      debugPrint('Order ID: $orderId');
      debugPrint('Reason: $reason');

      final success = await _transactionService.rejectOrder(orderId, reason: reason);

      if (success) {
        Get.snackbar(
          'Success',
          'Order rejected successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        await refreshOrders();
      } else {
        throw Exception('Failed to reject order');
      }
    } catch (e) {
      debugPrint('Error rejecting order: $e');
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
