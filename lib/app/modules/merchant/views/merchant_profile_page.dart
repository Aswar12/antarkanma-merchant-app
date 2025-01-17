import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/add_operational_hours_bottom_sheet.dart';
import 'package:antarkanma_merchant/app/widgets/logout_confirmation_dialog.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MerchantProfilePage extends GetView<MerchantProfileController> {
  const MerchantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profil Toko',
          style: primaryTextStyle.copyWith(color: logoColor),
        ),
        backgroundColor: transparentColor,
        elevation: 0,
      ),
      body: Obx(() {
        // If the merchant data is null, show loading state
        if (controller.merchantData.value == null) {
          return Center(
            child: CircularProgressIndicator(color: logoColor),
          );
        }

        // If there's an error, show the error message
        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: alertColor),
                SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: primaryTextStyle.copyWith(color: alertColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Display the merchant profile information
        return ListView(
          padding: EdgeInsets.all(Dimenssions.width16),
          children: [
            _buildHeader(),
            _buildStoreInfoCard(),
            _buildOperationalHoursCard(),
            _buildPaymentMethodsCard(),
            _buildMenuSection(),
            SizedBox(height: Dimenssions.height10),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    final merchant = controller.merchant;
    return Container(
      height: Dimenssions.height200,
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      child: Stack(
        children: [
          Container(
            height: Dimenssions.height150,
            decoration: BoxDecoration(
              color: backgroundColor1,
              borderRadius: BorderRadius.circular(Dimenssions.radius15),
              image: controller.merchantLogo != null &&
                      controller.merchantLogo!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(controller.merchantLogo!),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        print('Error loading image: $exception');
                      },
                    )
                  : null,
            ),
            child: controller.merchantLogo == null ||
                    controller.merchantLogo!.isEmpty
                ? Center(
                    child: Icon(
                      Icons.store,
                      color: Colors.grey[500],
                      size: 50,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  _buildProfileImage(merchant),
                  SizedBox(height: Dimenssions.height8),
                  Obx(() => Text(
                        controller.merchantName ?? 'Nama belum ditambahkan',
                        style: primaryTextStyle.copyWith(
                          fontSize: Dimenssions.font18,
                          fontWeight: semiBold,
                          color: (controller.merchantName?.isNotEmpty ?? false)
                              ? null
                              : Colors.grey,
                        ),
                      )),
                  Obx(() => Text(
                        controller.merchantDescription ??
                            'Deskripsi belum ditambahkan',
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                          color: controller.merchantDescription?.isNotEmpty ??
                                  false
                              ? null
                              : Colors.grey,
                        ),
                      )),
                  Obx(() => Text(
                        controller.merchantAddress ??
                            'Alamat belum ditambahkan',
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                          color: controller.merchantAddress?.isNotEmpty ?? false
                              ? null
                              : Colors.grey,
                        ),
                      )),
                  Obx(() => Text(
                        controller.merchantPhone ??
                            'Nomor telepon belum ditambahkan',
                        style: secondaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                          color: controller.merchantPhone?.isNotEmpty ?? false
                              ? null
                              : Colors.grey,
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(dynamic merchant) {
    return GestureDetector(
      onTap: () => Get.toNamed('/merchant/edit-profile'),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: CircleAvatar(
          radius: Dimenssions.height40,
          backgroundColor: Colors.grey[300],
          child: controller.merchantLogo != null &&
                  controller.merchantLogo!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: controller.merchantLogo!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(
                    Icons.store,
                    size: Dimenssions.height40,
                    color: Colors.grey[600],
                  ),
                )
              : Icon(
                  Icons.store,
                  size: Dimenssions.height40,
                  color: Colors.grey[600],
                ),
        ),
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    final merchant = controller.merchant;
    return Card(
      color: backgroundColor1,
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimenssions.width16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: logoColor),
                SizedBox(width: Dimenssions.width8),
                Text(
                  'Informasi Toko',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            Divider(height: Dimenssions.height24),
            _buildInfoRow(
                'Telepon',
                controller.merchant?.phoneNumber ??
                    'Telepon belum ditambahkan'),
            _buildInfoRow('Alamat',
                controller.merchantAddress ?? 'Alamat belum ditambahkan'),
            _buildInfoRow('Status', merchant?.status ?? 'Tidak ada status'),
            _buildInfoRow(
                'Deskripsi', merchant?.description ?? 'Tidak ada deskripsi'),
            _buildInfoRow(
                'Jam Buka', merchant?.openingTime ?? 'Tidak ada jam buka'),
            _buildInfoRow(
                'Jam Tutup', merchant?.closingTime ?? 'Tidak ada jam tutup'),
            _buildInfoRow(
                'Hari Operasional',
                (merchant?.operatingDays?.join(', ') ??
                    'Tidak ada hari operasional')),
            SizedBox(height: Dimenssions.height16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed('/merchant/edit-store-info'),
                icon: Icon(Icons.edit, size: Dimenssions.height18),
                label: Text('Edit Informasi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: logoColor,
                  side: BorderSide(color: logoColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimenssions.height8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Dimenssions.width100,
            child: Text(label, style: secondaryTextStyle),
          ),
          Text(': ', style: secondaryTextStyle),
          Expanded(
            child: Text(value, style: primaryTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalHoursCard() {
    return Card(
      elevation: 1,
      color: backgroundColor1,
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: logoColor),
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimenssions.width16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: logoColor),
                SizedBox(width: Dimenssions.width8),
                Text(
                  'Jam Operasional',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            Divider(height: Dimenssions.height24),
            Obx(() {
              final merchant = controller.merchant;
              if (merchant == null) {
                return _buildTimeRow('Status', 'Memuat data...');
              }

              if (merchant.openingTime == null ||
                  merchant.closingTime == null ||
                  merchant.operatingDays == null ||
                  merchant.operatingDays!.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam operasional belum diatur',
                      style: secondaryTextStyle.copyWith(
                        color: alertColor,
                        fontSize: Dimenssions.font14,
                      ),
                    ),
                    SizedBox(height: Dimenssions.height8),
                    Text(
                      'Atur jam operasional toko Anda agar pembeli mengetahui waktu toko Anda buka',
                      style: secondaryTextStyle.copyWith(
                        fontSize: Dimenssions.font12,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(Dimenssions.width12),
                    decoration: BoxDecoration(
                      color: logoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Dimenssions.radius8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jam Buka',
                              style: secondaryTextStyle.copyWith(
                                fontSize: Dimenssions.font12,
                              ),
                            ),
                            Text(
                              merchant.openingTime!,
                              style: primaryTextStyle.copyWith(
                                fontWeight: semiBold,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward, color: logoColor),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Jam Tutup',
                              style: secondaryTextStyle.copyWith(
                                fontSize: Dimenssions.font12,
                              ),
                            ),
                            Text(
                              merchant.closingTime!,
                              style: primaryTextStyle.copyWith(
                                fontWeight: semiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimenssions.height16),
                  Text(
                    'Hari Operasional',
                    style: secondaryTextStyle.copyWith(
                      fontSize: Dimenssions.font14,
                    ),
                  ),
                  SizedBox(height: Dimenssions.height8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: merchant.operatingDays!
                        .map((day) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimenssions.width12,
                                vertical: Dimenssions.height6,
                              ),
                              decoration: BoxDecoration(
                                color: logoColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(Dimenssions.radius15),
                              ),
                              child: Text(
                                day,
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font12,
                                  color: logoColor,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              );
            }),
            SizedBox(height: Dimenssions.height16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.bottomSheet(
                    AddOperationalHoursBottomSheet(),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Dimenssions.radius15),
                      ),
                    ),
                    isScrollControlled: true,
                  );
                },
                icon: Icon(Icons.edit, size: Dimenssions.height18),
                label: Text('Atur Jam Operasional'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: logoColor,
                  side: BorderSide(color: logoColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String day, String hours) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimenssions.height8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: secondaryTextStyle),
          Text(hours, style: primaryTextStyle),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Card(
      color: backgroundColor1,
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimenssions.width16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: logoColor),
                SizedBox(width: Dimenssions.width8),
                Text(
                  'Metode Pembayaran',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                  ),
                ),
              ],
            ),
            Divider(height: Dimenssions.height24),
            _buildPaymentMethodRow('Transfer Bank', false),
            _buildPaymentMethodRow('E-Wallet', false),
            _buildPaymentMethodRow('COD', true),
            SizedBox(height: Dimenssions.height16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => {},
                icon: Icon(Icons.edit, size: Dimenssions.height18),
                label: Text('Atur Pembayaran'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: logoColor,
                  side: BorderSide(color: logoColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(String method, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimenssions.height8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(method, style: primaryTextStyle),
          Switch(
            value: isActive,
            onChanged: (value) {
              // Handle payment method toggle
            },
            activeColor: logoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Card(
      color: backgroundColor1,
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimenssions.width16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu Lainnya',
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font16,
                fontWeight: semiBold,
              ),
            ),
            Divider(height: Dimenssions.height24),
            _buildMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Orderan Kamu',
              onTap: () => Get.toNamed('/merchant/orders'),
            ),
            _buildMenuItem(
              icon: Icons.headset_mic_outlined,
              title: 'Bantuan',
              onTap: () => Get.toNamed('/merchant/help'),
            ),
            SizedBox(height: Dimenssions.height16),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Get.dialog(const LogoutConfirmationDialog()),
                icon: Icon(Icons.logout, color: alertColor),
                label: Text('Keluar'),
                style: TextButton.styleFrom(
                  backgroundColor: alertColor.withOpacity(0.1),
                  foregroundColor: alertColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: logoColor),
      title: Text(title, style: primaryTextStyle),
      trailing: Icon(Icons.arrow_forward_ios, size: Dimenssions.height16),
      onTap: onTap,
    );
  }
}
