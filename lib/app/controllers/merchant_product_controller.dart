import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';

class MerchantProductController extends GetxController {
  final MerchantService merchantService;

  var isLoading = false.obs;
  var isRefreshing = false.obs;
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
  Timer? _debounceTimer;

  final searchController = TextEditingController();

  MerchantProductController({required this.merchantService});

  @override
  void onInit() {
    super.onInit();
    _initializeProducts();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _initializeProducts() async {
    try {
      isLoading(true);
      await fetchProducts();
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchProducts() async {
    if (isLoadingMore.value) return;

    try {
      if (currentPage == 1) {
        if (!isRefreshing.value) {
          isLoading(true);
        }
        errorMessage('');
      }

      final response = await merchantService.getMerchantProducts(
        page: currentPage,
        pageSize: 10,
        query: searchQuery.value,
        category: selectedCategory.value == 'Semua' ? null : selectedCategory.value,
      );

      if (currentPage == 1) {
        products.clear();
      }

      products.addAll(response.data);
      hasMoreData.value = response.hasMore;
      lastPage = response.lastPage;
      totalItems = response.total;

      // Extract and sort categories
      _updateCategories();
      
      // Apply filters without fetching again
      _applyFilters();
    } catch (e) {
      errorMessage('Gagal memuat produk: $e');
      hasMoreData.value = false;
    } finally {
      isLoading(false);
      isLoadingMore(false);
      isRefreshing(false);
    }
  }

  void _updateCategories() {
    final uniqueCategories = products
        .where((p) => p.category != null)
        .map((p) => p.category!.name)
        .toSet()
        .toList()
      ..sort();
    categories.assignAll(uniqueCategories);
  }

  Future<void> loadMoreProducts() async {
    if (!hasMoreData.value || isLoadingMore.value || currentPage >= lastPage) {
      return;
    }

    try {
      isLoadingMore(true);
      currentPage++;
      await fetchProducts();
    } catch (e) {
      currentPage--;
      errorMessage('Gagal memuat lebih banyak produk: $e');
    }
  }

  void searchProducts(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      _resetAndRefetch();
    });
  }

  void filterByCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    _resetAndRefetch();
  }

  void sortProducts(String sortType) {
    if (sortBy.value == sortType) return;
    sortBy.value = sortType;
    _applyFilters();
  }

  void toggleActiveOnly(bool value) {
    showActiveOnly.value = value;
    _applyFilters();
  }

  Future<void> refreshProducts() async {
    isRefreshing(true);
    currentPage = 1;
    hasMoreData.value = true;
    await fetchProducts();
  }

  void _resetAndRefetch() {
    currentPage = 1;
    hasMoreData.value = true;
    fetchProducts();
  }

  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final result = await merchantService.deleteProduct(productId);
      if (result['success']) {
        products.removeWhere((product) => product.id == productId);
        filteredProducts.removeWhere((product) => product.id == productId);
        _updateCategories();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Error deleting product: $e'};
    }
  }

  void _applyFilters() {
    if (products.isEmpty) {
      filteredProducts.clear();
      return;
    }

    var filtered = List<ProductModel>.from(products);

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
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
    }

    // Update filtered products in a single batch
    filteredProducts.assignAll(filtered);
  }
}
