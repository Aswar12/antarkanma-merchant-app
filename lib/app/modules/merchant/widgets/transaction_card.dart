import 'package:antarkanma_merchant/app/controllers/merchant_order_controller.dart';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/order_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import 'profile_photo.dart';

// ─── Layout constants ─────────────────────────────────────────────────────────
const _kCardRadius = 14.0;
const _kPillRadius = 24.0;
// ─────────────────────────────────────────────────────────────────────────────

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

  void _showOrderDetails(BuildContext context) {
    Get.to(() => OrderDetailPage(order: order));
  }

  int _getTotalItems() {
    int total = 0;
    for (var item in order.items) {
      total += item.quantity;
    }
    return total;
  }

  _StatusConfig _getStatusConfig() {
    switch (order.orderStatus) {
      case OrderModel.STATUS_PENDING:
      case OrderModel.STATUS_WAITING_APPROVAL:
        return _StatusConfig(
          label: 'Menunggu',
          icon: Icons.pending_outlined,
          color: Colors.orange,
          bgColor: Colors.orange.withValues(alpha: 0.1),
        );
      case OrderModel.STATUS_PROCESSING:
        return _StatusConfig(
          label: 'Diproses',
          icon: Icons.autorenew_rounded,
          color: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        );
      case OrderModel.STATUS_READY_FOR_PICKUP:
        return _StatusConfig(
          label: 'Siap Diambil',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          bgColor: Colors.green.withValues(alpha: 0.1),
        );
      case OrderModel.STATUS_COMPLETED:
        return _StatusConfig(
          label: 'Selesai',
          icon: Icons.done_all_rounded,
          color: Colors.grey,
          bgColor: Colors.grey.withValues(alpha: 0.1),
        );
      case OrderModel.STATUS_CANCELED:
        return _StatusConfig(
          label: 'Dibatalkan',
          icon: Icons.cancel_rounded,
          color: Colors.red,
          bgColor: Colors.red.withValues(alpha: 0.1),
        );
      default:
        return _StatusConfig(
          label: order.statusDisplay,
          icon: Icons.help_outline_rounded,
          color: subtitleColor,
          bgColor: backgroundColor3,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();
    final isActionRequired = order.isWaitingApproval || order.isProcessing;

    return GestureDetector(
      onTap: () => _showOrderDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(_kCardRadius),
          border: Border.all(color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimenssions.height12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status Badge & Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(config: statusConfig),
                  Text(
                    order.formattedDate,
                    style: subtitleTextStyle.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer & Order Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfilePhoto(
                    photoUrl: order.customer.photo,
                    name: order.customerName,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: primaryTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: semiBold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${order.id} • ${_getTotalItems()} item',
                          style: subtitleTextStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.formattedTotal,
                        style: primaryTextOrange.copyWith(
                          fontSize: 14,
                          fontWeight: bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _PaymentChip(method: order.paymentMethod),
                    ],
                  ),
                ],
              ),

              // Action Buttons or Status Chips
              if (isActionRequired ||
                  order.orderStatus == OrderModel.STATUS_READY_FOR_PICKUP) ...[
                const SizedBox(height: 12),
                Divider(height: 1, color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider),
                const SizedBox(height: 12),
                if (isActionRequired) _buildActionArea(),
                if (order.orderStatus == OrderModel.STATUS_READY_FOR_PICKUP)
                  _buildReadyChip(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── "Siap Diambil" chip ───────────────────────────────────────────────────
  Widget _buildReadyChip() {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Dimenssions.width10, vertical: Dimenssions.height6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimenssions.radius20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              size: Dimenssions.font12, color: Colors.green),
          SizedBox(width: Dimenssions.width5),
          Text(
            order.courier != null
                ? '✓ Siap — Kurir ${order.courier?.name ?? "otw"}'
                : '✓ Siap — Menunggu Kurir',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font11,
              fontWeight: semiBold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionArea() {
    if (order.isWaitingApproval) return _buildWaitingButtons();
    if (order.isProcessing) return _buildReadyButton();
    return const SizedBox.shrink();
  }

  Widget _buildWaitingButtons() {
    return Row(
      children: [
        // Tolak
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.showRejectDialog(order.id),
            icon: Icon(Icons.close_rounded, size: Dimenssions.font16),
            label: const Text('Tolak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: Dimenssions.height10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kPillRadius),
              ),
              textStyle:
                  TextStyle(fontSize: Dimenssions.font12, fontWeight: semiBold),
            ),
          ),
        ),
        SizedBox(width: Dimenssions.width8),

        // Terima
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () => controller.approveTransaction(order.id),
            icon: Icon(Icons.check_rounded, size: Dimenssions.font16),
            label: const Text('Terima Pesanan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: Dimenssions.height10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_kPillRadius),
              ),
              textStyle:
                  TextStyle(fontSize: Dimenssions.font12, fontWeight: semiBold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadyButton() {
    return Obx(() {
      final isLoading = controller.loadingOrders[order.id.toString()] ?? false;
      return SizedBox(
        width: double.infinity,
        height: Dimenssions.height48,
        child: ElevatedButton.icon(
          onPressed:
              isLoading ? null : () => controller.markOrderReady(order.id),
          icon: isLoading
              ? SizedBox(
                  width: Dimenssions.font16,
                  height: Dimenssions.font16,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(Icons.local_shipping_rounded, size: Dimenssions.font18),
          label: Text(
            isLoading ? 'Memproses...' : 'Tandai Siap Diambil',
            style: textwhite.copyWith(
                fontSize: Dimenssions.font12, fontWeight: bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: logoColorSecondary,
            foregroundColor: Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kPillRadius),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _StatusConfig config;
  const _StatusBadge({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Dimenssions.width8, vertical: Dimenssions.height4),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: Dimenssions.font11, color: config.color),
          SizedBox(width: Dimenssions.width4),
          Text(
            config.label,
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font11,
              fontWeight: semiBold,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String method;
  const _PaymentChip({required this.method});

  @override
  Widget build(BuildContext context) {
    String emoji;
    switch (method.toLowerCase()) {
      case 'cash':
      case 'cod':
        emoji = '💵';
        break;
      case 'qris':
        emoji = '📱';
        break;
      case 'transfer':
        emoji = '🏦';
        break;
      default:
        emoji = '💳';
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Dimenssions.width8, vertical: Dimenssions.height4),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppColors.darkDivider : AppColors.lightDivider.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Dimenssions.radius20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: Dimenssions.font12)),
          SizedBox(width: Dimenssions.width4),
          Text(
            method.toUpperCase(),
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font10,
              fontWeight: semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Config model ─────────────────────────────────────────────────────────────
class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
