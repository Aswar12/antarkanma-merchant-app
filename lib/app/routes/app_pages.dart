import 'package:antarkanma_merchant/app/modules/auth/views/login_view.dart';
import 'package:antarkanma_merchant/app/modules/auth/views/register_view.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_main_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_order_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_profile_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_management_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_form_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_home_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/edit_store_info_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_analytics_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/notification_inbox_page.dart';
import 'package:antarkanma_merchant/app/modules/splash/views/splash_page.dart';
import 'package:antarkanma_merchant/app/bindings/app_binding.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/middleware/auth_middleware.dart';
import 'package:antarkanma_merchant/app/modules/chat/views/chat_view.dart';
import 'package:antarkanma_merchant/app/modules/chat/bindings/chat_binding.dart';

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
  static const merchantAnalytics = '/merchantmain/analytics';
  static const notificationInbox = '/notifications/inbox';
}

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: AppBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AppBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
      binding: AppBinding(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.merchantMainPage,
      page: () => const MerchantMainPage(),
      binding: AppBinding(),
      preventDuplicates: true,
      middlewares: [
        AuthMiddleware(),
      ],
      children: [
        GetPage(
          name: '/home',
          page: () => const MerchantHomePage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/profile',
          page: () => MerchantProfilePage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/orders',
          page: () => const MerchantOrderPage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/products',
          page: () => const ProductManagementPage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/add-product',
          page: () => const ProductFormPage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/edit-product/:id',
          page: () => const ProductFormPage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/edit-store-info',
          page: () => const EditStoreInfoPage(),
          preventDuplicates: true,
        ),
        GetPage(
          name: '/analytics',
          page: () => const MerchantAnalyticsPage(),
          preventDuplicates: true,
        ),
      ],
    ),
    // Notification Inbox route
    GetPage(
      name: Routes.notificationInbox,
      page: () => const NotificationInboxPage(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    // Chat route (without chatId - for new chats from orders)
    GetPage(
      name: '/chat',
      page: () => const ChatView(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),
    // Chat route (with chatId - for existing chats from chat list)
    GetPage(
      name: '/chat/:chatId',
      page: () => const ChatView(),
      binding: ChatBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
