import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/models/table_activity_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/services/pos_api_service.dart';

class TableManagementController extends GetxController {
  final PosApiService _api = PosApiService.instance;

  final tables = <MerchantTableModel>[].obs;
  final tablesReadyToRelease = <TableReadyToRelease>[].obs;
  final isLoadingTables = false.obs;
  final isLoadingReadyToRelease = false.obs;
  final isProcessing = false.obs;

  final filterStatus = 'ALL'.obs;
  Timer? _refreshTimer;

  static const List<String> filterOptions = ['ALL', 'AVAILABLE', 'OCCUPIED', 'RESERVED'];

  @override
  void onInit() {
    super.onInit();
    fetchTables();
    fetchTablesReadyToRelease();
    _startPolling();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchTables();
      fetchTablesReadyToRelease();
    });
  }

  List<MerchantTableModel> get filteredTables {
    if (filterStatus.value == 'ALL') return tables;
    return tables.where((t) => t.status == filterStatus.value).toList();
  }

  void setFilter(String status) => filterStatus.value = status;

  Future<void> fetchTables() async {
    try {
      isLoadingTables.value = true;
      final result = await _api.getTables();
      tables.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching tables: $e');
    } finally {
      isLoadingTables.value = false;
    }
  }

  Future<void> fetchTablesReadyToRelease() async {
    try {
      isLoadingReadyToRelease.value = true;
      final result = await _api.getTablesReadyToRelease();
      tablesReadyToRelease.assignAll(result);
    } catch (e) {
      debugPrint('Error fetching ready to release: $e');
    } finally {
      isLoadingReadyToRelease.value = false;
    }
  }

  Future<void> addTable(String tableNumber, int capacity) async {
    try {
      isProcessing.value = true;
      await _api.createTable(tableNumber: tableNumber, capacity: capacity);
      Get.snackbar(
        'Berhasil',
        'Meja $tableNumber berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      await fetchTables();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().contains('Exception') ? e.toString().replaceAll('Exception: ', '') : 'Terjadi kesalahan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> updateTable(int tableId, {String? tableNumber, int? capacity}) async {
    try {
      isProcessing.value = true;
      await _api.updateTable(tableId, tableNumber: tableNumber, capacity: capacity);
      Get.snackbar(
        'Berhasil',
        'Meja berhasil diperbarui',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      await fetchTables();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat memperbarui meja',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> deleteTable(int tableId) async {
    try {
      isProcessing.value = true;
      await _api.deleteTable(tableId);
      Get.snackbar(
        'Berhasil',
        'Meja berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      await fetchTables();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menghapus meja',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> releaseTable(int tableId) async {
    try {
      isProcessing.value = true;
      await _api.releaseTable(tableId);
      Get.snackbar(
        'Berhasil',
        'Meja berhasil dikosongkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      await fetchTables();
      await fetchTablesReadyToRelease();
      return true;
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengosongkan meja',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  int get totalTables => tables.length;
  int get availableCount => tables.where((t) => t.isAvailable).length;
  int get occupiedCount => tables.where((t) => t.isOccupied).length;
  int get reservedCount => tables.where((t) => t.isReserved).length;
}
