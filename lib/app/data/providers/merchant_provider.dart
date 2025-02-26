import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';

class MerchantProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  MerchantProvider() {
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

          if (options.data is! FormData) {
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

  Future<Response> getMerchantsByOwnerId(String token, int ownerId) async {
    try {
      print('Fetching merchant data for owner ID: $ownerId');
      final response = await _dio.get(
        '/merchants/owner/$ownerId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('API Response: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching merchants: $e');
      throw Exception('Failed to load merchants: $e');
    }
  }

  Future<Response> getMerchantProducts(
    String token,
    int merchantId, {
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      print('Fetching products for merchant ID: $merchantId (page: $page, pageSize: $pageSize)');
      
      final Map<String, dynamic> params = {
        'page': page,
        'page_size': pageSize,
      };

      if (queryParams != null) {
        params.addAll(queryParams);
      }

      final response = await _dio.get(
        '/merchants/$merchantId/products',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: params,
      );
      print('Products API Response: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching merchant products: $e');
      throw Exception('Failed to load merchant products: $e');
    }
  }

  Future<Response> getMerchantOrders(
    String token,
    int merchantId, {
    int page = 1,
    int limit = 10,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      print('Fetching orders for merchant ID: $merchantId');
      
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
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: queryParams,
      );
      print('Orders API Response: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching merchant orders: $e');
      throw Exception('Failed to load merchant orders: $e');
    }
  }

  Future<Response> getPendingTransactions(String token, int merchantId) async {
    try {
      print('Fetching pending transactions for merchant ID: $merchantId');
      final response = await _dio.get(
        '/merchants/$merchantId/transactions/pending',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Pending transactions API Response: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching pending transactions: $e');
      throw Exception('Failed to load pending transactions: $e');
    }
  }

  Future<Response> approveTransaction(String token, int merchantId, dynamic transactionId) async {
    try {
      print('Approving transaction $transactionId for merchant ID: $merchantId');
      final response = await _dio.put(
        '/merchants/$merchantId/transactions/$transactionId/approve',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Approve transaction response: ${response.data}');
      return response;
    } catch (e) {
      print('Error approving transaction: $e');
      throw Exception('Failed to approve transaction: $e');
    }
  }

  Future<Response> rejectTransaction(String token, int merchantId, dynamic transactionId) async {
    try {
      print('Rejecting transaction $transactionId for merchant ID: $merchantId');
      final response = await _dio.put(
        '/merchants/$merchantId/transactions/$transactionId/reject',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Reject transaction response: ${response.data}');
      return response;
    } catch (e) {
      print('Error rejecting transaction: $e');
      throw Exception('Failed to reject transaction: $e');
    }
  }

  Future<Response> updateOrderStatus(
    String token,
    int merchantId,
    int orderId,
    String status,
  ) async {
    try {
      print('Updating order status: Merchant ID: $merchantId, Order ID: $orderId, New Status: $status');
      final response = await _dio.put(
        '/merchants/$merchantId/orders/$orderId/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: {
          'status': status,
        },
      );
      print('Update order status response: ${response.data}');
      return response;
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<Response> updateMerchant(
      String token, int merchantId, Map<String, dynamic> data) async {
    try {
      print('Updating merchant $merchantId with data: $data');
      final response = await _dio.put(
        '/merchant/$merchantId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      print('Update response: ${response.data}');
      return response;
    } catch (e) {
      print('Error updating merchant: $e');
      throw Exception('Failed to update merchant: $e');
    }
  }

  Future<Response> createProduct(
      String token, int merchantId, Map<String, dynamic> data) async {
    try {
      print('Creating product for merchant ID: $merchantId');
      data['merchant_id'] = merchantId;

      final response = await _dio.post(
        '/products',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      print('Product creation response: ${response.data}');
      return response;
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  Future<Response> updateProduct(
      String token, int productId, Map<String, dynamic> data) async {
    try {
      print('Updating product ID: $productId with data: $data');
      final response = await _dio.put(
        '/products/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
      print('Product update response: ${response.data}');
      return response;
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  Future<Response> uploadProductGallery(
      String token, int productId, List<String> imagePaths) async {
    try {
      print('Uploading gallery for product ID: $productId');

      final formData = FormData();

      for (var i = 0; i < imagePaths.length; i++) {
        formData.files.add(
          MapEntry(
            'gallery[]',
            await MultipartFile.fromFile(
              imagePaths[i],
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }

      print('Uploading files with FormData: ${formData.files}');

      final response = await _dio.post(
        '/products/$productId/gallery',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );
      print('Gallery upload response: ${response.data}');
      return response;
    } catch (e) {
      print('Error uploading gallery: $e');
      throw Exception('Failed to upload gallery: $e');
    }
  }

  Future<Response> updateProductGallery(
      String token, int productId, int galleryId, String imagePath) async {
    try {
      print('Updating gallery image $galleryId for product ID: $productId');

      final formData = FormData();
      formData.files.add(
        MapEntry(
          'gallery',
          await MultipartFile.fromFile(
            imagePath,
            filename: 'updated_image.jpg',
          ),
        ),
      );

      final response = await _dio.put(
        '/products/$productId/gallery/$galleryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );
      print('Gallery update response: ${response.data}');
      return response;
    } catch (e) {
      print('Error updating gallery image: $e');
      throw Exception('Failed to update gallery image: $e');
    }
  }

  Future<Response> deleteProductGallery(
      String token, int productId, int galleryId) async {
    try {
      print('Deleting gallery image $galleryId from product ID: $productId');
      final response = await _dio.delete(
        '/products/$productId/gallery/$galleryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Gallery delete response: ${response.data}');
      return response;
    } catch (e) {
      print('Error deleting gallery image: $e');
      throw Exception('Failed to delete gallery image: $e');
    }
  }

  Future<Response> deleteProduct(String token, int productId) async {
    try {
      print('Deleting product ID: $productId');
      final response = await _dio.delete(
        '/products/$productId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print('Delete product response: ${response.data}');
      return response;
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
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
          if (error.response?.data != null && error.response?.data['data'] != null) {
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
