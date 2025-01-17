import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../controllers/auth_controller.dart';

import '../modules/splash/controllers/splash_controller.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/merchant_service.dart';
import '../services/notification_service.dart';
import '../services/fcm_token_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('Initializing dependencies...');

    // Services - Order matters due to dependencies
    debugPrint('Initializing AuthService...');
    Get.put(AuthService(), permanent: true);

    debugPrint('Initializing TransactionService...');
    Get.put(TransactionService(), permanent: true);

    debugPrint('Initializing FCMTokenService...');
    Get.putAsync(() => FCMTokenService().init(), permanent: true);

    debugPrint('Initializing NotificationService...');
    Get.putAsync(() => NotificationService().init(), permanent: true);

    debugPrint('Initializing CategoryService...');
    Get.put(CategoryService(), permanent: true);

    debugPrint('Initializing ProductService...');
    Get.put(ProductService(), permanent: true);

    debugPrint('Initializing MerchantService...');
    Get.put(MerchantService(), permanent: true);

    // Controllers
    debugPrint('Initializing SplashController...');
    Get.put(SplashController(), permanent: true);

    debugPrint('Initializing AuthController...');
    Get.put(AuthController(), permanent: true);



    // Note: HomePageController is now initialized by UserMainController
    // only after successful authentication as a regular user

    debugPrint('Dependencies initialization complete');
  }
}
