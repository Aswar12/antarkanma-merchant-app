import 'package:antarkanma_merchant/app/controllers/merchant_product_controller.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/utils/image_viewer_page.dart';
import 'package:intl/intl.dart';
import 'product_form_page.dart';

class MerchantProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const MerchantProductDetailPage({Key? key, required this.product})
      : super(key: key);

  @override
  State<MerchantProductDetailPage> createState() =>
      _MerchantProductDetailPageState();
}

class _MerchantProductDetailPageState extends State<MerchantProductDetailPage> {
  int currentImageIndex = 0;
  final MerchantProductController productController =
      Get.find<MerchantProductController>();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Expanded(child: Text('Konfirmasi Hapus')),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Get.back(result: false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true && widget.product.id != null) {
      final result = await productController.deleteProduct(widget.product.id!);
      if (result['success']) {
        Get.back(result: true);
        Get.snackbar(
          'Sukses',
          'Produk berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal menghapus produk',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void _handleImageTap(int index) {
    Get.to(
      () => ImageViewerPage(
        imageUrls: widget.product.imageUrls.isEmpty
            ? ['assets/image_shoes.png']
            : widget.product.imageUrls,
        initialIndex: index,
        heroTagPrefix: 'product_${widget.product.id}',
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: SafeArea(
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildProductInfo(),
                  _buildVariantSection(),
                  _buildStatisticsSection(),
                  _buildReviewsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.width,
      floating: false,
      pinned: true,
      backgroundColor: backgroundColor1,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor1.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: logoColor),
        ),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider(
              items: widget.product.imageUrls.isEmpty
                  ? [
                      _buildImageItem(
                        'assets/image_shoes.png',
                        isAsset: true,
                        index: 0,
                      ),
                    ]
                  : List.generate(
                      widget.product.imageUrls.length,
                      (index) => _buildImageItem(
                        widget.product.imageUrls[index],
                        index: index,
                      ),
                    ),
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: widget.product.imageUrls.length > 1,
                autoPlay: widget.product.imageUrls.length > 1,
                onPageChanged: (index, _) {
                  setState(() => currentImageIndex = index);
                },
              ),
            ),
            if (widget.product.imageUrls.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: currentImageIndex,
                    count: widget.product.imageUrls.length,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      spacing: 6,
                      activeDotColor: logoColor,
                      dotColor: backgroundColor1.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: backgroundColor1,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl,
      {bool isAsset = false, required int index}) {
    return GestureDetector(
      onTap: () => _handleImageTap(index),
      behavior: HitTestBehavior.opaque,
      child: isAsset
          ? Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/image_shoes.png',
                fit: BoxFit.cover,
              ),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: logoColor,
                  ),
                );
              },
            ),
    );
  }

  // Rest of the widget methods remain unchanged...
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: primaryTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.product.category?.name ?? 'No Category',
                        style: primaryTextStyle.copyWith(
                          color: logoColor,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.product.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.product.isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    color: widget.product.isActive ? Colors.green : Colors.red,
                    fontWeight: medium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.product.formattedPrice,
            style: priceTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Deskripsi Produk',
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: secondaryTextStyle.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantSection() {
    if (widget.product.variants.isEmpty) return const SizedBox();

    final variantGroups = <String, List<dynamic>>{};
    for (var variant in widget.product.variants) {
      if (!variantGroups.containsKey(variant.name)) {
        variantGroups[variant.name] = [];
      }
      variantGroups[variant.name]!.add(variant);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Varian Produk',
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: 16),
          ...variantGroups.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: secondaryTextStyle,
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((variant) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: backgroundColor1,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            variant.value,
                            style: primaryTextStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          if (variant.priceAdjustment > 0) ...[
                            SizedBox(width: 4),
                            Text(
                              '+${NumberFormat('#,###', 'id_ID').format(variant.priceAdjustment)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: logoColor,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Produk',
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  value: widget.product.averageRating.toStringAsFixed(1),
                  label: 'Rating',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.reviews,
                  iconColor: logoColor,
                  value: widget.product.totalReviews.toString(),
                  label: 'Reviews',
                ),
              ),
              if (widget.product.variants.isNotEmpty)
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.style,
                    iconColor: Colors.blue,
                    value: widget.product.variants.length.toString(),
                    label: 'Variants',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (widget.product.totalReviews == 0) return const SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan Pembeli',
                style: primaryTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              if (widget.product.totalReviews > 3)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all reviews page
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: logoColor,
                      fontWeight: medium,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          // TODO: Replace with actual reviews data
          _buildReviewItem(
              username: "John Doe",
              rating: 5,
              comment: "Produk sangat bagus dan sesuai deskripsi",
              date: "2 hari yang lalu"),
          Divider(height: 24),
          _buildReviewItem(
              username: "Jane Smith",
              rating: 4,
              comment: "Kualitas bagus, pengiriman cepat",
              date: "1 minggu yang lalu"),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String username,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: logoColor.withOpacity(0.1),
              child: Text(
                username[0],
                style: TextStyle(
                  color: logoColor,
                  fontWeight: semiBold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: primaryTextStyle.copyWith(
                      fontWeight: semiBold,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                      SizedBox(width: 8),
                      Text(
                        date,
                        style: secondaryTextStyle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          comment,
          style: primaryTextStyle.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        Text(
          label,
          style: secondaryTextStyle.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    Map<String, dynamic> productData = {
      'id': widget.product.id,
      'name': widget.product.name,
      'description': widget.product.description,
      'price': widget.product.price,
      'status': widget.product.isActive,
      'gallery': widget.product.galleries
          .map((g) => {
                'id': g.id,
                'url': g.url,
              })
          .toList(),
      'imageUrls': widget.product.imageUrls,
      'variants': widget.product.variants.map((v) => v.toJson()).toList(),
      'category': widget.product.category?.toJson(),
    };

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => ProductFormPage(product: productData));
                },
                icon: Icon(Icons.edit),
                label: Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _handleDelete,
                icon: Icon(Icons.delete),
                label: Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
