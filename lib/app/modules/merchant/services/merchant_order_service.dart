import 'package:antarkanma_merchant/app/data/providers/merchant_provider.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:get_storage/get_storage.dart';

class MerchantOrderService {
  final MerchantProvider _merchantProvider = MerchantProvider();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService.instance;
  final _storage = GetStorage();

  // Storage keys
  static const String _merchantOrdersKey = 'merchant_orders';
  static const String _orderStatusCountsKey = 'order_status_counts';
  static const Duration ordersCacheExpiration = Duration(minutes: 5);

  DateTime? _lastOrdersFetch;
  String get token => _authService.getToken() ?? '';

  int get currentMerchantId {
    final merchantData = _storageService.getMerchantData();
    return merchantData?['id'] ?? 0;
  }

  Future<Map<String, dynamic>?> getMerchantOrders({
    int? merchantId,
    int page = 1,
    int limit = 10,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final mId = merchantId ?? currentMerchantId;
      if (mId == 0) return null;

      // Check cache if not forcing refresh
      if (!forceRefresh && _lastOrdersFetch != null) {
        final timeSinceLastFetch = DateTime.now().difference(_lastOrdersFetch!);
        if (timeSinceLastFetch < ordersCacheExpiration) {
          final cachedOrders = _storage.read(_merchantOrdersKey);
          final cachedCounts = _storage.read(_orderStatusCountsKey);
          if (cachedOrders != null && cachedCounts != null) {
            return {
              'transactions': {
                'data': cachedOrders,
                'pagination': {
                  'current_page': page,
                  'total': cachedOrders.length,
                }
              },
              'status_counts': cachedCounts,
            };
          }
        }
      }

      final response = await _merchantProvider.getMerchantOrders(
        token,
        mId,
        page: page,
        limit: limit,
        status: status,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
      );

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        final responseData = response.data['data'];

        // Transform the response to match the new structure
        final transformedData = {
          'transactions': responseData['transactions'] ??
              {
                'data': [],
                'pagination': {
                  'current_page': 1,
                  'last_page': 1,
                  'total': 0,
                }
              },
          'status_counts': responseData['status_counts'] ??
              {
                'PENDING': 0,
                'PROCESSING': 0,
                'COMPLETED': 0,
                'CANCELED': 0,
              },
        };

        // Cache the transformed data
        await _storage.write(
            _merchantOrdersKey, transformedData['transactions']['data']);
        await _storage.write(
            _orderStatusCountsKey, transformedData['status_counts']);
        _lastOrdersFetch = DateTime.now();

        return transformedData;
      }

      return null;
    } catch (e) {
      print('Error fetching merchant orders: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      if (currentMerchantId == 0) return false;

      final response = await _merchantProvider.updateOrderStatus(
        token,
        currentMerchantId,
        int.parse(orderId),
        status,
      );

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        // Clear orders cache to force refresh on next fetch
        await clearOrdersCache();
        return true;
      }

      return false;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  Future<void> clearOrdersCache() async {
    await _storage.remove(_merchantOrdersKey);
    await _storage.remove(_orderStatusCountsKey);
    _lastOrdersFetch = null;
  }
}
