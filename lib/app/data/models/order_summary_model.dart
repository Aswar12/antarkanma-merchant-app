class OrderStatsModel {
  final Map<String, int> statusCounts;

  OrderStatsModel({
    required this.statusCounts,
  });

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) {
    return OrderStatsModel(
      statusCounts: Map<String, int>.from(json),
    );
  }
}

class OrderSummaryModel {
  final Map<String, int> statusCounts;
  final OrderTotalSummaryModel summary;

  OrderSummaryModel({
    required this.statusCounts,
    required this.summary,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      statusCounts: Map<String, int>.from(json['status_counts'] ?? {}),
      summary: OrderTotalSummaryModel.fromJson(json['summary'] ?? {}),
    );
  }
}

class OrderTotalSummaryModel {
  final int totalOrders;
  final int totalCompleted;
  final int totalProcessing;
  final int totalPending;
  final int totalCanceled;

  OrderTotalSummaryModel({
    required this.totalOrders,
    required this.totalCompleted,
    required this.totalProcessing,
    required this.totalPending,
    required this.totalCanceled,
  });

  factory OrderTotalSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderTotalSummaryModel(
      totalOrders: json['total_orders'] ?? 0,
      totalCompleted: json['total_completed'] ?? 0,
      totalProcessing: json['total_processing'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      totalCanceled: json['total_canceled'] ?? 0,
    );
  }
}
