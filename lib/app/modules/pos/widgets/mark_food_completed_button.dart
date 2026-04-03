import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';

class MarkFoodCompletedButton extends StatelessWidget {
  final int transactionId;
  final bool isLoading;
  final void Function() onConfirm;

  const MarkFoodCompletedButton({
    super.key,
    required this.transactionId,
    this.isLoading = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading
          ? null
          : () => _showConfirmDialog(context),
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.restaurant, size: 20),
      label: const Text('Tandai Makanan Selesai'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restaurant, color: Colors.green),
            SizedBox(width: 8),
            Text('Makanan Disajikan?'),
          ],
        ),
        content: const Text(
          'Tandai makanan sudah selesai disajikan. Timer auto-release akan dimulai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Tandai'),
          ),
        ],
      ),
    );
  }
}
