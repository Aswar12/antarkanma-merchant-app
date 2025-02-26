import 'package:antarkanma_merchant/config.dart';
import 'package:dio/dio.dart';

class AuthProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  // Expose dio instance through a getter
  Dio get dio => _dio;

  AuthProvider() {
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

  Future<Response> deleteAccount(String token) async {
    try {
      return await _dio.delete(
        '/auth/delete-account',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  Future<Response> refreshToken(String token) async {
    try {
      return await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to refresh token: $e');
    }
  }

  Future<Response> updateProfilePhoto(String token, FormData formData) async {
    try {
      return await _dio.post(
        '/user/profile/photo',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception('File size too large. Maximum size is 2MB.');
      } else if (e.response?.statusCode == 415) {
        throw Exception('Invalid file type. Please upload an image file.');
      }
      print('Error response: ${e.response?.data}');
      throw Exception('Failed to update profile photo: ${e.message}');
    } catch (e) {
      print('Error updating photo: $e');
      throw Exception('Failed to update profile photo: $e');
    }
  }

  Future<Response> updateProfile(
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          if (errors['email'] != null) {
            throw Exception('Email already exists');
          }
          if (errors['phone_number'] != null) {
            throw Exception('Phone number already exists');
          }
        }
      }
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Response> getProfile(String token) async {
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
      throw Exception('Failed to get profile: $e');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Don't set Content-Type here as it will be set per-request
          options.headers['Accept'] = 'application/json';
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

  /// Login dengan email atau nomor WA
  Future<Response> login(String identifier, String password) async {
    try {
      final Map<String, dynamic> loginData = {
        'identifier': identifier,
        'password': password,
      };

      return await _dio.post(Config.login, data: loginData);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Register
  Future<Response> register(Map<String, dynamic> userData) async {
    try {
      return await _dio.post(Config.register, data: userData);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Change Password
  Future<Response> changePassword(
      String token, Map<String, dynamic> data) async {
    try {
      return await _dio.put(
        '/auth/change-password',
        options: _getAuthOptions(token),
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<Response> logout(String token) async {
    try {
      return await _dio.post('/auth/logout', options: _getAuthOptions(token));
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Get Current User
  Future<Response> getCurrentUser(String token) async {
    try {
      return await _dio.get('/auth/user', options: _getAuthOptions(token));
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Register FCM Token
  Future<Response> registerFCMToken(
      String token, Map<String, dynamic> data) async {
    try {
      return await _dio.post(
        Config.fcmToken,
        options: _getAuthOptions(token),
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to register FCM token: $e');
    }
  }

  /// Unregister FCM Token
  Future<Response> unregisterFCMToken(
      String token, Map<String, dynamic> data) async {
    try {
      return await _dio.delete(
        Config.fcmToken,
        options: _getAuthOptions(token),
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to unregister FCM token: $e');
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

  /// Helper method untuk auth header
  Options _getAuthOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}
