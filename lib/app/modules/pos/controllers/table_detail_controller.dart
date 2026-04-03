import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/models/table_activity_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/services/pos_api_service.dart';

class TableDetailController extends GetxController {
  final PosApiService _api = PosApiService.instance;

  final table = Rxn<MerchantTableModel>();
  final readyToRelease = Rxn<TableReadyToRelease>();
  final isLoading = false.obs;
  final isProcessing = false.obs;

  Future<void> loadTable(MerchantTableModel t) async {
    table.value = t;
    if (t.isOccupied && t.currentPosTransactionId != null) {
      await _loadReadyToRelease(t.currentPosTransactionId!);
    }
  }

  Future<void> _loadReadyToRelease(int transactionId) async {
    try {
      isLoading.value = true;
      final result = await _api.getTablesReadyToRelease();
      readyToRelease.value = result.where((r) => r.transactionId == transactionId).firstOrNull;
    } catch (e) {
      debugPrint('Error loading ready to release: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> releaseTable() async {
    final t = table.value;
    if (t == null) return false;
    try {
      isProcessing.value = true;
      await _api.releaseTable(t.id!);
      Get.snackbar(
        'Berhasil',
        'Meja berhasil dikosongkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
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

  Future<bool> extendDuration(int transactionId, int minutes) async {
    try {
      isProcessing.value = true;
      await _api.extendDuration(transactionId, minutes);
      Get.snackbar(
        'Berhasil',
        'Durasi ditambah $minutes menit',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menambah durasi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> markFoodCompleted(int transactionId) async {
    try {
      isProcessing.value = true;
      await _api.markFoodCompleted(transactionId);
      Get.snackbar(
        'Berhasil',
        'Makanan ditandai sudah disajikan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menandai makanan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // Generate QR code data for table
  Map<String, dynamic> getQrData(int merchantId) {
    final t = table.value;
    if (t == null) return {};
    return {
      'type': 'pos_order',
      'table_id': t.id,
      'merchant_id': merchantId,
    };
  }
}
