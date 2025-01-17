import 'package:antarkanma_merchant/config.dart';
import 'package:dio/dio.dart';

class CategoryProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  CategoryProvider() {
    _setupBaseOptions();
  }

  void _setupBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    );
  }

  Future<Response> getCategories(String token) async {
    try {
      return await _dio.get(
        '/api/product-categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }
}
