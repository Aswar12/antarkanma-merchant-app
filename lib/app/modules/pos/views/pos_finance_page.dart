import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/finance_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

class PosFinancePage extends StatelessWidget {
  PosFinancePage({super.key});

  final controller = Get.put(FinanceController());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchAll(),
      color: AppColors.orange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildWalletBalanceCard(),
          const SizedBox(height: 16),
          _buildOverviewCards(),
          const SizedBox(height: 16),
          _buildPaymentMethodBreakdown(),
          const SizedBox(height: 16),
          _buildCashFlowChart(),
          const SizedBox(height: 16),
          _buildIncomeBreakdown(),
          const SizedBox(height: 16),
          _buildExpenseSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ─── Date Range ────────────────────────────────────────
  Widget _buildDateRangeSelector() {
    return Obx(() {
      final from = controller.dateFrom.value;
      final to = controller.dateTo.value;
      final df = DateFormat('dd MMM', 'id_ID');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: AppColors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              from != null && to != null
                  ? '${df.format(from)} - ${df.format(to)}'
                  : 'Pilih Periode',
              style: primaryTextStyle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _periodChip('Hari Ini', () {
              final now = DateTime.now();
              controller.setDateRange(now, now);
            }),
            const SizedBox(width: 4),
            _periodChip('Minggu', () {
              final now = DateTime.now();
              controller.setDateRange(
                  now.subtract(const Duration(days: 7)), now);
            }),
            const SizedBox(width: 4),
            _periodChip('Bulan', () {
              final now = DateTime.now();
              controller.setDateRange(DateTime(now.year, now.month, 1), now);
            }),
          ],
        ),
      );
    });
  }

  Widget _periodChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.orange,
          ),
        ),
      ),
    );
  }

  // ─── Wallet Balance Card ───────────────────────────────
  Widget _buildWalletBalanceCard() {
    return Obx(() {
      if (controller.isLoadingWallet.value) {
        return _buildShimmerWalletCard();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange,
              AppColors.orange.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Wallet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  controller.isWalletActive.value
                      ? Icons.check_circle
                      : Icons.pause_circle,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              controller.formatCurrency(controller.walletBalance.value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            // Today's summary
            Row(
              children: [
                Expanded(
                  child: _walletMiniCard(
                    'Hari Ini',
                    controller.formatCurrency(controller.todayTotalIn.value),
                    Icons.trending_up,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _walletMiniCard(
                    'Pengeluaran',
                    controller.formatCurrency(controller.todayExpenses.value),
                    Icons.trending_down,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Net and transaction count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        controller.todayNet.value >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: controller.todayNet.value >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Net Hari Ini',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${controller.todayNet.value >= 0 ? "+" : ""}${controller.formatCurrency(controller.todayNet.value)}',
                    style: TextStyle(
                      color: controller.todayNet.value >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _walletMiniCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.orange,
            AppColors.orange.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(width: 80, height: 14),
              _buildShimmerBox(width: 16, height: 16),
            ],
          ),
          const SizedBox(height: 4),
          _buildShimmerBox(width: 180, height: 28),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(width: 60, height: 12),
                      const SizedBox(height: 4),
                      _buildShimmerBox(width: 80, height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(width: 60, height: 12),
                      const SizedBox(height: 4),
                      _buildShimmerBox(width: 80, height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerBox(width: 100, height: 14),
                _buildShimmerBox(width: 80, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Overview Cards ────────────────────────────────────
  Widget _buildOverviewCards() {
    return Obx(() {
      if (controller.isLoadingOverview.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Column(
        children: [
          // Main profit card with comparison
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.navy.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Laba Bersih',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Period comparison indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.profitChange.value >= 0
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.profitChange.value >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: controller.profitChange.value >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.profitChange.value >= 0 ? "+" : ""}${controller.profitChange.value.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: controller.profitChange.value >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  controller.formatCurrency(controller.netProfit.value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _overviewMiniCard(
                      'Pendapatan',
                      controller.formatCurrency(controller.totalIncome.value),
                      Icons.trending_up,
                      Colors.greenAccent,
                    ),
                    const SizedBox(width: 12),
                    _overviewMiniCard(
                      'Pengeluaran',
                      controller.formatCurrency(controller.totalExpenses.value),
                      Icons.trending_down,
                      Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // POS vs Online split
          Row(
            children: [
              Expanded(
                child: _sourceCard(
                  'POS Kasir',
                  controller.formatCurrency(controller.posIncome.value),
                  '${controller.posCount.value} transaksi',
                  Icons.point_of_sale,
                  AppColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _sourceCard(
                  'Online',
                  controller.formatCurrency(controller.onlineIncome.value),
                  '${controller.onlineCount.value} pesanan',
                  Icons.shopping_bag_outlined,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Profit Margin & Quick Stats
          Row(
            children: [
              Expanded(
                child: _profitMarginCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _quickStatsCard(),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _profitMarginCard() {
    return Obx(() {
      final margin = controller.profitMargin.value;
      final marginColor = margin >= 50
          ? Colors.green
          : margin >= 30
              ? Colors.orange
              : Colors.red;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, size: 16, color: marginColor),
                const SizedBox(width: 6),
                Text(
                  'Margin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${margin.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: marginColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              margin >= 30 ? 'Sehat' : 'Perlu Perbaikan',
              style: TextStyle(
                fontSize: 9,
                color: marginColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _quickStatsCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 16, color: Colors.purple),
                const SizedBox(width: 6),
                Text(
                  'Stats',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Avg: ${controller.formatCurrency(controller.avgTransactionValue.value)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Hari: ${controller.revenuePerDay.value >= 1000000 ? 'Rp ${(controller.revenuePerDay.value / 1000000).toStringAsFixed(1)}J' : 'Rp ${(controller.revenuePerDay.value / 1000).toStringAsFixed(0)}K'}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    });
  }

  Widget _overviewMiniCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceCard(String title, String amount, String subtitle,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: primaryTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Payment Method Breakdown ─────────────────────────
  Widget _buildPaymentMethodBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metode Pembayaran',
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingPaymentMethods.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.paymentMethods.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.payment,
                          size: 40, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada data pembayaran',
                        style: TextStyle(
                          color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final paymentMethodIcons = {
              'CASH': {'icon': Icons.money, 'color': Colors.green, 'label': 'Tunai'},
              'QRIS': {'icon': Icons.qr_code_2, 'color': AppColors.orange, 'label': 'QRIS'},
              'TRANSFER': {'icon': Icons.account_balance, 'color': Colors.blue, 'label': 'Transfer'},
            };

            return Column(
              children: [
                ...controller.paymentMethods.entries.map((entry) {
                  final method = entry.key;
                  final data = entry.value;
                  final amount = controller.toDouble(data['amount']);
                  final count = data['count'] as int? ?? 0;
                  final percentage = data['percentage'] as double? ?? 0.0;
                  
                  final methodInfo = paymentMethodIcons[method] ?? {
                    'icon': Icons.payment,
                    'color': Colors.grey,
                    'label': method,
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (methodInfo['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            methodInfo['icon'] as IconData,
                            color: methodInfo['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                methodInfo['label'] as String,
                                style: primaryTextStyle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.formatCurrency(amount),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$percentage%',
                              style: primaryTextStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: methodInfo['color'] as Color,
                              ),
                            ),
                            Text(
                              '$count transaksi',
                              style: TextStyle(
                                fontSize: 10,
                                color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Income Breakdown ──────────────────────────────────
  Widget _buildIncomeBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rincian Pendapatan',
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(() => Row(
                    children: [
                      _toggleChip('Harian', 'daily',
                          controller.incomePeriod.value == 'daily'),
                      const SizedBox(width: 4),
                      _toggleChip('Mingguan', 'weekly',
                          controller.incomePeriod.value == 'weekly'),
                      const SizedBox(width: 4),
                      _toggleChip('Bulanan', 'monthly',
                          controller.incomePeriod.value == 'monthly'),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingIncome.value) {
              return _buildShimmerIncomeList();
            }

            final posData = controller.posIncomeData;
            final onlineData = controller.onlineIncomeData;

            if (posData.isEmpty && onlineData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart,
                          size: 40, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada data pendapatan',
                        style: TextStyle(
                          color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Simple bar list
            return Column(
              children: [
                if (posData.isNotEmpty) ...[
                  _dataLabel('POS Kasir', AppColors.orange),
                  ...posData.map((d) => _incomeRow(
                        d['period']?.toString() ?? '-',
                        controller.toDouble(d['total']),
                        (d['count'] ?? 0) as int,
                        AppColors.orange,
                      )),
                ],
                if (onlineData.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _dataLabel('Online', Colors.blue),
                  ...onlineData.map((d) => _incomeRow(
                        d['period']?.toString() ?? '-',
                        controller.toDouble(d['total']),
                        (d['count'] ?? 0) as int,
                        Colors.blue,
                      )),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, String value, bool active) {
    return GestureDetector(
      onTap: () => controller.setPeriod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.orange : Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ─── Cash Flow Chart ───────────────────────────────────
  Widget _buildCashFlowChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arus Kas',
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Obx(() => Row(
                    children: [
                      _toggleChip('Harian', 'daily',
                          controller.cashFlowPeriod.value == 'daily'),
                      const SizedBox(width: 4),
                      _toggleChip('Mingguan', 'weekly',
                          controller.cashFlowPeriod.value == 'weekly'),
                      const SizedBox(width: 4),
                      _toggleChip('Bulanan', 'monthly',
                          controller.cashFlowPeriod.value == 'monthly'),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingCashFlow.value) {
              return _buildShimmerCashFlowChart();
            }

            if (controller.cashFlowData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.show_chart,
                          size: 50, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada data arus kas',
                        style: TextStyle(
                          color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildLineChart();
          }),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final data = controller.cashFlowData;
    final maxIncome = data.map((e) => controller.toDouble(e['income'] ?? 0.0)).reduce((a, b) => a > b ? a : b);
    final maxExpenses = data.map((e) => controller.toDouble(e['expenses'] ?? 0.0)).reduce((a, b) => a > b ? a : b);
    final maxValue = maxIncome > maxExpenses ? maxIncome : maxExpenses;
    
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis labels
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.formatCurrency(maxValue),
                style: TextStyle(fontSize: 9, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500),
              ),
              Text(
                controller.formatCurrency(maxValue / 2),
                style: TextStyle(fontSize: 9, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500),
              ),
              Text(
                'Rp 0',
                style: TextStyle(fontSize: 9, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Chart
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final income = controller.toDouble(item['income'] ?? 0.0);
                final expenses = controller.toDouble(item['expenses'] ?? 0.0);
                final incomeHeight = maxValue > 0 ? (income / maxValue) * 160 : 0.0;
                final expensesHeight = maxValue > 0 ? (expenses / maxValue) * 160 : 0.0;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Income bar
                    Container(
                      width: 12,
                      height: incomeHeight,
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Expenses bar
                    Container(
                      width: 12,
                      height: expensesHeight,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCashFlowChart() {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Y-axis shimmer
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShimmerBox(width: 50, height: 12),
              _buildShimmerBox(width: 50, height: 12),
              _buildShimmerBox(width: 50, height: 12),
            ],
          ),
          const SizedBox(width: 8),
          // Chart shimmer
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = 30 + (index % 3) * 30;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildShimmerBox(width: 12, height: height.toDouble()),
                    const SizedBox(height: 4),
                    _buildShimmerBox(width: 12, height: (height * 0.7).toDouble()),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dataLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomeRow(String period, double total, int count, Color color) {
    final maxWidth = 200.0;
    // Simple relative bar
    final barWidth = total > 0
        ? (total /
                (controller.totalIncome.value > 0
                    ? controller.totalIncome.value
                    : 1)) *
            maxWidth
        : 4.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              period,
              style: TextStyle(fontSize: 11, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Container(
              height: 18,
              alignment: Alignment.centerLeft,
              child: Container(
                width: barWidth.clamp(4, maxWidth),
                height: 18,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  controller.formatCurrency(total),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${count}x',
            style: TextStyle(
              fontSize: 10,
              color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Expense Section ───────────────────────────────────
  Widget _buildExpenseSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengeluaran',
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  // Export button
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download, size: 16, color: AppColors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Export',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'pdf') {
                        _exportToPDF();
                      } else if (value == 'excel') {
                        _exportToExcel();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('PDF Document'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'excel',
                        child: Row(
                          children: [
                            Icon(Icons.table_chart, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Excel Spreadsheet'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Add expense button
                  GestureDetector(
                    onTap: () => _showAddExpenseDialog(),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category summary
          Obx(() {
            if (controller.expenseCategories.isEmpty) {
              return const SizedBox.shrink();
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.expenseCategories.map((cat) {
                final category = cat['category']?.toString() ?? '';
                final total = controller.toDouble(cat['total']);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        controller.getCategoryColor(category).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller
                          .getCategoryColor(category)
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.getCategoryIcon(category),
                        size: 14,
                        color: controller.getCategoryColor(category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.getCategoryDisplay(category)}: ${controller.formatCurrency(total)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: controller.getCategoryColor(category),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 12),
          // Expense list with pagination
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                  controller.loadMoreExpenses();
                }
              }
              return false;
            },
            child: Obx(() {
            if (controller.isLoadingExpenses.value) {
              return _buildShimmerExpenseList();
            }

            if (controller.filteredExpenses.isEmpty && controller.expenses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long,
                          size: 40, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada pengeluaran',
                        style: TextStyle(
                          color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.filteredExpenses.isEmpty && controller.expenses.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.search_off,
                          size: 40, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada pengeluaran yang cocok',
                        style: TextStyle(
                          color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => controller.clearFilters(),
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Search & Filter Bar
                _buildSearchFilterBar(),
                const SizedBox(height: 12),
                // Expense list
                ...controller.filteredExpenses.map((e) {
                  final category = e['category']?.toString() ?? '';
                  final amount = controller.toDouble(e['amount']);
                  final desc = e['description']?.toString() ?? '-';
                  final date = e['expense_date']?.toString() ?? '-';
                  final id = e['id'] as int?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: controller
                                .getCategoryColor(category)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            controller.getCategoryIcon(category),
                            size: 18,
                            color: controller.getCategoryColor(category),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                desc,
                                style: primaryTextStyle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${controller.getCategoryDisplay(category)} • $date',
                              style: TextStyle(
                                fontSize: 11,
                                color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '-${controller.formatCurrency(amount)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                          if (id != null)
                            const SizedBox(height: 4),
                          if (id != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit button
                                GestureDetector(
                                  onTap: () => _showEditExpenseDialog(id, category, amount, desc, date),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(Icons.edit,
                                        size: 14, color: AppColors.orange),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Delete button
                                GestureDetector(
                                  onTap: () => _confirmDelete(id, desc),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(Icons.delete,
                                        size: 14, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        }),
      ),
    ],
  ),
);
}

  // ─── Add Expense Dialog ────────────────────────────────
  void _showAddExpenseDialog() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final selectedCategory = 'BAHAN_BAKU'.obs;
    final selectedDate = DateTime.now().obs;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Pengeluaran',
                style: primaryTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              // Category dropdown
              Text('Kategori',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600)),
              const SizedBox(height: 6),
              Obx(() => Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      'BAHAN_BAKU',
                      'OPERASIONAL',
                      'GAJI',
                      'SEWA',
                      'UTILITAS',
                      'LAINNYA'
                    ].map((cat) {
                      final active = selectedCategory.value == cat;
                      return GestureDetector(
                        onTap: () => selectedCategory.value = cat,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? controller
                                    .getCategoryColor(cat)
                                    .withValues(alpha: 0.15)
                                : Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active
                                  ? controller.getCategoryColor(cat)
                                  : Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.getCategoryIcon(cat),
                                size: 14,
                                color: active
                                    ? controller.getCategoryColor(cat)
                                    : Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.getCategoryDisplay(cat),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? controller.getCategoryColor(cat)
                                      : Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 14),
              // Amount
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  filled: true,
                  fillColor: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Description
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  filled: true,
                  fillColor: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Date
              Obx(() => GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) selectedDate.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(selectedDate.value),
                            style: primaryTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              // Submit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountCtrl.text.replaceAll('.', ''));
                    if (amount == null || amount <= 0) {
                      Get.snackbar('Error', 'Masukkan jumlah yang valid',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }
                    if (descCtrl.text.trim().isEmpty) {
                      Get.snackbar('Error', 'Masukkan keterangan',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    final success = await controller.createExpense(
                      category: selectedCategory.value,
                      amount: amount,
                      description: descCtrl.text.trim(),
                      expenseDate: selectedDate.value,
                    );

                    if (success) {
                      Get.back();
                      Get.snackbar(
                        'Berhasil',
                        'Pengeluaran berhasil ditambahkan',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int id, String desc) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pengeluaran?'),
        content: Text('Pengeluaran "$desc" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteExpense(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseDialog(int id, String currentCategory, double currentAmount, String currentDesc, String currentDate) {
    final descCtrl = TextEditingController(text: currentDesc);
    final amountCtrl = TextEditingController(text: currentAmount.toString().replaceAll('.', ''));
    final selectedCategory = currentCategory.obs;
    final selectedDate = DateTime.now().obs;
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    // Parse date if possible
    try {
      final parsedDate = DateTime.parse(currentDate);
      selectedDate.value = parsedDate;
    } catch (e) {
      // Use current date if parsing fails
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Pengeluaran',
                style: primaryTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              // Category dropdown
              Text('Kategori',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600)),
              const SizedBox(height: 6),
              Obx(() => Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      'BAHAN_BAKU',
                      'OPERASIONAL',
                      'GAJI',
                      'SEWA',
                      'UTILITAS',
                      'LAINNYA'
                    ].map((cat) {
                      final active = selectedCategory.value == cat;
                      return GestureDetector(
                        onTap: () => selectedCategory.value = cat,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? controller
                                    .getCategoryColor(cat)
                                    .withValues(alpha: 0.15)
                                : Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active
                                  ? controller.getCategoryColor(cat)
                                  : Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.getCategoryIcon(cat),
                                size: 14,
                                color: active
                                    ? controller.getCategoryColor(cat)
                                    : Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.getCategoryDisplay(cat),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? controller.getCategoryColor(cat)
                                      : Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 14),
              // Amount
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  filled: true,
                  fillColor: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Description
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  filled: true,
                  fillColor: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Date
              Obx(() => GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate.value,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) selectedDate.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade500),
                          const SizedBox(width: 8),
                          Text(
                            dateFormat.format(selectedDate.value),
                            style: primaryTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              // Submit
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountCtrl.text.replaceAll('.', ''));
                    if (amount == null || amount <= 0) {
                      Get.snackbar('Error', 'Masukkan jumlah yang valid',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }
                    if (descCtrl.text.trim().isEmpty) {
                      Get.snackbar('Error', 'Masukkan keterangan',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white);
                      return;
                    }

                    final success = await controller.updateExpense(
                      id: id,
                      category: selectedCategory.value,
                      amount: amount,
                      description: descCtrl.text.trim(),
                      expenseDate: selectedDate.value,
                    );

                    if (success) {
                      Get.back();
                      Get.snackbar(
                        'Berhasil',
                        'Pengeluaran berhasil diupdate',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    } else {
                      Get.snackbar(
                        'Error',
                        'Gagal mengupdate pengeluaran',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Shimmer Loading for Expenses ──────────────────────
  Widget _buildShimmerExpenseList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Get.isDarkMode ? AppColors.darkInputBorder : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Get.isDarkMode 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              // Text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 180, height: 16),
                    const SizedBox(height: 6),
                    _buildShimmerBox(width: 120, height: 14),
                  ],
                ),
              ),
              // Amount placeholder
              _buildShimmerBox(width: 80, height: 16),
              const SizedBox(width: 8),
              // Delete icon placeholder
              _buildShimmerBox(width: 16, height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Get.isDarkMode 
            ? Colors.white.withValues(alpha: 0.05) 
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildShimmerIncomeList() {
    return Column(
      children: [
        // POS section
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _buildShimmerBox(width: 10, height: 10),
              const SizedBox(width: 6),
              _buildShimmerBox(width: 80, height: 14),
            ],
          ),
        ),
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: _buildShimmerBox(width: 60, height: 14),
              ),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildShimmerBox(width: 30, height: 14),
            ],
          ),
        )),
        const SizedBox(height: 12),
        // Online section
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _buildShimmerBox(width: 10, height: 10),
              const SizedBox(width: 6),
              _buildShimmerBox(width: 80, height: 14),
            ],
          ),
        ),
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: _buildShimmerBox(width: 60, height: 14),
              ),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Get.isDarkMode 
                        ? Colors.white.withValues(alpha: 0.05) 
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildShimmerBox(width: 30, height: 14),
            ],
          ),
        )),
      ],
    );
  }

  // ─── Search & Filter Bar ───────────────────────────────
  Widget _buildSearchFilterBar() {
    return Obx(() {
      return Column(
        children: [
          // Search bar
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Cari pengeluaran...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => controller.setSearchQuery(''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          // Category filter chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('Semua'),
                      ...['BAHAN_BAKU', 'OPERASIONAL', 'GAJI', 'SEWA', 'UTILITAS', 'LAINNYA']
                          .map((cat) => _buildCategoryChip(cat)),
                    ],
                  ),
                ),
              ),
              if (controller.searchQuery.value.isNotEmpty || controller.selectedCategory.value != 'Semua')
                TextButton(
                  onPressed: () => controller.clearFilters(),
                  child: const Text('Clear'),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = controller.selectedCategory.value == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          controller.getCategoryDisplay(category),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Get.isDarkMode ? AppColors.darkTextHint : Colors.grey.shade700,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          controller.setSelectedCategory(selected ? category : 'Semua');
        },
        backgroundColor: Get.isDarkMode ? AppColors.darkSurface : Colors.grey.shade100,
        selectedColor: AppColors.orange,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppColors.orange : Colors.transparent,
          ),
        ),
      ),
    );
  }

  // ─── Export Functions ──────────────────────────────────
  Future<void> _exportToPDF() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating PDF...'),
              ],
            ),
          ),
        ),
      );

      final result = await controller.exportToPDF();
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (result != null) {
        Get.snackbar(
          'Sukses',
          'PDF berhasil diexport',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal export PDF',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _exportToExcel() async {
    try {
      Get.dialog(
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating Excel...'),
              ],
            ),
          ),
        ),
      );

      final result = await controller.exportToExcel();
      
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (result != null) {
        Get.snackbar(
          'Sukses',
          'Excel berhasil diexport',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal export Excel',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
