import 'package:antarkanma_merchant/app/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../theme.dart';
import '../../../controllers/merchant_home_controller.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final MerchantHomeController controller;

  const TransactionCard({
    Key? key,
    required this.transaction,
    required this.controller,
  }) : super(key: key);

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final orderItems = transaction.order?.orderItems ?? [];
    final customerName = transaction.user?.name ?? 'Customer';
    final customerPhone = transaction.user?.phoneNumber ?? '-';

    return Container(
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: backgroundColor1,
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
          // Order ID and Time
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
              Text(
                _formatDateTime(transaction.createdAt),
                style: subtitleTextStyle.copyWith(
                  fontSize: Dimenssions.font14,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height12),
          
          // Customer Details
          Text(
            customerName,
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font14,
              fontWeight: medium,
            ),
          ),
          Text(
            customerPhone,
            style: subtitleTextStyle.copyWith(
              fontSize: Dimenssions.font12,
            ),
          ),
          SizedBox(height: Dimenssions.height8),
          
          // Order Items Summary
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: orderItems.map((item) {
              return Text(
                '${item.quantity}x ${item.product.name} (${NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(item.price)})',
                style: secondaryTextStyle.copyWith(
                  fontSize: Dimenssions.font14,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: Dimenssions.height12),
          
          // Total Amount
          Text(
            'Total: ${NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(transaction.totalAmount)}',
            style: primaryTextOrange.copyWith(
              fontSize: Dimenssions.font16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.rejectTransaction(transaction.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alertColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimenssions.height12,
                    ),
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
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: Dimenssions.height12,
                    ),
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
  }
}
