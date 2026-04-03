import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_management_page.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'pos_cashier_page.dart';
import 'pos_table_page.dart';
import 'pos_queue_page.dart';
import 'pos_history_page.dart';
import 'pos_finance_page.dart';

class PosMainPage extends StatelessWidget {
  const PosMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();

    return Scaffold(
      backgroundColor: Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ─── Premium Navy Header ─────────────────────────
          _buildHeader(controller),
          // ─── Tab Content ────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                const PosCashierPage(),
                ProductManagementPage(),
                const PosTablePage(),
                const PosQueuePage(),
                const PosHistoryPage(),
                PosFinancePage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PosController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sub-tabs with Orange theme
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: TabBar(
                controller: controller.tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                labelColor: AppColors.orange,
                unselectedLabelColor: Colors.orange.withOpacity(0.5),
                indicatorColor: AppColors.orange,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                tabs: [
                  _buildTab(Icons.point_of_sale, 'Kasir'),
                  _buildTab(Icons.inventory_2, 'Produk'),
                  _buildTab(Icons.table_restaurant, 'Meja'),
                  _buildTab(Icons.queue, 'Antrian'),
                  _buildTab(Icons.history, 'Riwayat'),
                  _buildTab(Icons.account_balance_wallet, 'Keuangan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      height: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
