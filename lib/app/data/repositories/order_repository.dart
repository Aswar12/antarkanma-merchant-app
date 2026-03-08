import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/app/data/models/order_summary_model.dart';
import 'package:antarkanma_merchant/app/data/models/paginated_order_response.dart';
import 'package:antarkanma_merchant/app/services/transaction_service.dart';

class OrderRepository {
  final TransactionService _transactionService = Get.find<TransactionService>();

  /// Get paginated merchant orders with filters
  Future<PaginatedOrderResponse> getOrders({
    int page = 1,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    try {
      return await _transactionService.getOrders(
        page: page,
        status: status,
        startDate: startDate,
        endDate: endDate,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } catch (e) {
      debugPrint('❌ [OrderRepository] getOrders error: $e');
      rethrow;
    }
  }

  /// Get a single order by ID
  Future<OrderModel?> getOrderById(dynamic orderId) async {
    try {
      return await _transactionService.getOrderById(orderId);
    } catch (e) {
      debugPrint('❌ [OrderRepository] getOrderById error: $e');
      rethrow;
    }
  }

  /// Approve an order
  Future<void> approveOrder(dynamic orderId) async {
    try {
      await _transactionService.approveOrder(orderId);
    } catch (e) {
      debugPrint('❌ [OrderRepository] approveOrder error: $e');
      rethrow;
    }
  }

  /// Reject an order with reason
  Future<void> rejectOrder(dynamic orderId, {String? reason}) async {
    try {
      await _transactionService.rejectOrder(orderId, reason: reason);
    } catch (e) {
      debugPrint('❌ [OrderRepository] rejectOrder error: $e');
      rethrow;
    }
  }

  /// Mark order as ready for pickup
  Future<void> markOrderReady(dynamic orderId) async {
    try {
      await _transactionService.markOrderReady(orderId);
    } catch (e) {
      debugPrint('❌ [OrderRepository] markOrderReady error: $e');
      rethrow;
    }
  }

  /// Mark order as picked up by courier
  Future<void> markOrderPickedUp(dynamic orderId) async {
    try {
      await _transactionService.markOrderPickedUp(orderId);
    } catch (e) {
      debugPrint('❌ [OrderRepository] markOrderPickedUp error: $e');
      rethrow;
    }
  }

  /// Get order summary/statistics
  Future<OrderSummaryModel?> getOrderSummary() async {
    try {
      return await _transactionService.getOrderSummary();
    } catch (e) {
      debugPrint('❌ [OrderRepository] getOrderSummary error: $e');
      rethrow;
    }
  }
}
