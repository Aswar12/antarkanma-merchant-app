import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';

class OrderItemProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  OrderItemProvider() {
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
          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    String message;
    switch (error.response?.statusCode) {
      case 401:
        message = 'Unauthorized access. Please log in again.';
        break;
      case 422:
        final errors = error.response?.data['errors'];
        message = errors.toString();
        break;
      default:
        message = error.response?.data['message'] ?? 'An error occurred';
    }
    throw Exception(message);
  }

  Future<Response> createOrderItem(Map<String, dynamic> orderItemData) async {
    try {
      return await _dio.post('/order_items', data: orderItemData);
    } catch (e) {
      throw Exception('Failed to create order item: $e');
    }
  }

  Future<Response> getOrderItems(String orderId) async {
    try {
      return await _dio.get('/order_items?order_id=$orderId');
    } catch (e) {
      throw Exception('Failed to get order items: $e');
    }
  }

  Future<Response> getOrderItemById(String orderItemId) async {
    try {
      return await _dio.get('/order_items/$orderItemId');
    } catch (e) {
      throw Exception('Failed to get order item: $e');
    }
  }
}
