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
            color: logoColor.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimenssions.height16,
              horizontal: Dimenssions.width16,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: logoColor,
                  size: Dimenssions.iconSize24,
                ),
                SizedBox(width: Dimenssions.width12),
                Text(
                  'Manajemen Produk',
                  style: primaryTextStyle.copyWith(
                    color: logoColor,
                    fontSize: Dimenssions.font20,
                    fontWeight: bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(Dimenssions.height16),
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
                SizedBox(height: Dimenssions.height12),
                _buildFilterRow(),
                _buildVisibilityToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: Dimenssions.height45,
            decoration: BoxDecoration(
              color: backgroundColor1,
              borderRadius: BorderRadius.circular(Dimenssions.radius12),
              border: Border.all(
                color: logoColor.withOpacity(0.1),
              ),
            ),
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCategory.value,
                  isDense: true,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: logoColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Dimenssions.width16,
                    ),
                    border: InputBorder.none,
                  ),
                  dropdownColor: backgroundColor1,
                  items: ['Semua', ...controller.categories]
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: primaryTextStyle.copyWith(
                                fontSize: Dimenssions.font14,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.filterByCategory(value);
                    }
                  },
                )),
          ),
        ),
        SizedBox(width: Dimenssions.width12),
        Expanded(
          child: Container(
            height: Dimenssions.height45,
            decoration: BoxDecoration(
              color: backgroundColor1,
              borderRadius: BorderRadius.circular(Dimenssions.radius12),
              border: Border.all(
                color: logoColor.withOpacity(0.1),
              ),
            ),
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.sortBy.value,
                  isDense: true,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: logoColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Dimenssions.width16,
                    ),
                    border: InputBorder.none,
                  ),
                  dropdownColor: backgroundColor1,
                  items: _buildSortItems(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.sortProducts(value);
                    }
                  },
                )),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildSortItems() {
    return [
      _buildSortItem('Baru', Icons.access_time_rounded, 'Terbaru'),
      _buildSortItem('A-Z', Icons.sort_by_alpha_rounded, 'A-Z'),
      _buildSortItem('Z-A', Icons.sort_by_alpha_rounded, 'Z-A'),
      _buildSortItem('price_asc', Icons.arrow_upward_rounded, 'Harga ↑'),
      _buildSortItem('price_desc', Icons.arrow_downward_rounded, 'Harga ↓'),
    ];
  }

  DropdownMenuItem<String> _buildSortItem(
      String value, IconData icon, String label) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: Dimenssions.iconSize16, color: logoColor),
          SizedBox(width: Dimenssions.width8),
          Text(
            label,
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      margin: EdgeInsets.only(top: Dimenssions.height8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: Row(
          children: [
            Icon(
              Icons.visibility_rounded,
              size: Dimenssions.iconSize16,
              color: logoColor,
            ),
            SizedBox(width: Dimenssions.width8),
            Text(
              'Tampilkan Produk Aktif',
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font14,
              ),
            ),
          ],
        ),
        trailing: Obx(() => Switch.adaptive(
              value: controller.showActiveOnly.value,
              onChanged: controller.toggleActiveOnly,
              activeColor: logoColor,
            )),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
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
                  color: logoColor.withOpacity(0.2),
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
    return FloatingActionButton(
      onPressed: () => _navigateToProductForm(),
      backgroundColor: logoColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimenssions.radius16),
      ),
      child: const Icon(Icons.add_rounded),
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
