import 'package:antarkanma_merchant/config.dart';
import 'package:dio/dio.dart';

class UserProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  UserProvider() {
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

  Future<Response> getUserProfile(String token) async {
    try {
      return await _dio.get(
        '/user/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<Response> updateUserProfile(
      String token, Map<String, dynamic> data) async {
    try {
      return await _dio.put(
        '/user/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Response> uploadProfileImage(String token, String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });

      return await _dio.post(
        '/user/profile/photo', // Adjust the endpoint as necessary
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: formData,
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void _handleError(DioException error) {
    String message;
    
    // Handle timeout and connection errors first
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Response timeout. Server is taking too long to respond.';
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to server. Please check your network.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.badResponse:
        // Handle HTTP status codes
        switch (error.response?.statusCode) {
          case 401:
            message = 'Unauthorized access. Please log in again.';
            break;
          case 403:
            message = 'Access denied. You do not have permission.';
            break;
          case 404:
            message = 'Resource not found.';
            break;
          case 422:
            final errors = error.response?.data['errors'];
            if (errors != null) {
              message = errors.toString();
            } else {
              message = error.response?.data['message'] ?? 'Validation failed';
            }
            break;
          case 500:
            message = 'Server error. Please try again later.';
            break;
          case 503:
            message = 'Server is under maintenance. Please try again later.';
            break;
          default:
            message = error.response?.data['message'] ?? 'An error occurred';
        }
        break;
      default:
        message = 'An unexpected error occurred: ${error.message}';
    }
    
    print('DioException: $message (Type: ${error.type})');
    throw Exception(message);
  }
}
