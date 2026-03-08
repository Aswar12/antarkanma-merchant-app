import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/paginated_response.dart';
import 'package:antarkanma_merchant/app/services/product_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';

class ProductRepository {
  final ProductService _productService = Get.find<ProductService>();
  final StorageService _storage = StorageService.instance;

  /// Get paginated list of products with optional filters
  Future<PaginatedResponse<ProductModel>> getProducts({
    String? query,
    int? categoryId,
    double? priceFrom,
    double? priceTo,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final token = _storage.getToken();
      return await _productService.getAllProducts(
        query: query,
        categoryId: categoryId,
        priceFrom: priceFrom,
        priceTo: priceTo,
        token: token,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      debugPrint('❌ [ProductRepository] getProducts error: $e');
      rethrow;
    }
  }

  /// Get a single product by ID
  Future<ProductModel> getProductById(int id) async {
    try {
      final token = _storage.getToken();
      return await _productService.getProductById(id, token: token);
    } catch (e) {
      debugPrint('❌ [ProductRepository] getProductById error: $e');
      rethrow;
    }
  }

  /// Get products filtered by category
  Future<PaginatedResponse<ProductModel>> getProductsByCategory(
    int categoryId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final token = _storage.getToken();
      return await _productService.getProductsByCategory(
        categoryId,
        token: token,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      debugPrint('❌ [ProductRepository] getProductsByCategory error: $e');
      rethrow;
    }
  }
}
