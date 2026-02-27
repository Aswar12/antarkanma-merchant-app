import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/widgets/product_readiness_sheet.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/theme.dart';
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

  final MerchantService _merchantService = Get.find<MerchantService>();

  // Product Readiness Observables
  final products = <ProductModel>[].obs;
  final unavailableProductIds = <int>[].obs;
  final isLoadingProducts = false.obs;

  // UI State
  final orderSummary = Rxn<OrderSummaryModel>();
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isOpen = true.obs; // For merchant open/close status

  // Metrics
  final todayRevenue = 0.0.obs;
  final todayCompletedOrders = 0.obs;
  final todayAverageOrder = 0.0.obs;
  final currentPage = 0.obs;

  // Active Orders - orders from backend
  final activeOrders = <OrderModel>[].obs;
  final isLoadingActiveOrders = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchActiveOrders();
    setupFCMListeners();
    // Check status periodically or on init
    ever(isOpen, (callback) => checkStoreStatus());
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
          fetchActiveOrders(); // Also fetch active orders
          break;
      }
    });
  }

  Future<void> fetchActiveOrders() async {
    try {
      isLoadingActiveOrders.value = true;
      print('=== Fetching Active Orders from Backend ===');

      // Get waiting approval orders
      final waitingResult = await transactionService.getOrders(
        status: 'WAITING_APPROVAL',
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      // Get processing orders
      final processingResult = await transactionService.getOrders(
        status: 'PROCESSING',
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      // Get ready for pickup orders
      final readyResult = await transactionService.getOrders(
        status: 'READY_FOR_PICKUP',
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      // Combine all active orders
      final allActiveOrders = <OrderModel>[];
      allActiveOrders.addAll(waitingResult.orders);
      allActiveOrders.addAll(processingResult.orders);
      allActiveOrders.addAll(readyResult.orders);

      // Sort by created date (newest first)
      allActiveOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      activeOrders.assignAll(allActiveOrders);

      print('=== Active Orders Loaded ===');
      print('Waiting: ${waitingResult.orders.length}');
      print('Processing: ${processingResult.orders.length}');
      print('Ready: ${readyResult.orders.length}');
      print('Total Active: ${activeOrders.length}');
    } catch (e) {
      print('Error fetching active orders: $e');
    } finally {
      isLoadingActiveOrders.value = false;
    }
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Get merchant details for status
      final merchant = await _merchantService.getMerchant();
      if (merchant != null) {
        isOpen.value = merchant.status == 'OPEN';

        // Auto-close check (Client-side notification trigger)
        checkStoreStatus(merchant: merchant);
      }

      // Get all orders for today to calculate metrics
      final result = await transactionService.getOrders(
        status: 'COMPLETED',
        startDate: DateTime.now().toIso8601String().split('T')[0],
        endDate: DateTime.now().toIso8601String().split('T')[0],
      );

      orderSummary.value = result.summary;

      // Calculate today's metrics from completed orders
      todayCompletedOrders.value = result.orders.length;
      todayRevenue.value =
          result.orders.fold(0.0, (sum, order) => sum + order.total);
      todayAverageOrder.value = result.orders.isEmpty
          ? 0.0
          : todayRevenue.value / todayCompletedOrders.value;
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
      await fetchActiveOrders();
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

  void toggleMerchantStatus() async {
    if (isOpen.value) {
      // Currently OPEN, trying to CLOSE
      await _closeShop();
    } else {
      // Currently CLOSED, trying to OPEN
      await _prepareOpenShop();
    }
  }

  Future<void> _closeShop() async {
    try {
      final success = await _merchantService.updateStatus('CLOSED');
      if (success) {
        isOpen.value = false;
        Get.snackbar('Toko Tutup', 'Toko berhasil ditutup',
            backgroundColor: Colors.orange, colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Gagal menutup toko',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menutup toko: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _prepareOpenShop() async {
    // 1. Fetch products
    isLoadingProducts.value = true;

    // Show Sheet immediately with loading state
    Get.bottomSheet(
      const ProductReadinessSheet(),
      isScrollControlled: true,
      enableDrag: false,
    );

    try {
      final response =
          await _merchantService.getMerchantProducts(pageSize: 100); // Get many
      products.assignAll(response.data);
      unavailableProductIds.clear(); // Reset: All assumed ready
    } catch (e) {
      Get.back(); // Close sheet
      Get.snackbar('Error', 'Gagal memuat produk: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void toggleProductUnavailable(int productId) {
    if (unavailableProductIds.contains(productId)) {
      unavailableProductIds.remove(productId);
    } else {
      unavailableProductIds.add(productId);
    }
  }

  Future<void> confirmOpenShop() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()),
          barrierDismissible: false);

      // 1. Update unavailable products
      if (unavailableProductIds.isNotEmpty) {
        final productsToUpdate = unavailableProductIds
            .map((id) => {
                  'id': id,
                  'status':
                      'UNAVAILABLE' // Or INACTIVE based on business logic, assuming UNAVAILABLE for temporary out of stock
                })
            .toList();

        await _merchantService.updateProductAvailability(productsToUpdate);
      }

      // 2. Open Shop
      final success = await _merchantService.updateStatus('OPEN');

      Get.back(); // Close loading dialog

      if (success) {
        isOpen.value = true;
        Get.snackbar('Toko Buka', 'Toko berhasil dibuka',
            backgroundColor: Colors.green, colorText: Colors.white);
        refreshData();
      } else {
        Get.snackbar('Error', 'Gagal membuka toko',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void checkStoreStatus({MerchantModel? merchant}) {
    if (merchant == null) return;

    // Logic: If status is CLOSED but we are within operating hours (and not manually closed?),
    // OR if we are showing CLOSED due to time but it's just happened.

    // Simpler logic for "Overtime":
    // If status is CLOSED, check if it was due to time (now > closing_time).
    // If so, show "Extend" dialog.

    if (merchant.status == 'CLOSED' && merchant.closingTime != null) {
      final closing = _parseTime(merchant.closingTime!);
      final now = DateTime.now();
      final closingDateTime =
          DateTime(now.year, now.month, now.day, closing.hour, closing.minute);

      // If we are past closing time (e.g. within 1 hour after closing)
      if (now.isAfter(closingDateTime) &&
          now.difference(closingDateTime).inHours < 1) {
        Get.defaultDialog(
          title: "Jam Operasional Berakhir",
          middleText: "Toko telah tutup otomatis. Ingin perpanjang 1 jam?",
          textConfirm: "Perpanjang",
          textCancel: "Tutup",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
            _extendShop();
          },
        );
      }
    }
  }

  Future<void> _extendShop() async {
    try {
      final success = await _merchantService.extendOperatingHours();
      if (success) {
        isOpen.value = true;
        Get.snackbar('Berhasil', 'Jam operasional diperpanjang 1 jam',
            backgroundColor: Colors.green, colorText: Colors.white);
        refreshData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperpanjang jam',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void changePage(int index) {
    currentPage.value = index;
  }

  // Order Actions - Delegate to TransactionService directly
  Future<void> approveOrder(int orderId) async {
    debugPrint('🔵 [MerchantHomeController] Approving order - Order ID: $orderId');
    try {
      Get.snackbar(
        'Memproses',
        'Menerima pesanan...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      debugPrint('🔵 [MerchantHomeController] Calling transactionService.approveOrder($orderId)');
      await transactionService.approveOrder(orderId);
      debugPrint('✅ [MerchantHomeController] Order approved successfully');

      debugPrint('🔵 [MerchantHomeController] Fetching active orders...');
      await fetchActiveOrders();
      debugPrint('🔵 [MerchantHomeController] Fetching data...');
      await fetchData();

      Get.snackbar(
        'Berhasil',
        'Pesanan #${orderId} telah diterima',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('🔴 [MerchantHomeController] Error approving order: $e');
      Get.snackbar(
        'Gagal',
        'Tidak dapat menerima pesanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> markOrderReady(int orderId) async {
    debugPrint('🔵 [MerchantHomeController] Marking order as ready - Order ID: $orderId');
    try {
      Get.snackbar(
        'Memproses',
        'Menandai pesanan siap diambil...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      debugPrint('🔵 [MerchantHomeController] Calling transactionService.markOrderReady($orderId)');
      await transactionService.markOrderReady(orderId);
      debugPrint('✅ [MerchantHomeController] Order marked as ready');

      debugPrint('🔵 [MerchantHomeController] Fetching active orders...');
      await fetchActiveOrders();
      debugPrint('🔵 [MerchantHomeController] Fetching data...');
      await fetchData();

      Get.snackbar(
        'Berhasil',
        'Pesanan #${orderId} ditandai siap diambil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('🔴 [MerchantHomeController] Error marking order as ready: $e');
      Get.snackbar(
        'Gagal',
        'Tidak dapat memperbarui pesanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showRejectDialog(int orderId) {
    debugPrint('🔵 [MerchantHomeController] Showing reject dialog for order - Order ID: $orderId');
    final reasonController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('Tolak Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menolak pesanan #${orderId}?'),
            SizedBox(height: 16),
            Text(
              'Alasan penolakan:',
              style: primaryTextStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Stok habis, toko tutup, dll',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: primaryTextStyle,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Alasan penolakan wajib diisi',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              debugPrint('🔵 [MerchantHomeController] User confirmed reject for order $orderId with reason: $reason');
              Get.back();
              rejectOrder(orderId, reason: reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Tolak'),
          ),
        ],
      ),
    );
  }

  Future<void> rejectOrder(int orderId, {String? reason}) async {
    debugPrint('🔵 [MerchantHomeController] Rejecting order - Order ID: $orderId');
    debugPrint('🔵 [MerchantHomeController] Reason: ${reason ?? "N/A"}');
    try {
      debugPrint('🔵 [MerchantHomeController] Calling transactionService.rejectOrder($orderId, reason: $reason)');
      await transactionService.rejectOrder(orderId, reason: reason);
      debugPrint('✅ [MerchantHomeController] Order rejected successfully');

      debugPrint('🔵 [MerchantHomeController] Fetching active orders...');
      await fetchActiveOrders();
      debugPrint('🔵 [MerchantHomeController] Fetching data...');
      await fetchData();

      Get.snackbar(
        'Berhasil',
        'Pesanan #${orderId} ditolak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('🔴 [MerchantHomeController] Error rejecting order: $e');
      Get.snackbar(
        'Gagal',
        'Tidak dapat menolak pesanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
