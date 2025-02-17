import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_review_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_gallery_model.dart';
import 'package:antarkanma_merchant/app/data/models/variant_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_category_model.dart';
import 'package:intl/intl.dart';

class ProductModel {
  final int? id;
  final String name;
  final String description;
  final List<ProductGalleryModel> galleries;
  final List<VariantModel> variants;
  final double price;
  final String? status;
  final List<ProductReviewModel>? reviews;
  final MerchantModel? merchant;
  final ProductCategory? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? averageRatingRaw;
  final int? totalReviewsRaw;
  final Map<String, dynamic>? ratingInfo;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    this.galleries = const [],
    required this.price,
    this.variants = const [],
    this.reviews = const [],
    this.status,
    this.merchant,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.averageRatingRaw,
    this.totalReviewsRaw,
    this.ratingInfo,
  });

  List<String> get imageUrls =>
      galleries.map((gallery) => gallery.url).toList();

  String get firstImageUrl {
    if (galleries.isEmpty || !isValidImageUrl(galleries.first.url)) {
      return 'assets/image_shoes.png';
    }
    return galleries.first.url;
  }

  bool get hasImages =>
      galleries.isNotEmpty && galleries.any((g) => isValidImageUrl(g.url));

  bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  List<String> get validImageUrls => galleries
      .map((gallery) => gallery.url)
      .where((url) => isValidImageUrl(url))
      .toList();

  String getImageUrl(int index,
      {String defaultImage = 'assets/image_shoes.png'}) {
    if (index < 0 ||
        index >= galleries.length ||
        !isValidImageUrl(galleries[index].url)) {
      return defaultImage;
    }
    return galleries[index].url;
  }

  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  String getFormattedPriceWithVariant(VariantModel variant) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(calculatePriceWithVariant(variant));
  }

  double calculatePriceWithVariant(VariantModel variant) {
    return price + variant.priceAdjustment;
  }

  double get averageRating {
    if (ratingInfo != null && ratingInfo!.containsKey('average_rating')) {
      final rating = ratingInfo!['average_rating'];
      if (rating is num) return rating.toDouble();
      if (rating is String) return double.tryParse(rating) ?? 0.0;
    }
    if (averageRatingRaw != null) {
      return double.tryParse(averageRatingRaw!) ?? 0.0;
    }
    return 0.0;
  }

  int get totalReviews {
    if (ratingInfo != null && ratingInfo!.containsKey('total_reviews')) {
      final total = ratingInfo!['total_reviews'];
      if (total is int) return total;
      if (total is String) return int.tryParse(total) ?? 0;
    }
    return totalReviewsRaw ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'status': status,
      'reviews': reviews?.map((review) => review.toJson()).toList(),
      'variants': variants.map((variant) => variant.toJson()).toList(),
      'merchant': merchant?.toJson(),
      'category': category?.toJson(),
      'galleries': galleries.map((gallery) => gallery.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'average_rating': averageRatingRaw,
      'total_reviews': totalReviewsRaw,
      'rating_info': ratingInfo,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse price with validation
      double parsePrice(dynamic value) {
        if (value == null) return 0.0;
        if (value is num) return value.toDouble();
        if (value is String) {
          try {
            return double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
          } catch (e) {
            return 0.0;
          }
        }
        return 0.0;
      }

      // Parse galleries with validation
      List<ProductGalleryModel> parseGalleries(dynamic galleriesData) {
        if (galleriesData == null) return [];
        if (galleriesData is! List) return [];

        return galleriesData
            .map((gallery) {
              if (gallery is! Map<String, dynamic>) return null;
              try {
                return ProductGalleryModel.fromJson(gallery);
              } catch (e) {
                return null;
              }
            })
            .where((gallery) => gallery != null)
            .cast<ProductGalleryModel>()
            .toList();
      }

      // Parse rating info with validation
      Map<String, dynamic>? parseRatingInfo(dynamic ratingData) {
        if (ratingData == null) return null;
        if (ratingData is! Map) return null;

        return {
          'average_rating': parsePrice(ratingData['average_rating']) ?? 0.0,
          'total_reviews': ratingData['total_reviews'] is num
              ? (ratingData['total_reviews'] as num).toInt()
              : int.tryParse(ratingData['total_reviews'].toString()) ?? 0,
        };
      }

      final product = ProductModel(
        id: json['id'] is int
            ? json['id']
            : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: parsePrice(json['price']),
        galleries: parseGalleries(json['galleries']),
        status: json['status']?.toString(),
        variants: (json['variants'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((variant) => VariantModel.fromJson(variant))
                .toList() ??
            [],
        reviews: (json['reviews'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((review) => ProductReviewModel.fromJson(review))
                .toList() ??
            [],
        merchant: json['merchant'] is Map<String, dynamic>
            ? MerchantModel.fromJson(json['merchant'] as Map<String, dynamic>)
            : null,
        category: json['category'] is Map<String, dynamic>
            ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
        averageRatingRaw: json['average_rating']?.toString(),
        totalReviewsRaw: json['total_reviews'] is int
            ? json['total_reviews']
            : int.tryParse(json['total_reviews'].toString()) ?? 0,
        ratingInfo: parseRatingInfo(json['rating_info']),
      );

      return product;
    } catch (e) {
      return ProductModel(
        name: '',
        description: '',
        price: 0.0,
      );
    }
  }

  bool get isActive => status?.toLowerCase() == 'active';

  List<String> get uniqueVariantNames {
    return variants.map((v) => v.name).toSet().toList();
  }

  Map<String, List<String>> get variantValuesByName {
    final map = <String, List<String>>{};
    for (var variant in variants) {
      if (!map.containsKey(variant.name)) {
        map[variant.name] = [];
      }
      map[variant.name]!.add(variant.value);
    }
    return map;
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, images: ${galleries.length}, rating: $averageRating)';
  }
}

class UninitializedProductModel extends ProductModel {
  UninitializedProductModel()
      : super(
          id: 0,
          name: '',
          description: '',
          galleries: const [],
          variants: const [],
          price: 0.0,
        );
}
