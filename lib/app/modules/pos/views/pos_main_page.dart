import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/product_management_page.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'pos_cashier_page.dart';
import 'pos_history_page.dart';
import 'pos_finance_page.dart';

class PosMainPage extends StatelessWidget {
  const PosMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();

    return Scaffold(
      backgroundColor: dashBackgroundLight,
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
        color: dashNavyDeep,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: dashNavyDeep.withOpacity(0.3),
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: TabBar(
                controller: controller.tabController,
                labelColor: dashPrimary, // Orange aktif
                unselectedLabelColor:
                    Colors.orange.withOpacity(0.5), // Orange pudar
                indicatorColor: dashPrimary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  _buildTab(Icons.point_of_sale, 'Kasir'),
                  _buildTab(Icons.inventory_2, 'Produk'),
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
      height: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
