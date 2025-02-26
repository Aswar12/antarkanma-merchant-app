import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';

class TransactionProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  TransactionProvider() {
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
          print('Making request to: ${options.path}');
          print('Request data: ${options.data}');

          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response received: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print('Error occurred: ${error.message}');
          print('Error response: ${error.response?.data}');
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> getOrders(
    String token, {
    int? merchantId,
    String? status,
    int page = 1,
    int limit = 10,
    required List<int> orderIds, // Add the required orderIds parameter here
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null) queryParams['status'] = status;
      if (orderIds.isNotEmpty) queryParams['orderIds'] = orderIds.join(','); // Join order IDs for the API call

      final response = await _dio.get(
        'https://dev.antarkanmaa.my.id/api/merchant/$merchantId/orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Response> getPendingOrders(String token, int merchantId) async {
    try {
      final response = await _dio.get(
        '/merchants/$merchantId/orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'status': 'WAITING_APPROVAL',
        },
      );
      return response;
    } catch (e) {
      print('Error fetching pending orders: $e');
      throw Exception('Failed to load pending orders: $e');
    }
  }

  Future<Response> approveOrder(
      String token, int orderId, int merchantId) async {
    try {
      final response = await _dio.post(
        '/orders/$orderId/merchant-approval',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'merchant_id': merchantId,
          'is_approved': true,
        },
      );
      return response;
    } catch (e) {
      print('Error approving order: $e');
      throw Exception('Failed to approve order: $e');
    }
  }

  Future<Response> rejectOrder(
    String token,
    int orderId,
    int merchantId, {
    String? reason,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'merchant_id': merchantId,
        'is_approved': false,
      };
      if (reason != null) {
        data['reason'] = reason;
      }

      final response = await _dio.post(
        '/orders/$orderId/merchant-approval',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      return response;
    } catch (e) {
      print('Error rejecting order: $e');
      throw Exception('Failed to reject order: $e');
    }
  }

  Future<Response> markOrderReady(
      String token, int orderId, int merchantId) async {
    try {
      final response = await _dio.post(
        '/orders/$orderId/ready',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'merchant_id': merchantId,
        },
      );
      return response;
    } catch (e) {
      print('Error marking order as ready: $e');
      throw Exception('Failed to mark order as ready: $e');
    }
  }

  void _handleError(DioException error) {
    String message;
    print('Error status code: ${error.response?.statusCode}');
    print('Error response data: ${error.response?.data}');

    if (error.response?.data != null && error.response?.data['meta'] != null) {
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
          message = 'Resource not found.';
          break;
        case 422:
          if (error.response?.data != null &&
              error.response?.data['data'] != null) {
            final errors = error.response?.data['data'];
            if (errors is Map) {
              message = errors.values.first.first.toString();
            } else {
              message = 'Validation error occurred';
            }
          } else {
            message = 'Validation error occurred';
          }
          break;
        case 500:
          message = 'Failed to process request';
          break;
        default:
          message = error.response?.data?['message'] ?? 'An error occurred';
      }
    }
    throw Exception(message);
  }
}
