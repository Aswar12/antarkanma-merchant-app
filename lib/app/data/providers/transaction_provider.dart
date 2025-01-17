import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:antarkanma_merchant/config.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart';

class TransactionProvider {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = Config.baseUrl;
  final StorageService _storageService = StorageService.instance;

  TransactionProvider() {
    _setupBaseOptions();
    _setupInterceptors();
  }

  void _setupBaseOptions() {
    _dio.options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => true,
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storageService.getToken();

          if (token != null) {
            options.headers.addAll({
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            });
          }

          debugPrint('\n=== API Request ===');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          debugPrint('Method: ${options.method}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Data: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          debugPrint('\n=== API Response ===');
          debugPrint('Status code: ${response.statusCode}');
          debugPrint('Data: ${response.data}');

          return handler.next(response);
        },
        onError: (dio.DioException error, handler) async {
          debugPrint('\n=== API Error Interceptor ===');
          debugPrint('Status code: ${error.response?.statusCode}');
          debugPrint('Error data: ${error.response?.data}');
          debugPrint('Error message: ${error.message}');
          debugPrint('Error type: ${error.type}');
          debugPrint('Error stacktrace: ${error.stackTrace}');

          if (error.response?.statusCode == 401) {
            try {
              final authService = Get.find<AuthService>();
              authService.handleAuthError(error);
            } catch (e) {
              debugPrint('Failed to handle auth error in interceptor: $e');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  void _handleError(dio.DioException error) {
    String message;
    switch (error.response?.statusCode) {
      case 401:
        message = 'Sesi anda telah berakhir. Silakan login kembali.';
        try {
          final authService = Get.find<AuthService>();
          authService.handleAuthError(error);
        } catch (e) {
          debugPrint('Failed to handle auth error: $e');
        }
        break;
      case 422:
        final data = error.response?.data;
        if (data != null &&
            data['meta'] != null &&
            data['meta']['message'] != null) {
          message = data['meta']['message'];
        } else if (data != null && data['data'] != null) {
          final errors = data['data'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => e.toString()));
            } else {
              errorMessages.add(value.toString());
            }
          });
          message = errorMessages.join('\n');
        } else {
          message = 'Validasi gagal';
        }
        break;
      case 403:
        message = 'Anda tidak memiliki akses ke halaman ini.';
        break;
      case 404:
        message = 'Data tidak ditemukan.';
        break;
      case 405:
        message = error.response?.data?['message'] ?? 'Method not allowed';
        break;
      case 500:
        final data = error.response?.data;
        if (data != null && data['message'] != null) {
          message = data['message'];
        } else {
          message =
              'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        }
        break;
      default:
        if (error.type == dio.DioExceptionType.connectionTimeout) {
          message = 'Koneksi timeout. Silakan periksa koneksi internet Anda.';
        } else if (error.type == dio.DioExceptionType.receiveTimeout) {
          message = 'Server tidak merespons. Silakan coba lagi.';
        } else {
          message = error.response?.data?['message'] ??
              error.message ??
              'Terjadi kesalahan yang tidak diketahui';
        }
    }

    CustomSnackbarX.showError(
      title: 'Error',
      message: message,
      position: SnackPosition.BOTTOM,
    );
    throw Exception(message);
  }

  Future<dio.Response> createTransaction(
      Map<String, dynamic> transactionData) async {
    try {
      debugPrint('\n=== Creating Transaction ===');
      debugPrint('Transaction Data: $transactionData');

      final response = await _dio.post(
        '/transactions',
        data: transactionData,
      );

      debugPrint('\n=== Transaction Response ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 500) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      if (response.statusCode == 422) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getTransactions({
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'include': 'items.product,items.merchant,user_location',
      };

      if (status != null && status.isNotEmpty) {
        final statuses = status.split(',');
        if (statuses.length > 1) {
          queryParameters['status[]'] = statuses;
        } else {
          queryParameters['status'] = status;
        }
      }

      debugPrint('\n=== Transaction Provider Debug ===');
      debugPrint('Making GET request to: ${baseUrl}/transactions');
      debugPrint('Query parameters: $queryParameters');
      debugPrint('Headers: ${_dio.options.headers}');

      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParameters,
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getTransactionById(String transactionId) async {
    try {
      return await _dio.get(
        '/transactions/$transactionId',
        queryParameters: {
          'include': 'items.product,items.merchant,user_location',
        },
      );
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> cancelTransaction(String transactionId) async {
    try {
      debugPrint('\n=== Canceling Transaction ===');
      debugPrint('Transaction ID: $transactionId');

      final response = await _dio.put(
        '/transactions/$transactionId/cancel',
        data: {'reason': 'Dibatalkan oleh pengguna'},
      );

      if (response.statusCode == 200) {
        debugPrint('Successfully canceled transaction');
        return response;
      }

      if (response.statusCode == 422) {
        final message = response.data?['meta']?['message'] ??
            'Transaksi tidak dapat dibatalkan';
        throw dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
          error: message,
        );
      }

      throw dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: dio.DioExceptionType.badResponse,
        error: 'Failed to cancel transaction',
      );
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getTransactionsByMerchant(
    String merchantId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (status != null) 'order_status': status,
      };

      debugPrint('\n=== Getting Merchant Orders ===');
      debugPrint('Query parameters: $queryParams');

      final response = await _dio.get(
        '/merchants/$merchantId/orders',
        queryParameters: queryParams,
      );

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getTransactionSummaryByMerchant(
      String merchantId) async {
    try {
      final response = await _dio.get('/merchants/$merchantId/orders/summary');

      // Add READYTOPICKUP to statistics if not present
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        if (data['statistics'] != null) {
          data['statistics']['readytopickup_orders'] =
              data['statistics']['readytopickup_orders'] ?? 0;
        }
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> updateOrderStatus(String orderId, String action,
      {String? notes}) async {
    try {
      debugPrint('\n=== Updating Order Status ===');
      debugPrint('Order ID: $orderId');
      debugPrint('Action: $action');
      if (notes != null) debugPrint('Notes: $notes');

      final response = await _dio.post(
        '/orders/$orderId/$action',
        data: notes != null ? {'notes': notes} : null,
      );

      debugPrint('\n=== Update Order Status Response ===');
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      // Check for error status codes
      if (response.statusCode == 500) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      if (response.statusCode == 422) {
        final message = response.data?['meta']?['message'] ?? 'Validasi gagal';
        throw dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
          error: message,
        );
      }

      if (response.statusCode != 200) {
        throw dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
          error: 'Failed to update order status',
        );
      }

      // Verify response data structure
      if (response.data == null ||
          response.data['meta']?['status'] != 'success') {
        throw dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
          error: 'Invalid response format',
        );
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}
