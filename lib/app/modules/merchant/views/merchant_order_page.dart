import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/widgets/merchant_order_card.dart';
import 'package:antarkanma_merchant/app/widgets/order_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:antarkanma_merchant/app/data/enums/order_item_status.dart';

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
    controller = Get.find<MerchantOrderController>();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          controller.filterOrders(OrderItemStatus.pending.value);
          break;
        case 1:
          controller.filterOrders(OrderItemStatus.processing.value);
          break;
        case 2:
          controller.filterOrders(OrderItemStatus.ready.value);
          break;
        case 3:
          controller.filterOrders(OrderItemStatus.completed.value);
          break;
        case 4:
          controller.filterOrders('all');
          break;
      }
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      controller.loadMore();
    }
  }

  void _showOrderDetails(TransactionModel transaction) {
    final orderStatus = transaction.order?.orderStatus ?? transaction.status;
    if (controller.canProcessOrder(orderStatus)) {
      Get.bottomSheet(
        OrderDetailsBottomSheet(
          transaction: transaction,
          controller: controller,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    }
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

      if (controller.errorMessage.value.isNotEmpty && controller.orders.isEmpty) {
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
                    valueColor: AlwaysStoppedAnimation<Color>(logoColorSecondary),
                  ),
                ),
              );
            }
            final transaction = controller.filteredOrders[index];
            return MerchantOrderCard(
              transaction: transaction,
              onTap: _showOrderDetails,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor1,
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Obx(() {
              final stats = controller.orderStats;
              final totalOrders = (stats[OrderItemStatus.pending.value] ?? 0) +
                  (stats[OrderItemStatus.processing.value] ?? 0) +
                  (stats[OrderItemStatus.ready.value] ?? 0) +
                  (stats[OrderItemStatus.completed.value] ?? 0) +
                  (stats[OrderItemStatus.canceled.value] ?? 0);
              return TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: logoColor,
                unselectedLabelColor: subtitleColor,
                indicatorColor: logoColor,
                tabs: [
                  _buildTab('Pending', stats[OrderItemStatus.pending.value] ?? 0),
                  _buildTab('Proses', stats[OrderItemStatus.processing.value] ?? 0),
                  _buildTab('Siap Antar', stats[OrderItemStatus.ready.value] ?? 0),
                  _buildTab('Selesai', stats[OrderItemStatus.completed.value] ?? 0),
                  _buildTab('Semua', totalOrders),
                ],
              );
            }),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(OrderItemStatus.pending.value),
                _buildOrderList(OrderItemStatus.processing.value),
                _buildOrderList(OrderItemStatus.ready.value),
                _buildOrderList(OrderItemStatus.completed.value),
                _buildOrderList('all'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
