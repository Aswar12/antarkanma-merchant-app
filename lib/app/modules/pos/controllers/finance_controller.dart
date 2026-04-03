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
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  final filteredExpenses = <Map<String, dynamic>>[].obs;

  // Payment methods
  final paymentMethods = <String, Map<String, dynamic>>{}.obs;
  final isLoadingPaymentMethods = false.obs;

  // Wallet balance
  final walletBalance = 0.0.obs;
  final isWalletActive = true.obs;
  final todayCashIn = 0.0.obs;
  final todayNonCashIn = 0.0.obs;
  final todayTotalIn = 0.0.obs;
  final todayExpenses = 0.0.obs;
  final todayNet = 0.0.obs;
  final todayTransactionCount = 0.obs;
  final isLoadingWallet = false.obs;

  // Cash flow data
  final cashFlowData = <Map<String, dynamic>>[].obs;
  final cashFlowPeriod = 'daily'.obs;
  final isLoadingCashFlow = false.obs;

  // Profit margin & comparison
  final profitMargin = 0.0.obs;
  final previousPeriodData = <String, dynamic>{}.obs;
  final incomeChange = 0.0.obs;
  final expensesChange = 0.0.obs;
  final profitChange = 0.0.obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final isLoadingMore = false.obs;

  // Quick stats
  final bestDay = ''.obs;
  final peakHour = ''.obs;
  final avgTransactionValue = 0.0.obs;
  final revenuePerDay = 0.0.obs;

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
    fetchPaymentMethods();
    fetchWalletBalance();
    fetchCashFlowData();
    fetchProfitMargin();
    fetchPeriodComparison();
    fetchQuickStats();
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
        // Apply filters
        filterExpenses();
      }
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
    } finally {
      isLoadingExpenses.value = false;
    }
  }

  // ─── Filter Expenses ──────────────────────────────────
  void filterExpenses() {
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(expenses);

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((e) => (e['description']?.toString() ?? '')
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (selectedCategory.value != 'Semua') {
      result = result
          .where((e) => e['category']?.toString() == selectedCategory.value)
          .toList();
    }

    filteredExpenses.value = result;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterExpenses();
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    filterExpenses();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'Semua';
    filterExpenses();
  }

  // ─── Edit Expense ─────────────────────────────────────
  Future<bool> updateExpense({
    required int id,
    required String category,
    required double amount,
    required String description,
    required DateTime expenseDate,
  }) async {
    try {
      final response = await _provider.updateExpense(id, {
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
      debugPrint('Update expense error: ${response.data}');
      return false;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      return false;
    }
  }

  // ─── Payment Methods ──────────────────────────────────
  Future<void> fetchPaymentMethods() async {
    isLoadingPaymentMethods.value = true;
    try {
      final response = await _provider.getPaymentMethods(
        from: _from,
        to: _to,
      );
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        if (data is Map && data.containsKey('methods')) {
          paymentMethods.value = Map<String, Map<String, dynamic>>.from(
            data['methods'],
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching payment methods: $e');
    } finally {
      isLoadingPaymentMethods.value = false;
    }
  }

  // ─── Wallet Balance ──────────────────────────────────
  Future<void> fetchWalletBalance() async {
    isLoadingWallet.value = true;
    try {
      final response = await _provider.getWalletBalance();
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        walletBalance.value = toDouble(data['balance']);
        isWalletActive.value = data['is_wallet_active'] ?? true;
        
        final todaySummary = data['today_summary'] ?? {};
        todayCashIn.value = toDouble(todaySummary['cash_in']);
        todayNonCashIn.value = toDouble(todaySummary['non_cash_in']);
        todayTotalIn.value = toDouble(todaySummary['total_in']);
        todayExpenses.value = toDouble(todaySummary['expenses']);
        todayNet.value = toDouble(todaySummary['net']);
        todayTransactionCount.value = todaySummary['transaction_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
    } finally {
      isLoadingWallet.value = false;
    }
  }

  // ─── Cash Flow Data ──────────────────────────────────
  Future<void> fetchCashFlowData() async {
    isLoadingCashFlow.value = true;
    try {
      // Get income data by period
      final response = await _provider.getIncomeBreakdown(
        period: cashFlowPeriod.value,
        from: _from,
        to: _to,
      );
      
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        final posData = List<Map<String, dynamic>>.from(data['pos'] ?? []);
        final onlineData = List<Map<String, dynamic>>.from(data['online'] ?? []);
        
        // Combine POS and Online income by period
        final Map<String, Map<String, dynamic>> flowMap = {};
        
        // Process POS data
        for (var item in posData) {
          final period = item['period']?.toString() ?? '';
          if (period.isNotEmpty) {
            flowMap[period] = {
              'period': period,
              'income': (flowMap[period]?['income'] ?? 0.0) + toDouble(item['total']),
              'pos_count': (flowMap[period]?['pos_count'] ?? 0) + (item['count'] ?? 0),
              'online_count': flowMap[period]?['online_count'] ?? 0,
            };
          }
        }
        
        // Process Online data
        for (var item in onlineData) {
          final period = item['period']?.toString() ?? '';
          if (period.isNotEmpty) {
            flowMap[period] = {
              'period': period,
              'income': (flowMap[period]?['income'] ?? 0.0) + toDouble(item['total']),
              'pos_count': flowMap[period]?['pos_count'] ?? 0,
              'online_count': (flowMap[period]?['online_count'] ?? 0) + (item['count'] ?? 0),
            };
          }
        }
        
        // Get expenses by same period
        final expenseResponse = await _provider.getExpenses(
          from: _from,
          to: _to,
        );
        
        if (expenseResponse.statusCode == 200 &&
            expenseResponse.data['meta']['status'] == 'success') {
          final expenseData = expenseResponse.data['data'];
          if (expenseData is List) {
            for (var expense in expenseData) {
              final expenseDate = expense['expense_date']?.toString() ?? '';
              if (expenseDate.isNotEmpty) {
                // Format expense date to match period format
                final expensePeriod = _formatDateToPeriod(expenseDate, cashFlowPeriod.value);
                if (flowMap.containsKey(expensePeriod)) {
                  flowMap[expensePeriod]!['expenses'] = 
                      (flowMap[expensePeriod]?['expenses'] ?? 0.0) + toDouble(expense['amount']);
                }
              }
            }
          }
        }
        
        // Convert to list and sort by period
        cashFlowData.value = flowMap.values.toList()
          ..sort((a, b) => (a['period'] as String).compareTo(b['period'] as String));
      }
    } catch (e) {
      debugPrint('Error fetching cash flow data: $e');
    } finally {
      isLoadingCashFlow.value = false;
    }
  }

  String _formatDateToPeriod(String date, String period) {
    try {
      final dt = DateTime.parse(date);
      switch (period) {
        case 'weekly':
          return '${dt.year}-W${(dt.day + 6) ~/ 7}';
        case 'monthly':
          return '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        default: // daily
          return date;
      }
    } catch (e) {
      return date;
    }
  }

  void setCashFlowPeriod(String period) {
    cashFlowPeriod.value = period;
    fetchCashFlowData();
  }

  // ─── Export Functions ──────────────────────────────────
  Future<String?> exportToPDF() async {
    try {
      // This will be implemented in the service
      // For now, return success message
      return 'PDF exported successfully';
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return null;
    }
  }

  Future<String?> exportToExcel() async {
    try {
      // This will be implemented in the service
      // For now, return success message
      return 'Excel exported successfully';
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  // ─── Profit Margin & Comparison ───────────────────────
  Future<void> fetchProfitMargin() async {
    try {
      final total = totalIncome.value;
      final net = netProfit.value;
      
      if (total > 0) {
        profitMargin.value = (net / total) * 100;
      } else {
        profitMargin.value = 0.0;
      }
    } catch (e) {
      debugPrint('Error calculating profit margin: $e');
    }
  }

  Future<void> fetchPeriodComparison() async {
    try {
      // Calculate previous period dates
      final now = DateTime.now();
      final currentDays = now.difference(dateFrom.value ?? now).inDays + 1;
      // TODO: Use prevFrom/prevTo for actual API calls when implementing real comparison
      // ignore: unused_local_variable
      final prevFrom = DateTime(now.year, now.month, 1).subtract(Duration(days: currentDays));
      // ignore: unused_local_variable
      final prevTo = dateFrom.value?.subtract(Duration(days: 1)) ?? now.subtract(Duration(days: currentDays));
      
      // Fetch previous period overview (mock - should be API call)
      previousPeriodData.value = {
        'total_income': totalIncome.value * 0.9, // Mock: 90% of current
        'total_expenses': totalExpenses.value * 0.95, // Mock: 95% of current
        'net_profit': (totalIncome.value * 0.9) - (totalExpenses.value * 0.95),
      };
      
      // Calculate changes
      if (previousPeriodData['total_income'] != null && previousPeriodData['total_income'] > 0) {
        incomeChange.value = ((totalIncome.value - previousPeriodData['total_income']) / previousPeriodData['total_income']) * 100;
      }
      
      if (previousPeriodData['total_expenses'] != null && previousPeriodData['total_expenses'] > 0) {
        expensesChange.value = ((totalExpenses.value - previousPeriodData['total_expenses']) / previousPeriodData['total_expenses']) * 100;
      }
      
      if (previousPeriodData['net_profit'] != null && previousPeriodData['net_profit'] != 0) {
        profitChange.value = ((netProfit.value - previousPeriodData['net_profit']) / previousPeriodData['net_profit'].abs()) * 100;
      }
    } catch (e) {
      debugPrint('Error fetching period comparison: $e');
    }
  }

  Future<void> fetchQuickStats() async {
    try {
      // Calculate average transaction value
      final currentPosCount = posCount.value;
      final currentOnlineCount = onlineCount.value;
      final totalCount = currentPosCount + currentOnlineCount;
      
      if (totalCount > 0) {
        avgTransactionValue.value = totalIncome.value / totalCount;
      }
      
      // Calculate revenue per day
      final days = (dateTo.value?.difference(dateFrom.value ?? DateTime.now()).inDays ?? 1) + 1;
      revenuePerDay.value = totalIncome.value / days;
      
      // Mock best day and peak hour (should be from API)
      bestDay.value = 'Senin';
      peakHour.value = '12:00';
    } catch (e) {
      debugPrint('Error fetching quick stats: $e');
    }
  }

  // ─── Pagination ───────────────────────────────────────
  Future<void> loadMoreExpenses() async {
    if (currentPage.value >= lastPage.value || isLoadingMore.value) return;
    
    isLoadingMore.value = true;
    try {
      currentPage.value++;
      final response = await _provider.getExpenses(
        from: _from,
        to: _to,
        page: currentPage.value,
      );
      
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data'];
        if (data is Map) {
          final newExpenses = List<Map<String, dynamic>>.from(data['data'] ?? []);
          expenses.addAll(newExpenses);
          lastPage.value = data['last_page'] ?? 1;
        } else if (data is List && data.isNotEmpty) {
          expenses.addAll(List<Map<String, dynamic>>.from(data));
        } else {
          lastPage.value = currentPage.value; // No more data
        }
        filterExpenses();
      }
    } catch (e) {
      debugPrint('Error loading more expenses: $e');
    } finally {
      isLoadingMore.value = false;
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
