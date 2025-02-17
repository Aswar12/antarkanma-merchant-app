import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_review_model.dart';

class ProductDetailController extends GetxController {
  final RxList<ProductReviewModel> reviews = <ProductReviewModel>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt reviewCount = 0.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isExpanded = false.obs;
  final RxInt selectedRatingFilter = 0.obs;

  List<ProductReviewModel> get visibleReviews {
    var filteredReviews = reviews.toList();
    if (selectedRatingFilter.value > 0) {
      filteredReviews = filteredReviews.where((review) => 
        review.rating == selectedRatingFilter.value).toList();
    }
    
    if (!isExpanded.value && filteredReviews.length > 3) {
      return filteredReviews.sublist(0, 3);
    }
    return filteredReviews;
  }

  bool get hasMoreReviews => reviews.length > 3;

  void setRatingFilter(int rating) {
    selectedRatingFilter.value = rating;
  }

  void toggleReviews() {
    isExpanded.value = !isExpanded.value;
  }

  Future<void> fetchReviews() async {
    try {
      isLoadingReviews.value = true;
      // TODO: Implement API call to fetch reviews
      // For now using empty list
      reviews.clear();
      _updateReviewStats();
    } finally {
      isLoadingReviews.value = false;
    }
  }

  void _updateReviewStats() {
    reviewCount.value = reviews.length;
    if (reviews.isEmpty) {
      averageRating.value = 0;
      return;
    }
    
    double total = reviews.fold(0.0, (sum, review) => sum + review.rating);
    averageRating.value = total / reviews.length;
  }
}
