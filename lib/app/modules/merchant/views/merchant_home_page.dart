import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/merchant_home_controller.dart';
import '../../../../theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state.dart';
import '../../../widgets/order_details_bottom_sheet.dart';
import 'package:intl/intl.dart';

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
            // Header Section with Auto Approve Toggle
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
                                'Pesanan Masuk',
                                style: textwhite.copyWith(
                                  fontSize: Dimenssions.font24,
                                  fontWeight: semiBold,
                                ),
                              ),
                              SizedBox(height: Dimenssions.height4),
                              Obx(() => Text(
                                '${controller.newTransactions.length} pesanan menunggu persetujuan',
                                style: textwhite.copyWith(
                                  fontSize: Dimenssions.font14,
                                ),
                              )),
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
                
                if (controller.newTransactions.isEmpty) {
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
                  itemCount: controller.newTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.newTransactions[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: Dimenssions.height16,
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
                                'Order #${transaction.id}',
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
                                  color: logoColorSecondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(Dimenssions.radius4),
                                ),
                                child: Text(
                                  transaction.statusDisplay,
                                  style: primaryTextOrange.copyWith(
                                    fontSize: Dimenssions.font12,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimenssions.height12),
                          if (transaction.items.isNotEmpty) ...[
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                                  child: Image.network(
                                    transaction.items.first.product.firstImageUrl ?? '',
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
                                        transaction.items.first.product.name,
                                        style: primaryTextStyle.copyWith(
                                          fontSize: Dimenssions.font14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                      Text(
                                        '${transaction.items.first.quantity}x @ ${NumberFormat.currency(
                                          locale: 'id_ID',
                                          symbol: 'Rp ',
                                          decimalDigits: 0,
                                        ).format(transaction.items.first.price)}',
                                        style: subtitleTextStyle.copyWith(
                                          fontSize: Dimenssions.font12,
                                        ),
                                      ),
                                      if (transaction.items.length > 1)
                                        Text(
                                          '+${transaction.items.length - 1} items lainnya',
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
                                    transaction.customerName,
                                    style: primaryTextStyle.copyWith(
                                      fontSize: Dimenssions.font14,
                                      fontWeight: medium,
                                    ),
                                  ),
                                  Text(
                                    transaction.customerPhone,
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: Dimenssions.font12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                transaction.formattedTotalAmount,
                                style: primaryTextOrange.copyWith(
                                  fontSize: Dimenssions.font16,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimenssions.height16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => controller.rejectTransaction(transaction.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(Dimenssions.radius8),
                                    ),
                                  ),
                                  child: Text(
                                    'Tolak',
                                    style: textwhite.copyWith(
                                      fontSize: Dimenssions.font14,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Dimenssions.width12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => controller.approveTransaction(transaction.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: logoColorSecondary,
                                    padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(Dimenssions.radius8),
                                    ),
                                  ),
                                  child: Text(
                                    'Terima',
                                    style: textwhite.copyWith(
                                      fontSize: Dimenssions.font14,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
