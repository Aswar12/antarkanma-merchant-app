import 'package:antarkanma_merchant/app/modules/auth/auth_binding.dart';
import 'package:antarkanma_merchant/app/modules/auth/views/sign_in_page.dart';
import 'package:antarkanma_merchant/app/modules/auth/views/sign_up_page.dart';

import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_main_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_order_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_profile_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_management_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_form_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/merchant_binding.dart';
import 'package:antarkanma_merchant/app/modules/splash/views/splash_page.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/middleware/auth_middleware.dart';

abstract class Routes {
  // Common routes
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  // Merchant routes
  static const merchantMainPage = '/merchantmain';
  static const merchantHome = '/merchant';
  static const merchantProfile = '/merchantmain/profile';
  static const merchantOrders = '/merchantmain/orders';
  static const merchantProducts = '/merchantmain/products';
  static const merchantAddProduct = '/merchantmain/add-product';
  static const merchantEditProduct = '/merchantmain/edit-product/:id';
  static const merchantEditInfo = '/merchantmain/edit-store-info';
}

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.login,
      page: () => SignInPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => SignUpPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.merchantMainPage,
      page: () => const MerchantMainPage(),
      binding: MerchantBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
      children: [
        GetPage(
          name: '/profile',
          page: () => MerchantProfilePage(),
          binding: MerchantBinding(),
        ),
        GetPage(
          name: '/orders',
          page: () => const MerchantOrderPage(),
          binding: MerchantBinding(),
        ),
        GetPage(
          name: '/products',
          page: () => const ProductManagementPage(),
        ),
        GetPage(
          name: '/add-product',
          page: () => const ProductFormPage(),
        ),
        GetPage(
          name: '/edit-product/:id',
          page: () => const ProductFormPage(),
        ),
        GetPage(
          name: '/edit-store-info',
          page: () => MerchantProfilePage(),
        ),
      ],
    ),
  ];
}
