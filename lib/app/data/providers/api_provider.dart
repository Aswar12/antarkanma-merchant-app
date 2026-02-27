import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../config.dart';

class ApiProvider {
  late final Dio _dio;

  ApiProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.baseUrl,
        connectTimeout: const Duration(milliseconds: Config.connectTimeout),
        receiveTimeout: const Duration(milliseconds: Config.receiveTimeout),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    debugPrint(
        '🔴 API Error: ${e.type} | Path: ${e.requestOptions.path} | Message: ${e.message}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
            'Koneksi timeout. Pastikan server aktif atau cek "adb reverse".');
      case DioExceptionType.receiveTimeout:
        return Exception('Server lambat merespon (Receive timeout).');
      case DioExceptionType.sendTimeout:
        return Exception('Gagal mengirim data (Send timeout).');
      case DioExceptionType.connectionError:
        return Exception(
            'Tidak dapat terhubung ke server. Pastikan backend aktif.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? 'Kesalahan Server ($statusCode)';
        return Exception(message);
      case DioExceptionType.cancel:
        return Exception('Permintaan dibatalkan.');
      default:
        return Exception('Terjadi kesalahan koneksi. Silakan coba lagi.');
    }
  }
}
