import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../../../controllers/merchant_home_controller.dart';

class HeaderSection extends StatelessWidget {
  final MerchantHomeController controller;

  const HeaderSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: primaryGradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Toko Saya',
                      style: textwhite.copyWith(
                        fontSize: Dimenssions.font24,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selamat datang kembali!',
                      style: textwhite.copyWith(
                        fontSize: Dimenssions.font14,
                      ),
                    ),
                  ],
                ),
                // Auto Approve Toggle
                Obx(() => Switch(
                      value: controller.autoApprove.value,
                      onChanged: (value) => controller.toggleAutoApprove(),
                      activeColor: logoColorSecondary,
                      activeTrackColor: logoColorSecondary.withOpacity(0.5),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Auto Approve: ${controller.autoApprove.value ? 'Aktif' : 'Tidak Aktif'}',
              style: textwhite.copyWith(
                fontSize: Dimenssions.font12,
                fontWeight: medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
