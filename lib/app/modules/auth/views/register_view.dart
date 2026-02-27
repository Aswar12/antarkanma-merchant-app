import 'package:antarkanma_merchant/app/controllers/auth_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/map_picker_page.dart';
import 'package:antarkanma_merchant/app/widgets/custom_button.dart';
import 'package:antarkanma_merchant/app/widgets/custom_input_field.dart';
import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:latlong2/latlong.dart';

class RegisterView extends GetView<AuthController> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  RegisterView({super.key});

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
                    registrationForm(),
                    signButton(),
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
          height: Dimenssions.height65,
          fit: BoxFit.contain,
        ),
        SizedBox(height: Dimenssions.height20),
        Text(
          'Buat Akun Merchant',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font24,
            fontWeight: semiBold,
          ),
        ),
        SizedBox(height: Dimenssions.height10),
        Text(
          'Silahkan lengkapi data diri dan toko Anda',
          style: subtitleTextStyle.copyWith(
            fontSize: Dimenssions.font16,
          ),
        ),
      ],
    );
  }

  Widget registrationForm() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Pemilik',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font18,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height15),
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
          Obx(() => _buildInputField(
                label: 'Password',
                hintText: 'Masukkan Password Kamu',
                controller: controller.passwordController,
                validator: controller.validatePassword,
                icon: 'assets/icon_password.png',
                initialObscureText: controller.isPasswordHidden.value,
                showVisibilityToggle: true,
                onVisibilityToggle: controller.togglePasswordVisibility,
              )),
          SizedBox(height: Dimenssions.height15),
          Obx(() => _buildInputField(
                label: 'Konfirmasi Password',
                hintText: 'Masukkan Konfirmasi Password Kamu',
                controller: controller.confirmPasswordController,
                validator: controller.validateConfirmPassword,
                icon: 'assets/icon_password.png',
                initialObscureText: controller.isConfirmPasswordHidden.value,
                showVisibilityToggle: true,
                onVisibilityToggle: controller.toggleConfirmPasswordVisibility,
              )),
          SizedBox(height: Dimenssions.height30),
          Text(
            'Data Toko',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font18,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Nama Toko',
            hintText: 'Masukkan Nama Toko',
            controller: controller.merchantNameController,
            validator: controller.validateMerchantName,
            icon: 'assets/icon_store_location.png',
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Alamat Toko',
            hintText: 'Masukkan Alamat Lengkap Toko',
            controller: controller.addressController,
            validator: controller.validateAddress,
            icon: 'assets/icon_your_address.png',
            maxLines: 3,
          ),
          SizedBox(height: Dimenssions.height15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Jam Buka',
                  hintText: 'HH:mm',
                  controller: controller.openingTimeController,
                  validator: controller.validateTime,
                  icon: 'assets/icon_list.png',
                ),
              ),
              SizedBox(width: Dimenssions.width15),
              Expanded(
                child: _buildInputField(
                  label: 'Jam Tutup',
                  hintText: 'HH:mm',
                  controller: controller.closingTimeController,
                  validator: controller.validateTime,
                  icon: 'assets/icon_list.png',
                ),
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height15),
          Text(
            'Hari Operasional',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font16,
              fontWeight: medium,
            ),
          ),
          SizedBox(height: Dimenssions.height10),
          _buildOperatingDays(),
          SizedBox(height: Dimenssions.height15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lokasi Toko',
                style: primaryTextStyle.copyWith(
                  fontSize: Dimenssions.font16,
                  fontWeight: medium,
                ),
              ),
              SizedBox(height: Dimenssions.height10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor1,
                        borderRadius:
                            BorderRadius.circular(Dimenssions.radius12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon_store_location.png',
                                  width: 18,
                                  height: 18,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: Dimenssions.width15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Koordinat',
                                        style: primaryTextStyle.copyWith(
                                          fontSize: 14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                      Obx(() {
                                        final lat =
                                            controller.latitudeController.text;
                                        final lng =
                                            controller.longitudeController.text;
                                        return Text(
                                          lat.isNotEmpty && lng.isNotEmpty
                                              ? '$lat, $lng'
                                              : 'Pilih lokasi di peta',
                                          style: subtitleTextStyle.copyWith(
                                            fontSize: 12,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Get.to<LatLng>(
                                  () => const MapPickerPage());
                              if (result != null) {
                                controller.latitudeController.text =
                                    result.latitude.toString();
                                controller.longitudeController.text =
                                    result.longitude.toString();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: logoColorSecondary,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map,
                                    color: Colors.white, size: 18),
                                SizedBox(width: Dimenssions.width10),
                                Text(
                                  'Pilih di Peta',
                                  style: textwhite.copyWith(
                                    fontSize: 14,
                                    fontWeight: medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height15),
          _buildInputField(
            label: 'Deskripsi Toko (Opsional)',
            hintText: 'Masukkan Deskripsi Toko',
            controller: controller.descriptionController,
            icon: 'assets/icon_list.png',
            maxLines: 3,
          ),
          SizedBox(height: Dimenssions.height15),
          _buildLogoUpload(),
        ],
      ),
    );
  }

  Widget _buildOperatingDays() {
    final days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: days.map((day) {
        return Obx(() => FilterChip(
              label: Text(day[0].toUpperCase() + day.substring(1)),
              selected: controller.operatingDays.contains(day),
              onSelected: (selected) => controller.toggleOperatingDay(day),
              backgroundColor: backgroundColor1,
              selectedColor: logoColorSecondary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: controller.operatingDays.contains(day)
                    ? Colors.white
                    : Colors.black,
              ),
            ));
      }).toList(),
    );
  }

  Widget _buildLogoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo Toko (Opsional)',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font16,
            fontWeight: medium,
          ),
        ),
        SizedBox(height: Dimenssions.height10),
        Row(
          children: [
            Obx(() => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: backgroundColor1,
                    borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: controller.logoFile.value != null
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius12),
                          child: Image.file(
                            controller.logoFile.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.store,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                )),
            SizedBox(width: Dimenssions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: controller.pickLogo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoColorSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimenssions.radius12),
                      ),
                    ),
                    child: Text(
                      'Pilih Logo',
                      style: textwhite,
                    ),
                  ),
                  SizedBox(height: Dimenssions.height5),
                  Text(
                    'Format: JPEG/PNG/JPG/GIF/WEBP\nMaks: 20MB',
                    style: subtitleTextStyle.copyWith(
                      fontSize: Dimenssions.font12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
    required String icon,
    bool initialObscureText = false,
    bool showVisibilityToggle = false,
    int? maxLines,
    TextInputType? keyboardType,
    VoidCallback? onVisibilityToggle,
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
        maxLines: maxLines,
        keyboardType: keyboardType,
        onVisibilityToggle: onVisibilityToggle,
      ),
    );
  }

  Widget signButton() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: Dimenssions.height30,
      ),
      child: Obx(
        () => CustomButton(
          text: 'Daftar Sekarang',
          isLoading: controller.isLoading.value,
          backgroundColor: logoColorSecondary,
          onPressed: () {
            if (_signUpFormKey.currentState!.validate()) {
              controller.registerMerchant();
            }
          },
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
          onTap: () {
            controller.resetControllers();
            Get.offNamed(Routes.login);
          },
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
