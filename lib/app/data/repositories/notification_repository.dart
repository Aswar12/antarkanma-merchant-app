import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/notification_model.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/config.dart';

class NotificationRepository {
  final AuthService _authService = Get.find<AuthService>();
  final String baseUrl = Config.baseUrl;

  /// Get all notifications for the authenticated merchant
  Future<List<NotificationModel>?> getNotifications({bool? unreadOnly}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('No auth token found');
        return null;
      }

      final uri = Uri.parse('$baseUrl/notifications${_buildQueryString(unreadOnly: unreadOnly)}');
      debugPrint('Fetching notifications from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Config.connectTimeout),
        onTimeout: () {
          debugPrint('Request timeout - server not responding');
          throw Exception('Connection timeout');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final notifications = (data['data'] as List)
              .map((item) => NotificationModel.fromJson(item))
              .toList();
          debugPrint('Successfully fetched ${notifications.length} notifications');
          return notifications;
        } else {
          debugPrint('Unexpected response format: $data');
          return null;
        }
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized - token may be invalid');
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('Endpoint not found - check API route');
        return null;
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return null;
      }
    } on SocketException catch (e) {
      debugPrint('Network error: ${e.message}');
      debugPrint('Check if server is running and device has internet');
      return null;
    } on HttpException catch (e) {
      debugPrint('HTTP error: ${e.message}');
      return null;
    } on FormatException catch (e) {
      debugPrint('JSON parse error: ${e.message}');
      debugPrint('Response may not be valid JSON');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: ${e.message}');
      debugPrint('Server took too long to respond');
      return null;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(milliseconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
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
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(milliseconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
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
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(milliseconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
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
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(milliseconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  String _buildQueryString({bool? unreadOnly}) {
    if (unreadOnly == true) {
      return '?unread=1';
    }
    return '';
  }
}
