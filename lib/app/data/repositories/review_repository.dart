import 'package:antarkanma_merchant/app/data/models/product_review_model.dart';
import 'package:antarkanma_merchant/app/data/providers/product_provider.dart';

class ReviewRepository {
  final ProductProvider provider;

  ReviewRepository({required this.provider});
  Future<List<ProductReviewModel>> getProductReviews(
    int productId, {
    int? rating,
    String? token,
  }) async {
    try {
      print(
          'Repository: Fetching reviews for product $productId with rating filter: $rating');
      final response = await provider.getProductReviews(
        productId,
        token: token,
        rating: rating,
      );

      print('Repository: Raw Response: ${response.data}');

      if (response.data == null) {
        print('Repository: Response data is null');
        return [];
      }

      // Handle both direct review objects and nested structures
      List<dynamic> reviewsJson = [];

      if (response.data is Map<String, dynamic>) {
        if (response.data['data']?['reviews']?['data'] != null) {
          // Nested structure
          reviewsJson =
              response.data['data']['reviews']['data'] as List<dynamic>;
          print(
              'Repository: Found ${reviewsJson.length} reviews in nested structure');
        } else if (response.data['data'] is List) {
          // Direct list of reviews
          reviewsJson = response.data['data'] as List<dynamic>;
          print(
              'Repository: Found ${reviewsJson.length} reviews in direct list');
        } else if (response.data['data'] != null) {
          // Single review object in data field
          reviewsJson = [response.data['data']];
          print('Repository: Found single review object in data field');
        } else {
          // Direct single review object
          reviewsJson = [response.data];
          print('Repository: Found direct single review object');
        }
      }

      // Parse reviews
      final List<ProductReviewModel> reviews = [];
      for (var json in reviewsJson) {
        if (json == null) continue;
        try {
          final review = ProductReviewModel.fromJson(json);
          reviews.add(review);
        } catch (e) {
          print('Repository: Error parsing review: $e');
          print('Repository: Problematic JSON: $json');
        }
      }

      print('Repository: Successfully parsed ${reviews.length} reviews');
      return reviews;
    } catch (e) {
      print('Error in getProductReviews: $e');
      return [];
    }
  }

  Future<void> submitReview(
      Map<String, dynamic> reviewData, String token) async {
    try {
      await provider.submitProductReview(reviewData, token);
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<void> updateReview(
      int reviewId, Map<String, dynamic> reviewData, String token) async {
    try {
      await provider.updateProductReview(reviewId, reviewData, token);
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> deleteReview(int reviewId, String token) async {
    try {
      await provider.deleteProductReview(reviewId, token);
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }
}
