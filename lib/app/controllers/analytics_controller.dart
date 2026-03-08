import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/providers/analytics_provider.dart';

class AnalyticsController extends GetxController {
  final AnalyticsProvider _provider = AnalyticsProvider();

  // State
  final isLoading = true.obs;
  final selectedPeriod = 'daily'.obs;

  // Sales data
  final salesSummary = Rx<Map<String, dynamic>>({});
  final salesChartData = <Map<String, dynamic>>[].obs;

  // Top products
  final topProducts = <Map<String, dynamic>>[].obs;

  // Peak hours
  final peakHoursData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
  }

  Future<void> fetchOverview() async {
    try {
      isLoading.value = true;
      final response = await _provider.getOverview();

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meta']?['status'] == 'success' && data['data'] != null) {
          final overview = data['data'];

          // Sales
          if (overview['sales'] != null) {
            salesSummary.value =
                Map<String, dynamic>.from(overview['sales']['summary'] ?? {});
            salesChartData.assignAll(
              (overview['sales']['data'] as List?)
                      ?.map((e) => Map<String, dynamic>.from(e))
                      .toList() ??
                  [],
            );
          }

          // Top products
          if (overview['top_products'] != null) {
            topProducts.assignAll(
              (overview['top_products'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }

          // Peak hours
          if (overview['peak_hours'] != null) {
            peakHoursData.assignAll(
              (overview['peak_hours'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }

          debugPrint(
              '[Analytics] Loaded: ${salesChartData.length} sales points, ${topProducts.length} products, ${peakHoursData.length} peak hours');
        }
      }
    } catch (e) {
      debugPrint('[Analytics] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSales() async {
    try {
      isLoading.value = true;
      final response = await _provider.getSales(period: selectedPeriod.value);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['meta']?['status'] == 'success' && data['data'] != null) {
          salesSummary.value =
              Map<String, dynamic>.from(data['data']['summary'] ?? {});
          salesChartData.assignAll(
            (data['data']['data'] as List?)
                    ?.map((e) => Map<String, dynamic>.from(e))
                    .toList() ??
                [],
          );
        }
      }
    } catch (e) {
      debugPrint('[Analytics] Sales error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    fetchSales();
  }

  String formatCurrency(dynamic amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(double.tryParse(amount.toString()) ?? 0);
  }
}
