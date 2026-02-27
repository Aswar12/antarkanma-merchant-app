import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/app_binding.dart';
import 'firebase_options.dart';
import 'app/services/notification_service.dart';
import 'app/services/storage_service.dart';
import 'app/services/dimensions_service.dart';

Future<void> initServices() async {
  try {
    // Initialize core storage services first
    await GetStorage.init();
    final storage = GetStorage();
    final storageService = StorageService.instance;

    // Register core services
    Get.put(storage, permanent: true);
    Get.put(storageService, permanent: true);

    // Initialize Locale for formatting
    await initializeDateFormatting('id_ID', null);

    // Initialize and register DimensionsService
    final dimensionsService = DimensionsService();
    await dimensionsService.init();
    Get.put(dimensionsService, permanent: true);

    // Initialize plugins
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    Get.put(flutterLocalNotificationsPlugin, permanent: true);

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set the background message handler before anything else
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize NotificationService
    final notificationService = NotificationService();
    await notificationService.init();
    Get.put(notificationService, permanent: true);

    print('All services initialized...');
  } catch (e) {
    print('Error initializing services: $e');
    rethrow;
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initServices();
    runApp(const MyApp());
  } catch (e) {
    print('Error in main: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Antarkanma Merchant',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
