// ignore_for_file: avoid_print

import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:antarkanma_merchant/app/utils/validators.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isConfirmPasswordHidden = true.obs;
  final formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final rememberMe = false.obs;
  final StorageService _storageService = StorageService.instance;

  @override
  void onInit() {
    super.onInit();
    rememberMe.value = _storageService.getRememberMe();
  }

  void togglePasswordVisibility() =>
      isPasswordHidden.value = !isPasswordHidden.value;

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    _storageService.saveRememberMe(rememberMe.value);
  }

  Future<void> login() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final success = await _authService.login(
        identifierController.text,
        passwordController.text,
        rememberMe: rememberMe.value,
      );

      if (!success) {
        showCustomSnackbar(
          title: 'Login Gagal',
          message: 'Periksa kembali email/nomor telepon dan password Anda.',
          isError: true,
        );
      } else {
        String role = _authService.currentUser.value?.role ?? '';
        if (role != 'MERCHANT') {
          showCustomSnackbar(
            title: 'Login Gagal',
            message: 'Akun ini bukan akun merchant.',
            isError: true,
          );
          await _authService.logout();
          Get.offAllNamed(Routes.login);
          return;
        }
        Get.offAllNamed(Routes.merchantMainPage);
        showCustomSnackbar(
          title: 'Login Berhasil',
          message: 'Selamat datang kembali!',
        );
      }
    } finally {
      isLoading.value = false;
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

  Future<void> logout() async {
    try {
      // Store remember me state and credentials before logout
      final wasRememberMeEnabled = _storageService.getRememberMe();
      final savedCredentials = wasRememberMeEnabled ? _storageService.getSavedCredentials() : null;

      await _authService.logout();

      // Clear auth data while preserving remember me if enabled
      if (wasRememberMeEnabled && savedCredentials != null) {
        // Clear auth data but keep remember me settings
        await _storageService.clearAuth();
      } else {
        // Clear everything including remember me settings
        await _storageService.clearAll();
      }

      // Reset controllers
      identifierController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      nameController.clear();
      emailController.clear();
      phoneNumberController.clear();

      // Reset observable values except remember me if enabled
      isLoading.value = false;
      isPasswordHidden.value = true;
      isConfirmPasswordHidden.value = true;
      if (!wasRememberMeEnabled) {
        rememberMe.value = false;
      }

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

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }
}
