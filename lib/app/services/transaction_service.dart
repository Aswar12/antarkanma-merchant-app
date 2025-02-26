import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../data/models/transaction_model.dart';
import '../data/providers/transaction_provider.dart';

class OrderResult {
  final List<TransactionModel> orders;
  final Map<String, int> stats;
  final bool hasMore;

  OrderResult({
    required this.orders,
    required this.stats,
    required this.hasMore,
  });
}

class TransactionService extends GetxService {
  final TransactionProvider _transactionProvider;
  final GetStorage _storage;

  TransactionService({
    required TransactionProvider transactionProvider,
    required GetStorage storage,
  })  : _transactionProvider = transactionProvider,
        _storage = storage;

  String get _token => _storage.read('token') ?? '';
  int get _merchantId => _storage.read('merchant_id') ?? 0;

  Future<List<TransactionModel>> getPendingTransactions() async {
    try {
      final response = await _transactionProvider.getPendingOrders(_token, _merchantId);
      if (response.data != null && response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting pending transactions: $e');
      return [];
    }
  }

  Future<OrderResult> getOrders({
    required List<int> orderIds,
    required int page,
    String? status,
  }) async {
    try {
      final response = await _transactionProvider.getOrders(
        _token,
        merchantId: _merchantId,
        orderIds: orderIds, // Pass the orderIds parameter correctly
        page: page,
        status: status,
      );

      print('API Response: ${response.data}'); // Debugging line

      if (response.data != null) {
        final orders = (response.data['data'] as List? ?? [])
            .map((json) => TransactionModel.fromJson(json))
            .toList();

        final stats = Map<String, int>.from(response.data['stats'] ?? {});
        final hasMore = response.data['has_more'] ?? false;

        return OrderResult(
          orders: orders,
          stats: stats,
          hasMore: hasMore,
        );
      }

      return OrderResult(
        orders: [],
        stats: {},
        hasMore: false,
      );
    } catch (e) {
      print('Error getting orders: $e');
      return OrderResult(
        orders: [],
        stats: {},
        hasMore: false,
      );
    }
  }

  Future<void> approveOrder(dynamic orderId) async {
    try {
      await _transactionProvider.approveOrder(_token, orderId as int, _merchantId);
    } catch (e) {
      print('Error approving order: $e');
      rethrow;
    }
  }

  Future<void> rejectOrder(dynamic orderId, {String? reason}) async {
    try {
      await _transactionProvider.rejectOrder(_token, orderId as int, _merchantId, reason: reason);
    } catch (e) {
      print('Error rejecting order: $e');
      rethrow;
    }
  }

  Future<void> markOrderReady(dynamic orderId) async {
    try {
      await _transactionProvider.markOrderReady(_token, orderId as int, _merchantId);
    } catch (e) {
      print('Error marking order as ready: $e');
      rethrow;
    }
  }

  Future<void> saveAutoApprove(bool value) async {
    await _storage.write('auto_approve', value);
  }

  bool getAutoApprove() {
    return _storage.read('auto_approve') ?? false;
  }
}
