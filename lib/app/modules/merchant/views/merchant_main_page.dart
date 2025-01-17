
import 'package:antarkanma_merchant/app/controllers/merchant_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
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
  final MerchantController controller = Get.find();
  final MerchantProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
    // Load data in merchant controller
    controller.fetchMerchantData();
    profileController.fetchMerchantData();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MerchantHomePage(),
      const MerchantOrderPage(),
      ProductManagementPage(),
      MerchantProfilePage(),
    ];

    Widget body() {
      return GetX<MerchantController>(
        builder: (_) {
          // Check if merchant data exists
          if (!controller.isLoading.value && controller.merchant.value == null) {
            // Redirect to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(Routes.login);
            });
            return const SizedBox(); // Return empty widget while redirecting
          }

          return IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          );
        },
      );
    }

    BottomNavigationBarItem createNavItem(
        IconData icon, String label, int index) {
      return BottomNavigationBarItem(
        icon: Container(
          margin: EdgeInsets.only(top: Dimenssions.height5),
          child: GetX<MerchantController>(
            builder: (_) => Icon(
              icon,
              size: Dimenssions.height22,
              color: controller.currentIndex.value == index
                  ? logoColor
                  : Colors.grey,
            ),
          ),
        ),
        label: label,
      );
    }

    Widget customBottomNav() {
      return GetX<MerchantController>(
        builder: (_) => Container(
          decoration: BoxDecoration(
            color: backgroundColor1,
            boxShadow: controller.currentIndex.value == 1
                ? []
                : [
                    BoxShadow(
                      color: backgroundColor6.withOpacity(0.15),
                      offset: const Offset(0, -1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: backgroundColor6.withOpacity(0.3),
                      offset: const Offset(0, -0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: ClipRRect(
            child: BottomNavigationBar(
              selectedItemColor: logoColor,
              unselectedItemColor: Colors.grey,
              currentIndex: controller.currentIndex.value,
              onTap: (index) => controller.changePage(index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: backgroundColor1,
              elevation: 0,
              items: [
                createNavItem(Icons.home, 'Home', 0),
                createNavItem(Icons.list, 'Orders', 1),
                createNavItem(Icons.inventory, 'Products', 2),
                createNavItem(Icons.person, 'Profile', 3),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (controller.currentIndex.value != 0) {
          controller.changePage(0);
          return false;
        }
        return true;
      },
      child: Obx(() => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: controller.merchant.value != null ? customBottomNav() : null,
        body: controller.isLoading.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: logoColor),
                    SizedBox(height: 16),
                    Text(
                      'Memuat data...',
                      style: primaryTextStyle.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : body(),
      )),
    );
  }
}
