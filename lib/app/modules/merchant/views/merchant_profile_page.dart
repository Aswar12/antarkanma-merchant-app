import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/add_operational_hours_bottom_sheet.dart';
import 'package:antarkanma_merchant/app/widgets/logout_confirmation_dialog.dart';
import 'package:antarkanma_merchant/app/widgets/theme_toggle_widget.dart';
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
      backgroundColor: context.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppColors.navy,
          elevation: 0,
        ),
      ),
      body: Obx(() {
        if (controller.merchantData.value == null) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.orange),
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
                      _buildStoreInfoCard(context),
                      _buildOperationalHoursCard(context),
                      _buildPaymentMethodsCard(context),
                      _buildMenuSection(context),
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
      backgroundColor: AppColors.navy,
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
                    AppColors.navy,
                    AppColors.navy.withOpacity(0.8),
                    AppColors.orange.withOpacity(0.9),
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
                    _buildLogoSection(context),
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
            color: context.backgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
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
            onTap: () => _showLogoOptions(context),
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
              onTap: () => _showLogoOptions(context),
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

  void _showLogoOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Dimenssions.width20),
        decoration: BoxDecoration(
          color: context.cardColor,
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

  Widget _buildStoreInfoCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
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
                Icon(Icons.store, color: AppColors.orange),
                SizedBox(width: Dimenssions.width8),
                Text(
                  'Informasi Toko',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
            Divider(height: Dimenssions.height24, color: context.dividerColor),
            _buildInfoRow(context,
                'Telepon', controller.merchantPhone ?? 'Belum ditambahkan'),
            _buildInfoRow(context,
                'Alamat', controller.merchantAddress ?? 'Belum ditambahkan'),
            _buildInfoRow(context, 'Deskripsi',
                controller.merchantDescription ?? 'Belum ditambahkan'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Get.toNamed(Routes.merchantEditInfo);
                  controller.fetchMerchantData(); // Refresh after edit
                },
                icon: Icon(Icons.edit, size: Dimenssions.height18),
                label: const Text('Edit Informasi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  side: const BorderSide(color: AppColors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalHoursCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
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
                Icon(Icons.access_time, color: AppColors.orange),
                SizedBox(width: Dimenssions.width8),
                Text(
                  'Jam Operasional',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
            Divider(height: Dimenssions.height24, color: context.dividerColor),
            
            // Operating Days Section
            Obx(() {
              final merchant = controller.merchantData.value;
              if (merchant?.operatingDays == null || merchant!.operatingDays!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: Dimenssions.height16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Operasional:',
                      style: primaryTextStyle.copyWith(fontWeight: medium, color: context.textColor),
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
                            color: AppColors.orange.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius15),
                          ),
                          child: Text(
                            day,
                            style: primaryTextStyle.copyWith(
                              color: AppColors.orange,
                              fontSize: Dimenssions.font12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),

            // Operating Hours Section
            Obx(() {
              final merchant = controller.merchantData.value;
              if (merchant?.openingTime == null || merchant?.closingTime == null) {
                return Padding(
                  padding: EdgeInsets.only(bottom: Dimenssions.height16),
                  child: Center(
                    child: Text(
                      'Belum ada data jam operasional',
                      style: secondaryTextStyle.copyWith(
                        fontSize: Dimenssions.font12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.only(bottom: Dimenssions.height16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: AppColors.orange, size: 20),
                    SizedBox(width: Dimenssions.width8),
                    Text(
                      '${merchant?.openingTime} - ${merchant?.closingTime}',
                      style: primaryTextStyle.copyWith(color: context.textColor),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Get.bottomSheet(
                    const AddOperationalHoursBottomSheet(),
                    backgroundColor: context.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Dimenssions.radius15),
                      ),
                    ),
                    isScrollControlled: true,
                  );
                  controller.fetchMerchantData();
                },
                icon: Icon(Icons.edit, size: Dimenssions.height18),
                label: const Text('Atur Jam Operasional'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  side: const BorderSide(color: AppColors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
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
                Icon(Icons.payment, color: AppColors.orange),
                SizedBox(width: Dimenssions.width8),
                Text(
                  'Metode Pembayaran',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font16,
                    fontWeight: semiBold,
                    color: context.textColor,
                  ),
                ),
              ],
            ),
            Divider(height: Dimenssions.height24, color: context.dividerColor),
            // QRIS Section
            Obx(() {
              final qrisUrl = controller.qrisUrl;
              return Container(
                padding: EdgeInsets.all(Dimenssions.width12),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(Dimenssions.radius12),
                  border: Border.all(color: context.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.qr_code_2, color: AppColors.orange, size: 20),
                        SizedBox(width: Dimenssions.width8),
                        Text(
                          'QRIS',
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimenssions.font14,
                            fontWeight: semiBold,
                            color: context.textColor,
                          ),
                        ),
                        Spacer(),
                        if (qrisUrl != null && qrisUrl.isNotEmpty)
                          Text(
                            '✓ Aktif',
                            style: TextStyle(
                              color: AppColors.orange,
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
                              color: context.surfaceColor,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 48, color: context.textHintColor),
                                    SizedBox(height: 8),
                                    Text(
                                      'QRIS tidak dapat dimuat',
                                      style: TextStyle(
                                        color: context.textHintColor,
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
                          color: context.surfaceColor,
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius8),
                          border: Border.all(
                            color: AppColors.orange.withOpacity(0.3),
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
                                  color: AppColors.orange.withOpacity(0.5)),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada QRIS',
                                style: TextStyle(
                                  color: context.textHintColor,
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
                        onPressed: () => _showUploadQrisDialog(context),
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
                          foregroundColor: AppColors.orange,
                          side: BorderSide(color: AppColors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: Dimenssions.height16),
            _buildPaymentMethodRow(context, 'Transfer Bank', false),
            _buildPaymentMethodRow(context, 'E-Wallet', false),
            _buildPaymentMethodRow(context, 'COD (Bayar di Tempat)', true),
          ],
        ),
      ),
    );
  }

  void _showUploadQrisDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: context.cardColor,
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
                  color: context.textColor,
                ),
              ),
              SizedBox(height: Dimenssions.height8),
              Text(
                'Upload QRIS code untuk pembayaran customer. Format: JPG, PNG. Max size: 2MB.',
                style: TextStyle(
                  fontSize: 12,
                  color: context.textHintColor,
                ),
              ),
              SizedBox(height: Dimenssions.height20),
              GestureDetector(
                onTap: () => controller.uploadQris(),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    border: Border.all(
                      color: AppColors.orange.withOpacity(0.3),
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
                                color: AppColors.orange,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Mengupload...',
                              style: TextStyle(
                                color: AppColors.orange,
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
                            color: AppColors.orange,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap untuk upload QRIS',
                            style: TextStyle(
                              color: AppColors.orange,
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
                        style: TextStyle(color: context.textHintColor),
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

  Widget _buildPaymentMethodRow(BuildContext context, String method, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimenssions.height8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(method, style: primaryTextStyle.copyWith(color: context.textColor)),
          Switch(
            value: isActive,
            onChanged: (value) {
              // Handle payment method toggle
            },
            activeColor: AppColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimenssions.height16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
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
                color: context.textColor,
              ),
            ),
            Divider(height: Dimenssions.height24, color: context.dividerColor),
            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Orderan Kamu',
              onTap: () => Get.toNamed(Routes.merchantOrders),
            ),
            _buildMenuItem(
              context,
              icon: Icons.brightness_6_outlined,
              title: 'Tampilan Tema',
              onTap: () => _showThemeSelectionDialog(context),
            ),
            _buildMenuItem(
              context,
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.orange),
      title: Text(title, style: primaryTextStyle.copyWith(color: context.textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: Dimenssions.height16, color: context.textColor),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimenssions.height8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Dimenssions.width100,
            child: Text(label, style: secondaryTextStyle.copyWith(color: context.textSecondaryColor)),
          ),
          Text(': ', style: secondaryTextStyle.copyWith(color: context.textSecondaryColor)),
          Expanded(
            child: Text(value, style: primaryTextStyle.copyWith(color: context.textColor)),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Dimenssions.height20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimenssions.radius20),
            topRight: Radius.circular(Dimenssions.radius20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Dimenssions.height16),
            // Title
            Text(
              'Tampilan Tema',
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font18,
                fontWeight: semiBold,
                color: context.textColor,
              ),
            ),
            SizedBox(height: Dimenssions.height8),
            // Description
            Text(
              'Pilih tema tampilan yang kamu sukai',
              style: secondaryTextStyle.copyWith(
                fontSize: Dimenssions.font12,
                color: context.textSecondaryColor,
              ),
            ),
            SizedBox(height: Dimenssions.height24),
            // Theme Toggle Widget
            ThemeToggleWidget(showLabel: true),
            SizedBox(height: Dimenssions.height24),
            // Info card
            Container(
              padding: EdgeInsets.all(Dimenssions.height15),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(Dimenssions.radius12),
                border: Border.all(
                  color: context.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: Dimenssions.height20,
                    color: AppColors.orange,
                  ),
                  SizedBox(width: Dimenssions.width12),
                  Expanded(
                    child: Text(
                      'Tema akan tersimpan otomatis dan diterapkan ke seluruh aplikasi',
                      style: secondaryTextStyle.copyWith(
                        fontSize: Dimenssions.font11,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimenssions.height20),
          ],
        ),
      ),
    );
  }
}
