import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';

class ExtendDurationDialog extends StatelessWidget {
  final int transactionId;
  final DateTime? currentReleaseAt;
  final bool isLoading;
  final void Function(int minutes) onExtend;

  const ExtendDurationDialog({
    super.key,
    required this.transactionId,
    this.currentReleaseAt,
    this.isLoading = false,
    required this.onExtend,
  });

  static const List<int> durationOptions = [15, 30, 60];

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
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer, size: 32, color: Colors.blue.shade700),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tambah Durasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih durasi yang ingin ditambahkan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Get.isDarkMode ? AppColors.darkTextSecondary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ...durationOptions.map((mins) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DurationOption(
                minutes: mins,
                currentReleaseAt: currentReleaseAt,
                onTap: isLoading ? null : () => onExtend(mins),
              ),
            )),
            const SizedBox(height: 8),
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final int minutes;
  final DateTime? currentReleaseAt;
  final VoidCallback? onTap;

  const _DurationOption({
    required this.minutes,
    this.currentReleaseAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = minutes >= 60 ? '$minutes menit (${minutes ~/ 60} jam)' : '$minutes menit';
    String? newTime;
    if (currentReleaseAt != null) {
      final newDt = currentReleaseAt!.add(Duration(minutes: minutes));
      newTime = '${newDt.hour.toString().padLeft(2, '0')}:${newDt.minute.toString().padLeft(2, '0')}';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.orange.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.add_circle, color: AppColors.orange, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '+$label',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (newTime != null)
                      Text(
                        'Selesai pada: $newTime',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
