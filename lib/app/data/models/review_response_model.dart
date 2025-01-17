import 'package:antarkanma_merchant/app/data/models/product_review_model.dart';

class ReviewResponseModel {
  final List<ProductReviewModel> reviews;
  final ReviewStats stats;

  ReviewResponseModel({
    required this.reviews,
    required this.stats,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final reviewsList = json['data'] ?? [];
      return ReviewResponseModel(
        reviews: (reviewsList as List)
            .map((review) => ProductReviewModel.fromJson(review))
            .toList(),
        stats: ReviewStats.fromJson(json['stats'] ?? _defaultStats()),
      );
    } catch (e) {
      print('Error parsing ReviewResponseModel: $e');
      return ReviewResponseModel(
        reviews: [],
        stats: ReviewStats.fromJson(_defaultStats()),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': reviews.map((review) => review.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }

  static Map<String, dynamic> _defaultStats() {
    return {
      'average_rating': 0.0,
      'total_reviews': 0,
      'rating_distribution': {
        '1': 0,
        '2': 0,
        '3': 0,
        '4': 0,
        '5': 0,
      },
    };
  }
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingDistribution;

  ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      averageRating: (json['average_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      ratingDistribution: Map<String, int>.from(json['rating_distribution']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': ratingDistribution,
    };
  }
}
