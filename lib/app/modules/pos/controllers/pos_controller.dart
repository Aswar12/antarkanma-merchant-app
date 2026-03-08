import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // Processing state
  final isProcessing = false.obs;

  // Tab controller for POS sub-tabs
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
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
}
