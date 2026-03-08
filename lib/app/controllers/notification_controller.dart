import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/notification_model.dart';
import 'package:antarkanma_merchant/app/data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  void onClose() {
    super.onClose();
  }

  /// Fetch all notifications
  Future<void> fetchNotifications({bool? unreadOnly}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final notificationList =
          await _repository.getNotifications(unreadOnly: unreadOnly);

      if (notificationList != null) {
        notifications.assignAll(notificationList);
      } else {
        notifications.clear();
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat notifikasi: ${e.toString()}';
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch unread notification count
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      if (count != null) {
        unreadCount.value = count;
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);
      if (success) {
        // Update local state
        final notificationIndex =
            notifications.indexWhere((n) => n.id == notificationId);
        if (notificationIndex != -1) {
          final notification = notifications[notificationIndex];
          notifications[notificationIndex] = NotificationModel(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            imageUrl: notification.imageUrl,
          );
        }
        // Refresh unread count
        fetchUnreadCount();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();
      if (success) {
        // Update all notifications to read
        for (int i = 0; i < notifications.length; i++) {
          final notification = notifications[i];
          notifications[i] = NotificationModel(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            imageUrl: notification.imageUrl,
          );
        }
        // Reset unread count
        unreadCount.value = 0;
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final success = await _repository.deleteNotification(notificationId);
      if (success) {
        // Remove from local state
        notifications.removeWhere((n) => n.id == notificationId);
        // Refresh unread count
        fetchUnreadCount();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await fetchNotifications();
    await fetchUnreadCount();
  }

  /// Navigate to notification detail or action
  void navigateToNotification(NotificationModel notification) async {
    // Mark as read when tapped
    markAsRead(notification.id);

    // Handle different notification types
    switch (notification.type) {
      case 'new_order':
      case 'order_ready':
        // Navigate to orders page
        Get.back();
        // You can add navigation logic here
        break;
      case 'transaction_approved':
        // Navigate to order details
        Get.back();
        break;
      case 'chat_message':
        // Navigate to chat
        if (notification.data?['chatId'] != null) {
          Get.back();
          Get.toNamed('/chat/${notification.data!['chatId']}');
        }
        break;
      default:
        // Show notification details
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationModel notification) {
    Get.dialog(
      AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            if (notification.data != null) ...[
              const SizedBox(height: 16),
              Text(
                'Data: ${notification.data.toString()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Get notification icon based on type
  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'new_order':
        return Icons.shopping_cart;
      case 'order_ready':
        return Icons.check_circle;
      case 'transaction_approved':
        return Icons.payment;
      case 'chat_message':
        return Icons.chat;
      case 'system':
        return Icons.notifications;
      default:
        return Icons.notifications_none;
    }
  }

  /// Get notification color based on type
  int getNotificationColor(String type) {
    switch (type) {
      case 'new_order':
        return 0xFF00C896; // Green
      case 'order_ready':
        return 0xFF1187E8; // Blue
      case 'transaction_approved':
        return 0xFFFFAA33; // Orange
      case 'chat_message':
        return 0xFF9B9B9B; // Grey
      case 'system':
        return 0xFF6E6E6E; // Dark grey
      default:
        return 0xFF6E6E6E;
    }
  }
}
