import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import '../../../config.dart';
import '../../services/storage_service.dart';
import 'package:get/get.dart';

class PosProvider {
  final dio.Dio _dio;
  final StorageService _storage = StorageService.instance;

  PosProvider({dio.Dio? dioClient}) : _dio = dioClient ?? dio.Dio() {
    _dio.options.baseUrl = Config.baseUrl;
    _dio.options.connectTimeout =
        const Duration(milliseconds: Config.connectTimeout);
    _dio.options.receiveTimeout =
        const Duration(milliseconds: Config.receiveTimeout);
    _dio.options.validateStatus = (status) => status != null && status < 500;

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';
          debugPrint('POS Request: ${options.method} ${options.path}');
          debugPrint('POS Request Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('POS Response [${response.statusCode}]: ${response.data}');
          if (response.statusCode == 401) {
            _storage.clearAuth();
            Get.offAllNamed('/login');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('POS Error: ${error.message}');
          debugPrint('POS Error Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Get products optimized for POS grid
  Future<dio.Response> getProducts({String? categoryId, String? search}) async {
    return await _dio.get('/merchant/pos/products', queryParameters: {
      if (categoryId != null) 'category_id': categoryId,
      if (search != null) 'search': search,
    });
  }

  /// Create a new POS transaction
  Future<dio.Response> createTransaction(Map<String, dynamic> data) async {
    return await _dio.post('/merchant/pos/transactions', data: data);
  }

  /// Get POS transactions list
  Future<dio.Response> getTransactions({
    int page = 1,
    String? orderType,
    String? status,
    String? from,
    String? to,
    String? search,
    int perPage = 20,
  }) async {
    return await _dio.get('/merchant/pos/transactions', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (orderType != null) 'order_type': orderType,
      if (status != null) 'status': status,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (search != null) 'search': search,
    });
  }

  /// Get single transaction detail
  Future<dio.Response> getTransaction(int id) async {
    return await _dio.get('/merchant/pos/transactions/$id');
  }

  /// Void a POS transaction
  Future<dio.Response> voidTransaction(int id) async {
    return await _dio.post('/merchant/pos/transactions/$id/void');
  }

  /// Get daily summary
  Future<dio.Response> getDailySummary({String? date}) async {
    return await _dio.get('/merchant/pos/daily-summary', queryParameters: {
      if (date != null) 'date': date,
    });
  }
}
