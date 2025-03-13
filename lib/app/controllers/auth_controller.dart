// ignore_for_file: avoid_print

import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:antarkanma_merchant/app/utils/validators.dart';

class AuthController extends GetxController {
  final AuthService _authService;
  final StorageService _storageService;

  var isConfirmPasswordHidden = true.obs;
  final formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController identifierController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  
  // Observable values for text fields
  final RxString identifier = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final rememberMe = false.obs;
  bool _isAutoLoginInProgress = false;
  bool _isLoginInProgress = false;

  AuthController({
    AuthService? authService,
    StorageService? storageService,
  }) : 
    _authService = authService ?? Get.find<AuthService>(),
    _storageService = storageService ?? StorageService.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    rememberMe.value = _storageService.getRememberMe();
  }

  void _initializeControllers() {
    identifierController = TextEditingController()
      ..addListener(() => identifier.value = identifierController.text);
    passwordController = TextEditingController()
      ..addListener(() => password.value = passwordController.text);
    confirmPasswordController = TextEditingController()
      ..addListener(() => confirmPassword.value = confirmPasswordController.text);
    nameController = TextEditingController()
      ..addListener(() => name.value = nameController.text);
    emailController = TextEditingController()
      ..addListener(() => email.value = emailController.text);
    phoneNumberController = TextEditingController()
      ..addListener(() => phone.value = phoneNumberController.text);
  }

  void resetControllers() {
    // Dispose old controllers
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();

    // Initialize new controllers
    _initializeControllers();
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
        rememberMe: rememberMe.value,
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

      // Save credentials if remember me is enabled
      if (rememberMe.value) {
        await _storageService.setupAutoLogin(
          identifier: identifierController.text,
          password: passwordController.text,
          rememberMe: true,
        );
      } else {
        await _storageService.clearAutoLogin();
      }

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
        showCustomSnackbar(
          title: 'Error',
          message: 'Gagal login: ${e.toString()}',
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

      // Reset controllers safely
      resetControllers();

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
