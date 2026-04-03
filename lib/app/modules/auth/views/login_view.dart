import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class LoginView extends GetView<AuthController> {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  LoginView({super.key}) {
    // Ensure AuthController is initialized
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(
          authService: AuthService(),
          storageService: StorageService.instance,
        ),
        permanent: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: _signInFormKey,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(Dimenssions.height20),
              child: Column(
                children: [
                  SizedBox(height: Dimenssions.height20),
                  header(),
                  SizedBox(height: Dimenssions.height40),
                  loginForm(context),
                  SizedBox(height: Dimenssions.height30),
                  signButton(),
                  SizedBox(height: Dimenssions.height40),
                  footer(),
                  SizedBox(height: Dimenssions.height20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Column(
      children: [
        Image.asset(
          'assets/merchant_nobg.png',
          height: Dimenssions.height80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: Dimenssions.height30),
        Text(
          'Selamat Datang Kembali!',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font24,
            fontWeight: semiBold,
          ),
        ),
        SizedBox(height: Dimenssions.height10),
        Text(
          'Silahkan masuk untuk melanjutkan',
          style: subtitleTextStyle.copyWith(
            fontSize: Dimenssions.font16,
          ),
        ),
      ],
    );
  }

  Widget loginForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius20),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimenssions.width20,
        vertical: Dimenssions.height30,
      ),
      child: Column(
        children: [
          CustomInputField(
            label: 'Email atau WhatsApp',
            hintText: 'Masukkan Email atau Nomor WA',
            controller: controller.identifierController,
            validator: controller.validateIdentifier,
            icon: 'assets/icon_email.png',
          ),
          SizedBox(height: Dimenssions.height20),
          CustomInputField(
            label: 'Password',
            hintText: 'Masukkan Password Kamu',
            controller: controller.passwordController,
            validator: controller.validatePassword,
            initialObscureText: true,
            icon: 'assets/icon_password.png',
            showVisibilityToggle: true,
          ),
          SizedBox(height: Dimenssions.height15),
          // Remember Me Checkbox
          Obx(() => Container(
                margin: EdgeInsets.only(top: Dimenssions.height5),
                child: Row(
                  children: [
                    Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (value) => controller.toggleRememberMe(),
                      activeColor: logoColorSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: Dimenssions.width8),
                    Text(
                      'Ingat Saya',
                      style: primaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget signButton() {
    return Obx(
      () => CustomButton(
        text: 'Masuk',
        isLoading: controller.isLoading.value,
        backgroundColor: logoColorSecondary,
        onPressed: () async {
          if (_signInFormKey.currentState!.validate()) {
            await controller.login();
          }
        },
      ),
    );
  }

  Widget footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum Punya Akun? ',
          style: subtitleTextStyle.copyWith(
            fontSize: Dimenssions.font14,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.register),
          child: Text(
            'Daftar',
            style: primaryTextOrange.copyWith(
              fontSize: Dimenssions.font14,
              fontWeight: semiBold,
            ),
          ),
        ),
      ],
    );
  }
}
