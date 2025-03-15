// ignore_for_file: avoid_print

import 'dart:io';
import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import 'package:antarkanma_merchant/app/utils/validators.dart';
import 'package:image_picker/image_picker.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final StorageService _storageService;

  // Controllers for basic info
  late TextEditingController identifierController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  // Controllers for merchant info
  late TextEditingController merchantNameController;
  late TextEditingController addressController;
  late TextEditingController openingTimeController;
  late TextEditingController closingTimeController;
  late TextEditingController descriptionController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  
  // Observable values for text fields
  final RxString identifier = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString merchantName = ''.obs;
  final RxString address = ''.obs;
  final RxString openingTime = ''.obs;
  final RxString closingTime = ''.obs;
  final RxString description = ''.obs;
  final RxString latitude = ''.obs;
  final RxString longitude = ''.obs;

  // Observable values for merchant registration
  final RxList<String> operatingDays = <String>[].obs;
  final Rx<File?> logoFile = Rx<File?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool rememberMe = true.obs; // Always true by default
  bool _isAutoLoginInProgress = false;
  bool _isLoginInProgress = false;

  AuthController({
    required AuthService authService,
    required StorageService storageService,
  }) : 
    _authService = authService,
    _storageService = storageService;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    rememberMe.value = true; // Always set to true
    _storageService.saveRememberMe(true); // Save the remember me state
  }

  void _initializeControllers() {
    // Basic info controllers
    identifierController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();

    // Merchant info controllers
    merchantNameController = TextEditingController();
    addressController = TextEditingController();
    openingTimeController = TextEditingController();
    closingTimeController = TextEditingController();
    descriptionController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();

    // Add listeners
    identifierController.addListener(() => identifier.value = identifierController.text);
    passwordController.addListener(() => password.value = passwordController.text);
    confirmPasswordController.addListener(() => confirmPassword.value = confirmPasswordController.text);
    nameController.addListener(() => name.value = nameController.text);
    emailController.addListener(() => email.value = emailController.text);
    phoneNumberController.addListener(() => phone.value = phoneNumberController.text);
    merchantNameController.addListener(() => merchantName.value = merchantNameController.text);
    addressController.addListener(() => address.value = addressController.text);
    openingTimeController.addListener(() => openingTime.value = openingTimeController.text);
    closingTimeController.addListener(() => closingTime.value = closingTimeController.text);
    descriptionController.addListener(() => description.value = descriptionController.text);
    latitudeController.addListener(() => latitude.value = latitudeController.text);
    longitudeController.addListener(() => longitude.value = longitudeController.text);
  }

  void resetControllers() {
    // Dispose and clear basic info controllers
    identifierController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    emailController.clear();
    phoneNumberController.clear();

    // Dispose and clear merchant info controllers
    merchantNameController.clear();
    addressController.clear();
    openingTimeController.clear();
    closingTimeController.clear();
    descriptionController.clear();
    latitudeController.clear();
    longitudeController.clear();

    // Reset observable values
    operatingDays.clear();
    logoFile.value = null;
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void toggleRememberMe() {
    // Do nothing as remember me is always true
  }

  void toggleOperatingDay(String day) {
    if (operatingDays.contains(day)) {
      operatingDays.remove(day);
    } else {
      operatingDays.add(day);
    }
  }

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      logoFile.value = File(image.path);
    }
  }

  Future<bool> login({bool isAutoLogin = false}) async {
    if (_isLoginInProgress || _isAutoLoginInProgress) return false;
    
    if (isAutoLogin) {
      _isAutoLoginInProgress = true;
    } else {
      _isLoginInProgress = true;
    }
    
    isLoading.value = true;

    try {
      final success = await _authService.login(
        identifierController.text,
        passwordController.text,
        rememberMe: true, // Always true
      );

      if (!success) {
        if (!isAutoLogin) {
          showCustomSnackbar(
            title: 'Login Gagal',
            message: 'Periksa kembali email/nomor telepon dan password Anda.',
            isError: true,
          );
        }
        return false;
      }

      String role = _authService.currentUser.value?.role ?? '';
      if (role != 'MERCHANT') {
        showCustomSnackbar(
          title: 'Login Gagal',
          message: 'Akun ini bukan akun merchant.',
          isError: true,
        );
        await _authService.logout();
        Get.offAllNamed(Routes.login);
        return false;
      }

      // Always save credentials since remember me is always true
      await _storageService.setupAutoLogin(
        identifier: identifierController.text,
        password: passwordController.text,
        rememberMe: true,
      );

      if (!isAutoLogin) {
        Get.offAllNamed(Routes.merchantMainPage);
        showCustomSnackbar(
          title: 'Login Berhasil',
          message: 'Selamat datang kembali!',
        );
      }
      return true;
    } catch (e) {
      print('Login error: $e');
      if (!isAutoLogin) {
        String errorMessage = 'Terjadi kesalahan';
        
        if (e is DioException) {
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
            case DioExceptionType.sendTimeout:
            case DioExceptionType.receiveTimeout:
              errorMessage = 'Server tidak merespon. Silakan coba lagi nanti.';
              break;
            case DioExceptionType.connectionError:
              errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
              break;
            default:
              if (e.response?.statusCode == 503) {
                errorMessage = 'Server sedang dalam pemeliharaan. Silakan coba lagi nanti.';
              } else {
                errorMessage = 'Gagal terhubung ke server. Silakan coba lagi nanti.';
              }
          }
        }
        
        showCustomSnackbar(
          title: 'Error',
          message: errorMessage,
          isError: true,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
      if (isAutoLogin) {
        _isAutoLoginInProgress = false;
      } else {
        _isLoginInProgress = false;
      }
    }
  }

  Future<void> register() async {
    String? nameError = validateName(nameController.text);
    String? emailError = validateEmail(emailController.text);
    String? phoneError = validatePhoneNumber(phoneNumberController.text);

    if (nameError != null || emailError != null || phoneError != null) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: nameError ?? emailError ?? phoneError!,
        isError: true,
      );
      return;
    }

    isLoading.value = true;
    try {
      final success = await _authService.register(
          nameController.text,
          emailController.text,
          phoneNumberController.text,
          passwordController.text,
          confirmPasswordController.text);

      if (!success) {
        showCustomSnackbar(
          title: 'Registrasi Gagal',
          message: 'Pendaftaran gagal. Periksa kembali data Anda.',
          isError: true,
        );
      } else {
        showCustomSnackbar(
          title: 'Registrasi Berhasil',
          message: 'Akun Anda telah berhasil dibuat. Silakan login.',
        );
        Get.offAllNamed(Routes.login);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerMerchant() async {
    if (!_validateMerchantData()) return;

    isLoading.value = true;
    try {
      final formData = FormData.fromMap({
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'phone_number': phoneNumberController.text,
        'merchant_name': merchantNameController.text,
        'address': addressController.text,
        'opening_time': openingTimeController.text,
        'closing_time': closingTimeController.text,
        'operating_days': operatingDays,
        'latitude': double.parse(latitudeController.text),
        'longitude': double.parse(longitudeController.text),
        'description': descriptionController.text,
      });

      if (logoFile.value != null) {
        formData.files.add(MapEntry(
          'logo',
          await MultipartFile.fromFile(
            logoFile.value!.path,
            filename: 'logo.${logoFile.value!.path.split('.').last}',
          ),
        ));
      }

      final response = await _authService.registerMerchant(formData);

      if (response.statusCode == 200) {
        showCustomSnackbar(
          title: 'Registrasi Berhasil',
          message: 'Akun merchant Anda telah berhasil dibuat. Silakan login.',
        );
        Get.offAllNamed(Routes.login);
      } else {
        showCustomSnackbar(
          title: 'Registrasi Gagal',
          message: 'Pendaftaran gagal. Periksa kembali data Anda.',
          isError: true,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Gagal mendaftar: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // Clear all local storage data
      await _storageService.clearAll();
      
      // Clear auth service state
      await _authService.logout();
      
      // Reset all controllers
      resetControllers();
      
      // Navigate to login page
      Get.offAllNamed(Routes.login);
      
      showCustomSnackbar(
        title: 'Logout Berhasil',
        message: 'Anda telah berhasil keluar dari akun.',
      );
    } catch (e) {
      print('Error during logout: $e');
      showCustomSnackbar(
        title: 'Logout Gagal',
        message: 'Gagal logout. Silakan coba lagi.',
        isError: true,
      );
    }
  }

  bool _validateMerchantData() {
    if ([
      nameController,
      emailController,
      phoneNumberController,
      passwordController,
      merchantNameController,
      addressController,
      openingTimeController,
      closingTimeController,
      latitudeController,
      longitudeController,
    ].any((controller) => controller.text.isEmpty)) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: 'Semua field wajib harus diisi',
        isError: true,
      );
      return false;
    }

    if (operatingDays.isEmpty) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: 'Pilih minimal satu hari operasional',
        isError: true,
      );
      return false;
    }

    final emailError = validateEmail(emailController.text);
    if (emailError != null) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: emailError,
        isError: true,
      );
      return false;
    }

    final phoneError = validatePhoneNumber(phoneNumberController.text);
    if (phoneError != null) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: phoneError,
        isError: true,
      );
      return false;
    }

    final passwordError = validatePassword(passwordController.text);
    if (passwordError != null) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: passwordError,
        isError: true,
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: 'Password dan konfirmasi password tidak cocok',
        isError: true,
      );
      return false;
    }

    try {
      double.parse(latitudeController.text);
      double.parse(longitudeController.text);
    } catch (e) {
      showCustomSnackbar(
        title: 'Validasi Gagal',
        message: 'Latitude dan longitude harus berupa angka',
        isError: true,
      );
      return false;
    }

    return true;
  }

  String? validateIdentifier(String? value) {
    return Validators.validateIdentifier(value!);
  }

  String? validatePassword(String? value) {
    return Validators.validatePassword(value);
  }

  String? validateConfirmPassword(String? value) {
    return Validators.validateConfirmPassword(value, passwordController.text);
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    return null;
  }

  String? validateEmail(String? value) {
    return Validators.validateEmail(value);
  }

  String? validatePhoneNumber(String? value) {
    return Validators.validatePhoneNumber(value);
  }

  String? validateMerchantName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama merchant tidak boleh kosong';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    return null;
  }

  String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Waktu tidak boleh kosong';
    }
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Format waktu tidak valid (HH:mm)';
    }
    return null;
  }

  String? validateLatLong(String? value) {
    if (value == null || value.isEmpty) {
      return 'Koordinat tidak boleh kosong';
    }
    try {
      double.parse(value);
      return null;
    } catch (e) {
      return 'Koordinat harus berupa angka';
    }
  }

  @override
  void onClose() {
    // Dispose basic info controllers
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();

    // Dispose merchant info controllers
    merchantNameController.dispose();
    addressController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    descriptionController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    super.onClose();
  }
}
