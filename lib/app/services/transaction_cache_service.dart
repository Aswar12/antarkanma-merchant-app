import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:flutter/foundation.dart';

class TransactionCacheService extends GetxService {
  static TransactionCacheService get to => Get.find();
  final StorageService _storage = StorageService.instance;

  // Cache keys
  static const String _merchantTransactionsKey = 'merchant_transactions';
  static const String _merchantTransactionsTimestampKey = 'merchant_transactions_timestamp';
  static const String _merchantTransactionsFilterKey = 'merchant_transactions_filter';
  
  // Cache duration (30 minutes in milliseconds)
  static const int _cacheDuration = 1800000; // 30 * 60 * 1000

  // Save merchant transactions to cache
  Future<void> saveMerchantTransactions(
    List<TransactionModel> transactions,
    String? filterStatus,
  ) async {
    try {
      debugPrint('\n=== Saving Transactions to Cache ===');
      debugPrint('Transactions count: ${transactions.length}');
      debugPrint('Filter status: $filterStatus');

      // Convert transactions to JSON
      final transactionsJson = transactions.map((t) => t.toJson()).toList();

      // Save transactions
      await _storage.saveList(_merchantTransactionsKey, transactionsJson);

      // Save timestamp
      await _storage.saveInt(
        _merchantTransactionsTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      // Save filter status
      if (filterStatus != null) {
        await _storage.saveString(_merchantTransactionsFilterKey, filterStatus);
      } else {
        await _storage.remove(_merchantTransactionsFilterKey);
      }

      debugPrint('Successfully saved transactions to cache');
    } catch (e) {
      debugPrint('Error saving transactions to cache: $e');
    }
  }

  // Get merchant transactions from cache
  List<TransactionModel>? getMerchantTransactions(String? filterStatus) {
    try {
      debugPrint('\n=== Getting Transactions from Cache ===');
      debugPrint('Requested filter status: $filterStatus');

      // Check if cache exists
      if (!_storage.hasKey(_merchantTransactionsKey)) {
        debugPrint('No cached transactions found');
        return null;
      }

      // Check cache age
      final timestamp = _storage.getInt(_merchantTransactionsTimestampKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > _cacheDuration) {
        debugPrint('Cache expired (age: ${age}ms)');
        clearMerchantTransactions();
        return null;
      }

      // Check if filter matches
      final cachedFilter = _storage.getString(_merchantTransactionsFilterKey);
      if (filterStatus != null && filterStatus != cachedFilter) {
        debugPrint('Cache filter mismatch (cached: $cachedFilter, requested: $filterStatus)');
        return null;
      }

      // Get cached transactions
      final data = _storage.getList(_merchantTransactionsKey);
      if (data == null) {
        debugPrint('Failed to get transactions from cache');
        return null;
      }

      // Convert JSON to TransactionModel objects
      final transactions = data.map((json) {
        try {
          return TransactionModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing cached transaction: $e');
          return null;
        }
      }).where((t) => t != null).cast<TransactionModel>().toList();

      debugPrint('Successfully retrieved ${transactions.length} transactions from cache');
      return transactions;
    } catch (e) {
      debugPrint('Error getting transactions from cache: $e');
      return null;
    }
  }

  // Clear merchant transactions cache
  Future<void> clearMerchantTransactions() async {
    try {
      debugPrint('\n=== Clearing Transactions Cache ===');
      await _storage.remove(_merchantTransactionsKey);
      await _storage.remove(_merchantTransactionsTimestampKey);
      await _storage.remove(_merchantTransactionsFilterKey);
      debugPrint('Successfully cleared transactions cache');
    } catch (e) {
      debugPrint('Error clearing transactions cache: $e');
    }
  }

  // Check if cache is valid
  bool isCacheValid(String? filterStatus) {
    if (!_storage.hasKey(_merchantTransactionsKey)) return false;

    final timestamp = _storage.getInt(_merchantTransactionsTimestampKey) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > _cacheDuration) return false;

    final cachedFilter = _storage.getString(_merchantTransactionsFilterKey);
    if (filterStatus != null && filterStatus != cachedFilter) return false;

    return true;
  }

  // Get cache age in milliseconds
  int getCacheAge() {
    final timestamp = _storage.getInt(_merchantTransactionsTimestampKey) ?? 0;
    return DateTime.now().millisecondsSinceEpoch - timestamp;
  }

  // Get cached filter status
  String? getCachedFilterStatus() {
    return _storage.getString(_merchantTransactionsFilterKey);
  }
}
