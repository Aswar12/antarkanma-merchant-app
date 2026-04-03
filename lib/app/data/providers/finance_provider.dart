import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import '../../../config.dart';
import '../../services/storage_service.dart';

class FinanceProvider {
  late final dio.Dio _dio;

  FinanceProvider() {
    _dio = dio.Dio();
    _dio.options.baseUrl = Config.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.validateStatus = (status) => status != null && status < 500;

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.instance.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (e, handler) {
        debugPrint('Finance API Error: ${e.message}');
        handler.next(e);
      },
    ));
  }

  /// GET /merchant/finance/overview?from=&to=
  Future<dio.Response> getOverview({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    return _dio.get('/merchant/finance/overview', queryParameters: params);
  }

  /// GET /merchant/finance/income?period=daily&from=&to=
  Future<dio.Response> getIncomeBreakdown({
    String period = 'daily',
    String? from,
    String? to,
  }) async {
    final params = <String, dynamic>{'period': period};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    return _dio.get('/merchant/finance/income', queryParameters: params);
  }

  /// GET /merchant/finance/expenses?category=&from=&to=
  Future<dio.Response> getExpenses({
    String? category,
    String? from,
    String? to,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (category != null) params['category'] = category;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    return _dio.get('/merchant/finance/expenses', queryParameters: params);
  }

  /// GET /merchant/finance/payment-methods?from=&to=
  Future<dio.Response> getPaymentMethods({String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    return _dio.get('/merchant/finance/payment-methods', queryParameters: params);
  }

  /// GET /merchant/finance/wallet-balance
  Future<dio.Response> getWalletBalance() async {
    return _dio.get('/merchant/finance/wallet-balance');
  }

  /// POST /merchant/finance/expenses
  Future<dio.Response> createExpense(Map<String, dynamic> data) async {
    return _dio.post('/merchant/finance/expenses', data: data);
  }

  /// PUT /merchant/finance/expenses/{id}
  Future<dio.Response> updateExpense(int id, Map<String, dynamic> data) async {
    return _dio.put('/merchant/finance/expenses/$id', data: data);
  }

  /// DELETE /merchant/finance/expenses/{id}
  Future<dio.Response> deleteExpense(int id) async {
    return _dio.delete('/merchant/finance/expenses/$id');
  }
}
