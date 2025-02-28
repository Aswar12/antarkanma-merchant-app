import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme.dart';
import '../../../controllers/base_order_controller.dart';
import 'profile_photo.dart';

class TransactionCard extends StatelessWidget {
  final OrderModel order;
  final BaseOrderController controller;
  final VoidCallback? onTap;

  const TransactionCard({
    Key? key,
    required this.order,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimenssions.height16,
          vertical: Dimenssions.height8,
        ),
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
          children: [
            // Header with order ID, status, and time
            Container(
              padding: EdgeInsets.all(Dimenssions.height12),
              decoration: BoxDecoration(
                color: backgroundColor1,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimenssions.radius12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: subtitleColor,
                        size: Dimenssions.height20,
                      ),
                      SizedBox(width: Dimenssions.width8),
                      Text(
                        'Order #${order.id}',
                        style: primaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                          fontWeight: semiBold,
                        ),
                      ),
                    ],
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
                      order.statusDisplay,
                      style: primaryTextOrange.copyWith(
                        fontSize: Dimenssions.font12,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Order content
            Container(
              padding: EdgeInsets.all(Dimenssions.height16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.items.isNotEmpty) ...[
                    Row(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(Dimenssions.radius8),
                              child: Image.network(
                                order.items.first.product.firstImageUrl ?? '',
                                width: Dimenssions.height70,
                                height: Dimenssions.height70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: Dimenssions.height70,
                                  height: Dimenssions.height70,
                                  color: backgroundColor3,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: subtitleColor,
                                    size: Dimenssions.height24,
                                  ),
                                ),
                              ),
                            ),
                            if (order.items.length > 1)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimenssions.width6,
                                    vertical: Dimenssions.height4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(Dimenssions.radius8),
                                      bottomRight:
                                          Radius.circular(Dimenssions.radius8),
                                    ),
                                  ),
                                  child: Text(
                                    '+${order.items.length - 1}',
                                    style: textwhite.copyWith(
                                      fontSize: Dimenssions.font10,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                                ).format(double.parse(order.items.first.price))}',
                                style: subtitleTextStyle.copyWith(
                                  fontSize: Dimenssions.font12,
                                ),
                              ),
                              SizedBox(height: Dimenssions.height4),
                              Text(
                                order.formattedTotalAmount,
                                style: primaryTextOrange.copyWith(
                                  fontSize: Dimenssions.font14,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      height: Dimenssions.height24,
                      color: backgroundColor3,
                    ),
                  ],
                  // Customer and courier info
                  Row(
                    children: [
                      // Customer info
                      Expanded(
                        child: Row(
                          children: [
                            ProfilePhoto(
                              photoUrl: order.customer.photo,
                              name: order.customerName,
                              size: Dimenssions.height40,
                            ),
                            SizedBox(width: Dimenssions.width8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.customerName,
                                    style: primaryTextStyle.copyWith(
                                      fontSize: Dimenssions.font14,
                                      fontWeight: medium,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    order.customerPhone,
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: Dimenssions.font12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Courier info if available
                      if (order.courier != null) ...[
                        Container(
                          height: Dimenssions.height40,
                          width: 1,
                          color: backgroundColor3,
                          margin: EdgeInsets.symmetric(
                              horizontal: Dimenssions.width12),
                        ),
                        Row(
                          children: [
                            ProfilePhoto(
                              photoUrl: order.courier!.photo,
                              name: order.courier!.name,
                              size: Dimenssions.height40,
                            ),
                            SizedBox(width: Dimenssions.width8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.courier!.name,
                                  style: primaryTextStyle.copyWith(
                                    fontSize: Dimenssions.font14,
                                    fontWeight: medium,
                                  ),
                                ),
                                Text(
                                  order.courier!.plate,
                                  style: subtitleTextStyle.copyWith(
                                    fontSize: Dimenssions.font12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  // Order time
                  Padding(
                    padding: EdgeInsets.only(top: Dimenssions.height12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: Dimenssions.height16,
                          color: subtitleColor,
                        ),
                        SizedBox(width: Dimenssions.width4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm')
                              .format(DateTime.parse(order.createdAt)),
                          style: subtitleTextStyle.copyWith(
                            fontSize: Dimenssions.font12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            if (order.orderStatus == 'WAITING_APPROVAL') ...[
              Container(
                padding: EdgeInsets.all(Dimenssions.height12),
                decoration: BoxDecoration(
                  color: backgroundColor1,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(Dimenssions.radius12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.showRejectDialog(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              vertical: Dimenssions.height12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
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
                        onPressed: () =>
                            controller.approveTransaction(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: logoColorSecondary,
                          padding: EdgeInsets.symmetric(
                              vertical: Dimenssions.height12),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Dimenssions.radius8),
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
              ),
            ] else if (order.orderStatus == 'PROCESSING') ...[
              Container(
                padding: EdgeInsets.all(Dimenssions.height12),
                decoration: BoxDecoration(
                  color: backgroundColor1,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(Dimenssions.radius12),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => controller.markOrderReady(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoColorSecondary,
                    padding: EdgeInsets.symmetric(
                        vertical: Dimenssions.height12),
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
      ),
    );
  }
}
