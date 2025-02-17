import 'package:dio/dio.dart' as dio;
import 'package:antarkanma_merchant/config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/paginated_response.dart';

class ProductService extends GetxService {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = Config.baseUrl;
  final RxList<ProductModel> _localProducts = <ProductModel>[].obs;

  ProductService() {
    _setupBaseOptions();
    _setupInterceptors();
  }

  void _setupBaseOptions() {
    _dio.options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });
          debugPrint('🌐 Request URL: ${options.uri}');
          debugPrint('📝 Request Query Parameters: ${options.queryParameters}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ Response Status Code: ${response.statusCode}');
          if (response.data is Map) {
            final data = response.data as Map<String, dynamic>;
            if (data['meta'] != null) {
              final meta = data['meta'] as Map<String, dynamic>;
              debugPrint('📊 Response Meta: $meta');
            }
            if (data['data'] != null) {
              final dataSection = data['data'] as Map<String, dynamic>;
              debugPrint('📊 Current Page: ${dataSection['current_page']}');
              debugPrint('📊 Last Page: ${dataSection['last_page']}');
              debugPrint('📊 Total Items: ${dataSection['total']}');
              final items = dataSection['data'] as List;
              debugPrint('📊 Items in Current Page: ${items.length}');
            }
          }
          return handler.next(response);
        },
        onError: (dio.DioException error, handler) {
          debugPrint('❌ API Error:');
          debugPrint('   Status Code: ${error.response?.statusCode}');
          debugPrint('   Error Data: ${error.response?.data}');
          debugPrint('   Request URL: ${error.requestOptions.uri}');
          debugPrint('   Query Params: ${error.requestOptions.queryParameters}');
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  // Method to add product to local storage
  void addProductToLocal(ProductModel product) {
    if (!_localProducts.contains(product)) {
      _localProducts.add(product);
    }
  }

  // Method to get local products
  List<ProductModel> get localProducts => _localProducts.toList();

  // Method to clear local products
  void clearLocalProducts() {
    _localProducts.clear();
  }

  Future<PaginatedResponse<ProductModel>> getAllProducts({
    String? query,
    String? description,
    List<String>? tags,
    double? priceFrom,
    double? priceTo,
    double? rateFrom,
    double? rateTo,
    int? categoryId,
    String? token,
    String? cursor,
    int? page,
    int pageSize = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page ?? 1,
        'per_page': pageSize,
      };
      
      if (query != null && query.isNotEmpty) {
        queryParams['name'] = query;
        debugPrint('🔍 Adding search query: $query');
      }
      if (description != null) queryParams['description'] = description;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (priceFrom != null) queryParams['price_from'] = priceFrom;
      if (priceTo != null) queryParams['price_to'] = priceTo;
      if (rateFrom != null) queryParams['rate_from'] = rateFrom;
      if (rateTo != null) queryParams['rate_to'] = rateTo;
      if (categoryId != null) queryParams['categories'] = categoryId;
      if (cursor != null) queryParams['cursor'] = cursor;

      debugPrint('📤 Sending request to /products');
      debugPrint('📋 Query parameters: $queryParams');

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
        options: token != null ? _getAuthOptions(token) : null,
      );

      debugPrint('📥 Response received');
      debugPrint('📊 Status code: ${response.statusCode}');
      
      return PaginatedResponse<ProductModel>.fromJson(
        response.data,
        (json) => ProductModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<ProductModel> getProductById(int id, {String? token}) async {
    try {
      final response = await _dio.get(
        '/products/$id',
        options: token != null ? _getAuthOptions(token) : null,
      );
      
      if (response.data != null && 
          response.data['data'] != null) {
        return ProductModel.fromJson(response.data['data']);
      }
      throw Exception('Product data not found');
    } catch (e) {
      debugPrint('Error fetching product: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<PaginatedResponse<ProductModel>> getProductsByCategory(
    int categoryId, {
    String? token,
    String? cursor,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'categories': categoryId,
        'page': page,
        'per_page': pageSize,
      };
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
        options: token != null ? _getAuthOptions(token) : null,
      );

      return PaginatedResponse<ProductModel>.fromJson(
        response.data,
        (json) => ProductModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<void> clearLocalStorage() async {
    // Clear both API cache and local products
    clearLocalProducts();
    debugPrint('Clearing local storage...');
  }

  void _handleError(dio.DioException error) {
    String message;
    debugPrint('🚫 API Error Response: ${error.response?.data}');
    
    if (error.response?.data is Map && error.response?.data['meta'] != null) {
      message = error.response?.data['meta']['message'] ?? 'An error occurred';
    } else {
      switch (error.response?.statusCode) {
        case 401:
          message = 'Unauthorized access. Please log in again.';
          break;
        case 403:
          message = 'You don\'t have permission to perform this action.';
          break;
        case 404:
          message = 'Product not found.';
          break;
        case 422:
          final errors = error.response?.data['errors'];
          message = errors != null ? errors.toString() : 'Validation error occurred';
          break;
        default:
          message = error.response?.data?['message'] ?? 'An error occurred';
      }
    }
    throw Exception(message);
  }

  dio.Options _getAuthOptions(String token) {
    return dio.Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
