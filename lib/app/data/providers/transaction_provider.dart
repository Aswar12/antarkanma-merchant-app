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
          
          // Handle timeout errors with user-friendly messages
          String userMessage = 'Terjadi kesalahan. Silakan coba lagi.';
          if (error is dio.DioException) {
            switch (error.type) {
              case dio.DioExceptionType.connectionTimeout:
                userMessage = 'Koneksi timeout. Periksa internet Anda.';
                break;
              case dio.DioExceptionType.sendTimeout:
                userMessage = 'Request timeout. Silakan coba lagi.';
                break;
              case dio.DioExceptionType.receiveTimeout:
                userMessage = 'Respon server terlalu lama. Silakan coba lagi.';
                break;
              case dio.DioExceptionType.connectionError:
                userMessage = 'Tidak dapat terhubung ke server. Periksa jaringan.';
                break;
              case dio.DioExceptionType.badResponse:
                if (error.response?.statusCode == 401) {
                  userMessage = 'Sesi expired. Silakan login ulang.';
                } else if (error.response?.statusCode == 503) {
                  userMessage = 'Server sedang maintenance.';
                }
                break;
              default:
                break;
            }
            print('User-friendly error message: $userMessage');
          }
          
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
      final authService = Get.find<AuthService>();
      final merchantId = authService.currentUser.value?.merchant?.id;
      
      if (merchantId == null) {
        // Log more details for debugging
        print('Merchant ID not found!');
        print('Current user: ${authService.currentUser.value}');
        print('Merchant data: ${authService.currentUser.value?.merchant}');

        // Return an empty success response instead of throwing
        // This allows the app to continue loading without crashing
        return dio.Response(
          requestOptions:
              dio.RequestOptions(path: '/merchants/$merchantId/orders'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'orders': [],
              'status_counts': <String, int>{},
              'summary': {
                'total_orders': '0',
                'total_completed': '0',
                'total_processing': '0',
                'total_pending': '0',
                'total_canceled': '0',
              },
            },
            'message': 'Merchant data not loaded yet',
          },
        );
      }

      final queryParams = {
        'page': page.toString(),
        'order_status': status == 'ALL' ? null : status,  // Changed this line
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (sortOrder != null) 'sort_order': sortOrder,
      };

      // Remove null values from queryParams
      queryParams.removeWhere((key, value) => value == null);

      print('Requesting orders for merchant $merchantId with params: $queryParams');
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

  Future<dio.Response> getOrderSummary() async {
    try {
      final authService = Get.find<AuthService>();
      final merchantId = authService.currentUser.value?.merchant?.id;
      
      if (merchantId == null) {
        print('Merchant ID not found in getOrderSummary!');
        // Return empty summary instead of throwing
        return dio.Response(
          requestOptions:
              dio.RequestOptions(path: '/merchants/$merchantId/order-summary'),
          statusCode: 200,
          data: {
            'success': true,
            'data': {
              'status_counts': <String, int>{},
              'summary': {
                'total_orders': 0,
                'total_completed': 0,
                'total_processing': 0,
                'total_pending': 0,
                'total_canceled': 0,
              },
            },
          },
        );
      }

      return await _dio.get('/merchants/$merchantId/order-summary');
    } catch (e, stackTrace) {
      print('Error in getOrderSummary: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<dio.Response> getPendingTransactions() async {
    try {
      final authService = Get.find<AuthService>();
      final merchantId = authService.currentUser.value?.merchant?.id;
      
      if (merchantId == null) {
        print('Merchant ID not found in getPendingTransactions!');
        // Return empty list instead of throwing
        return dio.Response(
          requestOptions:
              dio.RequestOptions(path: '/merchants/$merchantId/orders'),
          statusCode: 200,
          data: {
            'success': true,
            'data': [],
          },
        );
      }

      return await _dio.get(
        '/merchants/$merchantId/orders',
        queryParameters: {
          'order_status': 'WAITING_APPROVAL',
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
      final authService = Get.find<AuthService>();
      final merchantId = authService.currentUser.value?.merchant?.id;
      
      if (merchantId == null) {
        throw Exception('Merchant ID not found. Please login again.');
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
      final authService = Get.find<AuthService>();
      final merchantId = authService.currentUser.value?.merchant?.id;
      
      if (merchantId == null) {
        throw Exception('Merchant ID not found. Please login again.');
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
      print('Marking order $orderId as ready for pickup');
      return await _dio.post(
        '/orders/$orderId/ready-for-pickup',
      );
    } catch (e, stackTrace) {
      print('Error in markOrderReady: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get single order by ID - optimized for notification handling
  /// Used when notification arrives to fetch only the new order
  Future<dio.Response> getOrderById(dynamic orderId) async {
    try {
      print('Fetching single order with ID: $orderId');
      return await _dio.get('/orders/$orderId');
    } catch (e, stackTrace) {
      print('Error in getOrderById: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Mark order as picked up by courier
  Future<dio.Response> markOrderPickedUp(dynamic orderId) async {
    try {
      print('Marking order $orderId as picked up by courier');
      return await _dio.post('/orders/$orderId/picked-up');
    } catch (e, stackTrace) {
      print('Error in markOrderPickedUp: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
