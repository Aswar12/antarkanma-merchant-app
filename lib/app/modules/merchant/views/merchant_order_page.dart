import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:antarkanma_merchant/app/data/models/order_item_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/widgets/merchant_order_card.dart';

class MerchantOrderPage extends StatefulWidget {
  const MerchantOrderPage({super.key});

  @override
  State<MerchantOrderPage> createState() => MerchantOrderPageState();
}

class MerchantOrderPageState extends State<MerchantOrderPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final MerchantOrderController controller;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize the controller using Get.find()
    controller = Get.find<MerchantOrderController>();

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            controller.filterOrders(OrderItemStatus.pending);
            break;
          case 1:
            controller.filterOrders(OrderItemStatus.processing);
            break;
          case 2:
            controller.filterOrders(OrderItemStatus.readyForPickup);
            break;
          case 3:
            controller.filterOrders(OrderItemStatus.completed);
            break;
          case 4:
            controller.filterOrders('all');
            break;
        }
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor1,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStatusTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(OrderItemStatus.pending),
                _buildOrderList(OrderItemStatus.processing),
                _buildOrderList(OrderItemStatus.readyForPickup),
                _buildOrderList(OrderItemStatus.completed),
                _buildOrderList('all'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Text(
        'Daftar Pesanan',
        style: primaryTextStyle.copyWith(
          color: logoColor,
          fontSize: Dimenssions.font18,
          fontWeight: semiBold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: logoColor),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: logoColor),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      color: Colors.white,
      child: Obx(() {
        final stats = controller.orderStats;
        final totalOrders = (stats[OrderItemStatus.pending] ?? 0) +
            (stats[OrderItemStatus.processing] ?? 0) +
            (stats[OrderItemStatus.readyForPickup] ?? 0) +
            (stats[OrderItemStatus.completed] ?? 0) +
            (stats[OrderItemStatus.canceled] ?? 0);
        return TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: logoColor,
          unselectedLabelColor: subtitleColor,
          indicatorColor: logoColor,
          tabs: [
            _buildTab('Pending', stats[OrderItemStatus.pending] ?? 0),
            _buildTab('Proses', stats[OrderItemStatus.processing] ?? 0),
            _buildTab('Siap Antar', stats[OrderItemStatus.readyForPickup] ?? 0),
            _buildTab('Selesai', stats[OrderItemStatus.completed] ?? 0),
            _buildTab('Semua', totalOrders),
          ],
        );
      }),
    );
  }

  Widget _buildTab(String text, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          if (count > 0) ...[
            SizedBox(width: Dimenssions.width8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimenssions.width6,
                vertical: Dimenssions.height2,
              ),
              decoration: BoxDecoration(
                color: logoColorSecondary,
                borderRadius: BorderRadius.circular(Dimenssions.radius8),
              ),
              child: Text(
                count.toString(),
                style: primaryTextStyle.copyWith(
                  color: Colors.white,
                  fontSize: Dimenssions.font12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return Obx(() {
      if (controller.isLoading.value && controller.orders.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(logoColorSecondary),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.orders.isEmpty) {
        return _buildErrorState();
      }

      if (controller.filteredOrders.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        color: logoColorSecondary,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(Dimenssions.width16),
          itemCount: controller.filteredOrders.length +
              (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.filteredOrders.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(Dimenssions.width8),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(logoColorSecondary),
                  ),
                ),
              );
            }
            final transaction = controller.filteredOrders[index];
            return MerchantOrderCard(
              transaction: transaction,
              onTap: (transaction) {
                _showOrderActions(transaction);
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: Dimenssions.height45,
            color: alertColor,
          ),
          SizedBox(height: Dimenssions.height20),
          Text(
            controller.errorMessage.value,
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font16,
              color: alertColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimenssions.height20),
          TextButton(
            onPressed: () => controller.refreshOrders(),
            child: Text(
              'Coba Lagi',
              style: primaryTextStyle.copyWith(
                color: logoColorSecondary,
                fontSize: Dimenssions.font16,
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon_empty_cart.png',
            width: Dimenssions.height80,
          ),
          SizedBox(height: Dimenssions.height20),
          Text(
            'Belum ada pesanan',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font20,
              fontWeight: semiBold,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderActions(TransactionModel transaction) {
    final orderStatus = transaction.order?.orderStatus ?? transaction.status;
    if (controller.canProcessOrder(orderStatus)) {
      Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Animated background overlay
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              // Bottom Sheet Content
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: 0.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, value * 400),
                    child: child,
                  );
                },
                child: DraggableScrollableSheet(
                  initialChildSize: 0.85,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Dimenssions.radius20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag Handle
                        Container(
                          margin: EdgeInsets.only(top: 12),
                        ),
                        // Header
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimenssions.width16,
                            vertical: Dimenssions.height16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(Dimenssions.radius20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          logoColorSecondary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.receipt_outlined,
                                      color: logoColorSecondary,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: Dimenssions.width12),
                                  Text(
                                    'Detail Pesanan',
                                    style: primaryTextStyle.copyWith(
                                      fontSize: Dimenssions.font18,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: subtitleColor),
                                onPressed: () => Get.back(),
                              ),
                            ],
                          ),
                        ),
                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.all(Dimenssions.width16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Order Status
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimenssions.width12,
                                      vertical: Dimenssions.height8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          logoColorSecondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          Dimenssions.radius8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18,
                                          color: logoColorSecondary,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Status: ${transaction.statusDisplay}',
                                          style: primaryTextStyle.copyWith(
                                            color: logoColorSecondary,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: Dimenssions.height20),

                                  // Order Items Section
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        color: logoColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Item Pesanan',
                                        style: primaryTextStyle.copyWith(
                                          fontSize: Dimenssions.font16,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: Dimenssions.height12),

                                  // Items List with Card Style
                                  ...transaction.items
                                      .map((item) => Container(
                                            margin: EdgeInsets.only(
                                                bottom: Dimenssions.height12),
                                            padding: EdgeInsets.all(
                                                Dimenssions.width12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimenssions.radius12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Product Image
                                                if (item.product.galleries
                                                    .isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimenssions
                                                                .radius8),
                                                    child: Image.network(
                                                      item.product
                                                          .firstImageUrl,
                                                      width:
                                                          Dimenssions.width60,
                                                      height:
                                                          Dimenssions.width60,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                        width:
                                                            Dimenssions.width60,
                                                        height:
                                                            Dimenssions.width60,
                                                        color: backgroundColor3,
                                                        child: Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color:
                                                                subtitleColor),
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(
                                                    width: Dimenssions.width12),
                                                // Product Details
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.product.name,
                                                        style: primaryTextStyle
                                                            .copyWith(
                                                          fontWeight: medium,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: Dimenssions
                                                              .height4),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: logoColorSecondary
                                                                  .withOpacity(
                                                                      0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              '${item.quantity}x',
                                                              style:
                                                                  primaryTextStyle
                                                                      .copyWith(
                                                                color:
                                                                    logoColorSecondary,
                                                                fontSize:
                                                                    Dimenssions
                                                                        .font12,
                                                                fontWeight:
                                                                    medium,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            item.formattedPrice,
                                                            style:
                                                                primaryTextStyle
                                                                    .copyWith(
                                                              color:
                                                                  subtitleColor,
                                                              fontSize:
                                                                  Dimenssions
                                                                      .font12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                          height: Dimenssions
                                                              .height4),
                                                      Text(
                                                        item.formattedTotalPrice,
                                                        style: primaryTextStyle
                                                            .copyWith(
                                                          color: logoColor,
                                                          fontWeight: semiBold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                      .toList(),

                                  SizedBox(height: Dimenssions.height20),

                                  // Total Section with Card Style
                                  Container(
                                    padding:
                                        EdgeInsets.all(Dimenssions.width16),
                                    decoration: BoxDecoration(
                                      color:
                                          logoColorSecondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          Dimenssions.radius12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Subtotal',
                                              style: primaryTextStyle,
                                            ),
                                            Text(
                                              transaction.formattedTotalPrice,
                                              style: primaryTextStyle,
                                            ),
                                          ],
                                        ),
                                        if (transaction.shippingPrice > 0) ...[
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Biaya Pengiriman',
                                                style: primaryTextStyle,
                                              ),
                                              Text(
                                                transaction
                                                    .formattedShippingPrice,
                                                style: primaryTextStyle,
                                              ),
                                            ],
                                          ),
                                        ],
                                        SizedBox(height: 12),
                                        Divider(color: Colors.grey[300]),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total Pembayaran',
                                              style: primaryTextStyle.copyWith(
                                                fontWeight: semiBold,
                                              ),
                                            ),
                                            Text(
                                              transaction.formattedGrandTotal,
                                              style: primaryTextStyle.copyWith(
                                                fontWeight: semiBold,
                                                color: logoColor,
                                                fontSize: Dimenssions.font16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: Dimenssions.height20),

                                  // Customer Information Section
                                  if (transaction.user != null) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          color: logoColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Informasi Pemesan',
                                          style: primaryTextStyle.copyWith(
                                            fontSize: Dimenssions.font16,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Dimenssions.height12),
                                    Container(
                                      padding:
                                          EdgeInsets.all(Dimenssions.width16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            Dimenssions.radius12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow(
                                            Icons.person,
                                            'Nama',
                                            transaction.user!.name,
                                          ),
                                          if (transaction.user!.phoneNumber !=
                                              null) ...[
                                            SizedBox(height: 8),
                                            _buildInfoRow(
                                              Icons.phone,
                                              'Telepon',
                                              transaction.user!.phoneNumber!,
                                            ),
                                          ],
                                          if (transaction.user!.email !=
                                              null) ...[
                                            SizedBox(height: 8),
                                            _buildInfoRow(
                                              Icons.email,
                                              'Email',
                                              transaction.user!.email!,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: Dimenssions.height20),
                                  ],

                                  // Delivery Address Section
                                  if (transaction.userLocation != null) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: logoColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Alamat Pengiriman',
                                          style: primaryTextStyle.copyWith(
                                            fontSize: Dimenssions.font16,
                                            fontWeight: medium,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Dimenssions.height12),
                                    Container(
                                      padding:
                                          EdgeInsets.all(Dimenssions.width16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            Dimenssions.radius12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildInfoRow(
                                            Icons.location_on,
                                            'Alamat',
                                            transaction
                                                .userLocation!.fullAddress,
                                          ),
                                          SizedBox(height: 8),
                                          _buildInfoRow(
                                            Icons.phone,
                                            'Telepon',
                                            transaction.userLocation!
                                                .formattedPhoneNumber,
                                          ),
                                          if (transaction.userLocation!.notes
                                                  ?.isNotEmpty ??
                                              false) ...[
                                            SizedBox(height: 8),
                                            _buildInfoRow(
                                              Icons.note,
                                              'Catatan',
                                              transaction.userLocation!.notes!,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],

                                  SizedBox(height: Dimenssions.height24),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Get.back();
                                            _showRejectDialog(transaction);
                                          },
                                          icon: Icon(Icons.close),
                                          label: Text('Tolak'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                alertColor.withOpacity(0.1),
                                            foregroundColor: alertColor,
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                              vertical: Dimenssions.height16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimenssions.radius12),
                                              side:
                                                  BorderSide(color: alertColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: Dimenssions.width12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Get.back();
                                            _showProcessDialog(transaction);
                                          },
                                          icon: Icon(Icons.check),
                                          label: Text('Terima'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: logoColorSecondary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.symmetric(
                                              vertical: Dimenssions.height16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimenssions.radius12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: subtitleColor,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: primaryTextStyle.copyWith(
                  color: subtitleColor,
                  fontSize: Dimenssions.font12,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: primaryTextStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProcessDialog(TransactionModel transaction) {
    Get.dialog(
      AlertDialog(
        backgroundColor: backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: logoColorSecondary,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Proses Pesanan',
              style: primaryTextStyle.copyWith(
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin memproses pesanan ini?',
          style: primaryTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: primaryTextStyle.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.processOrder(transaction.id.toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: logoColorSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimenssions.radius8),
              ),
            ),
            child: Text(
              'Proses',
              style: primaryTextStyle.copyWith(
                color: backgroundColor1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(TransactionModel transaction) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: backgroundColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              color: alertColor,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Tolak Pesanan',
              style: primaryTextStyle.copyWith(
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin menolak pesanan ini?',
              style: primaryTextStyle,
            ),
            SizedBox(height: Dimenssions.height16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Alasan penolakan (opsional)',
                hintStyle: primaryTextStyle.copyWith(
                  color: subtitleColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                  borderSide: BorderSide(color: backgroundColor3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                  borderSide: BorderSide(color: logoColorSecondary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: primaryTextStyle.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.rejectOrder(
                transaction.id.toString(),
                reasonController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: alertColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimenssions.radius8),
              ),
            ),
            child: Text(
              'Tolak',
              style: primaryTextStyle.copyWith(
                color: backgroundColor1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
