import 'package:dio/dio.dart' as dio;
import '../../../config.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'package:get/get.dart';

class TransactionProvider {
  final dio.Dio _dio;
  final StorageService _storage = StorageService.instance;

  TransactionProvider({dio.Dio? dioClient}) : _dio = dioClient ?? dio.Dio() {
    // Configure Dio defaults
    _dio.options.baseUrl = Config.baseUrl;
    _dio.options.connectTimeout =
        const Duration(milliseconds: Config.connectTimeout);
    _dio.options.receiveTimeout =
        const Duration(milliseconds: Config.receiveTimeout);
    _dio.options.validateStatus = (status) {
      return status != null && status < 500;
    };

    // Add auth interceptor
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';

          print('Making request to: ${options.uri}');
          print('Headers: ${options.headers}');
          print('Query Parameters: ${options.queryParameters}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response status: ${response.statusCode}');
          print('Response data: ${response.data}');

          if (response.statusCode == 401) {
            // Handle unauthorized
            print('Unauthorized request');
            _storage.clearAuth();
            Get.offAllNamed('/login');
            return handler.reject(
              dio.DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: dio.DioExceptionType.unknown,
                error: 'Unauthorized',
              ),
            );
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          print('API Error: ${error.message}');
          print('Error response: ${error.response?.data}');
          print('Error type: ${error.type}');
          print('Error stacktrace: ${error.stackTrace}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<dio.Response> getMerchantOrders({
    required int page,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    try {
      final merchantId =
          Get.find<AuthService>().currentUser.value?.merchant?.id;
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      final queryParams = {
        'page': page.toString(),
        if (status != null) 'status': status,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      print(
          'Requesting orders for merchant $merchantId with params: $queryParams');
      final response = await _dio.get(
        '/merchants/$merchantId/orders',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        if (response.data is! Map) {
          throw dio.DioException(
            requestOptions: response.requestOptions,
            error: 'Invalid response format',
            type: dio.DioExceptionType.unknown,
          );
        }
      }

      return response;
    } on dio.DioException catch (e) {
      print('DioException in getMerchantOrders:');
      print('  Message: ${e.message}');
      print('  Error: ${e.error}');
      print('  Response: ${e.response?.data}');
      print('  Stack trace: ${e.stackTrace}');
      rethrow;
    } catch (e, stackTrace) {
      print('Error in getMerchantOrders: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<dio.Response> getPendingTransactions() async {
    try {
      final merchantId =
          Get.find<AuthService>().currentUser.value?.merchant?.id;
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      return await _dio.get(
        '/merchants/$merchantId/orders',
        queryParameters: {
          'status': 'WAITING_APPROVAL',
          'sort_by': 'created_at',
          'sort_order': 'desc',
        },
      );
    } catch (e, stackTrace) {
      print('Error in getPendingTransactions: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<dio.Response> approveOrder(
    dynamic orderId,
  ) async {
    try {
      final merchantId =
          Get.find<AuthService>().currentUser.value?.merchant?.id;
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      return await _dio.put(
        '/merchants/orders/$orderId/approve',
        data: {
          'merchant_id': merchantId,
        },
      );
    } catch (e, stackTrace) {
      print('Error in approveOrder: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<dio.Response> rejectOrder(
    dynamic orderId, {
    String? reason,
  }) async {
    try {
      final merchantId =
          Get.find<AuthService>().currentUser.value?.merchant?.id;
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      return await _dio.put(
        '/merchants/orders/$orderId/reject',
        data: {
          'merchant_id': merchantId,
          'reason': reason,
        },
      );
    } catch (e, stackTrace) {
      print('Error in rejectOrder: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<dio.Response> markOrderReady(
    dynamic orderId,
  ) async {
    try {
      final merchantId =
          Get.find<AuthService>().currentUser.value?.merchant?.id;
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      return await _dio.post(
        '/merchants/$merchantId/orders/$orderId/ready',
      );
    } catch (e, stackTrace) {
      print('Error in markOrderReady: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
