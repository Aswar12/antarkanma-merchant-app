import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/transaction_model.dart';
import '../services/transaction_service.dart';
import 'base_order_controller.dart';
import 'merchant_order_controller.dart';
import 'merchant_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../routes/app_pages.dart';

class MerchantHomeController extends BaseOrderController {
  final TransactionService _transactionService;
  final GetStorage _storage = GetStorage();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = Get.find<FlutterLocalNotificationsPlugin>();
  late final MerchantController _merchantController;
  
  final isLoading = true.obs;
  final autoApprove = false.obs;
  final newTransactions = <TransactionModel>[].obs;
  final currentPage = 0.obs;
  bool _isPageChangeInProgress = false;
  
  // New properties for error handling
  final hasError = false.obs;
  final errorMessage = ''.obs;

  MerchantHomeController({
    required TransactionService transactionService,
  }) : _transactionService = transactionService {
    _merchantController = Get.find<MerchantController>();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize auto-approve state from storage
    autoApprove.value = _transactionService.getAutoApprove();
    loadData();
    _checkPendingNotifications();
  }

  Future<void> _checkPendingNotifications() async {
    final pendingNotification = _storage.read('pending_notification');
    if (pendingNotification != null) {
      if (pendingNotification['type'] == 'transaction_approved' && 
          pendingNotification['status'] == 'WAITING_APPROVAL') {
        // Navigate to orders page and set filter
        changePage(1); // Orders tab
        try {
          final orderController = Get.find<MerchantOrderController>();
          orderController.filterOrders('WAITING_APPROVAL');
        } catch (e) {
          print('Error setting order filter: $e');
        }
    
    // Call loadData to refresh the displayed orders
    await loadData();
      }
      // Clear the pending notification
      await _storage.remove('pending_notification');
    }
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final transactions = await _transactionService.getPendingTransactions();
      
      // Sort transactions by creation date (newest first)
      transactions.sort((a, b) => 
        (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
      
      newTransactions.value = transactions;
    } catch (e) {
      print('Error loading transactions: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load transactions';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    return loadData();
  }

  void toggleAutoApprove() {
    autoApprove.value = !autoApprove.value;
    _transactionService.saveAutoApprove(autoApprove.value);
    
    // Notify MerchantOrderController about auto-approve change
    try {
      final orderController = Get.find<MerchantOrderController>();
      // If there's a pending notification, handle it according to new auto-approve setting
      final pendingNotification = _storage.read('pending_notification');
      if (pendingNotification != null && 
          pendingNotification['type'] == 'transaction_approved' && 
          pendingNotification['status'] == 'WAITING_APPROVAL' &&
          pendingNotification['order_id'] != null) {
        if (autoApprove.value) {
          // Auto approve the pending order
          orderController.approveTransaction(pendingNotification['order_id']);
          _storage.remove('pending_notification');
        } else {
          // Show pending orders
          orderController.filterOrders('WAITING_APPROVAL');
        }
      }
    } catch (e) {
      print('Error syncing auto-approve state: $e');
    }
  }

  void changePage(int index) {
    if (!_isPageChangeInProgress && currentPage.value != index) {
      print("MerchantHomeController changing page to: $index");
      _isPageChangeInProgress = true;
      currentPage.value = index;
      _merchantController.changePage(index);
      _isPageChangeInProgress = false;

      if (index == 1) { // Orders tab
        try {
          final orderController = Get.find<MerchantOrderController>();
          orderController.loadOrders();
        } catch (e) {
          print('Error refreshing orders on tab change: $e');
        }
      }
    }
  }

  @override
  Future<void> approveTransaction(dynamic transactionId) async {
    try {
      isLoading.value = true;
      await _transactionService.approveOrder(transactionId);
      await loadData(); // Refresh the list
      Get.snackbar(
        'Sukses',
        'Pesanan #$transactionId telah disetujui',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error approving transaction: $e');
      Get.snackbar(
        'Error',
        'Gagal menyetujui pesanan #$transactionId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> rejectTransaction(dynamic transactionId, {String? reason}) async {
    try {
      isLoading.value = true;
      await _transactionService.rejectOrder(transactionId, reason: reason);
      await loadData(); // Refresh the list
      Get.snackbar(
        'Sukses',
        'Pesanan #$transactionId telah ditolak',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error rejecting transaction: $e');
      Get.snackbar(
        'Error',
        'Gagal menolak pesanan #$transactionId',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markOrderReady(dynamic orderId) async {
    try {
      isLoading.value = true;
      await _transactionService.markOrderReady(orderId);
      await loadData(); // Refresh the list
      Get.snackbar(
        'Sukses',
        'Pesanan #$orderId siap untuk diambil',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error marking order as ready: $e');
      Get.snackbar(
        'Error',
        'Gagal menandai pesanan #$orderId siap diambil',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _isPageChangeInProgress = false;
    super.onClose();
  }
}
