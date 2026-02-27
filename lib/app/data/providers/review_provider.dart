import 'package:dio/dio.dart' as dio;
import 'package:antarkanma_merchant/config.dart';
import 'package:get_storage/get_storage.dart';

class ReviewProvider {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = Config.baseUrl;

  ReviewProvider() {
    _dio.options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => true,
    );

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
      ),
    );
  }

  String? _getAuthToken() {
    try {
      final storage = GetStorage();
      return storage.read('token');
    } catch (e) {
      return null;
    }
  }

  /// Get reviews for a specific merchant (unified: merchant + product reviews)
  /// [type] can be 'merchant', 'product', or null for all
  Future<dio.Response> getMerchantReviews(int merchantId,
      {int? rating, int limit = 10, String? type}) async {
    try {
      final response = await _dio.get(
        '/merchants/$merchantId/reviews',
        queryParameters: {
          'limit': limit,
          if (rating != null) 'rating': rating,
          if (type != null) 'type': type,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to load merchant reviews: $e');
    }
  }
}
