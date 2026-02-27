import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/providers/review_provider.dart';
import 'package:antarkanma_merchant/app/constants/app_colors.dart';

class MerchantReviewsPage extends StatefulWidget {
  final int merchantId;
  final String merchantName;

  const MerchantReviewsPage({
    super.key,
    required this.merchantId,
    required this.merchantName,
  });

  @override
  State<MerchantReviewsPage> createState() => _MerchantReviewsPageState();
}

class _MerchantReviewsPageState extends State<MerchantReviewsPage>
    with SingleTickerProviderStateMixin {
  final ReviewProvider _reviewProvider = ReviewProvider();
  List<dynamic> _reviews = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int? _selectedRating;
  late TabController _tabController;

  // Tab types: all, merchant, product
  final List<String> _tabTypes = ['all', 'merchant', 'product'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _selectedRating = null;
        _loadReviews();
      }
    });
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _currentType {
    final idx = _tabController.index;
    if (idx == 0) return null; // all
    return _tabTypes[idx];
  }

  Future<void> _loadReviews({int? rating}) async {
    setState(() => _isLoading = true);
    try {
      final response = await _reviewProvider.getMerchantReviews(
        widget.merchantId,
        rating: rating,
        limit: 50,
        type: _currentType,
      );

      if (response.statusCode == 200 &&
          response.data['meta']?['status'] == 'success') {
        setState(() {
          final data = response.data['data'];
          // Handle both paginated and list responses
          if (data['reviews'] is List) {
            _reviews = data['reviews'];
          } else if (data['reviews']?['data'] is List) {
            _reviews = data['reviews']['data'];
          } else {
            _reviews = [];
          }
          _stats = data['stats'] ?? {};
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgRating = (_stats['average_rating'] ?? 0).toDouble();
    final totalReviews = _stats['total_reviews'] ?? 0;
    final merchantReviewCount = _stats['merchant_review_count'] ?? 0;
    final productReviewCount = _stats['product_review_count'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review ${widget.merchantName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                // Big Rating Number
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < avgRating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$totalReviews ulasan',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🏪 $merchantReviewCount  •  🍽️ $productReviewCount',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Rating Distribution Bars
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final dist = _stats['rating_distribution'] ?? {};
                      final count = dist[star.toString()] ?? 0;
                      final pct = totalReviews > 0 ? count / totalReviews : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 12,
                              child: Text('$star',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct.toDouble(),
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.amber),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 20,
                              child: Text('$count',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: '🏪 Merchant'),
                Tab(text: '🍽️ Produk'),
              ],
            ),
          ),

          // Rating Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('Semua', null),
                  for (var i = 5; i >= 1; i--) _filterChip('$i ⭐', i),
                ],
              ),
            ),
          ),

          // Reviews List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadReviews(rating: _selectedRating),
                    child: _reviews.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.rate_review_outlined,
                                        size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text('Belum ada review',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) =>
                                _buildReviewCard(_reviews[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int? rating) {
    final isSelected = _selectedRating == rating;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedRating = rating);
          _loadReviews(rating: rating);
        },
        selectedColor: AppColors.primary,
        labelStyle:
            TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final userName = review['user']?['name'] ?? 'Anonim';
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final createdAt = review['created_at'] ?? '';
    final reviewType = review['review_type'] ?? 'merchant';
    final productName = review['product_name'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User avatar
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                radius: 18,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Review type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: reviewType == 'product'
                                ? Colors.orange.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reviewType == 'product' ? '🍽️ Produk' : '🏪 Toko',
                            style: TextStyle(
                              fontSize: 10,
                              color: reviewType == 'product'
                                  ? Colors.orange.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(createdAt),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          // Show product name if product review
          if (reviewType == 'product' && productName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.fastfood,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  productName,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
          if (comment.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment.toString(), style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
