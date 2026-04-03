import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:antarkanma_merchant/app/modules/pos/controllers/table_settings_controller.dart';
import 'package:antarkanma_merchant/app/modules/pos/widgets/table_filter_widget.dart';
import 'package:antarkanma_merchant/theme.dart';

class TableSettingsPage extends StatelessWidget {
  const TableSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TableSettingsController>(
      init: TableSettingsController(),
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            title: const Text('Pengaturan Meja'),
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: ctrl.fetchConfig,
              ),
            ],
          ),
          body: Obx(() {
            if (ctrl.isLoading.value) {
              return _buildShimmer();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Aliran Pembayaran'),
                  const SizedBox(height: 8),
                  _buildPaymentFlowCard(ctrl),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Pengaturan Durasi'),
                  const SizedBox(height: 8),
                  _buildDurationCard(ctrl),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Auto-Release'),
                  const SizedBox(height: 8),
                  _buildAutoReleaseCard(ctrl),
                  const SizedBox(height: 32),
                  _buildSaveButton(ctrl),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Get.isDarkMode ? AppColors.darkTextPrimary : Colors.grey.shade800,
      ),
    );
  }

  Widget _buildPaymentFlowCard(TableSettingsController ctrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Get.isDarkMode ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontSize: 14,
                color: Get.isDarkMode ? AppColors.darkTextSecondary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                _PaymentOption(
                  title: 'Bayar Duluan',
                  subtitle: 'Pelanggan bayar sebelum memesan',
                  icon: Icons.payment,
                  isSelected: ctrl.paymentFlow.value == 'PAY_FIRST',
                  onTap: () => ctrl.setPaymentFlow('PAY_FIRST'),
                ),
                const SizedBox(height: 8),
                _PaymentOption(
                  title: 'Bayar Nanti',
                  subtitle: 'Pelanggan bayar setelah makan',
                  icon: Icons.receipt_long,
                  isSelected: ctrl.paymentFlow.value == 'PAY_LAST',
                  onTap: () => ctrl.setPaymentFlow('PAY_LAST'),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(TableSettingsController ctrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Get.isDarkMode ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durasi Makan Default',
              style: TextStyle(
                fontSize: 14,
                color: Get.isDarkMode ? AppColors.darkTextSecondary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Obx(() => Text(
              ctrl.durationDisplay,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.orange),
            )),
            const SizedBox(height: 12),
            Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TableSettingsController.durationOptions.map((mins) {
                final isSelected = ctrl.defaultDineDuration.value == mins;
                return ChoiceChip(
                  label: Text(_formatDuration(mins)),
                  selected: isSelected,
                  onSelected: (_) => ctrl.setDineDuration(mins),
                  selectedColor: AppColors.orange,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (Get.isDarkMode ? AppColors.darkTextPrimary : Colors.grey.shade700),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? AppColors.orange : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoReleaseCard(TableSettingsController ctrl) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Get.isDarkMode ? AppColors.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto-Release Meja',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Otomatis kosongkan meja saat waktu habis',
                    style: TextStyle(
                      fontSize: 13,
                      color: Get.isDarkMode ? AppColors.darkTextSecondary : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Obx(() => Switch(
              value: ctrl.autoReleaseTable.value,
              onChanged: ctrl.toggleAutoRelease,
              activeColor: AppColors.orange,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(TableSettingsController ctrl) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: ctrl.isSaving.value ? null : ctrl.saveConfig,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: ctrl.isSaving.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Simpan Pengaturan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      )),
    );
  }

  Widget _buildShimmer() {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )),
        ),
      ),
    );
  }

  String _formatDuration(int mins) {
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    }
    return '${mins}m';
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.orange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.orange : (Get.isDarkMode ? AppColors.darkTextPrimary : Colors.grey.shade800),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.orange, size: 24),
          ],
        ),
      ),
    );
  }
}
