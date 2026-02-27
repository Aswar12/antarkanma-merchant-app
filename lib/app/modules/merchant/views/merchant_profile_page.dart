import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/add_operational_hours_bottom_sheet.dart';
import 'package:antarkanma_merchant/app/widgets/logout_confirmation_dialog.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/routes/app_pages.dart';
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
        if (controller.merchantData.value == null) {
          return Center(
            child: CircularProgressIndicator(color: logoColor),
          );
        }

        if (controller.hasError.value) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchMerchantData(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
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
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchMerchantData(),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(Dimenssions.width16),
            children: [
              _buildHeader(),
              _buildStoreInfoCard(),
              _buildOperationalHoursCard(),
              _buildPaymentMethodsCard(),
              _buildMenuSection(),
              SizedBox(height: Dimenssions.height10),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: Dimenssions.height200,
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      child: Stack(
        children: [
          _buildHeaderBackground(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  _buildLogoSection(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      height: Dimenssions.height150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            logoColor.withOpacity(0.8),
            logoColor,
          ],
        ),
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _showLogoOptions(),
            child: Hero(
              tag: 'merchant_logo',
              child: CircleAvatar(
                radius: Dimenssions.height50,
                backgroundColor: Colors.white,
                child: Obx(() => controller.isUploadingLogo.value
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(logoColor),
                      )
                    : _buildLogoImage()),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: logoColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: InkWell(
              onTap: () => _showLogoOptions(),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoImage() {
    if (controller.merchantLogo != null &&
        controller.merchantLogo!.isNotEmpty) {
      return CachedNetworkImage(
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
        placeholder: (context, url) => CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(logoColor),
        ),
        errorWidget: (context, url, error) => _buildDefaultLogo(),
      );
    }
    return _buildDefaultLogo();
  }

  Widget _buildDefaultLogo() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: logoColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.store_rounded,
        size: Dimenssions.height40,
        color: logoColor,
      ),
    );
  }

  void _showLogoOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Dimenssions.width20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimenssions.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Logo Toko',
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font18,
                fontWeight: semiBold,
              ),
            ),
            SizedBox(height: Dimenssions.height20),
            ListTile(
              leading: Icon(Icons.photo_library, color: logoColor),
              title: Text('Pilih dari Galeri', style: primaryTextStyle),
              onTap: () {
                Get.back();
                controller.pickAndUpdateLogo();
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildStoreInfoCard() {
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
                'Telepon', controller.merchantPhone ?? 'Belum ditambahkan'),
            _buildInfoRow(
                'Alamat', controller.merchantAddress ?? 'Belum ditambahkan'),
            _buildInfoRow('Deskripsi',
                controller.merchantDescription ?? 'Belum ditambahkan'),
            SizedBox(height: Dimenssions.height16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Get.toNamed(Routes.merchantEditInfo);
                  controller.fetchMerchantData(); // Refresh after edit
                },
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

  Widget _buildOperationalHoursCard() {
    final merchant = controller.merchantData.value;

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
            if (merchant?.openingTime != null && merchant?.closingTime != null)
              Padding(
                padding: EdgeInsets.only(bottom: Dimenssions.height16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: logoColor, size: 20),
                    SizedBox(width: Dimenssions.width8),
                    Text(
                      '${merchant?.openingTime} - ${merchant?.closingTime}',
                      style: primaryTextStyle,
                    ),
                  ],
                ),
              ),
            if (merchant?.operatingDays != null &&
                merchant!.operatingDays!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: Dimenssions.height16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Operasional:',
                      style: primaryTextStyle.copyWith(fontWeight: medium),
                    ),
                    SizedBox(height: Dimenssions.height8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: merchant.operatingDays!.map((day) {
                        return Container(
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
                              color: logoColor,
                              fontSize: Dimenssions.font12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            SizedBox(height: Dimenssions.height16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Get.bottomSheet(
                    AddOperationalHoursBottomSheet(),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Dimenssions.radius15),
                      ),
                    ),
                    isScrollControlled: true,
                  );
                  // Refresh after bottom sheet is closed
                  controller.fetchMerchantData();
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
              onTap: () => Get.toNamed(Routes.merchantOrders),
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
}
