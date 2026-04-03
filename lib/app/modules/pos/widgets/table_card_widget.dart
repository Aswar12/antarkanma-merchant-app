import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/theme.dart';

class TableCardWidget extends StatelessWidget {
  final MerchantTableModel table;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TableCardWidget({
    super.key,
    required this.table,
    this.onTap,
    this.onLongPress,
  });

  Color get _statusColor {
    switch (table.status) {
      case MerchantTableModel.statusOccupied:
        return Colors.red;
      case MerchantTableModel.statusReserved:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Color get _bgColor {
    switch (table.status) {
      case MerchantTableModel.statusOccupied:
        return Colors.red.shade50;
      case MerchantTableModel.statusReserved:
        return Colors.blue.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  IconData get _statusIcon {
    switch (table.status) {
      case MerchantTableModel.statusOccupied:
        return Icons.person;
      case MerchantTableModel.statusReserved:
        return Icons.bookmark;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: _statusColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant, size: 32, color: _statusColor),
            const SizedBox(height: 6),
            Text(
              table.tableNumber,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_statusIcon, size: 14, color: _statusColor),
                const SizedBox(width: 4),
                Text(
                  table.statusDisplay,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chair, size: 12, color: _statusColor.withOpacity(0.7)),
                const SizedBox(width: 2),
                Text(
                  '${table.capacity}',
                  style: TextStyle(
                    fontSize: 10,
                    color: _statusColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
