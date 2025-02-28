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
    final ordersData = json['orders'];
    final List<OrderModel> ordersList = [];
    
    if (ordersData != null && ordersData['data'] != null) {
      ordersList.addAll((ordersData['data'] as List)
          .map((order) => OrderModel.fromJson(order as Map<String, dynamic>)));
    }

    return PaginatedOrderResponse(
      orders: ordersList,
      stats: OrderStatsModel.fromJson(json['status_counts'] ?? {}),
      summary: OrderSummaryModel.fromJson(json),
      hasMore: ordersData != null && 
               ordersData['current_page'] != null && 
               ordersData['last_page'] != null &&
               int.parse(ordersData['current_page'].toString()) < int.parse(ordersData['last_page'].toString()),
      currentPage: int.parse(ordersData?['current_page']?.toString() ?? '1'),
      lastPage: int.parse(ordersData?['last_page']?.toString() ?? '1'),
      total: int.parse(ordersData?['total']?.toString() ?? '0'),
    );
  }
}
