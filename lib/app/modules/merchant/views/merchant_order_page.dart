import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: backgroundColor1,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final statuses = [
      'ALL',
      'WAITING_APPROVAL',
      'PROCESSING',
      'READY_FOR_PICKUP',
      'PICKED_UP',
      'COMPLETED',
      'CANCELED'
    ];

    return DefaultTabController(
      length: 7,
      initialIndex: 1, // Set WAITING_APPROVAL as default
      child: Builder(builder: (context) {
        final tabController = DefaultTabController.of(context);

        // Initial load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.filterOrders(statuses[tabController.index]);

          // Listen to tab changes
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              controller.filterOrders(statuses[tabController.index]);
            }
          });
        });

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: backgroundColor1,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: logoColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Container(
                    color: logoColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                          size: Dimenssions.height24,
                        ),
                        SizedBox(width: Dimenssions.width8),
                        Text(
                          'Daftar Pesanan',
                          style: textwhite.copyWith(
                            fontSize: Dimenssions.font18,
                            fontWeight: semiBold,
                          ),
                        ),
                        const Spacer(),
                        // Auto approve switch
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimenssions.width10,
                            vertical: Dimenssions.height4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Terima Otomatis',
                                style: textwhite.copyWith(
                                  fontSize: Dimenssions.font12,
                                ),
                              ),
                              SizedBox(width: Dimenssions.width4),
                              Transform.scale(
                                scale: 0.8,
                                child: Obx(() => Switch(
                                      value: controller.autoApprove.value,
                                      onChanged: (value) =>
                                          controller.toggleAutoApprove(),
                                      activeColor: logoColorSecondary,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor:
                                          Colors.white.withOpacity(0.5),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // TabBar
                  Container(
                    color: logoColor,
                    child: Obx(() => TabBar(
                          isScrollable: true,
                          indicatorColor: Colors.white,
                          indicatorWeight: 3,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white.withOpacity(0.7),
                          labelStyle: TextStyle(
                            fontSize: Dimenssions.font14,
                            fontWeight: semiBold,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: Dimenssions.font14,
                            fontWeight: medium,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimenssions.width8),
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: Dimenssions.width12,
                            vertical: Dimenssions.height12,
                          ),
                          tabs: [
                            _buildTab('Semua', controller.getOrderCount('ALL'),
                                Icons.list),
                            _buildTab(
                                'Menunggu Persetujuan',
                                controller.getOrderCount('WAITING_APPROVAL'),
                                Icons.pending_outlined),
                            _buildTab(
                                'Diproses',
                                controller.getOrderCount('PROCESSING'),
                                Icons.sync),
                            _buildTab(
                                'Siap Diambil',
                                controller.getOrderCount('READY_FOR_PICKUP'),
                                Icons.check_circle_outline),
                            _buildTab(
                                'Dalam Pengantaran',
                                controller.getOrderCount('PICKED_UP'),
                                Icons.local_shipping_outlined),
                            _buildTab(
                                'Selesai',
                                controller.getOrderCount('COMPLETED'),
                                Icons.done_all),
                            _buildTab(
                                'Dibatalkan',
                                controller.getOrderCount('CANCELED'),
                                Icons.cancel_outlined),
                          ],
                        )),
                  ),
                  // TabBarView
                  Expanded(
                    child: Container(
                      color: backgroundColor1,
                      child: TabBarView(
                        physics: const BouncingScrollPhysics(),
                        children:
                            List.generate(7, (index) => _buildOrderList()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTab(String label, int count, IconData icon) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          SizedBox(width: Dimenssions.width6),
          Text(label),
          if (count > 0) ...[
            SizedBox(width: Dimenssions.width6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                count.toString(),
                style: textwhite.copyWith(
                  fontSize: 10,
                  fontWeight: semiBold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshOrders(),
      color: logoColor,
      backgroundColor: backgroundColor1,
      strokeWidth: 3,
      displacement: 40,
      child: Obx(() {
        if (controller.isLoading.value && controller.currentPage.value == 1) {
          return const ShimmerLoading();
        }

        final orders = controller.filteredOrders;

        if (orders.isEmpty) {
          if (controller.hasError.value) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(Dimenssions.height16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: Dimenssions.height48,
                      ),
                      SizedBox(height: Dimenssions.height8),
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: Dimenssions.height16),
                      ElevatedButton.icon(
                        onPressed: () => controller.refreshOrders(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: logoColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimenssions.width16,
                            vertical: Dimenssions.height12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: Dimenssions.height16),
                child: const EmptyState(),
              ),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollEndNotification &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                !controller.isLoadingMore.value &&
                controller.hasMore.value) {
              controller.loadMoreOrders();
            }
            return true;
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: Dimenssions.width8,
              vertical: Dimenssions.height8,
            ),
            itemCount: orders.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < orders.length) {
                return Padding(
                  padding: EdgeInsets.only(bottom: Dimenssions.height8),
                  child: TransactionCard(
                    order: orders[index],
                    controller: controller,
                  ),
                );
              } else if (controller.isLoadingMore.value) {
                return Padding(
                  padding: EdgeInsets.all(Dimenssions.height16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(logoColor),
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(Dimenssions.height16),
                  child: Text(
                    'Tidak ada pesanan lagi',
                    style: subtitleTextStyle.copyWith(
                      fontSize: Dimenssions.font12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          ),
        );
      }),
    );
  }
}
