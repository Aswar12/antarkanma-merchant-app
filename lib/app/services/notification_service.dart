import 'dart:convert';
import 'package:antarkanma_merchant/app/controllers/merchant_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/services/transaction_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:antarkanma_merchant/theme.dart';

import 'package:antarkanma_merchant/app/routes/app_pages.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  print('Background message data: ${message.data}');

  // Create notification service instance for background notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/notification_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Get order items if available
  List<dynamic>? items = [];
  if (message.data.containsKey('items')) {
    try {
      if (message.data['items'] is String) {
        items = json.decode(message.data['items'] as String) as List<dynamic>;
      } else {
        items = message.data['items'] as List<dynamic>;
      }
    } catch (e) {
      print('Error parsing items in background: $e');
    }
  }

  // Format items for display
  String itemsText = '';
  if (items != null && items.isNotEmpty) {
    itemsText = items
        .map((item) {
          if (item is Map) {
            return '${item['quantity']}x ${item['name']}';
          }
          return '';
        })
        .where((text) => text.isNotEmpty)
        .join(', ');
  }

  // Use notification title and body if available, otherwise use defaults
  String title = message.notification?.title ?? '📦 Pesanan Baru!';
  String body = message.notification?.body ??
      (itemsText.isNotEmpty
          ? 'Pesanan baru untuk: $itemsText'
          : 'Pesanan baru diterima');

  // Create notification channel for background notifications
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'antarkanma_order_channel',
    'Pesanan',
    description: 'Notifikasi untuk pesanan baru dan update status',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Show notification
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@drawable/notification_icon',
        largeIcon: const DrawableResourceAndroidBitmap('@drawable/logo'),
        styleInformation: BigTextStyleInformation(
          body,
          htmlFormatBigText: true,
          contentTitle: title,
          htmlFormatContentTitle: true,
          summaryText: 'Ada pesanan baru yang menunggu konfirmasi',
          htmlFormatSummaryText: true,
        ),
      ),
    ),
    payload: json.encode({
      'order_id': message.data['order_id'],
      'items': items,
    }),
  );
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final TransactionService _transactionService = Get.find<TransactionService>();

  final _notificationCount = RxInt(0);

  static const String _orderChannelKey = 'antarkanma_order_channel';
  static const String _paymentChannelKey = 'antarkanma_payment_channel';
  static const String _deliveryChannelKey = 'antarkanma_delivery_channel';

  int get notificationCount => _notificationCount.value;

  Future<NotificationService> init() async {
    // Request notification permissions
    await _requestPermissions();

    // Create notification channels
    await _createNotificationChannels();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        try {
          if (response.payload != null && response.payload!.isNotEmpty) {
            print('Notification payload: ${response.payload}');
            final data = json.decode(response.payload!) as Map<String, dynamic>;
            _handleNotificationData(data);
          }
        } catch (e) {
          print('Error parsing notification payload: $e');
        }
      },
    );

    // Set up message handlers
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Configure FCM to handle notifications when app is in background
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle token refresh
    _messaging.onTokenRefresh.listen((String token) {
      print('FCM Token refreshed: $token');
      // Here you might want to send the new token to your server
    });

    return this;
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: true,
    );
    print('FCM permission status: ${settings.authorizationStatus}');
  }

  Future<void> _createNotificationChannels() async {
    final plugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (plugin != null) {
      await plugin.createNotificationChannel(AndroidNotificationChannel(
        _orderChannelKey,
        'Pesanan',
        description: 'Notifikasi untuk pesanan baru dan update status',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: logoColorSecondary,
      ));

      await plugin.createNotificationChannel(AndroidNotificationChannel(
        _paymentChannelKey,
        'Pembayaran',
        description: 'Notifikasi untuk update pembayaran',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: logoColorSecondary,
      ));

      await plugin.createNotificationChannel(AndroidNotificationChannel(
        _deliveryChannelKey,
        'Pengiriman',
        description: 'Notifikasi untuk update pengiriman',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: logoColorSecondary,
      ));
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    print('Raw message data: ${message.data}');

    _notificationCount.value++;

    // Convert message data to Map and ensure it's not null
    Map<String, dynamic> notificationData =
        Map<String, dynamic>.from(message.data);

    // Get order items if available
    List<dynamic>? items = [];
    if (notificationData.containsKey('items')) {
      try {
        if (notificationData['items'] is String) {
          items =
              json.decode(notificationData['items'] as String) as List<dynamic>;
        } else {
          items = notificationData['items'] as List<dynamic>;
        }
      } catch (e) {
        print('Error parsing items: $e');
      }
    }

    // Format items for display
    String itemsText = '';
    if (items != null && items.isNotEmpty) {
      itemsText = items
          .map((item) {
            if (item is Map) {
              return '${item['quantity']}x ${item['name']}';
            }
            return '';
          })
          .where((text) => text.isNotEmpty)
          .join(', ');
    }

    // Use notification title and body if available, otherwise use defaults
    String title = message.notification?.title ?? '📦 Pesanan Baru!';
    String body = message.notification?.body ??
        (itemsText.isNotEmpty
            ? 'Pesanan baru untuk: $itemsText'
            : 'Pesanan baru diterima');

    print('Final notification content - Title: $title, Body: $body');

    final channelKey = _orderChannelKey;
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelKey,
      'Pesanan',
      channelDescription: 'Notifikasi untuk pesanan baru dan update status',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      enableVibration: true,
      playSound: true,
      icon: '@drawable/notification_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@drawable/logo'),
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: 'Ada pesanan baru yang menunggu konfirmasi',
        htmlFormatSummaryText: true,
      ),
      color: logoColorSecondary,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      // Create a safe payload with non-null values
      Map<String, dynamic> payloadData = {
        'order_id': notificationData['order_id'],
        'items': items,
      };

      await _localNotifications.show(
        _generateNotificationId(),
        title,
        body,
        platformChannelSpecifics,
        payload: json.encode(payloadData),
      );
      print('Successfully showed notification');
    } catch (e) {
      print('Error showing notification: $e');
      await _showFallbackNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    print('Message data when opened: ${message.data}');
    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
    }
  }

  Future<void> _handleNotificationData(Map<String, dynamic> data) async {
    print('Handling notification data: $data');
    String? orderId = data['order_id'];
    if (orderId != null) {
      try {
        // First navigate to merchant main page
        await Get.offAllNamed(Routes.merchantMainPage);

        // Add a small delay to ensure the main page is loaded
        await Future.delayed(const Duration(milliseconds: 300));

        // Set the merchant controller to orders tab
        try {
          final merchantController = Get.find<MerchantController>();
          merchantController.changePage(1); // Index 1 is for Orders tab
        } catch (e) {
          print('Error setting merchant controller tab: $e');
        }

        // Add another small delay to ensure the tab change is processed
        await Future.delayed(const Duration(milliseconds: 200));

        // Get the order controller and update the view
        try {
          final orderController = Get.find<MerchantOrderController>();
          orderController.filterOrders('PENDING');
          await orderController.refreshOrders();
        } catch (e) {
          print('Error updating order controller: $e');
        }
      } catch (e) {
        print('Error handling notification tap: $e');
        // Fallback navigation
        await Get.offAllNamed(Routes.merchantMainPage);
      }
    }
  }

  Future<void> _showFallbackNotification(RemoteMessage message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _orderChannelKey,
      'Pesanan',
      channelDescription: 'Notifikasi untuk pesanan baru dan update status',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/notification_icon',
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create a safe payload with non-null values
    Map<String, dynamic> safeData = {};
    if (message.data.containsKey('order_id')) {
      safeData['order_id'] = message.data['order_id'];
    }
    if (message.data.containsKey('items')) {
      safeData['items'] = message.data['items'];
    }

    await _localNotifications.show(
      _generateNotificationId(),
      '📦 Pesanan Baru!',
      'Pesanan baru diterima',
      platformChannelSpecifics,
      payload: json.encode(safeData),
    );
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
    _notificationCount.value = 0;
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    if (_notificationCount.value > 0) {
      _notificationCount.value--;
    }
  }
}
