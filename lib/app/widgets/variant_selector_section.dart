import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/variant_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VariantSelectorSection extends StatelessWidget {
  final ProductModel product;
  final VariantModel? selectedVariant;
  final Function(VariantModel) onVariantSelected;

  const VariantSelectorSection({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (product.variants.isEmpty) return const SizedBox();

    // Group variants by name
    final variantGroups = <String, List<VariantModel>>{};
    for (var variant in product.variants) {
      if (!variantGroups.containsKey(variant.name)) {
        variantGroups[variant.name] = [];
      }
      variantGroups[variant.name]!.add(variant);
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimenssions.width20,
        vertical: Dimenssions.height10,
      ),
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius12),
        border: Border.all(color: backgroundColor3.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pilih Varian',
                style: primaryTextStyle.copyWith(
                  fontSize: Dimenssions.font16,
                  fontWeight: semiBold,
                ),
              ),
              SizedBox(width: Dimenssions.width8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimenssions.width8,
                  vertical: Dimenssions.height4,
                ),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimenssions.radius8),
                ),
                child: Text(
                  'Wajib',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font12,
                    color: alertColor,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimenssions.height16),
          ...variantGroups.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: secondaryTextStyle.copyWith(
                    fontSize: Dimenssions.font14,
                  ),
                ),
                SizedBox(height: Dimenssions.height8),
                Wrap(
                  spacing: Dimenssions.width8,
                  runSpacing: Dimenssions.height8,
                  children: entry.value.map((variant) {
                    final isSelected = selectedVariant?.id == variant.id;
                    return GestureDetector(
                      onTap: () => onVariantSelected(variant),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimenssions.width12,
                          vertical: Dimenssions.height8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? logoColorSecondary
                              : backgroundColor1,
                          border: Border.all(
                            color: isSelected
                                ? logoColorSecondary
                                : backgroundColor3,
                            width: 1.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(Dimenssions.radius8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              variant.value,
                              style: TextStyle(
                                fontSize: Dimenssions.font14,
                                color: isSelected
                                    ? backgroundColor1
                                    : primaryTextColor,
                                fontWeight: medium,
                              ),
                            ),
                            if (variant.priceAdjustment > 0) ...[
                              SizedBox(width: Dimenssions.width4),
                              Text(
                                '+${NumberFormat('#,###', 'id_ID').format(variant.priceAdjustment)}',
                                style: TextStyle(
                                  fontSize: Dimenssions.font12,
                                  color: isSelected
                                      ? backgroundColor1
                                      : logoColorSecondary,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: Dimenssions.height12),
              ],
            );
          }),
        ],
      ),
    );
  }
}
