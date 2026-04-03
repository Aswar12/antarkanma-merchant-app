import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/modules/pos/models/merchant_config_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/services/pos_api_service.dart';

class TableSettingsController extends GetxController {
  final PosApiService _api = PosApiService.instance;

  final isLoading = false.obs;
  final isSaving = false.obs;
  final config = Rxn<MerchantConfigModel>();

  // Form values
  final paymentFlow = MerchantConfigModel.payFirst.obs;
  final autoReleaseTable = false.obs;
  final defaultDineDuration = 60.obs;

  static const List<int> durationOptions = [15, 30, 45, 60, 90, 120];

  @override
  void onInit() {
    super.onInit();
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    try {
      isLoading.value = true;
      final result = await _api.getMerchantConfig();
      config.value = result;
      paymentFlow.value = result.paymentFlow;
      autoReleaseTable.value = result.autoReleaseTable;
      defaultDineDuration.value = result.defaultDineDuration;
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat memuat pengaturan meja',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveConfig() async {
    try {
      isSaving.value = true;
      final updated = await _api.updateMerchantConfig(
        paymentFlow: paymentFlow.value,
        autoReleaseTable: autoReleaseTable.value,
        defaultDineDuration: defaultDineDuration.value,
      );
      config.value = updated;
      Get.snackbar(
        'Berhasil',
        'Pengaturan berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyimpan pengaturan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void setPaymentFlow(String value) => paymentFlow.value = value;
  void toggleAutoRelease(bool value) => autoReleaseTable.value = value;
  void setDineDuration(int value) => defaultDineDuration.value = value;

  String get durationDisplay {
    final mins = defaultDineDuration.value;
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      if (m == 0) return '$h jam';
      return '$h jam $m menit';
    }
    return '$mins menit';
  }
}
