import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:antarkanma_merchant/app/controllers/base_order_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

class OrderDetailsBottomSheet extends StatelessWidget {
  final TransactionModel transaction;
  final BaseOrderController controller;

  const OrderDetailsBottomSheet({
    super.key,
    required this.transaction,
    required this.controller,
  });

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

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: Dimenssions.width60,
        height: Dimenssions.width60,
        color: backgroundColor3,
        child: Icon(Icons.image_not_supported, color: subtitleColor),
      );
    }

    return Image.network(
      imageUrl,
      width: Dimenssions.width60,
      height: Dimenssions.width60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: Dimenssions.width60,
        height: Dimenssions.width60,
        color: backgroundColor3,
        child: Icon(Icons.image_not_supported, color: subtitleColor),
      ),
    );
  }

  void _showProcessDialog() {
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
              controller.approveTransaction(transaction.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: logoColorSecondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimenssions.radius8),
              ),
            ),
            child: Text('Proses'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
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
              controller.rejectTransaction(
                transaction.id,
                reason: reasonController.text.trim().isNotEmpty 
                  ? reasonController.text.trim() 
                  : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: alertColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimenssions.radius8),
              ),
            ),
            child: Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
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
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
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
                                  color: logoColorSecondary.withOpacity(0.1),
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
                                  color: logoColorSecondary.withOpacity(0.1),
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

                              // Order Items
                              ...transaction.items.map((item) => Container(
                                    margin: EdgeInsets.only(
                                        bottom: Dimenssions.height12),
                                    padding:
                                        EdgeInsets.all(Dimenssions.width12),
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
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  Dimenssions.radius8),
                                          child: _buildProductImage(
                                              item.product.firstImageUrl),
                                        ),
                                        SizedBox(width: Dimenssions.width12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.product.name,
                                                style: primaryTextStyle
                                                    .copyWith(
                                                  fontWeight: medium,
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      Dimenssions.height4),
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
                                                      color:
                                                          logoColorSecondary
                                                              .withOpacity(
                                                                  0.1),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(4),
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
                                                        fontWeight: medium,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    item.formattedPrice,
                                                    style: primaryTextStyle
                                                        .copyWith(
                                                      color: subtitleColor,
                                                      fontSize:
                                                          Dimenssions.font12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height:
                                                      Dimenssions.height4),
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
                                  )),

                              // Total Section
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

                              // Customer Information
                              if (transaction.user != null) ...[
                                Text(
                                  'Informasi Pemesan',
                                  style: primaryTextStyle.copyWith(
                                    fontSize: Dimenssions.font16,
                                    fontWeight: medium,
                                  ),
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
                                      if (transaction
                                              .user!.phoneNumber != null) ...[
                                        SizedBox(height: 8),
                                        _buildInfoRow(
                                          Icons.phone,
                                          'Telepon',
                                          transaction.user!.phoneNumber!,
                                        ),
                                      ],
                                      if (transaction.user!.email != null) ...[
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
                              ],

                              SizedBox(height: Dimenssions.height20),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.back();
                                        _showRejectDialog();
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
                                          side: BorderSide(
                                              color: alertColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: Dimenssions.width12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Get.back();
                                        _showProcessDialog();
                                      },
                                      icon: Icon(Icons.check),
                                      label: Text('Terima'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            logoColorSecondary,
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
    );
  }
}
