import 'order_model.dart';
import 'order_summary_model.dart';

class PaginatedOrderResponse {
  final List<OrderModel> orders;
  final OrderStatsModel stats;
  final OrderSummaryModel summary;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedOrderResponse({
    required this.orders,
    required this.stats,
    required this.summary,
    required this.hasMore,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginatedOrderResponse.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;
      final ordersData = data['orders'] as Map<String, dynamic>;
      final List<OrderModel> ordersList = [];
      
      if (ordersData['data'] != null) {
        ordersList.addAll((ordersData['data'] as List)
            .map((order) => OrderModel.fromJson(order as Map<String, dynamic>)));
      }

      // Handle status_counts properly
      final statusCountsData = data['status_counts'];
      Map<String, dynamic> statusCounts = {};
      if (statusCountsData is Map) {
        statusCountsData.forEach((key, value) {
          if (value != null) {
            // Convert any numeric value to string first, then parse to int
            statusCounts[key] = int.tryParse(value.toString()) ?? 0;
          } else {
            statusCounts[key] = 0;
          }
        });
      }

      return PaginatedOrderResponse(
        orders: ordersList,
        stats: OrderStatsModel.fromJson(statusCounts),
        summary: OrderSummaryModel.fromJson(data),
        hasMore: ordersData['current_page'] != null && 
                 ordersData['last_page'] != null &&
                 int.parse(ordersData['current_page'].toString()) < int.parse(ordersData['last_page'].toString()),
        currentPage: int.parse(ordersData['current_page']?.toString() ?? '1'),
        lastPage: int.parse(ordersData['last_page']?.toString() ?? '1'),
        total: int.parse(ordersData['total']?.toString() ?? '0'),
      );
    } catch (e, stackTrace) {
      print('Error parsing PaginatedOrderResponse: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
