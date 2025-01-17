import 'dart:io';
import 'package:antarkanma_merchant/app/controllers/merchant_product_form_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/variant_model.dart';
import 'package:antarkanma_merchant/app/utils/thousand_separator_formatter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(8),
      ));

    final Path dashPath = Path();
    final double dashWidth = 5.0;

    for (ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProductFormPage extends GetView<MerchantProductFormController> {
  final Map<String, dynamic>? product;

  const ProductFormPage({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.setInitialData(product);

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: false);
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundColor1,
        appBar: AppBar(
          title: Text(
            product != null ? 'Edit Produk' : 'Tambah Produk',
            style: primaryTextStyle.copyWith(color: logoColor),
          ),
          backgroundColor: transparentColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: logoColor),
            onPressed: () => Get.back(result: false),
          ),
        ),
        body: GetBuilder<MerchantProductFormController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            return Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageUploadSection(),
                    if (controller.images.isEmpty &&
                        controller.existingImages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Minimal 1 foto harus diupload',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 20),
                    _buildTextField(
                      'Nama Produk',
                      'Masukkan nama produk',
                      controller: controller.nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Deskripsi',
                      'Masukkan deskripsi produk',
                      controller: controller.descriptionController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    SizedBox(height: 16),
                    _buildTextField(
                      'Harga',
                      'Masukkan harga produk',
                      controller: controller.priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      prefixText: 'Rp ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga produk tidak boleh kosong';
                        }
                        String numericValue =
                            value.replaceAll(RegExp(r'[^\d]'), '');
                        if (double.tryParse(numericValue) == null) {
                          return 'Harga harus berupa angka';
                        }
                        if (double.parse(numericValue) <= 0) {
                          return 'Harga harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildVariantSection(),
                    SizedBox(height: 16),
                    _buildStatusSwitch(),
                    SizedBox(height: 24),
                    if (controller.errorMessage.value.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.canSave.value
                            ? () async {
                                if (controller.formKey.currentState
                                        ?.validate() ??
                                    false) {
                                  await controller.saveProduct();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.canSave.value
                              ? logoColor
                              : Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Simpan Produk',
                          style: primaryTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: primaryTextStyle.copyWith(
            fontSize: 14,
            fontWeight: bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: secondaryTextStyle,
            prefixText: prefixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GetBuilder<MerchantProductFormController>(
            builder: (controller) {
              if (controller.images.isEmpty &&
                  controller.existingImages.isEmpty) {
                return _buildImagePlaceholder();
              }
              return _buildImageGrid();
            },
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await controller.pickImages();
            },
            icon: Icon(Icons.add_photo_alternate),
            label: Text('Tambah Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: logoColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          CustomPaint(
            size: Size(double.infinity, 200),
            painter: DashedBorderPainter(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              gap: 5.0,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Tambahkan Foto Produk',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GetBuilder<MerchantProductFormController>(
      builder: (controller) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.existingImages.length + controller.images.length,
          itemBuilder: (context, index) {
            bool isExisting = index < controller.existingImages.length;
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isExisting
                      ? Image.network(
                          controller.existingImages[index]['url'] as String,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.error_outline, color: Colors.red),
                            );
                          },
                        )
                      : Image.file(
                          File(controller.images[index - controller.existingImages.length].path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.error_outline, color: Colors.red),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () async {
                      await controller.removeImage(
                        isExisting ? index : index - controller.existingImages.length,
                        isExisting: isExisting,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: primaryTextStyle.copyWith(
            fontSize: 14,
            fontWeight: bold,
          ),
        ),
        SizedBox(height: 8),
        GetBuilder<MerchantProductFormController>(
          builder: (controller) {
            return DropdownButtonFormField<String>(
              value: controller.selectedCategoryName.value,
              hint: Text('Pilih kategori'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori harus dipilih';
                }
                return null;
              },
              items: controller.categories
                  .map((category) => DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  final selectedCategory = controller.categories
                      .firstWhere((cat) => cat.name == value);
                  controller.setCategory(selectedCategory);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVariantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Varian Produk (Opsional)',
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showVariantDialog(),
              icon: Icon(Icons.add, color: logoColor),
              label: Text(
                'Tambah Varian',
                style: primaryTextStyle.copyWith(color: logoColor),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        GetBuilder<MerchantProductFormController>(
          builder: (controller) {
            if (controller.variants.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Belum ada varian',
                    style: secondaryTextStyle,
                  ),
                ),
              );
            }

            final variantGroups = <String, List<VariantModel>>{};
            for (var variant in controller.variants) {
              if (!variantGroups.containsKey(variant.name)) {
                variantGroups[variant.name] = [];
              }
              variantGroups[variant.name]!.add(variant);
            }

            return Column(
              children: variantGroups.entries.map((entry) {
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: primaryTextStyle.copyWith(
                            fontWeight: semiBold,
                          ),
                        ),
                        Divider(),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.value.map((variant) {
                            return Chip(
                              label: Text(
                                '${variant.value} (+${NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp ',
                                  decimalDigits: 0,
                                ).format(variant.priceAdjustment)})',
                                style: primaryTextStyle.copyWith(fontSize: 12),
                              ),
                              deleteIcon: Icon(Icons.close, size: 16),
                              onDeleted: () =>
                                  controller.removeVariant(variant),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Status Produk',
          style: primaryTextStyle.copyWith(
            fontSize: 14,
            fontWeight: bold,
          ),
        ),
        GetBuilder<MerchantProductFormController>(
          builder: (controller) {
            return Switch(
              value: controller.isActive.value,
              onChanged: (value) {
                controller.isActive.value = value;
                controller.update();
              },
              activeColor: logoColor,
            );
          },
        ),
      ],
    );
  }

  void _showVariantDialog({VariantModel? existingVariant, int? index}) {
    final nameController = TextEditingController(text: existingVariant?.name);
    final valueController = TextEditingController(text: existingVariant?.value);
    final priceController = TextEditingController(
      text: existingVariant?.priceAdjustment.toString() ?? '0',
    );

    Get.dialog(
      AlertDialog(
        title: Text(
          existingVariant == null ? 'Tambah Varian' : 'Edit Varian',
          style: primaryTextStyle.copyWith(fontWeight: semiBold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Varian',
                labelStyle: secondaryTextStyle,
                hintText: 'Contoh: Ukuran, Warna',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: InputDecoration(
                labelText: 'Nilai Varian',
                labelStyle: secondaryTextStyle,
                hintText: 'Contoh: XL, Merah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Tambahan Harga',
                labelStyle: secondaryTextStyle,
                hintText: 'Masukkan tambahan harga',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: 'Rp ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: primaryTextStyle.copyWith(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String numericValue =
                  priceController.text.replaceAll(RegExp(r'[^\d]'), '');
              final variant = VariantModel(
                id: existingVariant?.id,
                productId: existingVariant?.productId,
                name: nameController.text,
                value: valueController.text,
                priceAdjustment: double.tryParse(numericValue) ?? 0,
                status: existingVariant?.status ?? 'ACTIVE',
              );

              if (index != null) {
                controller.updateVariant(index, variant);
              } else {
                controller.addVariant(variant);
              }

              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: logoColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Simpan',
              style: primaryTextStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
