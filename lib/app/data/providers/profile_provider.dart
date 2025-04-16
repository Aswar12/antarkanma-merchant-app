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
        '/merchant/$merchantId',
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
        '/merchant/$merchantId',
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
      // Create FormData with the logo file
      final formData = FormData();
      formData.files.add(
        MapEntry(
          'logo',
          await MultipartFile.fromFile(
            imagePath,
            filename: 'logo.png',
          ),
        ),
      );

      // Make the request with proper headers and form data
      final response = await _dio.post(
        '/merchant/$merchantId/logo',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            // Log the status code for debugging
            print('Response status code: $status');
            return status! < 500;
          },
        ),
        data: formData,
      );

      // Log response for debugging
      print('Response data: ${response.data}');
      print('Response headers: ${response.headers}');

      return response;
    } catch (e) {
      print('Error details: $e');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response?.data}');
      }
      throw Exception('Failed to update merchant logo: $e');
    }
  }
}
