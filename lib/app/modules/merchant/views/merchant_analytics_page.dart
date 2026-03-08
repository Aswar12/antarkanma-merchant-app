import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:antarkanma_merchant/app/controllers/analytics_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

class MerchantAnalyticsPage extends StatelessWidget {
  const MerchantAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());

    return Scaffold(
      backgroundColor: dashBackgroundLight,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
            color: dashTextDark,
          ),
        ),
        backgroundColor: dashCardLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: dashTextDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: dashPrimary),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchOverview,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(controller),
                const SizedBox(height: 20),
                _buildSalesChart(controller),
                const SizedBox(height: 20),
                _buildTopProducts(controller),
                const SizedBox(height: 20),
                _buildPeakHours(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards(AnalyticsController controller) {
    final summary = controller.salesSummary.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
            color: dashTextDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total Penjualan',
                controller.formatCurrency(summary['total_sales'] ?? 0),
                Icons.payments_outlined,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Total Order',
                '${summary['total_orders'] ?? 0}',
                Icons.shopping_bag_outlined,
                const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Transaksi',
                '${summary['total_transactions'] ?? 0}',
                Icons.receipt_long_outlined,
                const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Ongkir',
                controller.formatCurrency(summary['total_shipping'] ?? 0),
                Icons.local_shipping_outlined,
                const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: primaryTextStyle.copyWith(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: bold,
              color: dashTextDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                'Tren Penjualan',
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                  color: dashTextDark,
                ),
              ),
              // Period selector
              Obx(() => DropdownButton<String>(
                    value: controller.selectedPeriod.value,
                    underline: const SizedBox(),
                    isDense: true,
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Harian')),
                      DropdownMenuItem(
                          value: 'weekly', child: Text('Mingguan')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Bulanan')),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.changePeriod(v);
                    },
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: controller.salesChartData.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data penjualan',
                      style: primaryTextStyle.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  )
                : SfCartesianChart(
                    primaryXAxis: const CategoryAxis(
                      labelRotation: -45,
                      labelStyle: TextStyle(fontSize: 10),
                    ),
                    primaryYAxis: const NumericAxis(
                      labelStyle: TextStyle(fontSize: 10),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      SplineAreaSeries<Map<String, dynamic>, String>(
                        dataSource: controller.salesChartData,
                        xValueMapper: (d, _) => (d['period'] ?? '').toString(),
                        yValueMapper: (d, _) =>
                            double.tryParse(
                                (d['total_sales'] ?? '0').toString()) ??
                            0,
                        name: 'Revenue',
                        color: const Color(0xFF3B82F6),
                        borderColor: const Color(0xFF3B82F6),
                        borderWidth: 2,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.3),
                            const Color(0xFF3B82F6).withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProducts(AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Terlaris',
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              fontWeight: semiBold,
              color: dashTextDark,
            ),
          ),
          const SizedBox(height: 12),
          if (controller.topProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada data produk',
                  style: primaryTextStyle.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...controller.topProducts.asMap().entries.map((entry) {
              final idx = entry.key;
              final product = entry.value;
              final maxRevenue = controller.topProducts.isNotEmpty
                  ? (double.tryParse(controller
                              .topProducts.first['total_revenue']
                              ?.toString() ??
                          '0') ??
                      1)
                  : 1.0;
              final revenue = double.tryParse(
                      product['total_revenue']?.toString() ?? '0') ??
                  0;
              final progress = maxRevenue > 0 ? revenue / maxRevenue : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: idx < 3
                            ? const Color(0xFFF59E0B)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${idx + 1}',
                        style: primaryTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: bold,
                          color: idx < 3 ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? '-',
                            style: primaryTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: medium,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              color: const Color(0xFF3B82F6),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          controller.formatCurrency(revenue),
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: semiBold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '${product['total_quantity'] ?? 0} terjual',
                          style: primaryTextStyle.copyWith(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPeakHours(AnalyticsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jam Sibuk',
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              fontWeight: semiBold,
              color: dashTextDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: controller.peakHoursData.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada data jam sibuk',
                      style: primaryTextStyle.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  )
                : SfCartesianChart(
                    primaryXAxis: const CategoryAxis(
                      labelStyle: TextStyle(fontSize: 10),
                    ),
                    primaryYAxis: const NumericAxis(
                      labelStyle: TextStyle(fontSize: 10),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      ColumnSeries<Map<String, dynamic>, String>(
                        dataSource: controller.peakHoursData,
                        xValueMapper: (d, _) =>
                            '${(d['hour'] ?? 0).toString().padLeft(2, '0')}:00',
                        yValueMapper: (d, _) =>
                            (d['order_count'] as num?)?.toDouble() ?? 0,
                        name: 'Pesanan',
                        color: const Color(0xFFF59E0B),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
