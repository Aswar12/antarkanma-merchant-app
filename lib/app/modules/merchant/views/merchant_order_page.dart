import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/merchant_order_controller.dart';
import '../../../../theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state.dart';
import 'package:intl/intl.dart';

class MerchantOrderPage extends GetView<MerchantOrderController> {
  const MerchantOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: Text(
          'Pesanan',
          style: textwhite.copyWith(
            fontSize: Dimenssions.font20,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: logoColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        color: logoColor,
        backgroundColor: backgroundColor1,
        strokeWidth: 3,
        displacement: 40,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Filter Tabs
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: Dimenssions.height8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: Dimenssions.width16),
                  children: [
                    _buildFilterChip('Semua', 'ALL'),
                    _buildFilterChip('Diproses', 'PROCESSING'),
                    _buildFilterChip('Siap Diambil', 'READY_FOR_PICKUP'),
                    _buildFilterChip('Selesai', 'COMPLETED'),
                    _buildFilterChip('Dibatalkan', 'CANCELED'),
                  ],
                ),
              ),
            ),

            // Order List
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverToBoxAdapter(child: ShimmerLoading());
              }

              if (controller.errorMessage.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (controller.filteredOrders.isEmpty) {
                return const SliverToBoxAdapter(child: EmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = controller.filteredOrders[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Dimenssions.width16,
                        vertical: Dimenssions.height8,
                      ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font16,
                                  fontWeight: semiBold,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimenssions.width8,
                                  vertical: Dimenssions.height4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(Dimenssions.radius4),
                                ),
                                child: Text(
                                  order.statusDisplay,
                                  style: TextStyle(
                                    color: _getStatusColor(order.orderStatus),
                                    fontSize: Dimenssions.font12,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimenssions.height12),
                          if (order.items.isNotEmpty) ...[
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                                  child: Image.network(
                                    order.items.first.product.firstImageUrl ?? '',
                                    width: Dimenssions.height60,
                                    height: Dimenssions.height60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: Dimenssions.height60,
                                      height: Dimenssions.height60,
                                      color: backgroundColor3,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: subtitleColor,
                                        size: Dimenssions.height24,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: Dimenssions.width12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.items.first.product.name,
                                        style: primaryTextStyle.copyWith(
                                          fontSize: Dimenssions.font14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                      Text(
                                        '${order.items.first.quantity}x @ ${NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(order.items.first.price)}',
                                        style: subtitleTextStyle.copyWith(
                                          fontSize: Dimenssions.font12,
                                        ),
                                      ),
                                      if (order.items.length > 1)
                                        Text(
                                          '+${order.items.length - 1} items lainnya',
                                          style: subtitleTextStyle.copyWith(
                                            fontSize: Dimenssions.font12,
                                            fontWeight: medium,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimenssions.height12),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.customerName,
                                    style: primaryTextStyle.copyWith(
                                      fontSize: Dimenssions.font14,
                                      fontWeight: medium,
                                    ),
                                  ),
                                  Text(
                                    order.customerPhone,
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: Dimenssions.font12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                order.formattedTotalAmount,
                                style: primaryTextOrange.copyWith(
                                  fontSize: Dimenssions.font16,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                          if (order.orderStatus == 'PROCESSING') ...[
                            SizedBox(height: Dimenssions.height16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => controller.markAsReadyForPickup(order.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: logoColorSecondary,
                                  padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Dimenssions.radius8),
                                  ),
                                ),
                                child: Text(
                                  'Siap Diambil',
                                  style: textwhite.copyWith(
                                    fontSize: Dimenssions.font14,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  childCount: controller.filteredOrders.length,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    return Obx(() {
      final isSelected = controller.currentStatus.value == status;
      return Container(
        margin: EdgeInsets.only(right: Dimenssions.width8),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (bool selected) {
            controller.filterOrders(status);
          },
          backgroundColor: backgroundColor2,
          selectedColor: logoColorSecondary.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? logoColorSecondary : subtitleColor,
            fontWeight: isSelected ? semiBold : regular,
          ),
          checkmarkColor: logoColorSecondary,
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PROCESSING':
        return Colors.blue;
      case 'READY_FOR_PICKUP':
        return Colors.green;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
