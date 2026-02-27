import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/merchant_controller.dart';
import '../../../controllers/merchant_home_controller.dart';
import '../../../data/models/order_model.dart';
import '../../../../theme.dart';
import 'order_details_bottom_sheet.dart';
import '../../../widgets/custom_snackbar.dart';

class MerchantHomePage extends GetView<MerchantHomeController> {
  const MerchantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Need to access merchant data for the header (name, location)
    // Assuming `Get.find<MerchantController>()` is available and has merchant data
    final merchantController = Get.find<MerchantController>();

    return Scaffold(
      backgroundColor: dashBackgroundLight,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: dashPrimary,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        displacement: 40,
        child: CustomScrollView(
          key: const PageStorageKey<String>('merchant_home'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom Header matching the design
            SliverToBoxAdapter(
              child: _buildHeader(merchantController),
            ),

            // Stats Section (Ringkasan Hari Ini)
            SliverToBoxAdapter(
              child: _buildSummarySection(),
            ),

            // Sales Trend Section
            SliverToBoxAdapter(
              child: _buildSalesTrendSection(),
            ),

            // Active Orders Section
            SliverToBoxAdapter(
              child: _buildActiveOrdersSection(),
            ),

            // Add some bottom padding so it doesn't collide with BottomNav
            SliverToBoxAdapter(
              child: SizedBox(height: Dimenssions.height80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MerchantController merchantController) {
    return Container(
      decoration: BoxDecoration(
        color: dashNavyDeep,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(Dimenssions.radius20),
        ),
        boxShadow: [
          BoxShadow(
            color: dashNavyDeep.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          Dimenssions.width20,
          Dimenssions.height60, // Padding for status bar
          Dimenssions.width20,
          Dimenssions.height30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Info and Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MERCHANT DASHBOARD',
                      style: primaryTextStyle.copyWith(
                        color: dashPrimary.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: Dimenssions.height4),
                    Obx(() {
                      final name = merchantController.merchant.value?.name ??
                          'Nama Toko';
                      return Text(
                        name,
                        style: primaryTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: Dimenssions.font20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ],
                ),
              ),
              // Open/Close Toggle Button
              Obx(() => GestureDetector(
                    onTap: () => controller.toggleMerchantStatus(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width16,
                          vertical: Dimenssions.height8),
                      decoration: BoxDecoration(
                        color: controller.isOpen.value
                            ? dashPrimary
                            : Colors.grey.shade600,
                        borderRadius:
                            BorderRadius.circular(Dimenssions.radius30),
                      ),
                      child: Row(
                        children: [
                          if (controller.isOpen.value)
                            Container(
                              width: 8,
                              height: 8,
                              margin:
                                  EdgeInsets.only(right: Dimenssions.width8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            controller.isOpen.value ? 'BUKA' : 'TUTUP',
                            style: primaryTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: Dimenssions.height24),
          // Store Operations Badge
          Container(
            padding: EdgeInsets.all(Dimenssions.height12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimenssions.radius12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Operating Hours
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: dashPrimary.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
                          ),
                          child: Icon(Icons.access_time,
                              color: dashPrimary, size: 20),
                        ),
                        SizedBox(width: Dimenssions.width12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'JAM OPERASIONAL',
                                style: primaryTextStyle.copyWith(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Obx(() {
                                final merchant =
                                    merchantController.merchant.value;
                                String formatTime(String? time) {
                                  if (time == null || time.isEmpty)
                                    return '--:--';
                                  final p = time.split(':');
                                  return p.length >= 2
                                      ? '${p[0]}:${p[1]}'
                                      : time;
                                }

                                final open = formatTime(merchant?.openingTime);
                                final close = formatTime(merchant?.closingTime);
                                return Text(
                                  '$open - $close',
                                  style: primaryTextStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimenssions.font12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.white.withOpacity(0.2),
                    thickness: 1,
                    width: 24,
                  ),
                  // Total Orders
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: dashPrimary.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
                          ),
                          child: Icon(Icons.shopping_bag_outlined,
                              color: dashPrimary, size: 20),
                        ),
                        SizedBox(width: Dimenssions.width12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'TOTAL PESANAN',
                                style: primaryTextStyle.copyWith(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Obx(() {
                                final count = merchantController
                                        .merchant.value?.orderCount ??
                                    0;
                                return Text(
                                  '$count Pesanan',
                                  style: primaryTextStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimenssions.font12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      margin: EdgeInsets.symmetric(horizontal: Dimenssions.width20),
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: dashCardLight,
        borderRadius: BorderRadius.circular(Dimenssions.radius16),
        border: Border.all(color: dashBorderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ringkasan Hari Ini',
                style: primaryTextStyle.copyWith(
                  color: dashTextDark,
                  fontSize: Dimenssions.font14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.now()),
                style: primaryTextStyle.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height16),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final waitingCount = controller.orderSummary.value
                          ?.statusCounts['WAITING_APPROVAL'] ??
                      0;
                  return _buildSummaryItem(
                    icon: Icons.pending_actions,
                    label: 'Pesanan Baru',
                    value: waitingCount.toString(),
                  );
                }),
              ),
              SizedBox(width: Dimenssions.width12),
              Expanded(
                child: Obx(() {
                  // Format revenue to something like 1.2M if needed, but for precision use full
                  String formattedRevenue = NumberFormat.compactCurrency(
                          locale: 'id_ID', symbol: '', decimalDigits: 1)
                      .format(controller.todayRevenue.value);

                  return _buildSummaryItem(
                    icon: Icons.payments_outlined,
                    label: 'Pendapatan',
                    value: formattedRevenue,
                  );
                }),
              ),
              SizedBox(width: Dimenssions.width12),
              Expanded(
                child: Obx(() {
                  return _buildSummaryItem(
                    icon: Icons.check_circle_outline,
                    label: 'Selesai',
                    value: controller.todayCompletedOrders.value.toString(),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      {required IconData icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
      decoration: BoxDecoration(
        color: dashBackgroundLight,
        borderRadius: BorderRadius.circular(Dimenssions.radius12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: dashPrimary, size: 20),
          SizedBox(height: Dimenssions.height4),
          Text(
            label,
            style: primaryTextStyle.copyWith(
              color: Colors.grey.shade500,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimenssions.height4),
          Text(
            value,
            style: primaryTextStyle.copyWith(
              color: dashNavyDeep,
              fontSize: Dimenssions.font16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTrendSection() {
    return Container(
      margin: EdgeInsets.only(
          left: Dimenssions.width20,
          right: Dimenssions.width20,
          top: Dimenssions.height8),
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: dashCardLight,
        borderRadius: BorderRadius.circular(Dimenssions.radius16),
        border: Border.all(color: dashBorderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren Penjualan',
                style: primaryTextStyle.copyWith(
                  color: dashTextDark,
                  fontSize: Dimenssions.font14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.trending_up, color: dashPrimary, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Hari Ini',
                    style: primaryTextStyle.copyWith(
                      color: dashPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height16),
          // Placeholder for the Chart, simulating the HTML SVG graphic
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              // You can use a package like `fl_chart` here later.
              // For now, replacing the gradient SVG with a simple colored box to mimic
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  dashPrimary.withOpacity(0.2),
                  dashPrimary.withOpacity(0.0),
                ],
              ),
            ),
            child: CustomPaint(
              painter: MockChartPainter(color: dashPrimary),
            ),
          ),
          SizedBox(height: Dimenssions.height8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartLabel('08:00'),
              _buildChartLabel('12:00'),
              _buildChartLabel('16:00'),
              _buildChartLabel('20:00'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartLabel(String text) {
    return Text(
      text,
      style: primaryTextStyle.copyWith(
        color: Colors.grey.shade400,
        fontSize: 10,
      ),
    );
  }

  Widget _buildActiveOrdersSection() {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimenssions.width20,
        right: Dimenssions.width20,
        top: Dimenssions.height24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Aktif',
                style: primaryTextStyle.copyWith(
                  color: dashNavyDeep,
                  fontSize: Dimenssions.font16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Obx(() {
                final activeCount = controller.activeOrders.length;
                if (activeCount == 0) return const SizedBox.shrink();

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: dashPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$activeCount AKTIF',
                    style: primaryTextStyle.copyWith(
                      color: dashPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: Dimenssions.height16),
          Obx(() {
            if (controller.isLoadingActiveOrders.value) {
              return Container(
                padding: EdgeInsets.all(Dimenssions.height32),
                child: Center(
                  child: CircularProgressIndicator(
                    color: dashPrimary,
                  ),
                ),
              );
            }

            if (controller.activeOrders.isEmpty) {
              return Container(
                padding: EdgeInsets.all(Dimenssions.height32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: Dimenssions.height12),
                      Text(
                        'Tidak ada pesanan aktif',
                        style: primaryTextStyle.copyWith(
                          color: Colors.grey.shade500,
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: controller.activeOrders.map((order) {
                final items = order.orderItems.map((item) {
                  final productName = item.product.name;
                  final quantity = item.quantity;
                  return '${quantity}x $productName';
                }).toList();

                final isNew = order.status == 'WAITING_APPROVAL';

                return Padding(
                  padding: EdgeInsets.only(bottom: Dimenssions.height16),
                  child: _buildOrderCard(
                    orderId: order.id,
                    orderNumber: '#ORD-${order.id}',
                    customerName: order.customerName,
                    price: order.formattedTotalAmount,
                    paymentMethod: order.paymentMethod,
                    items: items,
                    status: order.status,
                    isNew: isNew,
                    createdAt: order.formattedDate,
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required int orderId,
    required String orderNumber,
    required String customerName,
    required String price,
    required String paymentMethod,
    required List<String> items,
    required String status,
    required bool isNew,
    required String createdAt,
  }) {
    debugPrint('🔵 [_buildOrderCard] Order #$orderId - Status: "$status"');
    
    return GestureDetector(
      onTap: () => _viewOrderDetail(orderId),
      child: Container(
        padding: EdgeInsets.all(Dimenssions.height16),
        decoration: BoxDecoration(
          color: dashCardLight,
          borderRadius: BorderRadius.circular(Dimenssions.radius12),
          border: Border.all(color: dashBorderLight),
          boxShadow: [
            if (isNew)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
        children: [
          if (isNew)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: dashPrimary,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(Dimenssions.radius12),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: isNew ? 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderNumber,
                          style: primaryTextStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          customerName,
                          style: primaryTextStyle.copyWith(
                            color: dashTextDark,
                            fontSize: Dimenssions.font14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          createdAt,
                          style: primaryTextStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(status),
                            style: primaryTextStyle.copyWith(
                              color: _getStatusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          price,
                          style: primaryTextStyle.copyWith(
                            color: dashPrimary,
                            fontSize: Dimenssions.font14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          paymentMethod,
                          style: primaryTextStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Dimenssions.height12),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant,
                              size: 14, color: Colors.grey.shade600),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: primaryTextStyle.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: Dimenssions.height16),
                Row(
                  children: [
                    if (status == 'PENDING' || status == 'WAITING_APPROVAL')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _acceptOrder(orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dashPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimenssions.radius8),
                            ),
                          ),
                          child: Text(
                            'TERIMA',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    if (status == 'PROCESSING')
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _markAsReady(orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dashPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimenssions.radius8),
                            ),
                          ),
                          child: Text(
                            'SIAP DIAMBIL',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    if (status == 'PENDING' || status == 'WAITING_APPROVAL') ...[
                      SizedBox(width: Dimenssions.width12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectOrder(orderId),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimenssions.radius8),
                            ),
                          ),
                          child: Text(
                            'TOLAK',
                            style: primaryTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
      case 'WAITING_APPROVAL':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'READY_FOR_PICKUP':
        return Colors.green;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
      case 'WAITING_APPROVAL':
        return 'MENUNGGU';
      case 'PROCESSING':
        return 'DIPROSES';
      case 'READY_FOR_PICKUP':
        return 'SIAP';
      case 'COMPLETED':
        return 'SELESAI';
      default:
        return status;
    }
  }

  void _acceptOrder(int orderId) {
    debugPrint('🔵 [MerchantHomePage] Accept order button pressed - Order ID: $orderId');
    try {
      controller.approveOrder(orderId);
    } catch (e) {
      debugPrint('🔴 [MerchantHomePage] Error accepting order: $e');
      CustomSnackbarX.showError(
        message: 'Gagal menerima pesanan: $e',
        position: SnackPosition.BOTTOM,
      );
    }
  }

  void _rejectOrder(int orderId) {
    debugPrint('🔵 [MerchantHomePage] Reject order button pressed - Order ID: $orderId');
    try {
      controller.showRejectDialog(orderId);
    } catch (e) {
      debugPrint('🔴 [MerchantHomePage] Error rejecting order: $e');
      CustomSnackbarX.showError(
        message: 'Gagal menolak pesanan: $e',
        position: SnackPosition.BOTTOM,
      );
    }
  }

  void _markAsReady(int orderId) {
    debugPrint('🔵 [MerchantHomePage] Mark as ready button pressed - Order ID: $orderId');
    try {
      controller.markOrderReady(orderId);
    } catch (e) {
      debugPrint('🔴 [MerchantHomePage] Error marking order as ready: $e');
      CustomSnackbarX.showError(
        message: 'Gagal menandai pesanan siap: $e',
        position: SnackPosition.BOTTOM,
      );
    }
  }

  void _viewOrderDetail(int orderId) {
    debugPrint('🔵 [MerchantHomePage] View order detail button pressed - Order ID: $orderId');
    try {
      // Find the order from active orders list
      final order = controller.activeOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () {
          debugPrint('🔴 [MerchantHomePage] Order #$orderId not found in active orders');
          throw Exception('Order not found');
        },
      );

      debugPrint('🔵 [MerchantHomePage] Opening order detail bottom sheet for order #$orderId');
      Get.bottomSheet(
        OrderDetailsBottomSheet(order: order),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    } catch (e) {
      debugPrint('🔴 [MerchantHomePage] Error showing order detail: $e');
      CustomSnackbarX.showError(
        message: 'Data order tidak ditemukan',
        position: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildMockOrderCard({
    required String orderNumber,
    required String customerName,
    required String price,
    required String paymentMethod,
    required List<String> items,
    required bool isNew,
  }) {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: dashCardLight,
        borderRadius: BorderRadius.circular(Dimenssions.radius12),
        border: Border.all(color: dashBorderLight),
        boxShadow: [
          if (isNew)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Stack(
        children: [
          // Left border indicator
          if (isNew)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: dashPrimary,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(Dimenssions.radius12),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: isNew ? 8 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderNumber,
                          style: primaryTextStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          customerName,
                          style: primaryTextStyle.copyWith(
                            color: dashTextDark,
                            fontSize: Dimenssions.font14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: primaryTextStyle.copyWith(
                            color: dashPrimary,
                            fontSize: Dimenssions.font14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          paymentMethod,
                          style: primaryTextStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Dimenssions.height12),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant,
                              size: 14, color: Colors.grey.shade600),
                          SizedBox(width: 8),
                          Text(
                            item,
                            style: primaryTextStyle.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: Dimenssions.height16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dashPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
                          ),
                        ),
                        child: Text(
                          'TERIMA',
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimenssions.width12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
                          ),
                        ),
                        child: Text(
                          'DETAIL',
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple mock painter to draw the line chart shape
class MockChartPainter extends CustomPainter {
  final Color color;
  MockChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2,
        size.width * 0.4, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.8, size.height * 0.3, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
