import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/order_summary_model.dart';
import '../services/transaction_service.dart';

class MerchantHomeController extends GetxController {
  final TransactionService transactionService;

  MerchantHomeController({
    required this.transactionService,
  });

  final orderSummary = Rxn<OrderSummaryModel>();
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isOpen = true.obs; // For merchant open/close status
  final todayRevenue = 0.0.obs;
  final todayCompletedOrders = 0.obs;
  final todayAverageOrder = 0.0.obs;
  final currentPage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    setupFCMListeners();
  }

  void setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // Handle specific notification types
      switch (message.data['type']) {
        case 'transaction_approved':
        case 'transaction_rejected':
        case 'new_order':
          refreshData(); // Reload the page data
          break;
      }
    });
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Get all orders for today to calculate metrics
      final result = await transactionService.getOrders(
        status: 'COMPLETED',
        startDate: DateTime.now().toIso8601String().split('T')[0],
        endDate: DateTime.now().toIso8601String().split('T')[0],
      );

      orderSummary.value = result.summary;
      
      // Calculate today's metrics from completed orders
      todayCompletedOrders.value = result.orders.length;
      todayRevenue.value = result.orders.fold(0.0, (sum, order) => 
        sum + double.parse(order.totalAmount));
      todayAverageOrder.value = result.orders.isEmpty ? 0.0 : 
        todayRevenue.value / todayCompletedOrders.value;

    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      await fetchData();
    } catch (e) {
      print('Error refreshing data: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void toggleMerchantStatus() {
    isOpen.value = !isOpen.value;
    Get.snackbar(
      'Status Toko',
      isOpen.value ? 'Toko sekarang buka' : 'Toko sekarang tutup',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isOpen.value ? Colors.green : Colors.orange,
      colorText: Colors.white,
    );
  }

  void changePage(int index) {
    currentPage.value = index;
  }
}
