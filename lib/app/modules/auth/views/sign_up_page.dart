import 'package:antarkanma_merchant/app/controllers/auth_controller.dart';
import 'package:antarkanma_merchant/app/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';

class SignUpPage extends StatelessWidget {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: backgroundColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(Dimenssions.height20),
            child: Form(
              key: _signUpFormKey,
              child: Column(
                children: [
                  header(),
                  SizedBox(height: Dimenssions.height30),
                  registrationForm(controller),
                  signButton(controller),
                  footer(),
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
          'assets/logo.png',
          height: Dimenssions
              .height65, // Reduced from height80 to height65 (20% smaller)
          fit: BoxFit.contain,
        ),
        SizedBox(height: Dimenssions.height20),
        Text(
          'Buat Akun Baru',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font24,
            fontWeight: semiBold,
          ),
        ),
        SizedBox(height: Dimenssions.height10),
        Text(
          'Silahkan lengkapi data diri Anda',
          style: subtitleTextStyle.copyWith(
            fontSize: Dimenssions.font16,
          ),
        ),
      ],
    );
  }

  Widget registrationForm(AuthController controller) {
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
          _buildInputField(
            label: 'Nama Lengkap',
            hintText: 'Masukkan Nama Lengkap Kamu',
            controller: controller.nameController,
            validator: controller.validateName,
            icon: 'assets/icon_name.png',
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Alamat Email',
            hintText: 'Masukkan Alamat Email Kamu',
            controller: controller.emailController,
            validator: controller.validateEmail,
            icon: 'assets/icon_email.png',
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Telepon/WA',
            hintText: 'Masukkan Nomor Telepon/WA Kamu',
            controller: controller.phoneNumberController,
            validator: controller.validatePhoneNumber,
            icon: 'assets/phone_icon.png',
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Password',
            hintText: 'Masukkan Password Kamu',
            controller: controller.passwordController,
            validator: controller.validatePassword,
            icon: 'assets/icon_password.png',
            initialObscureText: true,
            showVisibilityToggle: true,
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Konfirmasi Password',
            hintText: 'Masukkan Konfirmasi Password Kamu',
            controller: controller.confirmPasswordController,
            validator: controller.validateConfirmPassword,
            icon: 'assets/icon_password.png',
            initialObscureText: true,
            showVisibilityToggle: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required String icon,
    bool initialObscureText = false,
    bool showVisibilityToggle = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius12),
      ),
      child: CustomInputField(
        label: label,
        hintText: hintText,
        controller: controller,
        validator: validator,
        icon: icon,
        initialObscureText: initialObscureText,
        showVisibilityToggle: showVisibilityToggle,
      ),
    );
  }

  Widget signButton(AuthController controller) {
    return Container(
      height: Dimenssions.height50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: Dimenssions.height30,
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () {
                  if (_signUpFormKey.currentState!.validate()) {
                    controller.register();
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
                  'Daftar Sekarang',
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
          'Sudah Punya Akun? ',
          style: subtitleTextStyle.copyWith(
            fontSize: Dimenssions.font14,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed('/login'),
          child: Text(
            'Masuk',
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
