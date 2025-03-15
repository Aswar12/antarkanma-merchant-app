import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';

class ProfileProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  ProfileProvider() {
    _setupBaseOptions();
  }

  void _setupBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    );
  }

  Future<Response> updateMerchantProfile(
    String token,
    int merchantId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        '/merchant/$merchantId/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: data,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update merchant profile: $e');
    }
  }

  Future<Response> updateMerchantLocation(
    String token,
    int merchantId,
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.put(
        '/merchant/$merchantId/location',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update merchant location: $e');
    }
  }

  Future<Response> updateMerchantLogo(
    String token,
    int merchantId,
    String imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'logo': await MultipartFile.fromFile(
          imagePath,
          filename: 'merchant_logo.jpg',
        ),
      });

      final response = await _dio.post(
        '/merchant/$merchantId/logo',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        data: formData,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update merchant logo: $e');
    }
  }
}
