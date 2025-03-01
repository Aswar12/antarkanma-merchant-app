import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../theme.dart';
import 'profile_photo.dart';

class TransactionCard extends StatelessWidget {
  final OrderModel order;
  final MerchantOrderController controller;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.order,
    required this.controller,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (order.orderStatus) {
      case 'WAITING_APPROVAL':
        return Colors.orange.shade600;
      case 'PROCESSING':
        return Colors.blue.shade600;
      case 'READY_FOR_PICKUP':
        return Colors.green.shade600;
      case 'COMPLETED':
        return Colors.teal.shade600;
      case 'CANCELED':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon() {
    switch (order.orderStatus) {
      case 'WAITING_APPROVAL':
        return Icons.pending_outlined;
      case 'PROCESSING':
        return Icons.sync;
      case 'READY_FOR_PICKUP':
        return Icons.check_circle_outline;
      case 'COMPLETED':
        return Icons.done_all;
      case 'CANCELED':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Hero(
      tag: 'order_${order.id}',
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(
            horizontal: Dimenssions.height8,
            vertical: Dimenssions.height6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimenssions.radius16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Dimenssions.radius16),
            child: Column(
              children: [
                // Header with order ID and status
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimenssions.height12,
                    vertical: Dimenssions.height10,
                  ),
                  decoration: BoxDecoration(
                    color: backgroundColor1,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(Dimenssions.height6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(Dimenssions.radius8),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: Dimenssions.height18,
                            ),
                          ),
                          SizedBox(width: Dimenssions.width8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id}',
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font14,
                                  fontWeight: semiBold,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: subtitleColor,
                                  ),
                                  SizedBox(width: Dimenssions.width4),
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm').format(
                                        DateTime.parse(order.createdAt)),
                                    style: subtitleTextStyle.copyWith(
                                      fontSize: Dimenssions.font10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width10,
                          vertical: Dimenssions.height4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withOpacity(0.1),
                              statusColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 14,
                              color: statusColor,
                            ),
                            SizedBox(width: Dimenssions.width4),
                            Text(
                              order.statusDisplay,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: Dimenssions.font12,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Order content
                Container(
                  padding: EdgeInsets.all(Dimenssions.height12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.items.isNotEmpty) ...[
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        Dimenssions.radius12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        Dimenssions.radius12),
                                    child: Image.network(
                                      order.items.first.product.firstImageUrl ??
                                          '',
                                      width: Dimenssions.height70,
                                      height: Dimenssions.height70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: Dimenssions.height70,
                                        height: Dimenssions.height70,
                                        decoration: BoxDecoration(
                                          color: backgroundColor3,
                                          borderRadius: BorderRadius.circular(
                                              Dimenssions.radius12),
                                        ),
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: subtitleColor,
                                          size: Dimenssions.height24,
                                        ),
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
                                        horizontal: Dimenssions.width8,
                                        vertical: Dimenssions.height4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            logoColorSecondary,
                                            logoColorSecondary.withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              Dimenssions.radius8),
                                          bottomRight: Radius.circular(
                                              Dimenssions.radius12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: logoColorSecondary
                                                .withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '+${order.items.length - 1}',
                                        style: textwhite.copyWith(
                                          fontSize: Dimenssions.font12,
                                          fontWeight: semiBold,
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
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                  SizedBox(height: Dimenssions.height4),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimenssions.width8,
                                      vertical: Dimenssions.height2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: backgroundColor3.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                          Dimenssions.radius4),
                                    ),
                                    child: Text(
                                      '${order.items.first.quantity}x @ ${NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp ',
                                        decimalDigits: 0,
                                      ).format(double.parse(order.items.first.price))}',
                                      style: subtitleTextStyle.copyWith(
                                        fontSize: Dimenssions.font12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: Dimenssions.height8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimenssions.width10,
                                      vertical: Dimenssions.height4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          logoColorSecondary.withOpacity(0.15),
                                          logoColorSecondary.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          Dimenssions.radius8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.payment,
                                          size: 16,
                                          color: logoColorSecondary,
                                        ),
                                        SizedBox(width: Dimenssions.width6),
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
                            ),
                          ],
                        ),
                        SizedBox(height: Dimenssions.height12),
                      ],
                      // Customer and courier info
                      Row(
                        children: [
                          // Customer info
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(Dimenssions.height8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    backgroundColor3.withOpacity(0.1),
                                    backgroundColor3.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(Dimenssions.radius12),
                                border: Border.all(
                                  color: backgroundColor3.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              size: 12,
                                              color: subtitleColor,
                                            ),
                                            SizedBox(width: Dimenssions.width4),
                                            Text(
                                              order.customerPhone,
                                              style: subtitleTextStyle.copyWith(
                                                fontSize: Dimenssions.font10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Courier info if available
                          if (order.courier != null) ...[
                            SizedBox(width: Dimenssions.width8),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(Dimenssions.height8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      logoColorSecondary.withOpacity(0.1),
                                      logoColorSecondary.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      Dimenssions.radius12),
                                  border: Border.all(
                                    color: logoColorSecondary.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ProfilePhoto(
                                      photoUrl: order.courier!.photo,
                                      name: order.courier!.name,
                                      size: Dimenssions.height40,
                                    ),
                                    SizedBox(width: Dimenssions.width8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.courier!.name,
                                            style: primaryTextStyle.copyWith(
                                              fontSize: Dimenssions.font14,
                                              fontWeight: medium,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.motorcycle,
                                                size: 12,
                                                color: logoColorSecondary,
                                              ),
                                              SizedBox(
                                                  width: Dimenssions.width4),
                                              Text(
                                                order.courier!.plate,
                                                style: TextStyle(
                                                  color: logoColorSecondary,
                                                  fontSize: Dimenssions.font10,
                                                  fontWeight: medium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
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
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.showRejectDialog(order.id),
                            icon: Icon(Icons.close, size: 18),
                            label: Text('Tolak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: Dimenssions.height12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimenssions.radius8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Dimenssions.width8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.approveTransaction(order.id),
                            icon: Icon(Icons.check, size: 18),
                            label: Text('Terima'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: logoColorSecondary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: Dimenssions.height12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimenssions.radius8),
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
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Obx(() {
                      final isLoading =
                          controller.loadingOrders[order.id.toString()] ??
                              false;
                      return SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => controller.markOrderReady(order.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: logoColorSecondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimenssions.width16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(Dimenssions.radius8),
                            ),
                          ),
                          child: isLoading
                              ? Shimmer(
                                  duration: Duration(milliseconds: 1500),
                                  interval: Duration(milliseconds: 100),
                                  color: Colors.white,
                                  colorOpacity: 0.3,
                                  enabled: true,
                                  direction: ShimmerDirection.fromLTRB(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Memproses...',
                                        style: textwhite.copyWith(
                                          fontSize: Dimenssions.font14,
                                          fontWeight: medium,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Siap Diambil',
                                      style: textwhite.copyWith(
                                        fontSize: Dimenssions.font14,
                                        fontWeight: medium,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
