import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/pos_transaction_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

class PosQueuePage extends StatelessWidget {
  const PosQueuePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.activeQueue.isEmpty) controller.fetchActiveQueue();
    });

    return Scaffold(
      backgroundColor: dashBackgroundLight,
      body: Obx(() {
        if (controller.isLoadingQueue.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activeQueue.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchActiveQueue,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activeQueue.length,
            itemBuilder: (context, index) {
              final tx = controller.activeQueue[index];
              return _buildQueueCard(context, controller, tx, index + 1);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.fetchActiveQueue(),
        backgroundColor: dashPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada antrian aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan baru akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(
    BuildContext context,
    PosController controller,
    PosTransactionModel tx,
    int queueNum,
  ) {
    final isPending = tx.status == 'PENDING';
    final isProcessing = tx.status == 'PROCESSING';
    final waitMinutes = DateTime.now().difference(tx.createdAt!).inMinutes;
    final isUrgent = waitMinutes > 15;

    Color statusColor = isPending ? Colors.orange : Colors.blue;
    if (isUrgent) statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent ? Border.all(color: Colors.red, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header with queue number & status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Big queue number
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#${queueNum.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.transactionCode ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _orderTypeBadge(tx.orderType),
                          if (tx.tableNumber != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Meja ${tx.tableNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPending ? 'MENUNGGU' : 'DIPROSES',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${waitMinutes}m lalu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isUrgent ? FontWeight.bold : null,
                        color: isUrgent ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Items list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: tx.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Tooltip(
                          message: item.notes!,
                          child: const Icon(Icons.sticky_note_2,
                              size: 14, color: Colors.amber),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                if (isPending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.updateTransactionStatus(
                          tx.id!, 'PROCESSING'),
                      icon: const Icon(Icons.local_fire_department, size: 18),
                      label: const Text('Proses'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (isProcessing)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.updateTransactionStatus(
                          tx.id!, 'COMPLETED'),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () =>
                      controller.updateTransactionStatus(tx.id!, 'VOIDED'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTypeBadge(String type) {
    Color bgColor;
    String label;
    switch (type) {
      case 'DINE_IN':
        bgColor = Colors.purple.shade100;
        label = 'Dine-In';
        break;
      case 'DELIVERY':
        bgColor = Colors.blue.shade100;
        label = 'Delivery';
        break;
      default:
        bgColor = Colors.grey.shade200;
        label = 'Takeaway';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: bgColor == Colors.grey.shade200
              ? Colors.grey.shade700
              : bgColor == Colors.purple.shade100
                  ? Colors.purple.shade800
                  : Colors.blue.shade800,
        ),
      ),
    );
  }
}
