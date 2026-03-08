import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/data/providers/finance_provider.dart';

class FinanceController extends GetxController {
  final FinanceProvider _provider = FinanceProvider();

  // ─── State ──────────────────────────────────────────────
  final isLoadingOverview = true.obs;
  final isLoadingIncome = false.obs;
  final isLoadingExpenses = false.obs;

  // Overview
  final totalIncome = 0.0.obs;
  final totalExpenses = 0.0.obs;
  final netProfit = 0.0.obs;
  final posIncome = 0.0.obs;
  final posCount = 0.obs;
  final onlineIncome = 0.0.obs;
  final onlineCount = 0.obs;
  final expenseCategories = <Map<String, dynamic>>[].obs;

  // Income breakdown
  final incomePeriod = 'daily'.obs;
  final posIncomeData = <Map<String, dynamic>>[].obs;
  final onlineIncomeData = <Map<String, dynamic>>[].obs;

  // Expenses
  final expenses = <Map<String, dynamic>>[].obs;

  // Date range
  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();

  // Formatters
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final _dateFormat = DateFormat('yyyy-MM-dd');

  String formatCurrency(double value) => _currency.format(value);

  @override
  void onInit() {
    super.onInit();
    // Default to this month
    final now = DateTime.now();
    dateFrom.value = DateTime(now.year, now.month, 1);
    dateTo.value = now;
    fetchAll();
  }

  void fetchAll() {
    fetchOverview();
    fetchIncomeBreakdown();
    fetchExpenses();
  }

  String? get _from =>
      dateFrom.value != null ? _dateFormat.format(dateFrom.value!) : null;
  String? get _to =>
      dateTo.value != null ? _dateFormat.format(dateTo.value!) : null;

  // ─── Overview ──────────────────────────────────────────
  Future<void> fetchOverview() async {
    isLoadingOverview.value = true;
    try {
      final response = await _provider.getOverview(from: _from, to: _to);
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        totalIncome.value = toDouble(data['total_income']);
        totalExpenses.value = toDouble(data['total_expenses']);
        netProfit.value = toDouble(data['net_profit']);

        final breakdown = data['income_breakdown'];
        posIncome.value = toDouble(breakdown['pos']['amount']);
        posCount.value = breakdown['pos']['count'] ?? 0;
        onlineIncome.value = toDouble(breakdown['online']['amount']);
        onlineCount.value = breakdown['online']['count'] ?? 0;

        if (data['expense_categories'] != null) {
          expenseCategories.value = List<Map<String, dynamic>>.from(
            data['expense_categories'],
          );
        }
      } else {
        debugPrint('Finance overview error: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error fetching overview: $e');
    } finally {
      isLoadingOverview.value = false;
    }
  }

  // ─── Income Breakdown ──────────────────────────────────
  Future<void> fetchIncomeBreakdown() async {
    isLoadingIncome.value = true;
    try {
      final response = await _provider.getIncomeBreakdown(
        period: incomePeriod.value,
        from: _from,
        to: _to,
      );
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        posIncomeData.value =
            List<Map<String, dynamic>>.from(data['pos'] ?? []);
        onlineIncomeData.value =
            List<Map<String, dynamic>>.from(data['online'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching income breakdown: $e');
    } finally {
      isLoadingIncome.value = false;
    }
  }

  // ─── Expenses ──────────────────────────────────────────
  Future<void> fetchExpenses({String? category}) async {
    isLoadingExpenses.value = true;
    try {
      final response = await _provider.getExpenses(
        category: category,
        from: _from,
        to: _to,
      );
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        // Handle paginated response
        if (data is Map && data.containsKey('data')) {
          expenses.value = List<Map<String, dynamic>>.from(data['data']);
        } else if (data is List) {
          expenses.value = List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  Future<bool> createExpense({
    required String category,
    required double amount,
    required String description,
    required DateTime expenseDate,
  }) async {
    try {
      final response = await _provider.createExpense({
        'category': category,
        'amount': amount,
        'description': description,
        'expense_date': _dateFormat.format(expenseDate),
      });
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        fetchExpenses();
        fetchOverview();
        return true;
      }
      debugPrint('Create expense error: ${response.data}');
      return false;
    } catch (e) {
      debugPrint('Error creating expense: $e');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final response = await _provider.deleteExpense(id);
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        fetchExpenses();
        fetchOverview();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      return false;
    }
  }

  // ─── Date Range ────────────────────────────────────────
  void setDateRange(DateTime from, DateTime to) {
    dateFrom.value = from;
    dateTo.value = to;
    fetchAll();
  }

  void setPeriod(String period) {
    incomePeriod.value = period;
    fetchIncomeBreakdown();
  }

  // ─── Helpers ───────────────────────────────────────────
  double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String getCategoryDisplay(String category) {
    return switch (category) {
      'BAHAN_BAKU' => 'Bahan Baku',
      'OPERASIONAL' => 'Operasional',
      'GAJI' => 'Gaji',
      'SEWA' => 'Sewa',
      'UTILITAS' => 'Utilitas',
      'LAINNYA' => 'Lainnya',
      _ => category,
    };
  }

  IconData getCategoryIcon(String category) {
    return switch (category) {
      'BAHAN_BAKU' => Icons.inventory_2,
      'OPERASIONAL' => Icons.settings,
      'GAJI' => Icons.people,
      'SEWA' => Icons.home,
      'UTILITAS' => Icons.bolt,
      'LAINNYA' => Icons.more_horiz,
      _ => Icons.receipt,
    };
  }

  Color getCategoryColor(String category) {
    return switch (category) {
      'BAHAN_BAKU' => Colors.orange,
      'OPERASIONAL' => Colors.blue,
      'GAJI' => Colors.purple,
      'SEWA' => Colors.teal,
      'UTILITAS' => Colors.amber,
      'LAINNYA' => Colors.grey,
      _ => Colors.grey,
    };
  }
}
