import 'package:antarkanma_merchant/app/controllers/merchant_product_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_product_detail_page.dart';
import 'product_form_page.dart';
import 'package:antarkanma_merchant/app/widgets/product_card.dart';

class ProductManagementPage extends GetView<MerchantProductController> {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: context.backgroundColor,
        systemNavigationBarIconBrightness:
            context.isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: GetX<MerchantProductController>(
                builder: (controller) {
                  if (controller.isLoading.value &&
                      controller.products.isEmpty) {
                    return _buildLoadingState(context);
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorState(context);
                  }

                  if (controller.filteredProducts.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildProductGrid(context);
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(
            color: context.dividerColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.black26
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.cardColor,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: context.textSecondaryColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view, size: 22),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale, size: 22),
            label: 'Kasir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining, size: 22),
            label: 'Online',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 22),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 22),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? Colors.black26 : Colors.grey.shade100,
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Row - Compact with Dynamic Text Color
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimenssions.width16,
              Dimenssions.height12,
              Dimenssions.width16,
              Dimenssions.height8,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: context.textColor,
                  size: Dimenssions.iconSize20,
                ),
                SizedBox(width: Dimenssions.width12),
                Expanded(
                  child: Text(
                    'Manajemen Produk',
                    style: primaryTextStyle.copyWith(
                      color: context.textColor,
                      fontSize: Dimenssions.font16,
                      fontWeight: bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Search & Filter - Navy Dark Style (Always Navy)
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimenssions.width16,
              0,
              Dimenssions.width16,
              Dimenssions.height12,
            ),
            child: _buildPremiumSearchFilter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSearchFilter(BuildContext context) {
    final controller = Get.find<MerchantProductController>();
    return Obx(() {
      final selectedCategory = controller.selectedCategory.value;
      final sortBy = controller.sortBy.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.navyDark : AppColors.navy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Search Input - 60%
            Expanded(
              flex: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.white30,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: controller.searchProducts,
                      ),
                    ),
                    // Clear Button
                    if (controller.searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          controller.searchController.clear();
                          controller.searchProducts('');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.clear,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Vertical Divider
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white.withOpacity(0.1),
            ),
            // Category Selector - 20% (Icon Only)
            Expanded(
              flex: 20,
              child: GestureDetector(
                onTap: () => _showCategoryFilterDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: selectedCategory == 'Semua'
                        ? AppColors.orange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: selectedCategory == 'Semua'
                        ? null
                        : Border.all(
                            color: AppColors.orange,
                            width: 1.5,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selectedCategory == 'Semua'
                            ? Icons.category
                            : Icons.category_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Vertical Divider
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.white.withOpacity(0.1),
            ),
            // Sort Filter - 20% (Icon Only)
            Expanded(
              flex: 20,
              child: GestureDetector(
                onTap: () => _showSortFilterDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sortBy == 'Baru'
                        ? AppColors.orange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: sortBy == 'Baru'
                        ? null
                        : Border.all(
                            color: AppColors.orange,
                            width: 1.5,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sortBy == 'Baru' ? Icons.tune : Icons.sort,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showCategoryFilterDialog(BuildContext context) {
    final controller = Get.find<MerchantProductController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
        ),
        title: Text(
          'Pilih Kategori',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font16,
            fontWeight: bold,
            color: context.textColor,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: controller.categories.length + 1,
                itemBuilder: (context, index) {
                  final category =
                      index == 0 ? 'Semua' : controller.categories[index - 1];
                  final isSelected =
                      controller.selectedCategory.value == category;

                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? AppColors.orange
                          : context.textSecondaryColor,
                    ),
                    title: Text(
                      category,
                      style: primaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.orange : context.textColor,
                      ),
                    ),
                    onTap: () {
                      controller.filterByCategory(category);
                      Get.back();
                    },
                  );
                },
              )),
        ),
      ),
    );
  }

  void _showSortFilterDialog(BuildContext context) {
    final controller = Get.find<MerchantProductController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
        ),
        title: Text(
          'Urutkan',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font16,
            fontWeight: bold,
            color: context.textColor,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  final options = [
                    {
                      'value': 'Baru',
                      'label': 'Terbaru',
                      'icon': Icons.new_releases
                    },
                    {
                      'value': 'A-Z',
                      'label': 'A-Z',
                      'icon': Icons.sort_by_alpha
                    },
                    {
                      'value': 'Z-A',
                      'label': 'Z-A',
                      'icon': Icons.sort_by_alpha
                    },
                    {
                      'value': 'price_asc',
                      'label': 'Harga: Rendah ke Tinggi',
                      'icon': Icons.arrow_downward
                    },
                    {
                      'value': 'price_desc',
                      'label': 'Harga: Tinggi ke Rendah',
                      'icon': Icons.arrow_upward
                    },
                  ];
                  final option = options[index];
                  final value = option['value'] as String;
                  final label = option['label'] as String;
                  final isSelected = controller.sortBy.value == value;

                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? AppColors.orange
                          : context.textSecondaryColor,
                    ),
                    title: Text(
                      label,
                      style: primaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected ? AppColors.orange : context.textColor,
                      ),
                    ),
                    onTap: () {
                      controller.sortBy.value = value;
                      controller.sortProducts(value);
                      Get.back();
                    },
                  );
                },
              )),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: Dimenssions.width40,
            height: Dimenssions.height40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: Dimenssions.height16),
          Text(
            'Memuat produk...',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font14,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshProducts();
      },
      color: AppColors.orange,
      backgroundColor: context.cardColor,
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshProducts(),
      color: AppColors.orange,
      backgroundColor: context.cardColor,
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
                  color: context.isDark ? AppColors.error : Colors.red[400],
                ),
                SizedBox(height: Dimenssions.height16),
                Text(
                  controller.errorMessage.value,
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font14,
                    color: context.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dimenssions.height16),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshProducts(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
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

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshProducts(),
      color: AppColors.orange,
      backgroundColor: context.cardColor,
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
                  color: context.textSecondaryColor,
                ),
                SizedBox(height: Dimenssions.height16),
                Text(
                  'Belum ada produk',
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font18,
                    fontWeight: bold,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: Dimenssions.height8),
                Text(
                  'Tambahkan produk pertama Anda',
                  style: secondaryTextStyle.copyWith(
                    fontSize: Dimenssions.font14,
                    color: context.textSecondaryColor,
                  ),
                ),
                SizedBox(height: Dimenssions.height24),
                ElevatedButton.icon(
                  onPressed: () => _navigateToProductForm(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Tambah Produk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
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
        backgroundColor: AppColors.orange,
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
