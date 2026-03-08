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
      backgroundColor: backgroundColor3,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: logoColor,
          elevation: 0,
        ),
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Dimenssions.width16),
                  child: Column(
                    children: [
                      _buildStoreInfoCard(),
                      _buildOperationalHoursCard(),
                      _buildPaymentMethodsCard(),
                      _buildMenuSection(),
                      SizedBox(height: Dimenssions.height80), // Extra space
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: Dimenssions.height250,
      pinned: true,
      stretch: true,
      backgroundColor: logoColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Modern Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    logoColor,
                    logoColor.withOpacity(0.8),
                    logoColorSecondary.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // Decorative Abstract Circles
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: 20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Profile Content Information
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: Dimenssions.height20,
                  bottom: Dimenssions.height10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoSection(),
                    SizedBox(height: Dimenssions.height12),
                    Obx(() => Text(
                          controller.merchantName ?? 'Nama belum ditambahkan',
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimenssions.font20,
                            fontWeight: bold,
                            color: Colors.white,
                          ),
                        )),
                    SizedBox(height: Dimenssions.height8),
                    // Glassmorphism Badge for Description
                    Obx(() {
                      final desc = controller.merchantDescription ?? '';
                      if (desc.isEmpty) return const SizedBox.shrink();

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width16,
                          vertical: Dimenssions.height6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          desc,
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimenssions.font12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: medium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(
          height: 20,
          decoration: BoxDecoration(
            color: backgroundColor3,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
        ),
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
                radius: Dimenssions.height60,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Obx(() => controller.isUploadingLogo.value
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(logoColor),
                        )
                      : _buildLogoImage()),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            padding: EdgeInsets.all(Dimenssions.height8),
            decoration: BoxDecoration(
              color: logoColorSecondary,
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
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
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

    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
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
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
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
            // QRIS Section
            Obx(() {
              final qrisUrl = controller.qrisUrl;
              return Container(
                padding: EdgeInsets.all(Dimenssions.width12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimenssions.radius12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_2, color: dashPrimary, size: 20),
                        SizedBox(width: Dimenssions.width8),
                        Text(
                          'QRIS',
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimenssions.font14,
                            fontWeight: semiBold,
                          ),
                        ),
                        Spacer(),
                        if (qrisUrl != null && qrisUrl.isNotEmpty)
                          Text(
                            '✓ Aktif',
                            style: TextStyle(
                              color: dashPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Dimenssions.height12),
                    if (qrisUrl != null && qrisUrl.isNotEmpty) ...[
                      // Show QRIS preview
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(Dimenssions.radius8),
                        child: Image.network(
                          qrisUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 48, color: Colors.grey.shade400),
                                    SizedBox(height: 8),
                                    Text(
                                      'QRIS tidak dapat dimuat',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: Dimenssions.height12),
                    ] else ...[
                      // Show placeholder if no QRIS
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius8),
                          border: Border.all(
                            color: dashPrimary.withOpacity(0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.qr_code_2,
                                  size: 48,
                                  color: dashPrimary.withOpacity(0.5)),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada QRIS',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Dimenssions.height12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showUploadQrisDialog(),
                        icon: Icon(
                          qrisUrl != null && qrisUrl.isNotEmpty
                              ? Icons.edit
                              : Icons.add_a_photo,
                          size: Dimenssions.height18,
                        ),
                        label: Text(
                          qrisUrl != null && qrisUrl.isNotEmpty
                              ? 'Ubah QRIS'
                              : 'Upload QRIS',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: dashPrimary,
                          side: BorderSide(color: dashPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: Dimenssions.height16),
            _buildPaymentMethodRow('Transfer Bank', false),
            _buildPaymentMethodRow('E-Wallet', false),
            _buildPaymentMethodRow('COD (Bayar di Tempat)', true),
          ],
        ),
      ),
    );
  }

  void _showUploadQrisDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
        ),
        child: Container(
          padding: EdgeInsets.all(Dimenssions.width20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload QRIS',
                style: primaryTextStyle.copyWith(
                  fontSize: Dimenssions.font18,
                  fontWeight: semiBold,
                ),
              ),
              SizedBox(height: Dimenssions.height8),
              Text(
                'Upload QRIS code untuk pembayaran customer. Format: JPG, PNG. Max size: 2MB.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: Dimenssions.height20),
              GestureDetector(
                onTap: () => controller.uploadQris(),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: dashPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    border: Border.all(
                      color: dashPrimary.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Obx(() {
                      if (controller.isUploadingQris.value) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: dashPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Mengupload...',
                              style: TextStyle(
                                color: dashPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: dashPrimary,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap untuk upload QRIS',
                            style: TextStyle(
                              color: dashPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: Dimenssions.height20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
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
