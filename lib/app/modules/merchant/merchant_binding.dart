import 'package:antarkanma_merchant/app/controllers/merchant_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_product_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_product_form_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';

import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/controllers/user_location_controller.dart';
import 'package:antarkanma_merchant/app/services/user_location_service.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/services/category_service.dart';

import 'package:antarkanma_merchant/app/modules/merchant/services/merchant_order_service.dart';
import 'package:antarkanma_merchant/app/data/providers/notification_provider.dart';
import 'package:antarkanma_merchant/app/controllers/category_controller.dart';

class MerchantBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // Core services initialization
      final authService = Get.put(AuthService(), permanent: true);
      final storageService = StorageService.instance;
      final merchantService = Get.put(MerchantService(), permanent: true);
      final merchantOrderService = Get.put(MerchantOrderService(), permanent: true);
      
      // Initialize CategoryService and ensure it loads categories
      final categoryService = Get.put(CategoryService(), permanent: true);
      categoryService.init(); // This will load categories immediately
      
      // Initialize CategoryController
      Get.put(CategoryController(), permanent: true);
      
      // Initialize location service
      final locationService = Get.put(UserLocationService());
      Get.put(UserLocationController(locationService: locationService));

      // Initialize notification provider
      Get.put(NotificationProvider(), permanent: true);
      
      // Initialize merchant controllers as permanent to maintain state
      Get.put<MerchantController>(
        MerchantController(
          authService: authService,
          merchantService: merchantService
        ),
        permanent: true
      );
      
      Get.put<MerchantProfileController>(
        MerchantProfileController(
          authService: authService,
          merchantService: merchantService
        ),
        permanent: true
      );
      
      Get.put<MerchantProductController>(
        MerchantProductController(
          merchantService: merchantService
        ),
        permanent: true
      );
      
      Get.put<MerchantOrderController>(
        MerchantOrderController(
          authService: authService,
          merchantService: merchantService,
          storageService: storageService
        ),
        permanent: true
      );
      
      // Initialize product form controller with fenix to recreate when needed
      Get.lazyPut<MerchantProductFormController>(
        () => MerchantProductFormController(
          merchantService: merchantService
        ),
        fenix: true
      );

    } catch (e) {
      print('Error in MerchantBinding dependencies(): $e');
      rethrow; // Re-throw to let the error be handled by the global error handler
    }
  }
}
