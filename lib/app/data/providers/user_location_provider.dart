import 'package:dio/dio.dart';
import 'package:antarkanma_merchant/config.dart';

class UserLocationProvider {
  final Dio _dio = Dio();
  final String baseUrl = Config.baseUrl;

  UserLocationProvider() {
    _setupBaseOptions();
    _setupInterceptors();
  }

  // Setup dasar untuk Dio
  void _setupBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status! < 500,
    );
  }

  // Setup interceptor untuk menangani request dan response
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          });
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _handleError(error);
          return handler.next(error);
        },
      ),
    );
  }

  // Menghandle error dari response
  void _handleError(DioException error) {
    String message;
    switch (error.response?.statusCode) {
      case 401:
        message = 'Unauthorized access. Please log in again.';
        break;
      case 422:
        final errors = error.response?.data['errors'];
        message = errors.toString();
        break;
      default:
        message = error.response?.data['message'] ?? 'An error occurred';
    }
    throw Exception(message);
  }

  // Mendapatkan semua lokasi pengguna
  Future<Response> getUserLocations(String token) async {
    try {
      return await _dio.get(
        '/user-locations',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to get user locations: $e');
    }
  }

  // Mendapatkan lokasi pengguna berdasarkan ID
  Future<Response> getUserLocation(String token, int locationId) async {
    try {
      return await _dio.get(
        '/user-locations/$locationId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to get user location: $e');
    }
  }

  // Menambahkan lokasi pengguna baru
  Future<Response> addUserLocation(
      String token, Map<String, dynamic> data) async {
    try {
      return await _dio.post(
        '/user-locations',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to add user location: $e');
    }
  }

  // Memperbarui lokasi pengguna
  Future<Response> updateUserLocation(
      String token, int locationId, Map<String, dynamic> data) async {
    try {
      return await _dio.put(
        '/user-locations/$locationId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update user location: $e');
    }
  }

  // Menghapus lokasi pengguna
  Future<Response> deleteUserLocation(String token, int locationId) async {
    try {
      return await _dio.delete(
        '/user-locations/$locationId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to delete user location: $e');
    }
  }

  // Mengatur lokasi default
  Future<Response> setDefaultLocation(String token, int locationId) async {
    try {
      return await _dio.post(
        '/user-locations/$locationId/set-default',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to set default location: $e');
    }
  }

  // Lanjutan metode sebelumnya
  Future<Response> getNearbyLocations(
      String token, double latitude, double longitude,
      {double radius = 5000}) async {
    try {
      return await _dio.get(
        '/user-locations/nearby',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );
    } catch (e) {
      throw Exception('Failed to get nearby locations: $e');
    }
  }

// Pencarian lokasi berdasarkan kriteria
  Future<Response> searchLocations(
    String token, {
    String? keyword,
    String? addressType,
    bool? isDefault,
    String? city,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (keyword != null) queryParams['keyword'] = keyword;
      if (addressType != null) queryParams['address_type'] = addressType;
      if (isDefault != null) queryParams['is_default'] = isDefault;
      if (city != null) queryParams['city'] = city;

      return await _dio.get(
        '/user-locations/search',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: queryParams,
      );
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }

// Validasi alamat
  Future<Response> validateAddress(
      String token, Map<String, dynamic> addressData) async {
    try {
      return await _dio.post(
        '/user-locations/validate',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: addressData,
      );
    } catch (e) {
      throw Exception('Failed to validate address: $e');
    }
  }

// Mendapatkan statistik lokasi pengguna
  Future<Response> getLocationStatistics(String token) async {
    try {
      return await _dio.get(
        '/user/locations/statistics',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw Exception('Failed to get location statistics: $e');
    }
  }

// Operasi bulk delete lokasi
  Future<Response> bulkDeleteLocations(
      String token, List<int> locationIds) async {
    try {
      return await _dio.delete(
        '/user/locations/bulk-delete',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'location_ids': locationIds},
      );
    } catch (e) {
      throw Exception('Failed to bulk delete locations: $e');
    }
  }

// Mendapatkan lokasi berdasarkan tipe alamat
  Future<Response> getLocationsByAddressType(
      String token, String addressType) async {
    try {
      return await _dio.get(
        '/user-locations/by-type',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: {'address_type': addressType},
      );
    } catch (e) {
      throw Exception('Failed to get locations by address type: $e');
    }
  }

// Metode untuk menambahkan koordinat ke lokasi
  Future<Response> addLocationCoordinates(
      String token, int locationId, double latitude, double longitude) async {
    try {
      return await _dio.post(
        '/user-locations/$locationId/coordinates',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } catch (e) {
      throw Exception('Failed to add location coordinates: $e');
    }
  }

// Metode untuk mengekspor lokasi pengguna
  Future<Response> exportUserLocations(String token) async {
    try {
      return await _dio.get(
        '/user-locations/export',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf' // Misalnya untuk export PDF
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to export user locations: $e');
    }
  }

// Metode untuk mendapatkan lokasi terakhir yang dikunjungi
  Future<Response> getRecentLocations(String token, {int limit = 5}) async {
    try {
      return await _dio.get(
        '/user-locations/recent',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: {'limit': limit},
      );
    } catch (e) {
      throw Exception('Failed to get recent locations: $e');
    }
  }
}
