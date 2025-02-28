import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/order_model.dart';
import '../data/models/order_summary_model.dart';
import '../services/transaction_service.dart';
import '../modules/merchant/widgets/reject_order_dialog.dart';
import 'base_order_controller.dart';

class MerchantOrderController extends BaseOrderController {
  final TransactionService _transactionService;

  MerchantOrderController({
    required TransactionService transactionService,
  }) : _transactionService = transactionService;

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final orders = <OrderModel>[].obs;
  final stats = Rx<OrderStatsModel?>(null);
  final hasMore = false.obs;
  final currentPage = 1.obs;
  final selectedStatus = RxString('WAITING_APPROVAL');
  final isLoadingMore = false.obs;
  final autoApprove = false.obs; // Auto-approve toggle

  // Computed properties
  List<OrderModel> get filteredOrders => orders;
  String get currentStatus => selectedStatus.value;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
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
        status: selectedStatus.value == 'ALL' ? null : selectedStatus.value,
      );

      if (currentPage.value == 1) {
        orders.value = response.orders;
      } else {
        orders.addAll(response.orders);
      }

      stats.value = response.stats;
      hasMore.value = response.hasMore;

      // Auto-approve new orders if enabled
      if (autoApprove.value) {
        final newOrders = response.orders.where((order) => order.orderStatus == 'WAITING_APPROVAL');
        for (final order in newOrders) {
          approveTransaction(order.id);
        }
      }
    } catch (e, stackTrace) {
      print('Error loading orders: $e');
      print('Stack trace: $stackTrace');
      hasError.value = true;
      errorMessage.value = 'Failed to load orders: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOrders() async {
    if (!hasMore.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final response = await _transactionService.getOrders(
        page: currentPage.value,
        status: selectedStatus.value == 'ALL' ? null : selectedStatus.value,
      );

      orders.addAll(response.orders);
      stats.value = response.stats;
      hasMore.value = response.hasMore;
    } catch (e, stackTrace) {
      print('Error loading more orders: $e');
      print('Stack trace: $stackTrace');
      currentPage.value--; // Revert page increment on error
    } finally {
      isLoadingMore.value = false;
    }
  }

  void filterOrders(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      orders.clear();
      currentPage.value = 1;
      loadOrders(refresh: true);
    }
  }

  void toggleAutoApprove() {
    autoApprove.value = !autoApprove.value;
    Get.snackbar(
      'Auto Approve',
      autoApprove.value ? 'Auto approve diaktifkan' : 'Auto approve dinonaktifkan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: autoApprove.value ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
  }

  @override
  Future<void> approveTransaction(dynamic orderId) async {
    try {
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
      print('Error approving order: $e');
      Get.snackbar(
        'Error',
        'Failed to approve order #$orderId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      print('Error rejecting order: $e');
      Get.snackbar(
        'Error',
        'Failed to reject order #$orderId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Future<void> markOrderReady(dynamic orderId) async {
    try {
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
      print('Error marking order as ready: $e');
      Get.snackbar(
        'Error',
        'Failed to mark order #$orderId as ready',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Alias for markOrderReady to maintain compatibility
  Future<void> markAsReadyForPickup(dynamic orderId) => markOrderReady(orderId);
}
