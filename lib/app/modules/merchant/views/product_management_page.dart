import 'package:antarkanma_merchant/app/controllers/merchant_product_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_product_detail_page.dart';
import 'package:antarkanma_merchant/app/widgets/search_input_field.dart';
import 'package:antarkanma_merchant/app/widgets/product_card.dart';
import 'product_form_page.dart';

class ProductManagementPage extends GetView<MerchantProductController> {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: backgroundColor1,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor8,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: GetX<MerchantProductController>(
                  builder: (controller) {
                    if (controller.isLoading.value &&
                        controller.products.isEmpty) {
                      return _buildLoadingState();
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return _buildErrorState();
                    }

                    if (controller.filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildProductGrid();
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor1,
        boxShadow: [
          BoxShadow(
            color: logoColor.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimenssions.height8,
              horizontal: Dimenssions.width16,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: logoColor,
                  size: Dimenssions.iconSize20,
                ),
                SizedBox(width: Dimenssions.width12),
                Text(
                  'Manajemen Produk',
                  style: primaryTextStyle.copyWith(
                    color: logoColor,
                    fontSize: Dimenssions.font18,
                    fontWeight: bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimenssions.width16,
              vertical: Dimenssions.height8,
            ),
            child: Column(
              children: [
                SearchInputField(
                  controller: controller.searchController,
                  hintText: 'Cari produk...',
                  onChanged: controller.searchProducts,
                  onClear: () {
                    controller.searchController.clear();
                    controller.searchProducts('');
                  },
                ),
                SizedBox(height: Dimenssions.height8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactDropdown(
                        value: controller.selectedCategory.value,
                        items: ['Semua', ...controller.categories],
                        onChanged: (value) {
                          if (value != null) {
                            controller.filterByCategory(value);
                          }
                        },
                      ),
                    ),
                    SizedBox(width: Dimenssions.width8),
                    Expanded(
                      child: _buildCompactDropdown(
                        value: controller.sortBy.value,
                        items: [
                          'Baru',
                          'A-Z',
                          'Z-A',
                          'price_asc',
                          'price_desc'
                        ],
                        displayLabels: [
                          'Terbaru',
                          'A-Z',
                          'Z-A',
                          'Harga ↑',
                          'Harga ↓'
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.sortProducts(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDropdown({
    required String value,
    required List<String> items,
    List<String>? displayLabels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: Dimenssions.height35,
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius8),
        border: Border.all(
          color: logoColor.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isDense: true,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: logoColor,
          size: Dimenssions.iconSize16,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: Dimenssions.width12,
          ),
          border: InputBorder.none,
        ),
        dropdownColor: backgroundColor1,
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final label = displayLabels != null && index < displayLabels.length
              ? displayLabels[index]
              : item;
          return DropdownMenuItem(
            value: item,
            child: Text(
              label,
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font12,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: Dimenssions.width40,
            height: Dimenssions.height40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(logoColor),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: Dimenssions.height16),
          Text(
            'Memuat produk...',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshProducts();
      },
      color: logoColor,
      backgroundColor: backgroundColor1,
      strokeWidth: 3,
      displacement: 20,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!controller.isLoadingMore.value &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.8) {
            controller.loadMoreProducts();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimenssions.width12,
                vertical: Dimenssions.height12,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: Dimenssions.width12,
                  mainAxisSpacing: Dimenssions.height12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= controller.filteredProducts.length) {
                      if (controller.hasMoreData.value) {
                        return _buildLoadingIndicator();
                      }
                      return null;
                    }
                    return ProductCard(
                      product: controller.filteredProducts[index],
                      onTap: () => _navigateToProductForm(
                        product: controller.filteredProducts[index],
                      ),
                    );
                  },
                  childCount: controller.hasMoreData.value
                      ? controller.filteredProducts.length + 1
                      : controller.filteredProducts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Dimenssions.height16),
        child: SizedBox(
          width: Dimenssions.width20,
          height: Dimenssions.height20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(logoColor),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshProducts(),
      color: logoColor,
      backgroundColor: backgroundColor1,
      strokeWidth: 3,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: Get.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: Dimenssions.iconSize24 * 2,
                  color: Colors.red[400],
                ),
                SizedBox(height: Dimenssions.height16),
                Text(
                  controller.errorMessage.value,
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font14,
                    color: Colors.red[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimenssions.height16),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshProducts(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimenssions.width20,
                      vertical: Dimenssions.height12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshProducts(),
      color: logoColor,
      backgroundColor: backgroundColor1,
      strokeWidth: 3,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: Get.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: Dimenssions.iconSize24 * 3,
                  color: logoColor.withValues(alpha: 0.2),
                ),
                SizedBox(height: Dimenssions.height16),
                Text(
                  'Belum ada produk',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font18,
                    fontWeight: bold,
                  ),
                ),
                SizedBox(height: Dimenssions.height8),
                Text(
                  'Tambahkan produk pertama Anda',
                  style: secondaryTextStyle.copyWith(
                    fontSize: Dimenssions.font14,
                  ),
                ),
                SizedBox(height: Dimenssions.height24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToProductForm(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah Produk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimenssions.width20,
                      vertical: Dimenssions.height12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimenssions.radius12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimenssions.height65),
      child: FloatingActionButton(
        onPressed: () => _navigateToProductForm(),
        backgroundColor: logoColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius16),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _navigateToProductForm({ProductModel? product}) async {
    if (product != null) {
      final result =
          await Get.to(() => MerchantProductDetailPage(product: product));
      if (result != null) {
        controller.refreshProducts();
      }
    } else {
      final result = await Get.to(() => ProductFormPage(product: null));
      if (result != null) {
        controller.refreshProducts();
      }
    }
  }
}
