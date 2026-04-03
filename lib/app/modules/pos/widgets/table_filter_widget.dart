import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';

class TableFilterWidget extends StatelessWidget {
  final List<String> filters;
  final RxString selectedFilter;
  final void Function(String) onFilterChanged;
  final Map<String, int> counts;

  const TableFilterWidget({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final count = counts[filter] ?? 0;
          return Obx(() {
            final isSelected = selectedFilter.value == filter;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_filterLabel(filter)),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white24 : AppColors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: Get.isDarkMode ? AppColors.darkCard : Colors.grey.shade100,
              selectedColor: AppColors.orange,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : (Get.isDarkMode ? AppColors.darkTextPrimary : Colors.grey.shade700),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.orange : Colors.grey.shade300,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            );
          });
        },
      ),
    );
  }

  String _filterLabel(String filter) {
    switch (filter) {
      case 'ALL': return 'Semua';
      case 'AVAILABLE': return 'Tersedia';
      case 'OCCUPIED': return 'Terisi';
      case 'RESERVED': return 'Dipesan';
      default: return filter;
    }
  }
}
