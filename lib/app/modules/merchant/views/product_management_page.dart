import 'package:antarkanma_merchant/app/controllers/merchant_product_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_product_detail_page.dart';
import 'package:antarkanma_merchant/app/widgets/search_input_field.dart';
import 'product_form_page.dart';

class ProductManagementPage extends GetView<MerchantProductController> {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: backgroundColor1,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: backgroundColor1,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor1,
        body: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: backgroundColor1,
                child: Center(
                  child: Text(
                    'Manajemen Produk',
                    style: primaryTextStyle.copyWith(
                      color: logoColor,
                      fontSize: 18,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
              ),
              _buildHeader(),
              Expanded(
                child: GetX<MerchantProductController>(
                  builder: (controller) {
                    if (controller.isLoading.value &&
                        controller.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToProductForm(),
          backgroundColor: logoColor,
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimenssions.width16,
        vertical: Dimenssions.height12,
      ),
      color: backgroundColor1,
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
          const SizedBox(height: 12),
          _buildFilterRow(),
          _buildVisibilityToggle(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCategory.value,
                  isDense: true,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryTextColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: backgroundColor1,
                  ),
                  dropdownColor: backgroundColor1,
                  items: ['Semua', ...controller.categories]
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryTextColor,
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
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: Obx(() => DropdownButtonFormField<String>(
                  value: controller.sortBy.value,
                  isDense: true,
                  isExpanded: true,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryTextColor,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: backgroundColor1,
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
      _buildSortItem('Baru', Icons.access_time, 'Terbaru'),
      _buildSortItem('A-Z', Icons.sort_by_alpha, 'A-Z'),
      _buildSortItem('Z-A', Icons.sort_by_alpha, 'Z-A'),
      _buildSortItem('price_asc', Icons.arrow_upward, 'Harga ↑'),
      _buildSortItem('price_desc', Icons.arrow_downward, 'Harga ↓'),
    ];
  }

  DropdownMenuItem<String> _buildSortItem(
      String value, IconData icon, String label) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: logoColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Transform.scale(
      scale: 0.9,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Icon(Icons.visibility, size: 16, color: logoColor),
            const SizedBox(width: 8),
            const Text('Produk Aktif', style: TextStyle(fontSize: 14)),
          ],
        ),
        trailing: Obx(() => Switch(
              value: controller.showActiveOnly.value,
              onChanged: controller.toggleActiveOnly,
              activeColor: logoColor,
            )),
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
      displacement: 20,
      strokeWidth: 3,
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
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= controller.filteredProducts.length) {
                      if (controller.hasMoreData.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return null;
                    }
                    return _buildProductCard(
                        controller.filteredProducts[index]);
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

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => _navigateToProductForm(product: product),
      child: Card(
        color: backgroundColor1,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null) _buildCategoryChip(product),
                  const SizedBox(height: 4),
                  _buildProductInfo(product),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              product.firstImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/image_shoes.png',
                  fit: BoxFit.cover,
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: primaryTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: priceTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(product),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ProductModel product) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: product.isActive
              ? Colors.green.withOpacity(0.9)
              : Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          product.isActive ? 'Aktif' : 'Nonaktif',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ProductModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: logoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        product.category!.name,
        style: TextStyle(
          color: logoColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Row(
      children: [
        const Icon(Icons.star, size: 14, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          product.averageRating.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          ' (${product.totalReviews})',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        if (product.variants.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.style, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${product.variants.length}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: () => controller.refreshProducts(),
      color: logoColor,
      backgroundColor: backgroundColor1,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: Get.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshProducts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Coba Lagi'),
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: Get.height - 200, // Adjust height to ensure scrollable area
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Belum ada produk',
                  style: primaryTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan produk pertama Anda',
                  style: secondaryTextStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToProductForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Produk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
