import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/services/print_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final merchantController = Get.find<MerchantProfileController>();
  late final MerchantOrderController orderController;
  bool _isPrinting = false;
  bool _isScanning = false;
  bool _expandItems = true;
  bool _expandCustomer = true;
  bool _expandDelivery = false;
  bool _expandPayment = true;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<MerchantOrderController>()) {
      orderController = Get.find<MerchantOrderController>();
    }
    ever(orderController.loadingOrders, (_) {
      if (mounted) setState(() {});
    });
    ever(orderController.orders, (_) {
      if (mounted) setState(() {});
    });
  }

  bool get isLoadingAction =>
      orderController.loadingOrders[widget.order.id.toString()] == true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildContent(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomAction(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final color = _getStatusColor();
    return AppBar(
      backgroundColor: Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      elevation: 0,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Get.back()),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Order ID - More prominent with copy-to-clipboard
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Copy order ID to clipboard
                      Clipboard.setData(ClipboardData(text: widget.order.orderNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order ID ${widget.order.orderNumber} disalin!'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: logoColor,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text('#${widget.order.orderNumber}',
                              style: primaryTextStyle.copyWith(
                                  fontSize: 16, fontWeight: bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy,
                          size: 14,
                          color: secondaryTextColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(6)),
                  child: Text(widget.order.statusDisplay,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Date/time - smaller and subtler
            Text(
                DateFormat('dd MMM yyyy, HH:mm').format(widget.order.createdAt),
                style: secondaryTextStyle.copyWith(fontSize: 10)),
          ]),
      actions: [
        // Print button - ORANGE color for better visibility
        IconButton(
            icon: Icon(_isPrinting ? Icons.hourglass_empty : Icons.print,
                color: AppColors.orange),
            onPressed: _isPrinting ? null : _handlePrintReceipt,
            tooltip: 'Cetak Struk'),
      ],
    );
  }


  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 90),
      child: Column(children: [
        const SizedBox(height: 12),
        _buildOrderInfoCard(),
        const SizedBox(height: 8),
        _buildExpandableCard(
            title: 'Produk (${widget.order.items.length})',
            icon: Icons.shopping_bag,
            isExpanded: _expandItems,
            onToggle: () => setState(() => _expandItems = !_expandItems),
            child: _buildItemsList()),
        const SizedBox(height: 8),
        _buildExpandableCard(
            title: 'Pelanggan',
            icon: Icons.person,
            isExpanded: _expandCustomer,
            onToggle: () => setState(() => _expandCustomer = !_expandCustomer),
            child: _buildCustomerInfo()),
        if (widget.order.customer.deliveryAddress != null) ...[
          const SizedBox(height: 8),
          _buildExpandableCard(
              title: 'Pengiriman',
              icon: Icons.location_on,
              isExpanded: _expandDelivery,
              onToggle: () =>
                  setState(() => _expandDelivery = !_expandDelivery),
              child: _buildDeliveryInfo(),
              showArrow: false),
        ],
        const SizedBox(height: 8),
        _buildExpandableCard(
            title: 'Pembayaran',
            icon: Icons.payment,
            isExpanded: _expandPayment,
            onToggle: () => setState(() => _expandPayment = !_expandPayment),
            child: _buildPaymentInfo()),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.receipt_long, size: 18, color: AppColors.orange),
          const SizedBox(width: 8),
          Text('Detail Order',
              style:
                  primaryTextStyle.copyWith(fontSize: 14, fontWeight: semiBold))
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child:
                  _buildInfoItem('ID Order', '#${widget.order.orderNumber}')),
          const SizedBox(width: 16),
          if (widget.order.notes != null && widget.order.notes!.isNotEmpty)
            Expanded(child: _buildInfoItem('Catatan', widget.order.notes!)),
        ]),
      ]),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: secondaryTextStyle.copyWith(fontSize: 10)),
      const SizedBox(height: 2),
      Text(value,
          style: primaryTextStyle.copyWith(fontSize: 11, fontWeight: medium),
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
    ]);
  }

  Widget _buildExpandableCard(
      {required String title,
      required IconData icon,
      required bool isExpanded,
      required VoidCallback onToggle,
      required Widget child,
      bool showArrow = true}) {
    return Container(
      decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon, size: 18, color: AppColors.orange),
              const SizedBox(width: 8),
              Text(title,
                  style: primaryTextStyle.copyWith(
                      fontSize: 14, fontWeight: semiBold)),
              const Spacer(),
              if (showArrow)
                RotationTransition(
                    turns: AlwaysStoppedAnimation(isExpanded ? 0.5 : 0),
                    child: Icon(Icons.expand_more,
                        size: 20, color: Get.isDarkMode ? AppColors.darkTextHint : AppColors.lightTextHint)),
            ]),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: child),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ]),
    );
  }

  Widget _buildItemsList() {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.order.items.length,
        separatorBuilder: (_, __) => const Divider(height: 12),
        itemBuilder: (_, index) {
          final item = widget.order.items[index];
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.product.firstImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.product.firstImageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                            width: 50, height: 50, 
                            color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey[200]),
                        errorWidget: (_, __, ___) => Container(
                            width: 50, height: 50, 
                            color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey[200]))
                    : Container(
                        width: 50, height: 50, 
                        color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey[200])),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(item.product.name,
                      style: primaryTextStyle.copyWith(
                          fontSize: 13, fontWeight: medium),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (item.variant != null) const SizedBox(height: 2),
                  if (item.variant != null)
                    Text(item.variant?.name ?? '',
                        style: secondaryTextStyle.copyWith(fontSize: 10)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                            color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('${item.quantity}x',
                            style: secondaryTextStyle.copyWith(fontSize: 10))),
                    const SizedBox(width: 6),
                    Text(item.formattedPrice,
                        style: priceTextStyle.copyWith(
                            fontSize: 12, fontWeight: semiBold))
                  ]),
                  if (item.customerNote != null &&
                      item.customerNote!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('📝 ${item.customerNote}',
                        style: secondaryTextStyle.copyWith(
                            fontSize: 10, 
                            color: Get.isDarkMode ? Colors.lightBlueAccent : Colors.blue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                  ],
                ])),
          ]);
        });
  }

  Widget _buildCustomerInfo() {
    final hasPhoto = widget.order.customer.photo != null &&
        widget.order.customer.photo!.isNotEmpty;

    return Column(children: [
      Row(children: [
        hasPhoto
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.order.customer.photo!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircleAvatar(
                    radius: 20,
                    backgroundColor: logoColorSecondary.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: logoColorSecondary),
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 20,
                    backgroundColor: logoColorSecondary.withValues(alpha: 0.2),
                    child: Text(
                      widget.order.customerName.isNotEmpty
                          ? widget.order.customerName[0].toUpperCase()
                          : '?',
                      style: primaryTextStyle.copyWith(
                          fontSize: 14, fontWeight: bold),
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                radius: 20,
                backgroundColor: logoColorSecondary.withValues(alpha: 0.2),
                child: Text(
                    widget.order.customerName.isNotEmpty
                        ? widget.order.customerName[0].toUpperCase()
                        : '?',
                    style: primaryTextStyle.copyWith(
                        fontSize: 14, fontWeight: bold))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nama', style: secondaryTextStyle.copyWith(fontSize: 10)),
          Text(widget.order.customerName,
              style:
                  primaryTextStyle.copyWith(fontSize: 13, fontWeight: medium))
        ]))
      ]),
      const SizedBox(height: 10),
      InkWell(
          onTap: () => _makePhoneCall(widget.order.customerPhone),
          child: Row(children: [
            Icon(Icons.phone, size: 16, color: logoColorSecondary),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Telepon',
                      style: secondaryTextStyle.copyWith(fontSize: 10)),
                  Text(widget.order.customerPhone,
                      style: primaryTextStyle.copyWith(
                          fontSize: 13, color: logoColorSecondary))
                ]))
          ])),
      const SizedBox(height: 12),
      SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed('/chat', arguments: {
                  'chatId': null,
                  'orderId': widget.order.id,
                });
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Chat Pelanggan'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: logoColorSecondary,
                  side: BorderSide(color: logoColorSecondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10)))),
    ]);
  }

  Widget _buildDeliveryInfo() {
    final a = widget.order.customer.deliveryAddress!;
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alamat Pengiriman',
              style: primaryTextStyle.copyWith(
                  fontSize: 12, fontWeight: semiBold)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.location_on, size: 14, color: Colors.blue),
            const SizedBox(width: 6),
            Expanded(
                child: Text(a.fullAddress,
                    style: secondaryTextStyle.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis))
          ]),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.note, size: 14, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(a.notes!,
                      style: secondaryTextStyle.copyWith(
                          fontSize: 10, color: Colors.orange),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis))
            ])
          ],
        ]));
  }

  Widget _buildPaymentInfo() {
    return Column(children: [
      _buildPaymentRow('Subtotal', widget.order.formattedSubtotal),
      const SizedBox(height: 6),
      _buildPaymentRow('Ongkir', widget.order.formattedShippingCost),
      if (widget.order.discount != null && widget.order.discount! > 0) ...[
        const SizedBox(height: 6),
        _buildPaymentRow('Diskon', '- ${widget.order.formattedDiscount}',
            isDiscount: true)
      ],
      const Divider(height: 16),
      _buildPaymentRow('Total', widget.order.formattedTotal, isTotal: true),
      const SizedBox(height: 10),
      Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Get.isDarkMode ? AppColors.darkSurface : Colors.grey[100], borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            Icon(Icons.payment, size: 16, color: Get.isDarkMode ? AppColors.darkTextHint : Colors.grey[600]),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Metode', style: secondaryTextStyle.copyWith(fontSize: 9)),
              Text(widget.order.paymentMethod,
                  style: primaryTextStyle.copyWith(
                      fontSize: 12, fontWeight: semiBold))
            ])
          ])),
    ]);
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isDiscount = false, bool isTotal = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: secondaryTextStyle.copyWith(fontSize: isTotal ? 13 : 11)),
      Text(value,
          style: (isTotal ? priceTextStyle : primaryTextStyle).copyWith(
              fontSize: isTotal ? 16 : 12,
              fontWeight: isTotal ? bold : null,
              color: isDiscount ? Colors.green : null))
    ]);
  }

  Widget _buildBottomAction() {
    if (isLoadingAction) {
      return _buildLoadingBottom();
    }
    final status = widget.order.orderStatus;

    if (status == OrderModel.STATUS_WAITING_APPROVAL) {
      return _buildActionBottom(children: [
        Expanded(
            child: _buildButton('Tolak', Icons.close, Colors.red, () {
          Get.back();
          orderController.showRejectDialog(widget.order.id);
        }, isPrimary: true)),
        const SizedBox(width: 8),
        Expanded(
            child: _buildButton('Terima', Icons.check, Colors.green, () {
          orderController.approveTransaction(widget.order.id);
          Get.back();
        }, isPrimary: true))
      ]);
    }

    if (status == OrderModel.STATUS_PROCESSING) {
      return _buildActionBottom(children: [
        // Chat Customer button - ORANGE background, white text/icon (PRIMARY)
        Expanded(
            child: _buildButton(
                'Chat', Icons.chat_bubble_outline, logoColorSecondary, () {
          Get.toNamed('/chat', arguments: {
            'orderId': widget.order.id,
            'transactionId': widget.order.id,
          });
        }, isPrimary: true)),
        const SizedBox(width: 8),
        // Siap Diambil - ORANGE outline, orange text (better visibility on dark mode)
        Expanded(
            child: _buildButton(
                'Siap Diambil', Icons.check_circle_outline, AppColors.orange, () {
          orderController.markOrderReady(widget.order.id);
          Get.back();
        }, isPrimary: false))
      ]);
    }

    // For completed/canceled orders, show chat button only
    if (status == OrderModel.STATUS_READY_FOR_PICKUP ||
        status == OrderModel.STATUS_COMPLETED) {
      return _buildActionBottom(children: [
        Expanded(
            child: _buildButton(
                'Chat', Icons.chat_bubble_outline, logoColorSecondary, () {
          Get.toNamed('/chat', arguments: {
            'orderId': widget.order.id,
            'transactionId': widget.order.id,
          });
        }, isPrimary: true))
      ]);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingBottom() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground, boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(logoColorSecondary)),
          const SizedBox(width: 10),
          Text('Memproses...', style: primaryTextStyle.copyWith(fontSize: 13))
        ]));
  }

  Widget _buildActionBottom({required List<Widget> children}) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground, boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ]),
        child: SafeArea(child: Row(children: children)));
  }

  Widget _buildButton(
      String label, IconData icon, Color color, VoidCallback onPressed,
      {bool isPrimary = false}) {
    if (isPrimary) {
      // Primary button: colored background, white text
      return ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label,
              style: primaryTextStyle.copyWith(
                  fontSize: 13, fontWeight: semiBold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 3));
    } else {
      // Secondary button: outline, colored text
      return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label,
              style: primaryTextStyle.copyWith(
                  fontSize: 13, fontWeight: semiBold, color: color)),
          style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0));
    }
  }

  Color _getStatusColor() {
    switch (widget.order.orderStatus) {
      case OrderModel.STATUS_WAITING_APPROVAL:
        return Colors.orange;
      case OrderModel.STATUS_PROCESSING:
        return Colors.blue;
      case OrderModel.STATUS_READY_FOR_PICKUP:
        return Colors.teal;
      case OrderModel.STATUS_COMPLETED:
        return Colors.green;
      case OrderModel.STATUS_CANCELED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  Future<void> _handlePrintReceipt() async {
    final merchant = merchantController.merchant;
    if (merchant == null) {
      Get.snackbar('Error', 'Data merchant tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }
    
    try {
      setState(() => _isPrinting = true);
      
      // Print directly like POS - auto-connect and print
      final success = await PrintService().printReceipt(
        order: widget.order,
        merchantName: merchant.name,
        merchantAddress: merchant.address,
        merchantPhone: merchant.phoneNumber,
      );

      if (success) {
        Get.snackbar('Sukses', 'Struk sedang dicetak...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mencetak: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('Error', 'Tidak dapat memanggil nomor $phoneNumber',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
