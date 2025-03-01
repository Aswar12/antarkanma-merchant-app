import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../../../controllers/merchant_home_controller.dart';

class HeaderSection extends StatelessWidget {
  final MerchantHomeController controller;

  const HeaderSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: logoColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: textwhite.copyWith(
                      fontSize: Dimenssions.font24,
                      fontWeight: semiBold,
                    ),
                  ),
                  SizedBox(height: Dimenssions.height4),
                  Obx(() {
                    final waitingCount = controller.orderSummary.value?.statusCounts['WAITING_APPROVAL'] ?? 0;
                    return Text(
                      '$waitingCount pesanan menunggu persetujuan',
                      style: textwhite.copyWith(
                        fontSize: Dimenssions.font14,
                      ),
                    );
                  }),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status Toko',
                    style: textwhite.copyWith(
                      fontSize: Dimenssions.font14,
                    ),
                  ),
                  Obx(() => Switch(
                    value: controller.isOpen.value,
                    onChanged: (value) => controller.toggleMerchantStatus(),
                    activeColor: logoColorSecondary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.5),
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
