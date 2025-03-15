class OrderStatsModel {
  final Map<String, int> statusCounts;

  OrderStatsModel({
    required this.statusCounts,
  });

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) {
    // Convert all values to int
    Map<String, int> counts = {};
    json.forEach((key, value) {
      if (value != null) {
        // Handle both String and int values
        counts[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
      } else {
        counts[key] = 0;
      }
    });
    
    return OrderStatsModel(
      statusCounts: counts,
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
    // Convert status counts to proper int values
    Map<String, int> counts = {};
    if (json['status_counts'] != null) {
      (json['status_counts'] as Map<String, dynamic>).forEach((key, value) {
        if (value != null) {
          counts[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
        } else {
          counts[key] = 0;
        }
      });
    }

    return OrderSummaryModel(
      statusCounts: counts,
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
      totalOrders: _parseIntValue(json['total_orders']),
      totalCompleted: _parseIntValue(json['total_completed']),
      totalProcessing: _parseIntValue(json['total_processing']),
      totalPending: _parseIntValue(json['total_pending']),
      totalCanceled: _parseIntValue(json['total_canceled']),
    );
  }

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
