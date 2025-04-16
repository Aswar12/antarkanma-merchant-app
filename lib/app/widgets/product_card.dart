import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimenssions.width4,
          vertical: Dimenssions.height4,
        ),
        decoration: BoxDecoration(
          color: backgroundColor2,
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimenssions.radius20),
          child: Stack(
            children: [
              // Product Image with Gradient
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Product Image
                    Hero(
                      tag: 'product-${product.id}',
                      child: product.hasImages
                          ? CachedNetworkImage(
                              imageUrl: product.firstImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: backgroundColor3,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(logoColor),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: backgroundColor3,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: secondaryTextColor.withOpacity(0.5),
                                    size: Dimenssions.iconSize24 * 2,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: backgroundColor3,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: secondaryTextColor.withOpacity(0.5),
                                  size: Dimenssions.iconSize24 * 2,
                                ),
                              ),
                            ),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.4, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Overlay
              Padding(
                padding: EdgeInsets.all(Dimenssions.width12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimenssions.width8,
                            vertical: Dimenssions.height4,
                          ),
                          decoration: BoxDecoration(
                            color: product.isActive
                                ? Colors.green.withOpacity(0.9)
                                : alertColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(Dimenssions.radius20),
                          ),
                          child: Text(
                            product.isActive ? 'Aktif' : 'Nonaktif',
                            style: primaryTextStyle.copyWith(
                              fontSize: Dimenssions.font12,
                              color: Colors.white,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                        if (product.category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimenssions.width8,
                              vertical: Dimenssions.height4,
                            ),
                            decoration: BoxDecoration(
                              color: logoColorSecondary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(Dimenssions.radius20),
                            ),
                            child: Text(
                              product.category!.name,
                              style: primaryTextStyle.copyWith(
                                fontSize: Dimenssions.font12,
                                color: Colors.white,
                                fontWeight: medium,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Product Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimenssions.font16,
                            fontWeight: semiBold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Dimenssions.height4),

                        // Product ID
                        Text(
                          'ID: ${product.id}',
                          style: secondaryTextStyle.copyWith(
                            fontSize: Dimenssions.font12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Dimenssions.height8),

                        // Bottom Row: Price and Variants
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimenssions.width8,
                                vertical: Dimenssions.height4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(Dimenssions.radius12),
                              ),
                              child: Text(
                                product.formattedPrice,
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font14,
                                  color: Colors.white,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimenssions.width8,
                                vertical: Dimenssions.height4,
                              ),
                              decoration: BoxDecoration(
                                color: logoColorSecondary.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(Dimenssions.radius12),
                              ),
                              child: Text(
                                '${product.variants.length} Varian',
                                style: secondaryTextStyle.copyWith(
                                  fontSize: Dimenssions.font12,
                                  color: Colors.white,
                                  fontWeight: medium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
