import 'package:dio/dio.dart' as dio;
import '../../../config.dart';
import '../../services/storage_service.dart';
import 'package:get/get.dart';

class AnalyticsProvider {
  final dio.Dio _dio;
  final StorageService _storage = StorageService.instance;

  AnalyticsProvider({dio.Dio? dioClient}) : _dio = dioClient ?? dio.Dio() {
    _dio.options.baseUrl = Config.baseUrl;
    _dio.options.connectTimeout =
        const Duration(milliseconds: Config.connectTimeout);
    _dio.options.receiveTimeout =
        const Duration(milliseconds: Config.receiveTimeout);

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            _storage.clearAuth();
            Get.offAllNamed('/login');
          }
          return handler.next(response);
        },
      ),
    );
  }

  /// Get merchant sales data
  Future<dio.Response> getSales({
    String period = 'daily',
    String? from,
    String? to,
  }) async {
    return await _dio.get('/merchant/analytics/sales', queryParameters: {
      'period': period,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
  }

  /// Get merchant top products
  Future<dio.Response> getTopProducts({int limit = 10}) async {
    return await _dio.get('/merchant/analytics/top-products', queryParameters: {
      'limit': limit,
    });
  }

  /// Get merchant peak hours
  Future<dio.Response> getPeakHours() async {
    return await _dio.get('/merchant/analytics/peak-hours');
  }

  /// Get merchant analytics overview
  Future<dio.Response> getOverview({String? from, String? to}) async {
    return await _dio.get('/merchant/analytics/overview', queryParameters: {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
  }
}
