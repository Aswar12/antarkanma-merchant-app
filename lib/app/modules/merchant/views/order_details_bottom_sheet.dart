import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_profile_controller.dart';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/app/services/receipt_service.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/services/print_service.dart';

class OrderDetailsBottomSheet extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsBottomSheet({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsBottomSheet> createState() =>
      _OrderDetailsBottomSheetState();
}

class _OrderDetailsBottomSheetState extends State<OrderDetailsBottomSheet> {
  final merchantController = Get.find<MerchantProfileController>();
  late final MerchantOrderController orderController;
  bool _isPrinting = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Try to get existing controller, if not found create new one temporarily for actions
    if (Get.isRegistered<MerchantOrderController>()) {
      orderController = Get.find<MerchantOrderController>();
    }

    // Listen for loading state changes on this specific order
    ever(orderController.loadingOrders, (_) {
      if (mounted) setState(() {});
    });

    // Also listen for orders list changes to refresh UI when order status changes
    ever(orderController.orders, (_) {
      if (mounted) setState(() {});
    });
  }

  bool get isLoadingAction =>
      orderController.loadingOrders[widget.order.id.toString()] == true;

  Future<void> _handlePrintReceipt() async {
    final merchant = merchantController.merchant;
    if (merchant == null) {
      Get.snackbar(
        'Error',
        'Data merchant tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text('Pilih Metode Cetak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.print),
              title: Text('Printer Bluetooth'),
              subtitle: Text('Cetak menggunakan printer thermal'),
              onTap: () => Get.back(result: 'bluetooth'),
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Bagikan'),
              subtitle: Text('Bagikan struk dalam format teks'),
              onTap: () => Get.back(result: 'share'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      setState(() => _isPrinting = true);

      if (result == 'bluetooth') {
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
              colorText: Colors.white);
        }
        Get.back(); // Close bottom sheet after successful printing
      } else if (result == 'share') {
        await ReceiptService.shareReceipt(widget.order, merchant);
        Get.back(); // Close bottom sheet after successful sharing
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencetak struk: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isPrinting = false;
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimenssions.radius15),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildOrderInfo(),
                const SizedBox(height: 16),
                _buildCustomerInfo(),
                const SizedBox(height: 16),
                _buildDeliveryInfo(),
                const SizedBox(height: 16),
                _buildItemsList(),
                const SizedBox(height: 16),
                _buildPaymentInfo(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detail Pesanan',
              style: primaryTextStyle.copyWith(
                fontSize: 18,
                fontWeight: semiBold,
              ),
            ),
            Text(
              '#${widget.order.orderNumber}',
              style: secondaryTextStyle.copyWith(
                fontSize: 14,
                color: logoColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Pesanan',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Status',
          _buildStatusBadge(widget.order.status),
        ),
        _buildInfoRow(
          'Tanggal',
          Text(
            DateFormat('dd MMM yyyy, HH:mm').format(widget.order.createdAt),
            style: primaryTextStyle,
          ),
        ),
        if (widget.order.notes != null && widget.order.notes!.isNotEmpty)
          _buildInfoRow(
            'Catatan',
            Text(
              widget.order.notes!,
              style: primaryTextStyle,
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Pelanggan',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Nama',
          Text(
            widget.order
                .customerName, // Using the getter instead of direct access
            style: primaryTextStyle,
          ),
        ),
        _buildInfoRow(
          'Telepon',
          Text(
            widget.order
                .customerPhone, // Using the getter instead of direct access
            style: primaryTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final deliveryAddress = widget.order.customer.deliveryAddress;
    if (deliveryAddress == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Pengiriman',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Penerima',
          Text(
            deliveryAddress.customerName,
            style: primaryTextStyle,
          ),
        ),
        _buildInfoRow(
          'Telepon',
          Text(
            deliveryAddress.phoneNumber,
            style: primaryTextStyle,
          ),
        ),
        _buildInfoRow(
          'Alamat',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deliveryAddress.address,
                style: primaryTextStyle,
              ),
              Text(
                '${deliveryAddress.district}, ${deliveryAddress.city}',
                style: primaryTextStyle,
              ),
              Text(
                deliveryAddress.postalCode,
                style: primaryTextStyle,
              ),
            ],
          ),
        ),
        if (deliveryAddress.notes != null && deliveryAddress.notes!.isNotEmpty)
          _buildInfoRow(
            'Catatan',
            Text(
              deliveryAddress.notes!,
              style: primaryTextStyle.copyWith(
                color: Colors.orange[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Produk',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.order.items.length,
          itemBuilder: (context, index) {
            final item = widget.order.items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: item.product.firstImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: item.product.firstImageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[400]!),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: primaryTextStyle.copyWith(
                              fontWeight: medium,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.variant != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Varian: ${item.variant!.name}',
                              style: secondaryTextStyle.copyWith(fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity}x ${item.formattedPrice}',
                            style: priceTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rincian Pembayaran',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          'Subtotal',
          Text(
            widget.order.formattedSubtotal,
            style: primaryTextStyle,
          ),
        ),
        _buildInfoRow(
          'Ongkos Kirim',
          Text(
            widget.order.formattedShippingCost,
            style: primaryTextStyle,
          ),
        ),
        if (widget.order.discount != null && widget.order.discount! > 0)
          _buildInfoRow(
            'Diskon',
            Text(
              '- ${widget.order.formattedDiscount}',
              style: primaryTextStyle.copyWith(color: Colors.green),
            ),
          ),
        const Divider(),
        _buildInfoRow(
          'Total',
          Text(
            widget.order.formattedTotal,
            style: priceTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
        ),
        _buildInfoRow(
          'Metode Pembayaran',
          Text(
            widget.order.paymentMethod,
            style: primaryTextStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final orderStatus = widget.order.orderStatus;
    final isWaitingApproval = orderStatus == OrderModel.STATUS_WAITING_APPROVAL;
    final isProcessing = orderStatus == OrderModel.STATUS_PROCESSING;

    // Jika order sedang dalam proses (loading action), tampilkan indicator
    if (isLoadingAction) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(logoColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Memproses...',
                style: secondaryTextStyle,
              ),
            ],
          ),
        ),
      );
    }

    // Jika status WAITING_APPROVAL, tampilkan tombol Approve dan Reject
    if (isWaitingApproval) {
      return Column(
        children: [
          Row(
            children: [
              // Tombol Tolak
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    orderController.showRejectDialog(widget.order.id);
                  },
                  icon: const Icon(Icons.close, size: 20),
                  label: const Text('Tolak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tombol Terima
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    orderController.approveTransaction(widget.order.id);
                    Get.back();
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Terima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Jika status PROCESSING, tampilkan tombol Tandai Siap Diambil
    if (isProcessing) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            orderController.markOrderReady(widget.order.id);
            Get.back();
          },
          icon: const Icon(Icons.check_circle_outline, size: 20),
          label: const Text('Tandai Siap Diambil'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Default: Tombol Tutup dan Cetak Struk
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: _isPrinting ? null : _handlePrintReceipt,
        icon: _isPrinting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.receipt_long),
        label: Text(_isPrinting
            ? _isScanning
                ? 'Mencari Printer...'
                : 'Mencetak...'
            : 'Cetak Struk'),
        style: ElevatedButton.styleFrom(
          backgroundColor: logoColor,
          disabledBackgroundColor: Color.fromARGB(
              153, logoColor.red, logoColor.green, logoColor.blue),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: secondaryTextStyle,
            ),
          ),
          Text(': ', style: secondaryTextStyle),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Menunggu';
        break;
      case 'processing':
        color = Colors.blue;
        text = 'Diproses';
        break;
      case 'shipped':
        color = Colors.indigo;
        text = 'Dikirim';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Dibatalkan';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color.fromARGB(26, color.red, color.green, color.blue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
