import 'package:antarkanma_merchant/app/services/profile_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/auth_service.dart';
import '../services/merchant_service.dart';
import '../services/transaction_service.dart';
import '../services/storage_service.dart';
import '../services/product_service.dart';
import '../services/dimensions_service.dart';
import '../services/fcm_token_service.dart';
import '../services/user_location_service.dart';
import '../services/category_service.dart';
import '../data/providers/auth_provider.dart';
import '../data/providers/merchant_provider.dart';
import '../data/providers/transaction_provider.dart';
import '../data/providers/notification_provider.dart';
import '../controllers/merchant_home_controller.dart';
import '../controllers/merchant_order_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/merchant_controller.dart';
import '../controllers/merchant_profile_controller.dart';
import '../controllers/merchant_product_controller.dart';
import '../controllers/merchant_product_form_controller.dart';
import '../controllers/user_location_controller.dart';
import '../controllers/category_controller.dart';
import '../modules/merchant/services/merchant_order_service.dart';
import '../modules/splash/controllers/splash_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Core dependencies
      final storage = Get.find<GetStorage>();
      final storageService = Get.find<StorageService>();
      final flutterLocalNotificationsPlugin =
          Get.find<FlutterLocalNotificationsPlugin>();
      final dimensionsService = Get.find<DimensionsService>();

      // Register providers
      final authProvider = Get.put(AuthProvider(), permanent: true);
      final merchantProvider = Get.put(MerchantProvider(), permanent: true);
      final transactionProvider =
          Get.put(TransactionProvider(), permanent: true);
      final notificationProvider =
          Get.put(NotificationProvider(), permanent: true);

      // Register base services
      final authService =
          Get.put(AuthService(authProvider: authProvider), permanent: true);
      final productService = Get.put(ProductService(), permanent: true);
      final categoryService = Get.put(CategoryService(), permanent: true);
      final locationService = Get.put(UserLocationService(), permanent: true);
      final merchantOrderService =
          Get.put(MerchantOrderService(), permanent: true);

      // Register dependent services
      final merchantService = Get.put(
        MerchantService(
          merchantProvider: merchantProvider,
          authService: authService,
          productService: productService,
          storage: storage,
        ),
        permanent: true,
      );

      final fcmTokenService = Get.put(
        FCMTokenService(
          authProvider: authProvider,
          storageService: storageService,
        ),
        permanent: true,
      );

      final transactionService = Get.put(
        TransactionService(
          transactionProvider: transactionProvider,
          storage: storage,
        ),
        permanent: true,
      );

      // Initialize CategoryService
      categoryService.init();

      // Register controllers
      Get.put(
        AuthController(
          authService: authService,
          storageService: storageService,
        ),
        permanent: true,
      );

      Get.put(
        MerchantController(
          merchantService: merchantService,
          authService: authService,
        ),
        permanent: true,
      );

      final profileService = Get.put(ProfileService(), permanent: true);

      Get.put(
        MerchantProfileController(
          merchantService: merchantService,
          authService: authService,
          profileService: profileService,
        ),
        permanent: true,
      );

      Get.put(
        MerchantProductController(
          merchantService: merchantService,
        ),
        permanent: true,
      );

      Get.put(
        MerchantHomeController(
          transactionService: transactionService,
        ),
        permanent: true,
      );

      Get.put(
        MerchantOrderController(
          transactionService: transactionService,
        ),
        permanent: true,
      );

      Get.put(
        UserLocationController(
          locationService: locationService,
        ),
        permanent: true,
      );

      Get.put(CategoryController(), permanent: true);

      // Initialize product form controller
      Get.lazyPut<MerchantProductFormController>(
        () => MerchantProductFormController(
          merchantService: merchantService,
        ),
        fenix: true,
      );

      // Initialize SplashController last, after all dependencies are ready
      Get.put(
        SplashController(),
        permanent: true,
      );
    } catch (e) {
      print('Error in AppBinding dependencies(): $e');
      rethrow;
    }
  }
}
