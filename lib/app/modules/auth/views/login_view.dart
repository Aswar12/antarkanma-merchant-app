import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input_field.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<AuthController> {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  LoginView({super.key});

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
          'assets/merchant_nobg.png',
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
            color: Colors.grey.withValues(alpha: 0.1),
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
          SizedBox(height: Dimenssions.height15),
          // Remember Me Checkbox
          Obx(() => Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: (value) {
                    // Remember me is always true
                  },
                  activeColor: logoColorSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(width: Dimenssions.width8),
              Text(
                'Ingat Saya',
                style: subtitleTextStyle.copyWith(
                  fontSize: Dimenssions.font14,
                ),
              ),
            ],
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
        onPressed: () {
          if (_signInFormKey.currentState!.validate()) {
            controller.login();
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
          onTap: () {
            controller.resetControllers();
            Get.toNamed(Routes.register);
          },
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
