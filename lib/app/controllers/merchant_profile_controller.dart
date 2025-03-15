import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/profile_service.dart';
import 'package:latlong2/latlong.dart';

class MerchantProfileController extends GetxController {
  final MerchantService merchantService;
  final AuthService authService;
  final ProfileService profileService;
  final formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Text Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final openingTimeController = TextEditingController();
  final closingTimeController = TextEditingController();

  // Observable variables
  final merchantData = Rxn<MerchantModel>();
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isLoading = false.obs;
  final isUploadingLogo = false.obs;
  final newLogoFile = Rxn<File>();
  final location = Rxn<LatLng>();
  final operatingDays = <String>[].obs;

  // Available operating days
  final List<String> availableDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  // Getters for merchant data
  String? get merchantName => merchantData.value?.name;
  String? get merchantDescription => merchantData.value?.description;
  String? get merchantAddress => merchantData.value?.address;
  String? get merchantPhone => merchantData.value?.phoneNumber;
  String? get merchantLogo => merchantData.value?.logoUrl;
  MerchantModel? get merchant => merchantData.value;

  MerchantProfileController({
    required this.merchantService,
    required this.authService,
    required this.profileService,
  });

  @override
  void onInit() {
    super.onInit();
    fetchMerchantData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    super.onClose();
  }

  void setNewLogo(File file) {
    newLogoFile(file);
  }

  Future<void> pickAndUpdateLogo() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        isUploadingLogo(true);
        
        final success = await profileService.updateMerchantLogo(
          merchant!.id!,
          pickedFile.path,
        );

        if (success) {
          await fetchMerchantData();
          Get.snackbar(
            'Sukses',
            'Logo berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          throw 'Gagal memperbarui logo';
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui logo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingLogo(false);
    }
  }

  Future<void> updateLocation(LatLng newLocation) async {
    try {
      isLoading(true);
      
      final success = await profileService.updateMerchantLocation(
        merchantId: merchant!.id!,
        latitude: newLocation.latitude,
        longitude: newLocation.longitude,
      );

      if (success) {
        location.value = newLocation;
        Get.snackbar(
          'Sukses',
          'Lokasi berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw 'Gagal memperbarui lokasi';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui lokasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateOperatingHours() async {
    try {
      isLoading(true);

      if (openingTimeController.text.isEmpty || closingTimeController.text.isEmpty) {
        throw 'Jam operasional harus diisi';
      }

      if (operatingDays.isEmpty) {
        throw 'Pilih minimal satu hari operasional';
      }

      final success = await profileService.updateOperatingHours(
        merchantId: merchant!.id!,
        openingTime: openingTimeController.text,
        closingTime: closingTimeController.text,
        operatingDays: operatingDays,
      );

      if (success) {
        await fetchMerchantData();
        Get.back();
        Get.snackbar(
          'Sukses',
          'Jam operasional berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw 'Gagal memperbarui jam operasional';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui jam operasional: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMerchantData() async {
    try {
      isLoading(true);
      final merchant = await merchantService.getMerchant();
      if (merchant != null) {
        merchantData(merchant);
        
        // Initialize text controllers with current data
        nameController.text = merchant.name ?? '';
        descriptionController.text = merchant.description ?? '';
        addressController.text = merchant.address ?? '';
        phoneController.text = merchant.phoneNumber ?? '';
        openingTimeController.text = merchant.openingTime ?? '';
        closingTimeController.text = merchant.closingTime ?? '';

        // Initialize location if available
        if (merchant.latitude != null && merchant.longitude != null) {
          location.value = LatLng(merchant.latitude!, merchant.longitude!);
        }

        // Initialize operating days
        if (merchant.operatingDays != null) {
          operatingDays.value = merchant.operatingDays!;
        }
      }
      hasError(false);
      errorMessage('');
    } catch (e) {
      hasError(true);
      errorMessage('Gagal memuat data: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateStoreInfo() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading(true);

      final success = await profileService.updateMerchantProfile(
        merchantId: merchant!.id!,
        name: nameController.text,
        description: descriptionController.text,
        address: addressController.text,
        phoneNumber: phoneController.text,
      );

      if (success) {
        await fetchMerchantData();
        Get.back();
        Get.snackbar(
          'Sukses',
          'Informasi toko berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw 'Gagal memperbarui informasi toko';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui informasi toko: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void toggleOperatingDay(String day) {
    if (operatingDays.contains(day)) {
      operatingDays.remove(day);
    } else {
      operatingDays.add(day);
    }
  }
}
