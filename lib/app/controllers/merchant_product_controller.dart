import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';

class MerchantProductController extends GetxController {
  final MerchantService merchantService;
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;
  var showActiveOnly = false.obs;
  var searchQuery = ''.obs;
  var selectedCategory = 'Semua'.obs;
  var sortBy = 'Baru'.obs;
  var categories = <String>[].obs;

  // Pagination variables
  var currentPage = 1;
  var hasMoreData = true.obs;
  var isLoadingMore = false.obs;
  var totalItems = 0;
  var lastPage = 1;

  final searchController = TextEditingController();

  MerchantProductController({required this.merchantService});

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    try {
      if (currentPage == 1) {
        isLoading(true);
      }
      errorMessage('');
      
      final response = await merchantService.getMerchantProducts(
        page: currentPage,
        pageSize: 10,
      );
      
      if (currentPage == 1) {
        products.clear();
      }
      
      products.addAll(response.data);
      hasMoreData.value = response.hasMore;
      lastPage = response.lastPage;
      totalItems = response.total;
      
      // Extract unique categories
      final uniqueCategories = products
          .where((p) => p.category != null)
          .map((p) => p.category!.name)
          .toSet()
          .toList();
      categories.assignAll(['Semua', ...uniqueCategories]);
      
      _applyFilters();
    } catch (e) {
      errorMessage('Gagal memuat produk: $e');
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMoreData.value || isLoadingMore.value || currentPage >= lastPage) {
      return;
    }

    try {
      isLoadingMore(true);
      currentPage++;
      await fetchProducts();
    } finally {
      isLoadingMore(false);
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      isLoading(true);
      final result = await merchantService.deleteProduct(productId);
      if (result['success']) {
        // Remove the product from the lists
        products.removeWhere((product) => product.id == productId);
        filteredProducts.removeWhere((product) => product.id == productId);
      }
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting product: $e'
      };
    } finally {
      isLoading(false);
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    currentPage = 1;
    hasMoreData.value = true;
    fetchProducts();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    currentPage = 1;
    hasMoreData.value = true;
    fetchProducts();
  }

  void sortProducts(String sortType) {
    sortBy.value = sortType;
    _applyFilters();
  }

  void toggleActiveOnly(bool value) {
    showActiveOnly.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<ProductModel>.from(products);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((product) =>
          product.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }

    // Apply category filter
    if (selectedCategory.value != 'Semua') {
      filtered = filtered.where((product) =>
          product.category?.name == selectedCategory.value).toList();
    }

    // Apply active filter
    if (showActiveOnly.value) {
      filtered = filtered.where((product) => product.isActive).toList();
    }

    // Apply sorting
    switch (sortBy.value) {
      case 'A-Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Z-A':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        filtered.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_desc':
        filtered.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'Baru':
      default:
        filtered.sort((a, b) => 
          (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
    }

    filteredProducts.assignAll(filtered);
  }
}
