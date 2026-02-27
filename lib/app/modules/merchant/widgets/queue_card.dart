import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/merchant_order_controller.dart';
import '../../../services/print_service.dart';
import '../../../../theme.dart';
import '../../../data/models/order_model.dart';

/// QueueCard - Card untuk antrian pesanan dengan nomor antrian besar
/// Designed for easy visibility by kitchen/barista staff
class QueueCard extends StatelessWidget {
  final OrderModel order;
  final int queueNumber;
  final MerchantOrderController controller;

  const QueueCard({
    super.key,
    required this.order,
    required this.queueNumber,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isWaitingApproval = order.isWaitingApproval;
    final isProcessing = order.isProcessing;
    final isReadyForPickup = order.isReadyForPickup;

    // Calculate waiting time
    final waitingTime = DateTime.now().difference(order.createdAt);
    final isUrgent = waitingTime.inMinutes > 15;

    return Dismissible(
      key: Key('order_${order.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) async {
        if (isReadyForPickup) {
          return false; // Cannot dismiss ready orders
        }
        return await _showMarkReadyDialog();
      },
      onDismissed: (direction) {
        if (isWaitingApproval) {
          controller.approveTransaction(order.id);
        } else if (isProcessing) {
          controller.markOrderReady(order.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor2,
          borderRadius: BorderRadius.circular(Dimenssions.radius16),
          border: Border.all(
            color: isUrgent ? Colors.red.shade300 : Colors.grey.shade300,
            width: isUrgent ? 2 : 1,
          ),
          boxShadow: [
            if (isUrgent)
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(isWaitingApproval, isProcessing, isReadyForPickup, isUrgent),
            _buildContent(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWaitingApproval, bool isProcessing, bool isReadyForPickup, bool isUrgent) {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height12),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimenssions.radius16),
          topRight: Radius.circular(Dimenssions.radius16),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Queue Number - Large and Bold
          Container(
            width: Dimenssions.height65,
            height: Dimenssions.height65,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : _getStatusColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? Colors.red : _getStatusColor()).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '#${queueNumber.toString().padLeft(2, '0')}',
                style: textwhite.copyWith(
                  fontSize: Dimenssions.font24,
                  fontWeight: bold,
                ),
              ),
            ),
          ),
          SizedBox(width: Dimenssions.width12),
          // Order Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Order #${order.id}',
                      style: primaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isUrgent ? Colors.red : Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _formatWaitingTime(),
                      style: secondaryTextStyle.copyWith(
                        fontSize: Dimenssions.font12,
                        color: isUrgent ? Colors.red : null,
                        fontWeight: isUrgent ? semiBold : null,
                      ),
                    ),
                    if (isUrgent) ...[
                      SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'URGENT',
                          style: textwhite.copyWith(
                            fontSize: 8,
                            fontWeight: bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Status Badge
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(Dimenssions.height12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Name
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 8),
              Text(
                order.customer.name ?? '-',
                style: primaryTextStyle.copyWith(
                  fontSize: Dimenssions.font14,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height8),
          // Order Items
          ...order.orderItems.take(3).map((item) => Padding(
            padding: EdgeInsets.only(bottom: Dimenssions.height4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: logoColorSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.quantity}x',
                    style: primaryTextStyle.copyWith(
                      fontSize: Dimenssions.font12,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: primaryTextStyle.copyWith(
                          fontSize: Dimenssions.font10,
                          fontWeight: medium,
                        ),
                      ),
                      if (item.customerNote != null && item.customerNote!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Note: ${item.customerNote}',
                            style: secondaryTextStyle.copyWith(
                              fontSize: Dimenssions.font11,
                              color: Colors.orange.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          if (order.orderItems.length > 3)
            Padding(
              padding: EdgeInsets.only(top: Dimenssions.height4),
              child: Text(
                '+ ${order.orderItems.length - 3} item lainnya',
                style: secondaryTextStyle.copyWith(
                  fontSize: Dimenssions.font12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height12),
      decoration: BoxDecoration(
        color: backgroundColor3,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimenssions.radius16),
          bottomRight: Radius.circular(Dimenssions.radius16),
        ),
      ),
      child: Row(
        children: [
          // Print Button
          IconButton(
            onPressed: () => _printReceipt(),
            icon: Icon(Icons.print, color: logoColorSecondary),
            tooltip: 'Print Receipt',
          ),
          SizedBox(width: 8),
          // View Details Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewDetails(),
              icon: Icon(Icons.visibility, size: 18),
              label: Text('Detail'),
              style: OutlinedButton.styleFrom(
                foregroundColor: logoColorSecondary,
                side: BorderSide(color: logoColorSecondary),
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                ),
              ),
            ),
          ),
          SizedBox(width: Dimenssions.width8),
          // Action Button (changes based on status)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _getPrimaryAction(),
              icon: Icon(_getPrimaryActionIcon(), size: 18),
              label: Text(_getPrimaryActionText()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: Dimenssions.width20),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(Dimenssions.radius16),
      ),
      child: Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Color _getStatusColor() {
    if (order.isWaitingApproval) return Colors.orange;
    if (order.isProcessing) return Colors.blue;
    if (order.isReadyForPickup) return Colors.green;
    return Colors.grey;
  }

  Widget _buildStatusBadge() {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: bold,
        ),
      ),
    );
  }

  String _getStatusText() {
    if (order.isWaitingApproval) return 'MENUNGGU';
    if (order.isProcessing) return 'PROSES';
    if (order.isReadyForPickup) return 'SIAP';
    return order.orderStatus;
  }

  String _formatWaitingTime() {
    final waitingTime = DateTime.now().difference(order.createdAt);
    if (waitingTime.inHours > 0) {
      return '${waitingTime.inHours}j ${waitingTime.inMinutes % 60}m';
    } else if (waitingTime.inMinutes > 0) {
      return '${waitingTime.inMinutes}m yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  String _getPrimaryActionText() {
    if (order.isWaitingApproval) return 'Terima';
    if (order.isProcessing) return 'Siap';
    if (order.isReadyForPickup) return 'Selesai';
    return 'Detail';
  }

  IconData _getPrimaryActionIcon() {
    if (order.isWaitingApproval) return Icons.check;
    if (order.isProcessing) return Icons.check_circle_outline;
    if (order.isReadyForPickup) return Icons.done_all;
    return Icons.visibility;
  }

  VoidCallback? _getPrimaryAction() {
    if (order.isWaitingApproval) {
      return () => controller.approveTransaction(order.id);
    } else if (order.isProcessing) {
      return () => controller.markOrderReady(order.id);
    } else if (order.isReadyForPickup) {
      return () => _showCompleteDialog();
    }
    return null;
  }

  Future<bool> _showMarkReadyDialog() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text('Tandai Pesanan?'),
        content: Text(
          order.isWaitingApproval
              ? 'Terima pesanan ini dan mulai memproses?'
              : 'Tandai pesanan sudah siap diambil?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(),
              foregroundColor: Colors.white,
            ),
            child: Text('Ya'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showCompleteDialog() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Pesanan Diambil?'),
        content: Text('Konfirmasi bahwa pesanan telah diambil oleh kurir/customer?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Ya, Sudah Diambil'),
          ),
        ],
      ),
    );

    if (confirm == true && order.id != null) {
      await controller.markOrderPickedUp(order.id);
    }
  }

  Future<void> _printReceipt() async {
    final printService = PrintService();
    await printService.printKitchenReceipt(
      order: order,
      merchantName: 'Merchant',
    );
  }

  void _viewDetails() {
    Get.toNamed('/order-details', arguments: {'order': order});
  }
}
