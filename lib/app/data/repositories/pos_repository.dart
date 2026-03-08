import 'package:flutter/material.dart';
import '../models/pos_transaction_model.dart';
import '../models/product_model.dart';
import '../providers/pos_provider.dart';

class PosRepository {
  final PosProvider _provider = PosProvider();

  /// Get products for POS grid
  Future<List<ProductModel>?> getProducts({
    String? categoryId,
    String? search,
  }) async {
    try {
      final response = await _provider.getProducts(
        categoryId: categoryId,
        search: search,
      );
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final productsData = response.data['data'] as List;
        return productsData.map((json) => ProductModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting POS products: $e');
      return null;
    }
  }

  /// Create a POS transaction
  Future<PosTransactionModel?> createTransaction(
      Map<String, dynamic> data) async {
    try {
      final response = await _provider.createTransaction(data);
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        return PosTransactionModel.fromJson(response.data['data']);
      }
      // Extract and log validation / error message from backend
      final errorMsg = response.data?['meta']?['message'] ??
          response.data?['message'] ??
          'Unknown error (${response.statusCode})';
      debugPrint('POS Transaction failed: $errorMsg');
      debugPrint('Response data: ${response.data}');
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('Error creating POS transaction: $e');
      rethrow;
    }
  }

  /// Get POS transaction history
  Future<List<PosTransactionModel>?> getTransactions({
    int page = 1,
    String? orderType,
    String? status,
    String? from,
    String? to,
    String? search,
  }) async {
    try {
      final response = await _provider.getTransactions(
        page: page,
        orderType: orderType,
        status: status,
        from: from,
        to: to,
        search: search,
      );
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        final data = response.data['data']['data'] as List;
        return data.map((json) => PosTransactionModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting POS transactions: $e');
      return null;
    }
  }

  /// Get single transaction detail
  Future<PosTransactionModel?> getTransaction(int id) async {
    try {
      final response = await _provider.getTransaction(id);
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        return PosTransactionModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting POS transaction detail: $e');
      return null;
    }
  }

  /// Void a transaction
  Future<bool> voidTransaction(int id) async {
    try {
      final response = await _provider.voidTransaction(id);
      return response.statusCode == 200 &&
          response.data['meta']['status'] == 'success';
    } catch (e) {
      debugPrint('Error voiding POS transaction: $e');
      return false;
    }
  }

  /// Get daily summary
  Future<Map<String, dynamic>?> getDailySummary({String? date}) async {
    try {
      final response = await _provider.getDailySummary(date: date);
      if (response.statusCode == 200 &&
          response.data['meta']['status'] == 'success') {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting daily summary: $e');
      return null;
    }
  }
}
