import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/repositories/pos_repository.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_product_controller.dart';
import 'pos_cart_controller.dart';

class PosController extends GetxController with GetTickerProviderStateMixin {
  final PosRepository _repository = PosRepository();
  final cartController = Get.put(PosCartController());

  // Reuse products from existing MerchantProductController
  MerchantProductController? _productController;

  // Products displayed in POS (from product management)
  final products = <ProductModel>[].obs;
  final isLoadingProducts = false.obs;
  final searchQuery = ''.obs;

  // Transactions history
  final transactions = <PosTransactionModel>[].obs;
  final isLoadingTransactions = false.obs;

  // Daily summary
  final dailySummary = Rxn<Map<String, dynamic>>();
  final isLoadingSummary = false.obs;

  // Tables
  final tables = <MerchantTableModel>[].obs;
  final isLoadingTables = false.obs;

  // Queue
  final activeQueue = <PosTransactionModel>[].obs;
  final isLoadingQueue = false.obs;

  // Processing state
  final isProcessing = false.obs;

  // Tab controller for POS sub-tabs (6 tabs)
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 6, vsync: this);
    // Load tables and queue when those tabs are selected
    tabController.addListener(() {
      if (tabController.index == 2) fetchTables();
      if (tabController.index == 3) fetchActiveQueue();
    });
    _loadProductsFromExisting();
    fetchDailySummary();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // ─── Product Methods ─────────────────────────────────────

  /// Load products from the already-registered MerchantProductController
  /// which is the same product list used in Product Management.
  void _loadProductsFromExisting() {
    try {
      _productController = Get.find<MerchantProductController>();
      // Listen to the product list from MerchantProductController
      ever(_productController!.filteredProducts, (List<ProductModel> items) {
        _filterForPos(items);
      });
      // Initial load from existing data
      if (_productController!.filteredProducts.isNotEmpty) {
        _filterForPos(_productController!.filteredProducts);
      } else {
        // Products haven't loaded yet — trigger a refresh
        _productController!.refreshProducts();
      }
    } catch (e) {
      debugPrint(
          'MerchantProductController not found, falling back to POS API: $e');
      _fetchProductsFromApi();
    }
  }

  /// Filter products for POS display (only active products)
  void _filterForPos(List<ProductModel> allProducts) {
    if (searchQuery.value.isEmpty) {
      products.assignAll(allProducts.where((p) => p.isActive));
    } else {
      final q = searchQuery.value.toLowerCase();
      products.assignAll(
        allProducts
            .where((p) => p.isActive && p.name.toLowerCase().contains(q)),
      );
    }
  }

  /// Fallback: fetch products directly from POS API if
  /// MerchantProductController is not available
  Future<void> _fetchProductsFromApi({String? search}) async {
    try {
      isLoadingProducts.value = true;
      final result = await _repository.getProducts(search: search);
      if (result != null) {
        products.assignAll(result);
      }
    } catch (e) {
      debugPrint('Error fetching POS products: $e');
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_productController != null) {
      _filterForPos(_productController!.filteredProducts);
    } else {
      _fetchProductsFromApi(search: query.isEmpty ? null : query);
    }
  }

  // ─── Transaction Methods ────────────────────────────────

  Future<PosTransactionModel?> submitTransaction() async {
    if (cartController.isCartEmpty) {
      Get.snackbar(
        'Keranjang Kosong',
        'Tambahkan produk ke keranjang terlebih dahulu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }

    try {
      isProcessing.value = true;
      final data = cartController.buildTransactionData();
      final result = await _repository.createTransaction(data);

      if (result != null) {
        Get.snackbar(
          'Transaksi Berhasil',
          'Kode: ${result.transactionCode}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Clear cart and refresh data
        cartController.clearCart();
        fetchDailySummary();
        fetchTransactions();

        return result;
      } else {
        Get.snackbar(
          'Gagal',
          'Tidak dapat membuat transaksi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> fetchTransactions({
    String? orderType,
    String? status,
    String? from,
    String? to,
  }) async {
    try {
      isLoadingTransactions.value = true;
      final result = await _repository.getTransactions(
        orderType: orderType,
        status: status,
        from: from,
        to: to,
      );
      if (result != null) {
        transactions.assignAll(result);
      }
    } catch (e) {
      debugPrint('Error fetching POS transactions: $e');
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<void> voidTransaction(int id) async {
    try {
      final success = await _repository.voidTransaction(id);
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Transaksi telah dibatalkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        fetchTransactions();
        fetchDailySummary();
      }
    } catch (e) {
      debugPrint('Error voiding transaction: $e');
    }
  }

  // ─── Summary ────────────────────────────────────────────

  Future<void> fetchDailySummary({String? date}) async {
    try {
      isLoadingSummary.value = true;
      final result = await _repository.getDailySummary(date: date);
      dailySummary.value = result;
    } catch (e) {
      debugPrint('Error fetching daily summary: $e');
    } finally {
      isLoadingSummary.value = false;
    }
  }

  // ─── Table Management ───────────────────────────────────

  Future<void> fetchTables() async {
    try {
      isLoadingTables.value = true;
      final result = await _repository.getTables();
      if (result != null) {
        tables.assignAll(result);
      }
    } catch (e) {
      debugPrint('Error fetching tables: $e');
    } finally {
      isLoadingTables.value = false;
    }
  }

  Future<void> addTable(String tableNumber, {int capacity = 4}) async {
    try {
      isProcessing.value = true;
      await _repository.createTable({
        'table_number': tableNumber,
        'capacity': capacity,
      });
      Get.snackbar(
        'Berhasil',
        'Meja $tableNumber berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      await fetchTables();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().contains('Gagal') ? e.toString() : 'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> updateTableStatus(int id, String status) async {
    try {
      await _repository.updateTable(id, {'status': status});
      fetchTables();
    } catch (e) {
      debugPrint('Error updating table status: $e');
    }
  }

  Future<void> removeTable(int id) async {
    try {
      final success = await _repository.deleteTable(id);
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Meja berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        await fetchTables();
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menghapus meja',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('Error removing table: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ─── Queue Management ───────────────────────────────────

  Future<void> fetchActiveQueue() async {
    try {
      isLoadingQueue.value = true;
      final result = await _repository.getActiveQueue();
      if (result != null) {
        activeQueue.assignAll(result);
      }
    } catch (e) {
      debugPrint('Error fetching active queue: $e');
    } finally {
      isLoadingQueue.value = false;
    }
  }

  Future<void> updateTransactionStatus(int id, String status) async {
    try {
      final result = await _repository.updateTransactionStatus(id, status);
      if (result != null) {
        Get.snackbar('Berhasil', 'Status diubah ke $status',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchActiveQueue();
        fetchDailySummary();
      }
    } catch (e) {
      debugPrint('Error updating transaction status: $e');
    }
  }

  // Helper: count tables by status
  int get availableTableCount => tables.where((t) => t.isAvailable).length;
  int get occupiedTableCount => tables.where((t) => t.isOccupied).length;
}
