import 'package:antarkanma_merchant/config.dart';
import 'package:dio/dio.dart';

class ProductCategoryProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  ProductCategoryProvider() {
    _setupBaseOptions();
    _setupInterceptors();
  }

  void _setupBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Making request to: ${options.uri}');
          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response: ${response.statusCode}');
          print('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print('Request error: ${error.message}');
          print('Error response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> getCategories(String token) async {
    try {
      return await _dio.get(
        '/product-categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Error in getCategories: $e');
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<Response> getCategory(String token, int id) async {
    try {
      return await _dio.get(
        '/product-category/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Error in getCategory: $e');
      throw Exception('Failed to get category: $e');
    }
  }

  Future<Response> createCategory(
      String token, Map<String, dynamic> data) async {
    try {
      return await _dio.post(
        '/product-category',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
    } catch (e) {
      print('Error in createCategory: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Response> updateCategory(
      String token, int id, Map<String, dynamic> data) async {
    try {
      return await _dio.put(
        '/product-category/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
    } catch (e) {
      print('Error in updateCategory: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  Future<Response> deleteCategory(String token, int id) async {
    try {
      return await _dio.delete(
        '/product-category/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      print('Error in deleteCategory: $e');
      throw Exception('Failed to delete category: $e');
    }
  }
}
