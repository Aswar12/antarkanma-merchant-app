import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'transaction_service.dart';
import '../controllers/merchant_home_controller.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize GetStorage for background notifications
  await GetStorage.init();
  
  // Then handle the background message
  if (message.data['type'] == 'transaction_approved' && 
      message.data['status'] == 'WAITING_APPROVAL') {
    final storage = GetStorage();
    await storage.write('pending_notification', {
      'type': message.data['type'],
      'status': message.data['status'],
      'order_id': message.data['order_id'],
    });

    // Fetch orders
    print('Fetching orders for transaction approved notification...');
    final transactionService = Get.find<TransactionService>();
    final homeController = Get.find<MerchantHomeController>();
    await transactionService.getOrders(
      orderIds: [], // Add the required orderIds parameter here
      page: 1, // Adjust page as needed
    );
    homeController.loadData(); // Refresh the displayed orders
    print('Orders fetched and loadData called.');
  }
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final GetStorage _storage = GetStorage();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle notification permissions
    await _requestPermissions();

    // Set up Firebase Messaging handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request Android notification channel
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
        _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'antarkanma_merchant_channel',
          'Antarkanma Merchant',
          description: 'Notifications for Antarkanma Merchant app',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    // Request FCM permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      await showNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    // Store notification data if needed
    if (message.data['type'] == 'transaction_approved' && 
        message.data['status'] == 'WAITING_APPROVAL') {
      await _storage.write('pending_notification', {
        'type': message.data['type'],
        'status': message.data['status'],
        'order_id': message.data['order_id'],
      });

      // Fetch orders
      print('Fetching orders for transaction approved notification...');
      final transactionService = Get.find<TransactionService>();
      final homeController = Get.find<MerchantHomeController>();
      await transactionService.getOrders(
        orderIds: [], // Add the required orderIds parameter here
        page: 1, // Adjust page as needed
      );
      homeController.loadData(); // Refresh the displayed orders
      print('Orders fetched and loadData called.');
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');
    _handleNotificationNavigation(message.data);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (data['type'] == 'transaction_approved' && 
        data['status'] == 'WAITING_APPROVAL') {
      Get.toNamed(
        Routes.merchantMainPage,
        arguments: {'pending_notification': data},
      );
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'antarkanma_merchant_channel',
      'Antarkanma Merchant',
      channelDescription: 'Notifications for Antarkanma Merchant app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
