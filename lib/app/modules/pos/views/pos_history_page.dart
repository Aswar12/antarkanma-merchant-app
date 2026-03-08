import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';
import 'package:antarkanma_merchant/app/services/print_service.dart';
import 'package:antarkanma_merchant/theme.dart';

class PosHistoryPage extends StatefulWidget {
  const PosHistoryPage({Key? key}) : super(key: key);

  @override
  State<PosHistoryPage> createState() => _PosHistoryPageState();
}

class _PosHistoryPageState extends State<PosHistoryPage> {
  final controller = Get.find<PosController>();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    controller.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Semua', null),
                const SizedBox(width: 8),
                _filterChip('Dine In', 'DINE_IN'),
                const SizedBox(width: 8),
                _filterChip('Takeaway', 'TAKEAWAY'),
                const SizedBox(width: 8),
                _filterChip('Delivery', 'DELIVERY'),
              ],
            ),
          ),
        ),
        // Daily summary card
        Obx(() {
          final summary = controller.dailySummary.value;
          if (summary == null) return const SizedBox.shrink();
          return _buildDailySummaryCard(summary);
        }),
        // Transaction list
        Expanded(
          child: Obx(() {
            if (controller.isLoadingTransactions.value) {
              return Center(
                child: CircularProgressIndicator(color: dashPrimary),
              );
            }

            if (controller.transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Belum ada transaksi',
                        style: subtitleTextStyle.copyWith(
                            color: Colors.grey.shade500)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchTransactions(
                orderType: _selectedType,
              ),
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionCard(controller.transactions[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String? type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
        controller.fetchTransactions(orderType: type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? dashPrimary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard(Map<String, dynamic> summary) {
    final totalRevenueRaw = summary['total_revenue'] ?? 0;
    final totalRevenue = totalRevenueRaw is String
        ? double.tryParse(totalRevenueRaw) ?? 0
        : totalRevenueRaw is num
            ? totalRevenueRaw.toDouble()
            : 0;
    final totalTx = summary['total_transactions'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [dashPrimary, dashPrimary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Hari Ini',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                NumberFormat.currency(
                        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                    .format(totalRevenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Column(
            children: [
              Text('Transaksi',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '$totalTx',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PosTransactionModel tx) {
    final isVoided = tx.status == 'VOIDED';

    return GestureDetector(
      onTap: () => _showTransactionDetail(tx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isVoided ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isVoided ? Colors.red.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      tx.transactionCode ?? '-',
                      style: primaryTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isVoided) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('VOID',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(
                  tx.formattedTotal,
                  style: primaryTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isVoided ? Colors.red : dashPrimary,
                    decoration: isVoided ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _infoChip(tx.orderTypeDisplay, Icons.restaurant),
                const SizedBox(width: 8),
                _infoChip(tx.paymentMethodDisplay, Icons.payment),
                const Spacer(),
                Text(
                  tx.formattedDate,
                  style: subtitleTextStyle.copyWith(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            if (tx.customerName != null && tx.customerName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Customer: ${tx.customerName}',
                style: subtitleTextStyle.copyWith(fontSize: 12),
              ),
            ],
            if (!isVoided) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _confirmVoid(tx),
                  child: Text('Void',
                      style:
                          TextStyle(color: Colors.red.shade400, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _confirmVoid(PosTransactionModel tx) {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Transaksi?'),
        content: Text(
            'Transaksi ${tx.transactionCode} akan dibatalkan. Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (tx.id != null) {
                controller.voidTransaction(tx.id!);
              }
            },
            child:
                const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TRANSACTION DETAIL DIALOG
  // ═══════════════════════════════════════════════════════════

  void _showTransactionDetail(PosTransactionModel tx) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isVoided = tx.status == 'VOIDED';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.transactionCode ?? '-',
                          style: primaryTextStyle.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(tx.formattedDate,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                  if (isVoided)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('VOID',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Info chips
              Row(
                children: [
                  _infoChip(tx.orderTypeDisplay, Icons.restaurant),
                  const SizedBox(width: 8),
                  _infoChip(tx.paymentMethodDisplay, Icons.payment),
                  if (tx.tableNumber != null && tx.tableNumber!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _infoChip('Meja ${tx.tableNumber}', Icons.table_bar),
                  ],
                ],
              ),
              if (tx.customerName != null && tx.customerName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('Pelanggan: ${tx.customerName}',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 12),
              // Items
              Text('Detail Pesanan',
                  style: primaryTextStyle.copyWith(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tx.items.length,
                  itemBuilder: (_, i) {
                    final item = tx.items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: dashPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text('${item.quantity}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: dashPrimary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: primaryTextStyle.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                if (item.notes != null &&
                                    item.notes!.isNotEmpty)
                                  Text('Catatan: ${item.notes}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                          fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(item.subtotal),
                            style: primaryTextStyle.copyWith(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(color: Colors.grey.shade200, height: 16),
              // Totals
              _detailRow('Subtotal', currencyFormat.format(tx.subtotal)),
              if (tx.discount > 0)
                _detailRow('Diskon', '-${currencyFormat.format(tx.discount)}',
                    color: Colors.red),
              if (tx.tax > 0)
                _detailRow('Pajak', currencyFormat.format(tx.tax)),
              const SizedBox(height: 4),
              _detailRow('Total', currencyFormat.format(tx.total),
                  isBold: true, color: dashPrimary),
              if (tx.amountPaid > 0) ...[
                _detailRow('Dibayar', currencyFormat.format(tx.amountPaid)),
                if (tx.changeAmount > 0)
                  _detailRow(
                      'Kembalian', currencyFormat.format(tx.changeAmount),
                      color: Colors.green.shade600),
              ],
              const SizedBox(height: 16),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        PrintService().printPosReceipt(tx: tx);
                      },
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Cetak Struk',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        PrintService()
                            .printPosKitchenTicket(tx: tx, station: 'DAPUR');
                      },
                      icon: const Icon(Icons.restaurant, size: 16),
                      label: const Text('Tiket Dapur',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dashPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Tutup',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(value,
              style: TextStyle(
                fontSize: isBold ? 16 : 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: color,
              )),
        ],
      ),
    );
  }
}
