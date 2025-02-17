import 'package:antarkanma_merchant/app/data/models/product_category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/providers/product_category_provider.dart';
import '../services/auth_service.dart';

class CategoryService extends GetxService {
  final ProductCategoryProvider _provider;
  final AuthService _authService;
  final RxList<ProductCategory> _categories = <ProductCategory>[].obs;
  final RxBool isLoading = false.obs;
  bool _isInitialized = false;

  CategoryService()
      : _provider = ProductCategoryProvider(),
        _authService = Get.find<AuthService>();

  List<ProductCategory> get categories => _categories;

  Future<List<ProductCategory>> fetchCategories() async {
    try {
      isLoading.value = true;
      final token = _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _provider.getCategories(token);
      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> categoriesData = response.data['data'];
        _categories.value = categoriesData
            .map((json) => ProductCategory.fromJson(json))
            .toList();
        return _categories;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<ProductCategory?> createCategory(ProductCategory category) async {
    try {
      isLoading.value = true;
      final token = _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _provider.createCategory(token, category.toJson());
      if (response.data != null && response.data['data'] != null) {
        final newCategory = ProductCategory.fromJson(response.data['data']);
        _categories.add(newCategory);
        return newCategory;
      }
      return null;
    } catch (e) {
      debugPrint('Error creating category: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCategory(ProductCategory category) async {
    try {
      isLoading.value = true;
      final token = _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _provider.updateCategory(
        token,
        category.id,
        category.toJson(),
      );
      
      if (response.statusCode == 200) {
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = category;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      isLoading.value = true;
      final token = _authService.getToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await _provider.deleteCategory(token, categoryId);
      
      if (response.statusCode == 200) {
        _categories.removeWhere((category) => category.id == categoryId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  ProductCategory? findCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  ProductCategory? findCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> init() async {
    if (!_isInitialized) {
      await fetchCategories();
      _isInitialized = true;
    }
  }

  void dispose() {
    _categories.clear();
    _isInitialized = false;
  }
}
