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
}
