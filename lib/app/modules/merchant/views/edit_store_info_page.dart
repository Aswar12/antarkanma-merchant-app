import 'dart:io';
import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/map_picker_page.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class EditStoreInfoPage extends GetView<MerchantProfileController> {
  const EditStoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: Text(
          'Edit Informasi Toko',
          style: primaryTextStyle.copyWith(color: logoColor),
        ),
        backgroundColor: transparentColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: logoColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoSection(),
            const SizedBox(height: 24),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() {
                if (controller.newLogoFile.value != null) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(controller.newLogoFile.value!),
                  );
                } else if (controller.merchantLogo != null &&
                    controller.merchantLogo!.isNotEmpty) {
                  return CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(controller.merchantLogo!),
                    onBackgroundImageError: (e, s) {
                      print('Error loading image: $e');
                    },
                  );
                }
                return CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.store,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                );
              }),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: logoColor,
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: _showImageSourceDialog,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Logo Toko',
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ukuran maksimal 2MB\nFormat: JPG, JPEG, PNG',
            style: secondaryTextStyle.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Nama Toko',
            hint: 'Masukkan nama toko',
            controller: controller.nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama toko tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Deskripsi',
            hint: 'Masukkan deskripsi toko',
            controller: controller.descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Alamat',
            hint: 'Masukkan alamat toko',
            controller: controller.addressController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Alamat toko tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          _buildLocationPicker(),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Nomor Telepon',
            hint: 'Masukkan nomor telepon',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor telepon tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.updateStoreInfo(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Simpan Perubahan'),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Obx(() {
      final location = controller.location.value;
      return OutlinedButton.icon(
        onPressed: () async {
          final result = await Get.to(() => const MapPickerPage());
          if (result != null && result is LatLng) {
            await controller.updateLocation(result);
          }
        },
        icon: Icon(Icons.location_on, color: logoColor),
        label: Text(
          location != null
              ? 'Ubah Lokasi Toko (${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)})'
              : 'Pilih Lokasi Toko',
          style: TextStyle(color: logoColor),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: logoColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(
            fontSize: 14,
            fontWeight: medium,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: primaryTextStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: secondaryTextStyle,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: logoColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: alertColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: alertColor),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: primaryTextStyle.copyWith(
                fontSize: 16,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('Galeri', style: primaryTextStyle),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('Kamera', style: primaryTextStyle),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        controller.setNewLogo(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Gagal memilih gambar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: alertColor,
        colorText: Colors.white,
      );
    }
  }
}
