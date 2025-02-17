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
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timeout');
      case DioExceptionType.badResponse:
        return Exception('Bad response: ${e.response?.statusCode}');
      default:
        return Exception('Something went wrong');
    }
  }
}
