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
        backgroundColor: backgroundColor1, // Changed to match header
        body: Column(
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
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: logoColor.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Title Row - Compact
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
                  color: logoColor,
                  size: Dimenssions.iconSize20,
                ),
                SizedBox(width: Dimenssions.width12),
                Expanded(
                  child: Text(
                    'Manajemen Produk',
                    style: primaryTextStyle.copyWith(
                      color: logoColor,
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
          // Search Bar with Icon Filters - Compact
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimenssions.width16,
              0,
              Dimenssions.width16,
              Dimenssions.height12,
            ),
            child: Row(
              children: [
                // Search Input - Expanded
                Expanded(
                  child: SearchInputField(
                    controller: controller.searchController,
                    hintText: 'Cari produk...',
                    onChanged: controller.searchProducts,
                    onClear: () {
                      controller.searchController.clear();
                      controller.searchProducts('');
                    },
                  ),
                ),
                // Category Filter Icon
                SizedBox(width: Dimenssions.width8),
                Obx(() => _buildFilterIconButton(
                      icon: controller.selectedCategory.value == 'Semua'
                          ? Icons.category_outlined
                          : Icons.category,
                      color: controller.selectedCategory.value == 'Semua'
                          ? logoColor
                          : dashPrimary,
                      onTap: () => _showCategoryFilterDialog(),
                    )),
                // Sort Icon
                SizedBox(width: Dimenssions.width4),
                Obx(() => _buildFilterIconButton(
                      icon: _getSortIcon(controller.sortBy.value),
                      color: controller.sortBy.value == 'Baru'
                          ? logoColor
                          : dashPrimary,
                      onTap: () => _showSortFilterDialog(),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(Dimenssions.height8),
        decoration: BoxDecoration(
          color: backgroundColor8,
          borderRadius: BorderRadius.circular(Dimenssions.radius12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortBy) {
    switch (sortBy) {
      case 'A-Z':
        return Icons.sort_by_alpha;
      case 'Z-A':
        return Icons.sort_by_alpha;
      case 'price_asc':
        return Icons.arrow_downward;
      case 'price_desc':
        return Icons.arrow_upward;
      default:
        return Icons.sort;
    }
  }

  void _showCategoryFilterDialog() {
    final controller = Get.find<MerchantProductController>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
        ),
        title: Text(
          'Pilih Kategori',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font16,
            fontWeight: bold,
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
                  final category = index == 0 ? 'Semua' : controller.categories[index - 1];
                  final isSelected = controller.selectedCategory.value == category;
                  
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? dashPrimary : Colors.grey,
                    ),
                    title: Text(
                      category,
                      style: primaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? dashPrimary : Colors.black,
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

  void _showSortFilterDialog() {
    final controller = Get.find<MerchantProductController>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
        ),
        title: Text(
          'Urutkan',
          style: primaryTextStyle.copyWith(
            fontSize: Dimenssions.font16,
            fontWeight: bold,
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
                    {'value': 'Baru', 'label': 'Terbaru', 'icon': Icons.new_releases},
                    {'value': 'A-Z', 'label': 'A-Z', 'icon': Icons.sort_by_alpha},
                    {'value': 'Z-A', 'label': 'Z-A', 'icon': Icons.sort_by_alpha},
                    {'value': 'price_asc', 'label': 'Harga: Rendah ke Tinggi', 'icon': Icons.arrow_downward},
                    {'value': 'price_desc', 'label': 'Harga: Tinggi ke Rendah', 'icon': Icons.arrow_upward},
                  ];
                  final option = options[index];
                  final value = option['value'] as String;
                  final label = option['label'] as String;
                  final isSelected = controller.sortBy.value == value;
                  
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? dashPrimary : Colors.grey,
                    ),
                    title: Text(
                      label,
                      style: primaryTextStyle.copyWith(
                        fontSize: Dimenssions.font14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? dashPrimary : Colors.black,
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
