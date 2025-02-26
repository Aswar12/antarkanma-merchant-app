import 'package:get/get.dart';
import '../services/transaction_service.dart';
import '../services/storage_service.dart';
import '../data/models/transaction_model.dart';
import '../controllers/base_order_controller.dart';
import '../widgets/custom_snackbar.dart';

class MerchantOrderController extends BaseOrderController {
  final TransactionService _transactionService;
  final StorageService _storageService;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString currentStatus = 'ALL'.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TransactionModel> orders = <TransactionModel>[].obs;
  final RxMap<String, int> stats = <String, int>{}.obs;
  final RxBool hasMore = false.obs;
  final RxList<TransactionModel> filteredOrders = <TransactionModel>[].obs;

  MerchantOrderController({
    TransactionService? transactionService,
    StorageService? storageService,
  })  : _transactionService = transactionService ?? Get.find<TransactionService>(),
        _storageService = storageService ?? StorageService.instance;

  @override
  void onInit() {
    super.onInit();
    checkPendingNotification();
    loadOrders();
  }

  void checkPendingNotification() async {
    try {
      final pendingNotification = _storageService.getMap('pending_notification');
      if (pendingNotification != null) {
        final type = pendingNotification['type'];
        final status = pendingNotification['status'];
        final orderId = pendingNotification['order_id'];
        
        if (type == 'transaction_approved' && 
            status == 'WAITING_APPROVAL' && 
            orderId != null) {
          // Clear the pending notification
          _storageService.remove('pending_notification');
          
          // Check if auto-approve is enabled
          if (_transactionService.getAutoApprove()) {
            // Auto approve the order
            await approveTransaction(orderId);
          } else {
            // Set status filter to WAITING_APPROVAL and refresh orders
            filterOrders('WAITING_APPROVAL');
          }
        }
      }
    } catch (e) {
      // Replace print with logging
      print('Error checking pending notification: $e');
      errorMessage.value = 'Error checking notifications';
    }
  }

  Future<void> loadOrders() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _transactionService.getOrders(
        orderIds: [], // Add the required orderIds parameter here
        page: 1,
        status: currentStatus.value == 'ALL' ? null : currentStatus.value,
      );
      
      orders.value = result.orders;
      stats.value = result.stats;
      hasMore.value = result.hasMore;
      _updateFilteredOrders();
    } catch (e) {
      // Replace print with logging
      print('Error loading orders: $e');
      errorMessage.value = 'Failed to load orders';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    if (isRefreshing.value) return;
    
    isRefreshing.value = true;
    errorMessage.value = '';
    try {
      final result = await _transactionService.getOrders(
        orderIds: [], // Add the required orderIds parameter here
        page: 1,
        status: currentStatus.value == 'ALL' ? null : currentStatus.value,
      );
      
      orders.value = result.orders;
      stats.value = result.stats;
      hasMore.value = result.hasMore;
      _updateFilteredOrders();
    } catch (e) {
      // Replace print with logging
      print('Error refreshing orders: $e');
      errorMessage.value = 'Failed to refresh orders';
    } finally {
      isRefreshing.value = false;
    }
  }

  void _updateFilteredOrders() {
    if (currentStatus.value.toUpperCase() == 'ALL') {
      filteredOrders.value = orders;
    } else {
      filteredOrders.value = orders.where((order) => 
        order.status.toUpperCase() == currentStatus.value.toUpperCase()
      ).toList();
    }
  }

  void filterOrders(String status) {
    if (currentStatus.value.toUpperCase() != status.toUpperCase()) {
      currentStatus.value = status.toUpperCase();
      loadOrders();
    }
  }

  @override
  Future<void> approveTransaction(dynamic transactionId) async {
    try {
      await _transactionService.approveOrder(transactionId);
      showCustomSnackbar(
        title: 'Success',
        message: 'Order approved successfully',
      );
      await refreshOrders();
    } catch (e) {
      // Replace print with logging
      print('Error approving transaction: $e');
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to approve order',
        isError: true,
      );
    }
  }

  @override
  Future<void> rejectTransaction(dynamic transactionId, {String? reason}) async {
    try {
      await _transactionService.rejectOrder(transactionId, reason: reason);
      showCustomSnackbar(
        title: 'Success',
        message: 'Order rejected successfully',
      );
      await refreshOrders();
    } catch (e) {
      // Replace print with logging
      print('Error rejecting transaction: $e');
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to reject order',
        isError: true,
      );
    }
  }

  Future<void> markAsReadyForPickup(dynamic orderId) async {
    try {
      await _transactionService.markOrderReady(orderId);
      showCustomSnackbar(
        title: 'Success',
        message: 'Order marked as ready for pickup',
      );
      await refreshOrders();
    } catch (e) {
      // Replace print with logging
      print('Error marking order as ready: $e');
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to mark order as ready',
        isError: true,
      );
    }
  }

  Future<void> completeOrder(dynamic orderId) async {
    try {
      await _transactionService.markOrderReady(orderId);
      showCustomSnackbar(
        title: 'Success',
        message: 'Order completed successfully',
      );
      await refreshOrders();
    } catch (e) {
      // Replace print with logging
      print('Error completing order: $e');
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to complete order',
        isError: true,
      );
    }
  }
}
