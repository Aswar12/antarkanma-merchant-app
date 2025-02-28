import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/merchant_order_controller.dart';
import '../../../../theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_card.dart';

class MerchantOrderPage extends GetView<MerchantOrderController> {
  const MerchantOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        color: logoColor,
        backgroundColor: backgroundColor1,
        strokeWidth: 3,
        displacement: 40,
        child: CustomScrollView(
          key: const PageStorageKey<String>('merchant_orders'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section with Status Filter
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
                                'Daftar Pesanan',
                                style: textwhite.copyWith(
                                  fontSize: Dimenssions.font24,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Auto Approve',
                                style: textwhite.copyWith(
                                  fontSize: Dimenssions.font14,
                                ),
                              ),
                              Obx(() => Switch(
                                value: controller.autoApprove.value,
                                onChanged: (value) => controller.toggleAutoApprove(),
                                activeColor: logoColorSecondary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(0.5),
                              )),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: Dimenssions.height8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusFilter('ALL', 'Semua'),
                            SizedBox(width: Dimenssions.width8),
                            _buildStatusFilter('WAITING_APPROVAL', 'Menunggu'),
                            SizedBox(width: Dimenssions.width8),
                            _buildStatusFilter('PROCESSING', 'Diproses'),
                            SizedBox(width: Dimenssions.width8),
                            _buildStatusFilter('READY_FOR_PICKUP', 'Siap Diambil'),
                            SizedBox(width: Dimenssions.width8),
                            _buildStatusFilter('COMPLETED', 'Selesai'),
                            SizedBox(width: Dimenssions.width8),
                            _buildStatusFilter('CANCELED', 'Dibatalkan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Empty, Loading, or List State
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ShimmerLoading();
                }
                
                if (controller.filteredOrders.isEmpty) {
                  return const EmptyState();
                }

                if (controller.hasError.value) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.filteredOrders[index];
                    return TransactionCard(
                      order: order,
                      controller: controller,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(String status, String label) {
    return Obx(() {
      final isSelected = controller.currentStatus == status;
      return InkWell(
        onTap: () => controller.filterOrders(status),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimenssions.width12,
            vertical: Dimenssions.height6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? logoColorSecondary : Colors.white,
            borderRadius: BorderRadius.circular(Dimenssions.radius20),
          ),
          child: Text(
            label,
            style: isSelected
                ? textwhite.copyWith(
                    fontSize: Dimenssions.font12,
                    fontWeight: medium,
                  )
                : primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font12,
                    fontWeight: medium,
                  ),
          ),
        ),
      );
    });
  }
}
