import 'package:antarkanma_merchant/app/controllers/user_location_controller.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressPage extends GetView<UserLocationController> {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: primaryTextColor,
            size: Dimenssions.height22,
          ),
          onPressed: () => Get.back(),
        ),
        backgroundColor: backgroundColor1,
        elevation: 0,
        title: Text(
          'Alamat Saya',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font18,
            fontWeight: semiBold,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: Dimenssions.width15),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(Dimenssions.height5),
                decoration: BoxDecoration(
                  color: logoColorSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                ),
                child: Icon(
                  Icons.add,
                  color: logoColorSecondary,
                  size: Dimenssions.height22,
                ),
              ),
              onPressed: () => Get.toNamed('/main/add-address'),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: logoColorSecondary,
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: secondaryTextStyle.copyWith(
                    fontSize: Dimenssions.font14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimenssions.height15),
                TextButton(
                  onPressed: controller.loadAddresses,
                  style: TextButton.styleFrom(
                    backgroundColor: logoColorSecondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimenssions.width20,
                      vertical: Dimenssions.height10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimenssions.radius8),
                    ),
                  ),
                  child: Text(
                    'Coba Lagi',
                    style: primaryTextStyle.copyWith(
                      color: backgroundColor1,
                      fontSize: Dimenssions.font14,
                      fontWeight: medium,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.addresses.isEmpty) {
          return _buildEmptyState();
        }

        return _buildAddressList();
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: Dimenssions.height65,
            color: secondaryTextColor.withOpacity(0.5),
          ),
          SizedBox(height: Dimenssions.height15),
          Text(
            'Belum ada alamat tersimpan',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height10),
          Text(
            'Tambahkan alamat untuk memudahkan pengiriman',
            style: secondaryTextStyle.copyWith(
              fontSize: Dimenssions.font14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimenssions.height20),
          Container(
            height: Dimenssions.height45,
            padding: EdgeInsets.symmetric(horizontal: Dimenssions.width30),
            child: TextButton(
              onPressed: () => Get.toNamed('/main/add-address'),
              style: TextButton.styleFrom(
                backgroundColor: logoColorSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                ),
              ),
              child: Text(
                'Tambah Alamat',
                style: primaryTextStyle.copyWith(
                  color: backgroundColor1,
                  fontSize: Dimenssions.font14,
                  fontWeight: medium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return RefreshIndicator(
      onRefresh: controller.loadAddresses,
      color: logoColorSecondary,
      child: ListView.builder(
        padding: EdgeInsets.all(Dimenssions.height15),
        itemCount: controller.addresses.length,
        itemBuilder: (context, index) {
          final address = controller.addresses[index];
          return _buildAddressItem(address);
        },
      ),
    );
  }

  Widget _buildAddressItem(UserLocationModel address) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height15),
      decoration: BoxDecoration(
        color: backgroundColor2,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: backgroundColor6.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: backgroundColor6.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAddressOptions(address),
          borderRadius: BorderRadius.circular(Dimenssions.radius15),
          child: Container(
            padding: EdgeInsets.all(Dimenssions.height15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: logoColorSecondary,
                            size: Dimenssions.height22,
                          ),
                          SizedBox(width: Dimenssions.width10),
                          Expanded(
                            child: Text(
                              address.customerName ?? 'Alamat ${address.id}',
                              style: primaryTextStyle.copyWith(
                                fontSize: Dimenssions.font16,
                                fontWeight: semiBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width10,
                          vertical: Dimenssions.height5,
                        ),
                        decoration: BoxDecoration(
                          color: logoColorSecondary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius8),
                        ),
                        child: Text(
                          'Utama',
                          style: primaryTextStyle.copyWith(
                            color: logoColorSecondary,
                            fontSize: Dimenssions.font12,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: Dimenssions.height10),
                Container(
                  margin: EdgeInsets.only(left: Dimenssions.height30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.fullAddress,
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                      SizedBox(height: Dimenssions.height5),
                      Text(
                        address.phoneNumber,
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                      SizedBox(height: Dimenssions.height5),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width10,
                          vertical: Dimenssions.height5,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor3,
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius8),
                        ),
                        child: Text(
                          address.addressType,
                          style: secondaryTextStyle.copyWith(
                            fontSize: Dimenssions.font12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressOptions(UserLocationModel address) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: backgroundColor1,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimenssions.radius20),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: Dimenssions.height20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Dimenssions.width45,
              height: Dimenssions.height5,
              decoration: BoxDecoration(
                color: backgroundColor3,
                borderRadius: BorderRadius.circular(Dimenssions.radius15),
              ),
            ),
            SizedBox(height: Dimenssions.height20),
            _buildOptionItem(
              icon: Icons.edit,
              title: 'Edit Alamat',
              color: logoColorSecondary,
              onTap: () {
                Get.back();
                Get.toNamed('/main/edit-address', arguments: address);
              },
            ),
            if (!address.isDefault)
              _buildOptionItem(
                icon: Icons.check_circle_outline,
                title: 'Jadikan Alamat Utama',
                color: logoColorSecondary,
                onTap: () {
                  Get.back();
                  _setDefaultAddress(address);
                },
              ),
            _buildOptionItem(
              icon: Icons.delete,
              title: 'Hapus Alamat',
              color: alertColor,
              onTap: () {
                Get.back();
                _deleteAddress(address);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimenssions.width20,
          vertical: Dimenssions.height15,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: Dimenssions.height22),
            SizedBox(width: Dimenssions.width15),
            Text(
              title,
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font14,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setDefaultAddress(UserLocationModel address) async {
    final result = await controller.setDefaultAddress(address.id!);
    if (result) {
      showCustomSnackbar(
        title: 'Sukses',
        message: 'Alamat utama berhasil diubah',
        backgroundColor: Colors.green,
      );
    } else {
      showCustomSnackbar(
        title: 'Gagal',
        message: controller.errorMessage.value,
        backgroundColor: Colors.red,
      );
    }
  }

  void _deleteAddress(UserLocationModel address) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Hapus Alamat',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font16,
            fontWeight: semiBold,
          ),
        ),
        content: Text(
          'Anda yakin ingin menghapus alamat ini?',
          style: secondaryTextStyle.copyWith(
            fontSize: Dimenssions.font14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Batal',
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Hapus',
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font14,
                color: alertColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await controller.deleteAddress(address.id!);
      if (result) {
        showCustomSnackbar(
          title: 'Sukses',
          message: 'Alamat berhasil dihapus',
          backgroundColor: Colors.green,
        );
      } else {
        showCustomSnackbar(
          title: 'Gagal',
          message: controller.errorMessage.value,
          backgroundColor: Colors.red,
        );
      }
    }
  }
}
