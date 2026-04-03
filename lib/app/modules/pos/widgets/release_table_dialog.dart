import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_table_model.dart';
import 'package:antarkanma_merchant/theme.dart';

class ReleaseTableDialog extends StatelessWidget {
  final MerchantTableModel table;
  final String? transactionCode;
  final bool isLoading;
  final VoidCallback onConfirm;

  const ReleaseTableDialog({
    super.key,
    required this.table,
    this.transactionCode,
    this.isLoading = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.table_restaurant, size: 32, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kosongkan Meja?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Meja ${table.tableNumber} akan dikosongkan dan siap untuk tamu berikutnya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Get.isDarkMode ? AppColors.darkTextSecondary : Colors.grey.shade600,
              ),
            ),
            if (transactionCode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      transactionCode!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Kosongkan'),
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
