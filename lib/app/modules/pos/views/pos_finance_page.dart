import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/finance_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

class PosFinancePage extends StatelessWidget {
  PosFinancePage({Key? key}) : super(key: key);

  final controller = Get.put(FinanceController());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchAll(),
      color: dashPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildOverviewCards(),
          const SizedBox(height: 16),
          _buildPaymentMethodBreakdown(),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: dashPrimary, size: 20),
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
          color: dashPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: dashPrimary,
          ),
        ),
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
          // Main profit card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [dashNavyDeep, dashNavyDeep.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: dashNavyDeep.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laba Bersih',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
                  dashPrimary,
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
        ],
      );
    });
  }

  Widget _overviewMiniCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.6),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                  color: color.withOpacity(0.1),
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
                  color: Colors.grey.shade600,
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
              color: dashNavyDeep,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
            // Mock data - will be replaced with API data
            final paymentMethods = [
              {
                'name': 'Tunai',
                'amount': controller.totalIncome.value * 0.6,
                'icon': Icons.money,
                'color': Colors.green,
              },
              {
                'name': 'QRIS',
                'amount': controller.totalIncome.value * 0.25,
                'icon': Icons.qr_code_2,
                'color': dashPrimary,
              },
              {
                'name': 'Transfer',
                'amount': controller.totalIncome.value * 0.15,
                'icon': Icons.account_balance,
                'color': Colors.blue,
              },
            ];

            return Column(
              children: [
                ...paymentMethods.map((method) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (method['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: method['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'] as String,
                              style: primaryTextStyle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.formatCurrency(method['amount'] as double),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Calculate percentage
                      Builder(
                        builder: (context) {
                          final amount = method['amount'] as double;
                          final total = controller.totalIncome.value;
                          final percentage = total > 0 
                              ? (amount / total * 100).toStringAsFixed(1)
                              : '0.0';
                          return Text(
                            '$percentage%',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: method['color'] as Color,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
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
                          size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada data pendapatan',
                        style: TextStyle(
                          color: Colors.grey.shade500,
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
                  _dataLabel('POS Kasir', dashPrimary),
                  ...posData.map((d) => _incomeRow(
                        d['period']?.toString() ?? '-',
                        controller.toDouble(d['total']),
                        (d['count'] ?? 0) as int,
                        dashPrimary,
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
          color: active ? dashPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.grey.shade600,
          ),
        ),
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
              color: Colors.grey.shade600,
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
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                  color: color.withOpacity(0.15),
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
              color: Colors.grey.shade500,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
              GestureDetector(
                onTap: () => _showAddExpenseDialog(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: dashPrimary,
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
                        controller.getCategoryColor(category).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller
                          .getCategoryColor(category)
                          .withOpacity(0.2),
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
          // Expense list
          Obx(() {
            if (controller.isLoadingExpenses.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.expenses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long,
                          size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada pengeluaran',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: controller.expenses.map((e) {
                final category = e['category']?.toString() ?? '';
                final amount = controller.toDouble(e['amount']);
                final desc = e['description']?.toString() ?? '-';
                final date = e['expense_date']?.toString() ?? '-';
                final id = e['id'] as int?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: controller
                              .getCategoryColor(category)
                              .withOpacity(0.1),
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
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '-${controller.formatCurrency(amount)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                      if (id != null)
                        GestureDetector(
                          onTap: () => _confirmDelete(id, desc),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.close,
                                size: 16, color: Colors.grey.shade400),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
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
                      color: Colors.grey.shade600)),
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
                                    .withOpacity(0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active
                                  ? controller.getCategoryColor(cat)
                                  : Colors.grey.shade200,
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
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                controller.getCategoryDisplay(cat),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? controller.getCategoryColor(cat)
                                      : Colors.grey.shade600,
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
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
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
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
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
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey.shade500),
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
                    backgroundColor: dashPrimary,
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
}
