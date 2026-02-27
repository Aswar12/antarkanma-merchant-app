import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/profile_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:mime/mime.dart';

class MerchantProfileController extends GetxController {
  // Constants for image validation
  static const List<String> _supportedImageTypes = ['jpg', 'jpeg', 'png', 'heic'];
  static const double _maxFileSizeMB = 2.0;
  static const double _maxImageDimension = 800.0;
  static const int _imageQuality = 80;

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
    // Only fetch merchant data if user is logged in
    if (authService.isLoggedIn.value || authService.getToken() != null) {
      fetchMerchantData();
    }
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

  // Validate image file
  Future<void> _validateImageFile(File file) async {
    // Check file size
    final sizeInBytes = await file.length();
    final sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > _maxFileSizeMB) {
      throw 'Ukuran file terlalu besar. Maksimal ${_maxFileSizeMB}MB';
    }

    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    if (!_supportedImageTypes.contains(extension)) {
      throw 'Format file tidak didukung. Gunakan format: ${_supportedImageTypes.join(", ")}';
    }

    // Check MIME type
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw 'File harus berupa gambar';
    }

    // Verify specific image MIME types
    final validMimeTypes = ['image/jpeg', 'image/png', 'image/heic'];
    if (!validMimeTypes.contains(mimeType)) {
      throw 'Format gambar tidak didukung. Gunakan JPEG, PNG, atau HEIC';
    }
  }

  Future<void> pickAndUpdateLogo() async {
    try {
      // Configure image picker with optimized settings
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxImageDimension,
        maxHeight: _maxImageDimension,
        imageQuality: _imageQuality,
        requestFullMetadata: true, // Enable full metadata
      );

      if (pickedFile != null) {
        isUploadingLogo(true);

        final file = File(pickedFile.path);
        
        // Validate the image file
        await _validateImageFile(file);

        final success = await profileService.updateMerchantLogo(
          merchant!.id!,
          pickedFile.path,
        );

        if (success) {
          await merchantService.clearCache(); // Clear cache before fetching
          await fetchMerchantData();
          Get.snackbar(
            'Sukses',
            'Logo berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          update(); // Force UI update
        } else {
          throw 'Gagal memperbarui logo. Silakan coba lagi';
        }
      }
    } catch (e) {
      print('Error updating logo: $e'); // For debugging
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
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
        await merchantService.clearCache(); // Clear cache before fetching
        await fetchMerchantData();
        Get.snackbar(
          'Sukses',
          'Lokasi berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        update(); // Force UI update
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

      if (openingTimeController.text.isEmpty ||
          closingTimeController.text.isEmpty) {
        throw 'Jam operasional harus diisi';
      }

      if (operatingDays.isEmpty) {
        throw 'Pilih minimal satu hari operasional';
      }

      // Convert operating days to Set to remove any duplicates
      final uniqueDays = operatingDays.toSet().toList();
      if (uniqueDays.length > 7) {
        throw 'Maksimal 7 hari dapat dipilih';
      }

      final success = await profileService.updateOperatingHours(
        merchantId: merchant!.id!,
        openingTime: openingTimeController.text,
        closingTime: closingTimeController.text,
        operatingDays: uniqueDays,
      );

      if (success) {
        // Clear cache before fetching new data
        await merchantService.clearCache();
        
        // Refresh merchant data
        await fetchMerchantData();
        
        // Update UI with unique days
        operatingDays.value = uniqueDays;
        operatingDays.refresh();
        
        // Close bottom sheet and show success message
        Get.back();
        Get.snackbar(
          'Sukses',
          'Jam operasional berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Force rebuild profile page
        update(); // Force UI update
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

        // Initialize operating days, ensuring uniqueness
        if (merchant.operatingDays != null) {
          operatingDays.value = merchant.operatingDays!.toSet().toList();
          operatingDays.refresh();
        }

        // Force UI update
        update();
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
        await merchantService.clearCache(); // Clear cache before fetching
        await fetchMerchantData();
        Get.back();
        Get.snackbar(
          'Sukses',
          'Informasi toko berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        update(); // Force UI update
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
    final currentDays = operatingDays.toSet(); // Convert to Set for uniqueness check
    
    if (currentDays.contains(day)) {
      currentDays.remove(day);
    } else {
      if (currentDays.length >= 7) {
        Get.snackbar(
          'Perhatian',
          'Maksimal 7 hari dapat dipilih',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      currentDays.add(day);
    }
    
    operatingDays.value = currentDays.toList();
    operatingDays.refresh();
    update(); // Force UI update
  }
}
