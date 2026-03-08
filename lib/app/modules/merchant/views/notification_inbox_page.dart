import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/controllers/notification_controller.dart';
import 'widgets/notification_list_tile.dart';
import 'widgets/empty_inbox_state.dart';

class NotificationInboxPage extends StatefulWidget {
  const NotificationInboxPage({Key? key}) : super(key: key);

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage>
    with WidgetsBindingObserver {
  final controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.fetchNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      debugPrint('App resumed, refreshing notifications');
      controller.fetchUnreadCount();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor3,
      appBar: AppBar(
        title: Text(
          'Kotak Masuk',
          style: primaryTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor2,
        elevation: 0,
        actions: [
          // Mark all as read button
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return IconButton(
                icon: Icon(
                  Icons.done_all,
                  color: logoColorSecondary,
                ),
                tooltip: 'Tandai semua sudah dibaca',
                onPressed: () => _markAllAsRead(),
              );
            }
            return const SizedBox.shrink();
          }),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: logoColorSecondary),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(logoColorSecondary),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const EmptyInboxState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return NotificationListTile(
                notification: notification,
                onTap: () => controller.navigateToNotification(notification),
                onLongPress: () => _showDeleteDialog(notification),
              );
            },
          ),
        );
      }),
    );
  }

  void _markAllAsRead() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tandai Semua Dibaca'),
        content: const Text(
            'Apakah Anda ingin menandai semua notifikasi sebagai sudah dibaca?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.markAllAsRead();
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(notification) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Notifikasi'),
        content:
            const Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteNotification(notification.id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
