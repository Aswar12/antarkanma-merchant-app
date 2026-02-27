import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/controllers/merchant_home_controller.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';

class ProductReadinessSheet extends GetView<MerchantHomeController> {
  const ProductReadinessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimenssions.radius20),
          topRight: Radius.circular(Dimenssions.radius20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: Dimenssions.height16),
          Text(
            'Cek Kesiapan Produk',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font18,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height8),
          Text(
            'Pilih produk yang HABIS (Tidak Tersedia). Produk yang tidak dipilih akan dianggap READY.',
            style: subtitleTextStyle.copyWith(
              fontSize: Dimenssions.font12,
            ),
          ),
          SizedBox(height: Dimenssions.height16),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingProducts.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.products.isEmpty) {
                return Center(
                  child: Text('Belum ada produk', style: subtitleTextStyle),
                );
              }

              return ListView.builder(
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return Obx(() {
                    final isUnavailable =
                        controller.unavailableProductIds.contains(product.id);
                    return CheckboxListTile(
                      title: Text(
                        product.name ?? '',
                        style: primaryTextStyle.copyWith(
                          fontSize: Dimenssions.font14,
                        ),
                      ),
                      value: isUnavailable,
                      activeColor: Colors.red,
                      onChanged: (bool? value) {
                        controller.toggleProductUnavailable(product.id!);
                      },
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                                product.galleries?.isNotEmpty == true
                                    ? product.galleries!.first.url!
                                    : 'https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          SizedBox(height: Dimenssions.height16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close sheet
                controller.confirmOpenShop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: logoColor,
                padding: EdgeInsets.symmetric(vertical: Dimenssions.height12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimenssions.radius12),
                ),
              ),
              child: Text(
                'Buka Toko Sekarang',
                style: textwhite.copyWith(
                  fontSize: Dimenssions.font16,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
