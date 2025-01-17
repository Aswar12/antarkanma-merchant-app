import 'package:antarkanma_merchant/app/controllers/product_detail_controller.dart';
import 'package:antarkanma_merchant/app/data/models/product_review_model.dart';
import 'package:antarkanma_merchant/app/widgets/profile_image.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductReviewSection extends StatelessWidget {
  final ProductDetailController controller;

  const ProductReviewSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimenssions.width20,
        vertical: Dimenssions.height10,
      ),
      child: Obx(() {
        if (controller.isLoadingReviews.value && controller.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            _buildReviews(),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor1,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: backgroundColor3.withAlpha(51)), // 0.2 opacity = 51 in alpha
          ),
          child: Column(
            children: [
              Obx(() => Text(
                controller.averageRating.value.toStringAsFixed(1),
                style: primaryTextStyle.copyWith(
                  fontSize: 24,
                  fontWeight: semiBold,
                ),
              )),
              const SizedBox(height: 1),
              Obx(() => Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < controller.averageRating.value
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  );
                }),
              )),
              const SizedBox(height: 2),
              Obx(() => Text(
                '${controller.reviewCount} Ulasan',
                style: subtitleTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: medium,
                ),
              )),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Rating Filters
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildRatingFilter(0, 'Semua'),
                  const SizedBox(width: 4),
                  ...List.generate(5, (index) {
                    final rating = 5 - index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildRatingFilter(rating, '$rating⭐'),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter(int rating, String label) {
    return Obx(() {
      final isSelected = controller.selectedRatingFilter.value == rating;
      return GestureDetector(
        onTap: () => controller.setRatingFilter(rating),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isSelected ? logoColorSecondary : backgroundColor1,
            border: Border.all(
              color: isSelected ? logoColorSecondary : backgroundColor3,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: primaryTextStyle.copyWith(
              fontSize: 12,
              color: isSelected ? backgroundColor1 : primaryTextColor,
              fontWeight: medium,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildReviews() {
    return Obx(() {
      if (controller.reviews.isEmpty) {
        return Center(
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: backgroundColor3,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada ulasan untuk produk ini.',
                style: secondaryTextStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Jadilah yang pertama memberikan ulasan!',
                style: subtitleTextStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.fetchReviews,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.visibleReviews.length,
              itemBuilder: (context, index) {
                final review = controller.visibleReviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _buildReviewItem(review),
                );
              },
            ),
            if (controller.hasMoreReviews) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: controller.toggleReviews,
                  child: Text(
                    controller.isExpanded.value
                        ? 'Lihat lebih sedikit'
                        : 'Lihat semua ulasan',
                    style: primaryTextOrange.copyWith(
                      fontSize: 12,
                      fontWeight: medium,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildReviewItem(ProductReviewModel review) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: backgroundColor3.withAlpha(38)), // 0.15 opacity = 38 in alpha
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewerAvatar(review),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          review.user?.name ?? 'Pengguna',
                          style: primaryTextStyle.copyWith(
                            fontSize: 13,
                            fontWeight: medium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: subtitleTextStyle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                    ],
                  ),
                  if (review.comment.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      review.comment,
                      style: secondaryTextStyle.copyWith(
                        fontSize: 12,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewerAvatar(ProductReviewModel review) {
    final user = review.user;
    if (user == null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor3,
        ),
        child: Icon(
          Icons.person,
          color: backgroundColor5,
          size: 18,
        ),
      );
    }

    return ProfileImage(
      user: user,
      size: 32,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    }
  }
}
