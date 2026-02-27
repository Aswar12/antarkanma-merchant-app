import 'package:get_storage/get_storage.dart';
import '../data/providers/transaction_provider.dart';
import '../data/models/transaction_model.dart' as transaction;
import '../data/models/order_model.dart';
import '../data/models/order_summary_model.dart';
import '../data/models/paginated_order_response.dart';
import 'package:dio/dio.dart';

class TransactionService {
  final TransactionProvider _transactionProvider;
  final GetStorage _storage;
  static const String _autoApproveKey = 'auto_approve_enabled';

  TransactionService({
    TransactionProvider? transactionProvider,
    GetStorage? storage,
  })  : _transactionProvider = transactionProvider ?? TransactionProvider(),
        _storage = storage ?? GetStorage();

  Future<Response> getMerchantOrders({
    required int page,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    try {
      return await _transactionProvider.getMerchantOrders(
        page: page,
        status: status,
        startDate: startDate,
        endDate: endDate,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
    } catch (e) {
      print('Error getting merchant orders: $e');
      rethrow;
    }
  }

  Future<List<transaction.TransactionModel>> getPendingTransactions() async {
    try {
      final response = await _transactionProvider.getPendingTransactions();
      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => transaction.TransactionModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting pending transactions: $e');
      return [];
    }
  }

  Future<PaginatedOrderResponse> getOrders({
    List<int>? orderIds,
    int page = 1,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    try {
      final response = await getMerchantOrders(
        page: page,
        status: status,
        startDate: startDate,
        endDate: endDate,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      if (response.data is! Map) {
        throw Exception('Invalid response format: expected Map, got ${response.data.runtimeType}');
      }

      final responseData = response.data as Map<String, dynamic>;
      if (!responseData.containsKey('data')) {
        throw Exception('Response missing data field');
      }

      final data = responseData['data'];

      // Handle case where 'data' could be either Map or List
      if (data is! Map<String, dynamic>) {
        print('Warning: data is not a Map, it is ${data.runtimeType}');
        return PaginatedOrderResponse(
          orders: [],
          stats: OrderStatsModel(statusCounts: {}),
          summary: OrderSummaryModel(
              statusCounts: {},
              summary: OrderTotalSummaryModel(
                  totalOrders: 0,
                  totalCompleted: 0,
                  totalProcessing: 0,
                  totalPending: 0,
                  totalCanceled: 0)),
          hasMore: false,
          currentPage: 1,
          lastPage: 1,
          total: 0,
        );
      }

      final ordersData = data['orders'];

      // Handle case where orders could be either Map or List
      if (ordersData is! Map<String, dynamic>) {
        print('Warning: orders is not a Map, it is ${ordersData.runtimeType}');
        return PaginatedOrderResponse(
          orders: [],
          stats: OrderStatsModel(statusCounts: {}),
          summary: OrderSummaryModel(
              statusCounts: {},
              summary: OrderTotalSummaryModel(
                  totalOrders: 0,
                  totalCompleted: 0,
                  totalProcessing: 0,
                  totalPending: 0,
                  totalCanceled: 0)),
          hasMore: false,
          currentPage: 1,
          lastPage: 1,
          total: 0,
        );
      }
      
      final List<OrderModel> ordersList = [];

      if (ordersData['data'] != null) {
        final List<dynamic> ordersJsonList = ordersData['data'] as List;
        ordersList.addAll(ordersJsonList
            .map((orderJson) => OrderModel.fromJson(orderJson as Map<String, dynamic>))
            .toList());
      }

      return PaginatedOrderResponse(
        orders: ordersList,
        stats: OrderStatsModel(statusCounts: Map<String, int>.from(data['status_counts'] ?? {})),
        summary: OrderSummaryModel(
          statusCounts: Map<String, int>.from(data['status_counts'] ?? {}),
          summary: OrderTotalSummaryModel(
            totalOrders: int.tryParse(data['summary']?['total_orders']?.toString() ?? '0') ?? 0,
            totalCompleted: int.tryParse(data['summary']?['total_completed']?.toString() ?? '0') ?? 0,
            totalProcessing: int.tryParse(data['summary']?['total_processing']?.toString() ?? '0') ?? 0,
            totalPending: int.tryParse(data['summary']?['total_pending']?.toString() ?? '0') ?? 0,
            totalCanceled: int.tryParse(data['summary']?['total_canceled']?.toString() ?? '0') ?? 0,
          ),
        ),
        hasMore: ordersData['current_page'] != null && 
                 ordersData['last_page'] != null &&
                 int.parse(ordersData['current_page'].toString()) < int.parse(ordersData['last_page'].toString()),
        currentPage: int.tryParse(ordersData['current_page']?.toString() ?? '1') ?? 1,
        lastPage: int.tryParse(ordersData['last_page']?.toString() ?? '1') ?? 1,
        total: int.tryParse(ordersData['total']?.toString() ?? '0') ?? 0,
      );
    } catch (e, stackTrace) {
      print('Error getting orders: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> approveOrder(dynamic orderId) async {
    try {
      await _transactionProvider.approveOrder(orderId);
    } catch (e) {
      print('Error approving order: $e');
      rethrow;
    }
  }

  Future<void> rejectOrder(dynamic orderId, {String? reason}) async {
    try {
      await _transactionProvider.rejectOrder(orderId, reason: reason);
    } catch (e) {
      print('Error rejecting order: $e');
      rethrow;
    }
  }

  Future<void> markOrderReady(dynamic orderId) async {
    try {
      await _transactionProvider.markOrderReady(orderId);
    } catch (e) {
      print('Error marking order as ready: $e');
      rethrow;
    }
  }

  Future<OrderSummaryModel> getOrderSummary() async {
    try {
      final response = await _transactionProvider.getOrderSummary();
      if (response.data != null && response.data['data'] != null) {
        return OrderSummaryModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch order summary');
    } catch (e) {
      print('Error fetching order summary: $e');
      rethrow;
    }
  }

  bool getAutoApprove() {
    return _storage.read(_autoApproveKey) ?? false;
  }

  Future<void> saveAutoApprove(bool value) async {
    await _storage.write(_autoApproveKey, value);
  }

  /// Get single order by ID - optimized for notification handling
  /// Used when notification arrives to fetch only the new order
  Future<OrderModel?> getOrderById(dynamic orderId) async {
    try {
      final response = await _transactionProvider.getOrderById(orderId);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData.containsKey('data')) {
          final orderData = responseData['data'] as Map<String, dynamic>;
          return OrderModel.fromJson(orderData);
        }
      }
      return null;
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }

  Future<void> markOrderPickedUp(dynamic orderId) async {
    try {
      await _transactionProvider.markOrderPickedUp(orderId);
    } catch (e) {
      print('Error marking order as picked up: $e');
      rethrow;
    }
  }
}
