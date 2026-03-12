import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/pos_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

class PosTablePage extends StatelessWidget {
  const PosTablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PosController>();
    // Auto-fetch on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.tables.isEmpty) controller.fetchTables();
    });

    return Scaffold(
      backgroundColor: dashBackgroundLight,
      body: Obx(() {
        if (controller.isLoadingTables.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tables.isEmpty) {
          return _buildEmptyState(controller);
        }

        return Column(
          children: [
            _buildSummaryBar(controller),
            Expanded(child: _buildTableGrid(controller)),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTableDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Meja'),
        backgroundColor: dashPrimary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(PosController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_restaurant, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada meja',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambahkan meja dine-in',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(PosController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: dashNavyDeep,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: dashNavyDeep.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
            'Total',
            '${controller.tables.length}',
            Colors.white,
          ),
          Container(height: 30, width: 1, color: Colors.white24),
          _summaryItem(
            'Tersedia',
            '${controller.availableTableCount}',
            Colors.greenAccent,
          ),
          Container(height: 30, width: 1, color: Colors.white24),
          _summaryItem(
            'Terisi',
            '${controller.occupiedTableCount}',
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTableGrid(PosController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: controller.tables.length,
        itemBuilder: (context, index) {
          final table = controller.tables[index];
          return _buildTableCard(context, controller, table);
        },
      ),
    );
  }

  Widget _buildTableCard(
    BuildContext context,
    PosController controller,
    MerchantTableModel table,
  ) {
    Color cardColor;
    Color iconColor;
    IconData statusIcon;

    switch (table.status) {
      case MerchantTableModel.statusOccupied:
        cardColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        statusIcon = Icons.person;
        break;
      case MerchantTableModel.statusReserved:
        cardColor = Colors.amber.shade50;
        iconColor = Colors.amber.shade700;
        statusIcon = Icons.bookmark;
        break;
      default: // AVAILABLE
        cardColor = Colors.green.shade50;
        iconColor = Colors.green.shade700;
        statusIcon = Icons.check_circle;
    }

    return GestureDetector(
      onLongPress: () => _showTableOptions(context, controller, table),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant, size: 32, color: iconColor),
            const SizedBox(height: 6),
            Text(
              table.tableNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  table.statusDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${table.capacity} kursi',
              style: TextStyle(
                fontSize: 10,
                color: iconColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTableOptions(
    BuildContext context,
    PosController controller,
    MerchantTableModel table,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Meja ${table.tableNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (table.isOccupied)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Kosongkan Meja'),
                onTap: () {
                  controller.updateTableStatus(
                      table.id!, MerchantTableModel.statusAvailable);
                  Navigator.pop(ctx);
                },
              ),
            if (table.isAvailable)
              ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.amber),
                title: const Text('Reservasi Meja'),
                onTap: () {
                  controller.updateTableStatus(
                      table.id!, MerchantTableModel.statusReserved);
                  Navigator.pop(ctx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Meja'),
              onTap: () {
                controller.removeTable(table.id!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTableDialog(BuildContext context, PosController controller) {
    final numberCtrl = TextEditingController();
    final capacityCtrl = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Meja Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberCtrl,
              decoration: InputDecoration(
                labelText: 'Nomor Meja',
                hintText: 'Contoh: 1, A1, VIP-1',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kapasitas (orang)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: dashPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final number = numberCtrl.text.trim();
              if (number.isNotEmpty) {
                controller.addTable(
                  number,
                  capacity: int.tryParse(capacityCtrl.text) ?? 4,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
