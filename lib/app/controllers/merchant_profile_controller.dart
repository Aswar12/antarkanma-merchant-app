import 'package:antarkanma_merchant/app/controllers/merchant_controller.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';

class MerchantProfileController extends GetxController {
  final AuthService _authService;
  final MerchantService _merchantService;
  late final MerchantController _merchantController;

  // Observable states
  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var merchantData = Rxn<MerchantModel>();
  var hasError = false.obs;
  var errorMessage = ''.obs;

  MerchantProfileController({
    required AuthService authService,
    required MerchantService merchantService,
  })  : _authService = authService,
        _merchantService = merchantService;

  @override
  void onInit() {
    super.onInit();
    print("MerchantProfileController onInit called");
    _merchantController = Get.find<MerchantController>();

    // Listen to merchant controller's data changes
    ever(_merchantController.merchant, (merchant) {
      if (merchant != null) {
        merchantData.value = merchant;
      }
    });

    // Initialize with current data if available
    if (_merchantController.merchant.value != null) {
      merchantData.value = _merchantController.merchant.value;
    }
  }

  Future<void> fetchMerchantData() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await _merchantService.getMerchant();

      if (data != null) {
        merchantData.value = data;
        print("Merchant data fetched successfully: ${data.name}");
      } else {
        hasError.value = true;
        errorMessage.value = 'Tidak dapat memuat data merchant';
      }
    } catch (e) {
      print("Error fetching merchant data: $e");
      hasError.value = true;
      errorMessage.value = 'Terjadi kesalahan saat memuat data';
    } finally {
      isLoading.value = false;
    }
  }

  void clearMerchantData() {
    merchantData.value = null;
    hasError.value = false;
    errorMessage.value = '';
  }

  Future<bool> updateOperationalHours(
    String openingTime,
    String closingTime,
    List<String> operatingDays,
  ) async {
    try {
      if (openingTime.isEmpty || closingTime.isEmpty || operatingDays.isEmpty) {
        CustomSnackbarX.showError(
          message: 'Semua field harus diisi',
          position: SnackPosition.BOTTOM,
        );
        return false;
      }

      final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
      if (!timeRegex.hasMatch(openingTime) ||
          !timeRegex.hasMatch(closingTime)) {
        CustomSnackbarX.showError(
          message: 'Format waktu tidak valid. Gunakan format HH:mm',
          position: SnackPosition.BOTTOM,
        );
        return false;
      }

      isLoading.value = true;

      final success = await _merchantService.updateOperationalHours(
        openingTime,
        closingTime,
        operatingDays,
      );

      if (success) {
        // Create a new MerchantModel instance with updated values
        if (merchantData.value != null) {
          final updatedMerchant = merchantData.value!.copyWith(
            openingTime: openingTime,
            closingTime: closingTime,
            operatingDays: operatingDays,
            updatedAt: DateTime.now(),
          );

          // Update the merchant data directly
          merchantData.value = updatedMerchant;
        } else {
          CustomSnackbarX.showError(
            message: 'Data merchant tidak tersedia',
            position: SnackPosition.BOTTOM,
          );
          return false;
        }

        CustomSnackbarX.showSuccess(
          message: 'Jam operasional berhasil diperbarui',
          position: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        CustomSnackbarX.showError(
          message: 'Gagal memperbarui jam operasional',
          position: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('Error updating operational hours: $e');
      CustomSnackbarX.showError(
        message: 'Terjadi kesalahan saat memperbarui jam operasional',
        position: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshMerchantData() async {
    await fetchMerchantData();
    update(); // Trigger UI update
  }

  // Getters
  MerchantModel? get merchant => merchantData.value;
  String? get merchantLogo => merchant?.merchantLogoUrl;
  String? get merchantName => merchant?.merchantName;
  String? get merchantDescription => merchant?.description;
  String? get merchantAddress => merchant?.address;
  String? get merchantPhone => merchant?.merchantContact;
  String? get merchantEmail => _authService.currentUser.value?.email;

  void logout() async {
    try {
      await _authService.logout();
      clearMerchantData();
      Get.offAllNamed('/login');
    } catch (e) {
      print("Error during logout: $e");
      CustomSnackbarX.showError(
        message: 'Gagal melakukan logout',
        position: SnackPosition.BOTTOM,
      );
    }
  }
}
