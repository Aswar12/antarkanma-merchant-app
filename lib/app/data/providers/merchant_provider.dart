import 'package:dio/dio.dart' as dio;
import 'package:antarkanma_merchant/config.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MerchantProvider {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = Config.baseUrl;

  MerchantProvider() {
    _setupBaseOptions();
    _setupInterceptors();
  }

  void _setupBaseOptions() {
    _dio.options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (options.data is! dio.FormData) {
            options.headers.addAll({
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            });
          } else {
            options.headers['Accept'] = 'application/json';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle 401
          if (response.statusCode == 401) {
            _clearAuthAndRedirect();
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
        onError: (dio.DioException error, handler) {
          // Handle 401 on error too
          if (error.response?.statusCode == 401) {
            _clearAuthAndRedirect();
          }

          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  String? _getAuthToken() {
    try {
      final storage = GetStorage();
      return storage.read('token');
    } catch (e) {
      return null;
    }
  }

  void _clearAuthAndRedirect() {
    try {
      final storage = GetStorage();
      storage.remove('token');
      storage.remove('user');
      Future.delayed(Duration.zero, () {
        Get.offAllNamed('/login');
      });
    } catch (e) {
      // Ignore errors
    }
  }

  Future<dio.Response<dynamic>> getMerchantsByOwnerId(
      String token, int ownerId) async {
    try {
      final response = await _dio.get(
        '/merchants/owner/$ownerId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load merchants: $e');
    }
  }

  Future<dio.Response<dynamic>> getMerchantProducts(
    String token,
    int merchantId, {
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'page_size': pageSize,
      };

      if (queryParams != null) {
        params.addAll(queryParams);
      }

      final response = await _dio.get(
        '/merchants/$merchantId/products',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: params,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load merchant products: $e');
    }
  }

  Future<dio.Response<dynamic>> getMerchantOrders(
    String token,
    int merchantId, {
    int page = 1,
    int limit = 10,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final response = await _dio.get(
        '/merchants/$merchantId/orders',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load merchant orders: $e');
    }
  }

  Future<dio.Response<dynamic>> getPendingTransactions(
      String token, int merchantId) async {
    try {
      final response = await _dio.get(
        '/merchants/$merchantId/transactions/pending',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load pending transactions: $e');
    }
  }

  Future<dio.Response<dynamic>> approveTransaction(
      String token, int merchantId, dynamic transactionId) async {
    try {
      final response = await _dio.put(
        '/merchants/$merchantId/transactions/$transactionId/approve',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to approve transaction: $e');
    }
  }

  Future<dio.Response<dynamic>> rejectTransaction(
      String token, int merchantId, dynamic transactionId) async {
    try {
      final response = await _dio.put(
        '/merchants/$merchantId/transactions/$transactionId/reject',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to reject transaction: $e');
    }
  }

  Future<dio.Response<dynamic>> updateOrderStatus(
    String token,
    int merchantId,
    int orderId,
    String status,
  ) async {
    try {
      final response = await _dio.put(
        '/merchants/$merchantId/orders/$orderId/status',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'status': status,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<dio.Response<dynamic>> updateMerchant(
      String token, int merchantId, Map<String, dynamic> data) async {
    try {
      // Convert operating days to lowercase if present
      if (data['operating_days'] != null) {
        data['operating_days'] = data['operating_days']
            .map((day) => day.toString().toLowerCase())
            .toList();
      }

      final response = await _dio.put(
        '/merchant/$merchantId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: data,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update merchant: $e');
    }
  }

  Future<dio.Response<dynamic>> createProduct(
      String token, int merchantId, Map<String, dynamic> data) async {
    try {
      data['merchant_id'] = merchantId;

      final response = await _dio.post(
        '/products',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<dio.Response<dynamic>> updateProduct(
      String token, int productId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/products/$productId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<dio.Response<dynamic>> uploadProductGallery(
      String token, int productId, List<String> imagePaths) async {
    try {
      final formData = dio.FormData();

      for (var i = 0; i < imagePaths.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery[]',
            await dio.MultipartFile.fromFile(
              imagePaths[i],
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/products/$productId/gallery',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to upload gallery: $e');
    }
  }

  Future<dio.Response<dynamic>> updateProductGallery(
      String token, int productId, int galleryId, String imagePath) async {
    try {
      final formData = dio.FormData();
      formData.files.add(
        MapEntry(
          'gallery',
          await dio.MultipartFile.fromFile(
            imagePath,
            filename: 'updated_image.jpg',
          ),
        ),
      );

      final response = await _dio.put(
        '/products/$productId/gallery/$galleryId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update gallery image: $e');
    }
  }

  Future<dio.Response<dynamic>> deleteProductGallery(
      String token, int productId, int galleryId) async {
    try {
      final response = await _dio.delete(
        '/products/$productId/gallery/$galleryId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to delete gallery image: $e');
    }
  }

  Future<dio.Response<dynamic>> deleteProduct(
      String token, int productId) async {
    try {
      final response = await _dio.delete(
        '/products/$productId',
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  void _handleError(dio.DioException error) {
    String message;

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
