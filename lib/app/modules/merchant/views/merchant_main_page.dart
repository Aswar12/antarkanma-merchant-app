import 'package:antarkanma_merchant/app/controllers/merchant_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_home_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_home_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_order_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_management_page.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_profile_page.dart';
import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MerchantMainPage extends StatefulWidget {
  const MerchantMainPage({super.key});

  @override
  State<MerchantMainPage> createState() => _MerchantMainPageState();
}

class _MerchantMainPageState extends State<MerchantMainPage> {
  late final MerchantController controller;
  late final MerchantProfileController profileController;
  late final MerchantHomeController homeController;
  late final MerchantOrderController orderController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (!_isInitialized) {
      _initializeControllers();
      _isInitialized = true;
    }
  }

  void _initializeControllers() {
    // Get controllers from GetX
    controller = Get.find<MerchantController>();
    profileController = Get.find<MerchantProfileController>();
    homeController = Get.find<MerchantHomeController>();
    orderController = Get.find<MerchantOrderController>();

    // Load data in merchant controller
    controller.fetchMerchantData();
    profileController.fetchMerchantData();

    // Check for pending notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingNotification = Get.arguments?['pending_notification'];
      if (pendingNotification != null) {
        final type = pendingNotification['type'];
        final status = pendingNotification['status'];

        if (type == 'transaction_approved' && status == 'WAITING_APPROVAL') {
          // Navigate to orders page and set filter
          homeController.changePage(1); // Orders tab
          orderController.filterOrders('WAITING_APPROVAL');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const MerchantHomePage(),
      const MerchantOrderPage(),
      const ProductManagementPage(),
      MerchantProfilePage(),
    ];

    Widget body() {
      return GetX<MerchantController>(
        builder: (_) {
          // Check if merchant data exists
          if (!controller.isLoading.value &&
              controller.merchant.value == null) {
            // Redirect to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(Routes.login);
            });
            return const SizedBox(); // Return empty widget while redirecting
          }

          return IndexedStack(
            index: homeController.currentPage.value,
            children: pages,
          );
        },
      );
    }

    BottomNavigationBarItem createNavItem(
        IconData icon, String label, int index) {
      bool isSelected = homeController.currentPage.value == index;
      return BottomNavigationBarItem(
        icon: Container(
          margin: const EdgeInsets.only(top: 4, bottom: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: Dimenssions.height24,
                color: isSelected ? dashPrimary : Colors.grey.shade400,
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
        activeIcon: Container(
          margin: const EdgeInsets.only(top: 4, bottom: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: Dimenssions.height24,
                color: dashPrimary,
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
        label: label,
      );
    }

    Widget customBottomNav() {
      return Container(
        decoration: BoxDecoration(
          color: dashCardLight,
          border: Border(
            top: BorderSide(
              color: dashBorderLight,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
              selectedItemColor: dashPrimary,
              unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: primaryTextStyle.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: primaryTextStyle.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              currentIndex: homeController.currentPage.value,
              onTap: (index) => homeController.changePage(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // Transparent to avoid double background
              elevation: 0, // Remove elevation since we have custom shadow
              items: [
                createNavItem(Icons.grid_view, 'Beranda', 0),
                createNavItem(Icons.receipt_long, 'Pesanan', 1),
                createNavItem(Icons.restaurant_menu, 'Menu', 2),
                createNavItem(Icons.person_outline, 'Profil', 3),
              ],
            )),
      );
    }

    return GetX<MerchantController>(
      builder: (controller) => PopScope(
        canPop: homeController.currentPage.value == 0,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          homeController.changePage(0);
        },
        child: Scaffold(
          backgroundColor: dashBackgroundLight,
          extendBody: true, // Allow content to flow under the bottom nav
          bottomNavigationBar:
              controller.merchant.value != null ? customBottomNav() : null,
          body: controller.isLoading.value
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: dashPrimary),
                      const SizedBox(height: 16),
                      Text(
                        'Memuat data...',
                        style: primaryTextStyle.copyWith(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : body(),
        ),
      ),
    );
  }
}
