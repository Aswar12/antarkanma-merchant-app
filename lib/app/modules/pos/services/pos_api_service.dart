import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';
import 'package:antarkanma_merchant/app/data/providers/pos_provider.dart';
import 'package:antarkanma_merchant/app/modules/pos/models/merchant_config_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/models/table_activity_model.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';

class PosApiService {
  static PosApiService? _instance;
  late final Dio _dio;

  PosApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000/api',
      connectTimeout: const Duration(milliseconds: 45000),
      receiveTimeout: const Duration(milliseconds: 45000),
      validateStatus: (status) => status != null && status < 500,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = StorageService.instance;
        final token = storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        debugPrint('POS API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('POS API Response [${response.statusCode}]: ${response.data}');
        if (response.statusCode == 401) {
          StorageService.instance.clearAuth();
          Get.offAllNamed('/login');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('POS API Error: ${error.message}');
        debugPrint('POS API Error Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  static PosApiService get instance {
    _instance ??= PosApiService._();
    return _instance!;
  }

  // ─── Merchant Config ───────────────────────────────────

  Future<MerchantConfigModel> getMerchantConfig() async {
    final response = await _dio.get('/merchant/pos/merchant-config');
    if (response.data['success'] == true) {
      return MerchantConfigModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to get merchant config');
  }

  Future<MerchantConfigModel> updateMerchantConfig({
    String? paymentFlow,
    bool? autoReleaseTable,
    int? defaultDineDuration,
  }) async {
    final response = await _dio.put(
      '/merchant/pos/merchant-config',
      data: {
        if (paymentFlow != null) 'payment_flow': paymentFlow,
        if (autoReleaseTable != null) 'auto_release_table': autoReleaseTable,
        if (defaultDineDuration != null) 'default_dine_duration': defaultDineDuration,
      },
    );
    if (response.data['success'] == true) {
      return MerchantConfigModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to update merchant config');
  }

  // ─── Tables ────────────────────────────────────────────

  Future<List<MerchantTableModel>> getTables() async {
    final response = await _dio.get('/merchant/pos/tables');
    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((json) => MerchantTableModel.fromJson(json)).toList();
    }
    throw Exception('Failed to get tables');
  }

  Future<MerchantTableModel> createTable({
    required String tableNumber,
    required int capacity,
  }) async {
    final response = await _dio.post(
      '/merchant/pos/tables',
      data: {
        'table_number': tableNumber,
        'capacity': capacity,
      },
    );
    if (response.data['success'] == true) {
      return MerchantTableModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to create table');
  }

  Future<MerchantTableModel> updateTable(
    int tableId, {
    String? tableNumber,
    int? capacity,
  }) async {
    final response = await _dio.put(
      '/merchant/pos/tables/$tableId',
      data: {
        if (tableNumber != null) 'table_number': tableNumber,
        if (capacity != null) 'capacity': capacity,
      },
    );
    if (response.data['success'] == true) {
      return MerchantTableModel.fromJson(response.data['data']);
    }
    throw Exception('Failed to update table');
  }

  Future<void> deleteTable(int tableId) async {
    final response = await _dio.delete('/merchant/pos/tables/$tableId');
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to delete table');
    }
  }

  // ─── Table Actions ─────────────────────────────────────

  Future<MerchantTableModel> releaseTable(int tableId) async {
    final response = await _dio.post('/merchant/pos/tables/$tableId/release');
    if (response.data['success'] == true) {
      return MerchantTableModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to release table');
  }

  Future<PosTransactionModel> extendDuration(int transactionId, int minutes) async {
    final response = await _dio.post(
      '/merchant/pos/transactions/$transactionId/extend',
      data: {'minutes': minutes},
    );
    if (response.data['success'] == true) {
      return PosTransactionModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to extend duration');
  }

  Future<PosTransactionModel> markFoodCompleted(int transactionId) async {
    final response = await _dio.post(
      '/merchant/pos/transactions/$transactionId/food-completed',
    );
    if (response.data['success'] == true) {
      return PosTransactionModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Failed to mark food completed');
  }

  Future<List<TableReadyToRelease>> getTablesReadyToRelease() async {
    final response = await _dio.get('/merchant/pos/tables/ready-to-release');
    if (response.data['success'] == true) {
      final data = response.data['data'] as List;
      return data.map((json) => TableReadyToRelease.fromJson(json)).toList();
    }
    throw Exception('Failed to get tables ready to release');
  }

  // ─── Activity History ──────────────────────────────────

  Future<List<TableActivityModel>> getActivityHistory({
    int days = 7,
    int? tableId,
    int? transactionId,
    String? type,
  }) async {
    final response = await _dio.get(
      '/merchant/pos/activity',
      queryParameters: {
        'days': days,
        if (tableId != null) 'table_id': tableId,
        if (transactionId != null) 'transaction_id': transactionId,
        if (type != null) 'type': type,
      },
    );
    if (response.data['success'] == true) {
      final data = response.data['data']['data'] as List;
      return data.map((json) => TableActivityModel.fromJson(json)).toList();
    }
    throw Exception('Failed to get activity history');
  }
}
