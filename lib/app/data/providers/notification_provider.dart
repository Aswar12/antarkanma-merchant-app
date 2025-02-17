import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class NotificationProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;
  final _storage = GetStorage();

  NotificationProvider() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get the authentication token, not FCM token
        final authToken = _storage.read('token');
        if (authToken != null) {
          options.headers['Authorization'] = 'Bearer $authToken';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Response> registerFCMToken(String fcmToken, String userId,
      {String? role}) async {
    try {
      final response = await _dio.post(
        '/fcm/token/create', // Matches Laravel route exactly
        data: {
          'token': fcmToken, // Renamed to be more explicit
          'user_id': userId,
          'role': role,
          'device_type': defaultTargetPlatform.name.toLowerCase(),
          'platform': defaultTargetPlatform.name.toLowerCase(),
          'app_version': '1.0.0',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Failed to register FCM token. Status: ${response.statusCode}');
      }

      print('FCM Token registration successful: ${response.data}');
      return response;
    } catch (e) {
      print('Error registering FCM token: $e');
      throw Exception('Failed to register FCM token: $e');
    }
  }

  Future<Response> updateFCMToken(
      String oldFcmToken, String newFcmToken) async {
    try {
      final response = await _dio.post(
        '/fcm/token/update', // Matches Laravel route exactly
        data: {
          'old_fcm_token': oldFcmToken, // Renamed to be more explicit
          'new_fcm_token': newFcmToken, // Renamed to be more explicit
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update FCM token. Status: ${response.statusCode}');
      }

      print('FCM Token update successful: ${response.data}');
      return response;
    } catch (e) {
      print('Error updating FCM token: $e');
      throw Exception('Failed to update FCM token: $e');
    }
  }

  Future<Response> unregisterFCMToken(String fcmToken) async {
    try {
      final response = await _dio.delete(
        '/fcm/token', // Matches Laravel route exactly
        data: {
          'fcm_token': fcmToken, // Renamed to be more explicit
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to unregister FCM token. Status: ${response.statusCode}');
      }

      print('FCM Token unregistration successful: ${response.data}');
      return response;
    } catch (e) {
      print('Error unregistering FCM token: $e');
      throw Exception('Failed to unregister FCM token: $e');
    }
  }
}
