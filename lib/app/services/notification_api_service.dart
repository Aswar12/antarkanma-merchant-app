import 'package:flutter/foundation.dart';
import 'package:antarkanma_merchant/app/data/models/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:get/get.dart' hide Response;

class NotificationApiService {
  late final Dio _dio;

  NotificationApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.baseUrl,
        connectTimeout: const Duration(milliseconds: Config.connectTimeout),
        receiveTimeout: const Duration(milliseconds: Config.receiveTimeout),
        responseType: ResponseType.json,
      ),
    );
  }

  Options _authOptions() {
    final storage = Get.find<StorageService>();
    final token = storage.getToken();
    return Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get all notifications for the authenticated merchant
  Future<List<NotificationModel>?> getNotifications({bool? unreadOnly}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (unreadOnly == true) queryParams['unread'] = '1';

      final response = await _dio.get(
        '/notifications',
        queryParameters: queryParams,
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return null;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _dio.put(
        '/notifications/$notificationId/read',
        data: {},
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.post(
        '/notifications/mark-all-read',
        data: {},
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _dio.delete(
        '/notifications/$notificationId',
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Get unread notification count
  Future<int?> getUnreadCount() async {
    try {
      final response = await _dio.get(
        '/notifications/unread-count',
        options: _authOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data']['count'] as int?;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return null;
    }
  }
}
