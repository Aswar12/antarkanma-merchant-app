import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/widgets/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/merchant_home_controller.dart';
import '../../../../theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state.dart';

class MerchantHomePage extends GetView<MerchantHomeController> {
  const MerchantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: logoColor,
        backgroundColor: backgroundColor1,
        strokeWidth: 3,
        displacement: 40,
        child: CustomScrollView(
          key: const PageStorageKey<String>('merchant_home'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section with Store Status Toggle
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
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
                ),
              ),
            ),
            // Combined Overview and Summary
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(Dimenssions.height16),
                padding: EdgeInsets.all(Dimenssions.height16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimenssions.radius12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan',
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font16,
                                  fontWeight: semiBold,
                                ),
                              ),
                              SizedBox(height: Dimenssions.height4),
                              Obx(() => Text(
                                'Rp ${NumberFormat('#,###', 'id_ID').format(controller.todayRevenue.value)}',
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font24,
                                  fontWeight: semiBold,
                                  color: Colors.green,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              Text(
                                'Pendapatan Hari Ini',
                                style: subtitleTextStyle.copyWith(
                                  fontSize: Dimenssions.font12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: Dimenssions.height50,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        SizedBox(width: Dimenssions.width12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: Dimenssions.height16,
                                ),
                                SizedBox(width: Dimenssions.width4),
                                Obx(() => Text(
                                  '${controller.todayCompletedOrders.value} Selesai',
                                  style: primaryTextStyle.copyWith(
                                    fontSize: Dimenssions.font14,
                                    color: Colors.blue,
                                  ),
                                )),
                              ],
                            ),
                            SizedBox(height: Dimenssions.height4),
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  color: Colors.orange,
                                  size: Dimenssions.height16,
                                ),
                                SizedBox(width: Dimenssions.width4),
                                Obx(() => Text(
                                  'Rp ${NumberFormat('#,###', 'id_ID').format(controller.todayAverageOrder.value)}',
                                  style: primaryTextStyle.copyWith(
                                    fontSize: Dimenssions.font14,
                                    color: Colors.orange,
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: Dimenssions.height24),
                    Obx(() {
                      final summary = controller.orderSummary.value?.summary;
                      if (summary == null) return const SizedBox.shrink();

                      return Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                'Total',
                                summary.totalOrders.toString(),
                                Colors.blue,
                              ),
                              SizedBox(width: Dimenssions.width8),
                              _buildStatCard(
                                'Diproses',
                                summary.totalProcessing.toString(),
                                Colors.orange,
                              ),
                              SizedBox(width: Dimenssions.width8),
                              _buildStatCard(
                                'Selesai',
                                summary.totalCompleted.toString(),
                                Colors.green,
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(Dimenssions.height8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimenssions.radius8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font12,
                color: color,
              ),
            ),
            SizedBox(height: Dimenssions.height4),
            Text(
              value,
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font16,
                fontWeight: semiBold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
