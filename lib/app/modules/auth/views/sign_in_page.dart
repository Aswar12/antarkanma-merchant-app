import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../constants/app_values.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../routes/app_pages.dart';

class SignInPage extends GetView<AuthController> {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          controller.resetControllers();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor1,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Form(
            key: _signInFormKey,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(Dimenssions.height20),
                child: Column(
                  children: [
                    header(),
                    SizedBox(height: Dimenssions.height30),
                    loginForm(),
                    SizedBox(height: Dimenssions.height20),
                    signButton(),
                    SizedBox(height: Dimenssions.height30),
                    footer(),
                  ],
                ),
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
          'assets/logo.png',
          height: Dimenssions.height80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: Dimenssions.height20),
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

  Widget loginForm() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor2,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(Dimenssions.height20),
      child: Column(
        children: [
          CustomInputField(
            label: 'Email atau WhatsApp',
            hintText: 'Masukkan Email atau Nomor WA',
            controller: controller.identifierController,
            validator: controller.validateIdentifier,
            icon: 'assets/icon_email.png',
          ),
          SizedBox(height: Dimenssions.height15),
          CustomInputField(
            label: 'Password',
            hintText: 'Masukkan Password Kamu',
            controller: controller.passwordController,
            validator: controller.validatePassword,
            initialObscureText: true,
            icon: 'assets/icon_password.png',
            showVisibilityToggle: true,
          ),
        ],
      ),
    );
  }

  Widget signButton() {
    return SizedBox(
      height: Dimenssions.height50,
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (_signInFormKey.currentState!.validate()) {
                    controller.login();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: logoColorSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimenssions.radius15),
            ),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : Text(
                  'Masuk',
                  style: textwhite.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                  ),
                ),
        ),
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
      ],
    );
  }
}
