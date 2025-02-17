// ignore_for_file: override_on_non_overriding_member

import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/app/data/providers/user_location_provider.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';

class UserLocationService extends GetxService {
  final StorageService _storageService = StorageService.instance;
  final UserLocationProvider _userLocationProvider = UserLocationProvider();
  final AuthService _authService = Get.find<AuthService>();

  // Singleton pattern
  static final UserLocationService _instance = UserLocationService._internal();
  factory UserLocationService() => _instance;
  UserLocationService._internal();

  // Observable state
  final RxList<UserLocationModel> userLocations = <UserLocationModel>[].obs;
  final Rx<UserLocationModel?> defaultLocation = Rx<UserLocationModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  static const String _userLocationsKey = 'user_locations';
  static const String _defaultLocationKey = 'default_location';
  static const String _lastSyncKey = 'last_locations_sync';
  static const Duration _cacheDuration =
      Duration(hours: 24); // Cache for 24 hours

  @override
  void onInit() {
    super.onInit();
    loadUserLocationsFromLocal();
    // Only load from backend if cache is expired
    if (_shouldSyncWithBackend()) {
      loadUserLocations();
    }
  }

  bool _shouldSyncWithBackend() {
    final lastSync = _storageService.getInt(_lastSyncKey);
    if (lastSync == null) return true;

    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSync);
    final now = DateTime.now();
    return now.difference(lastSyncTime) > _cacheDuration;
  }

  void loadUserLocationsFromLocal() {
    try {
      final localLocations = _storageService.getList(_userLocationsKey);
      final localDefaultLocation = _storageService.getMap(_defaultLocationKey);

      userLocations.value = localLocations != null
          ? localLocations
              .map((json) => UserLocationModel.fromJson(json))
              .toList()
          : [];

      defaultLocation.value = localDefaultLocation != null
          ? UserLocationModel.fromJson(localDefaultLocation)
          : null;
    } catch (e) {
      errorMessage.value = 'Gagal memuat lokasi lokal: ${e.toString()}';
    }
  }

  Future<void> loadUserLocations({bool forceRefresh = false}) async {
    try {
      isLoading.value = true;
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      // If not forcing refresh and we have local data, skip backend call
      if (!forceRefresh &&
          userLocations.isNotEmpty &&
          !_shouldSyncWithBackend()) {
        return;
      }

      final response = await _userLocationProvider.getUserLocations(token);
      if (response.statusCode == 200) {
        final List<dynamic> locationsData = response.data['data'];
        userLocations.value = locationsData
            .map((data) => UserLocationModel.fromJson(data))
            .toList();

        updateDefaultLocation();
        saveLocationsToLocal();

        // Update last sync time
        await _storageService.saveInt(
            _lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      } else {
        throw Exception('Gagal memuat lokasi');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal memuat lokasi: ${e.toString()}',
          isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Metode pencarian lokasi
  Future<List<UserLocationModel>> searchLocations({
    String? keyword,
    String? addressType,
    bool? isDefault,
    String? city,
  }) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response = await _userLocationProvider.searchLocations(
        token,
        keyword: keyword,
        addressType: addressType,
        isDefault: isDefault,
        city: city,
      );

      if (response.statusCode == 200) {
        final List<dynamic> locationsData = response.data['data'];
        return locationsData
            .map((data) => UserLocationModel.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal mencari lokasi: ${e.toString()}',
          isError: true);
      return [];
    }
  }

  // Metode lokasi terdekat
  Future<List<UserLocationModel>> getNearbyLocations(
      {required double latitude,
      required double longitude,
      double radius = 5000}) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response = await _userLocationProvider
          .getNearbyLocations(token, latitude, longitude, radius: radius);

      if (response.statusCode == 200) {
        final List<dynamic> locationsData = response.data['data'];
        return locationsData
            .map((data) => UserLocationModel.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal mendapatkan lokasi terdekat: ${e.toString()}',
          isError: true);
      return [];
    }
  }

  // Metode validasi alamat
  Future<bool> validateAddress(Map<String, dynamic> addressData) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response =
          await _userLocationProvider.validateAddress(token, addressData);

      return response.statusCode == 200;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal memvalidasi alamat: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  // Metode statistik lokasi
  Future<Map<String, dynamic>?> getLocationStatistics() async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response = await _userLocationProvider.getLocationStatistics(token);
      return response.statusCode == 200 ? response.data['data'] : null;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal mendapatkan statistik: ${e.toString()}',
          isError: true);
      return null;
    }
  }

  // Metode bulk delete
  Future<bool> bulkDeleteLocations(List<int> locationIds) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response =
          await _userLocationProvider.bulkDeleteLocations(token, locationIds);

      if (response.statusCode == 200) {
        // Hapus lokasi dari daftar lokal
        userLocations.removeWhere((loc) => locationIds.contains(loc.id));
        saveLocationsToLocal();
        return true;
      }
      return false;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal menghapus lokasi: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  // Metode lainnya tetap sama seperti sebelumnya...

  // Tambahan metode untuk reset dan pembersihan
  void resetService() {
    userLocations.clear();
    defaultLocation.value = null;
    isLoading.value = false;
    errorMessage.value = '';
    clearLocalData();
  }

  // Metode untuk mendapatkan lokasi terakhir
  Future<List<UserLocationModel>> getRecentLocations({int limit = 5}) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response =
          await _userLocationProvider.getRecentLocations(token, limit: limit);

      if (response.statusCode == 200) {
        final List<dynamic> locationsData = response.data['data'];
        return locationsData
            .map((data) => UserLocationModel.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal mendapatkan lokasi terakhir: ${e.toString()}',
          isError: true);
      return [];
    }
  }

  // Metode untuk mendapatkan lokasi berdasarkan tipe alamat
  Future<List<UserLocationModel>> getLocationsByAddressType(
      String addressType) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response = await _userLocationProvider.getLocationsByAddressType(
          token, addressType);

      if (response.statusCode == 200) {
        final List<dynamic> locationsData = response.data['data'];
        return locationsData
            .map((data) => UserLocationModel.fromJson(data))
            .toList();
      }
      return [];
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal mendapatkan lokasi berdasarkan tipe: ${e.toString()}',
          isError: true);
      return [];
    }
  }

  // Metode untuk menambahkan koordinat ke lokasi
  Future<bool> addLocationCoordinates(
      {required int locationId,
      required double latitude,
      required double longitude}) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response = await _userLocationProvider.addLocationCoordinates(
          token, locationId, latitude, longitude);

      if (response.statusCode == 200) {
        // Update lokasi di daftar lokal
        final index = userLocations.indexWhere((loc) => loc.id == locationId);
        if (index != -1) {
          final updatedLocation = userLocations[index]
              .copyWith(latitude: latitude, longitude: longitude);
          userLocations[index] = updatedLocation;
          saveLocationsToLocal();
        }
        return true;
      }
      return false;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal menambahkan koordinat: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  // Metode untuk mengekspor lokasi pengguna
  Future<bool> exportUserLocations() async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        throw Exception('Token tidak valid');
      }

      final response = await _userLocationProvider.exportUserLocations(token);

      if (response.statusCode == 200) {
        // Proses export, misalnya menyimpan file atau menampilkan dialog
        showCustomSnackbar(
            title: 'Sukses', message: 'Lokasi berhasil diekspor');
        return true;
      }
      return false;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal mengekspor lokasi: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  // Metode untuk memperbarui metode existing
  @override
  Future<bool> addUserLocation(UserLocationModel location) async {
    try {
      final token = _authService.getToken();
      if (token == null) throw Exception('Token tidak valid');

      final response =
          await _userLocationProvider.addUserLocation(token, location.toJson());

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newLocation = UserLocationModel.fromJson(response.data['data']);

        // Tambahkan lokasi baru ke daftar
        userLocations.add(newLocation);

        // Perbarui lokasi default jika perlu
        if (newLocation.isDefault) {
          for (var loc in userLocations) {
            if (loc.id != newLocation.id) loc.isDefault = false;
          }
          updateDefaultLocation();
        }

        saveLocationsToLocal();

        showCustomSnackbar(
            title: 'Sukses', message: 'Lokasi berhasil ditambahkan');
        return true;
      }

      throw Exception(response.data['message'] ?? 'Gagal menambahkan lokasi');
    } catch (e) {
      showCustomSnackbar(title: 'Error', message: e.toString(), isError: true);
      return false;
    }
  }

  // Metode untuk mendapatkan lokasi berdasarkan kriteria kompleks
  // Tambahkan metode-metode berikut ke dalam kelas UserLocationService

  Future<bool> updateUserLocation(UserLocationModel location) async {
    try {
      final token = _authService.getToken();
      if (token == null) throw Exception('Token tidak valid');

      final response = await _userLocationProvider.updateUserLocation(
          token, location.id!, location.toJson());

      if (response.statusCode == 200) {
        final updatedLocation =
            UserLocationModel.fromJson(response.data['data']);

        // Temukan dan perbarui lokasi di daftar lokal
        final index =
            userLocations.indexWhere((loc) => loc.id == updatedLocation.id);
        if (index != -1) {
          userLocations[index] = updatedLocation;

          // Perbarui lokasi default jika perlu
          if (updatedLocation.isDefault) {
            for (var loc in userLocations) {
              if (loc.id != updatedLocation.id) loc.isDefault = false;
            }
            updateDefaultLocation();
          }

          saveLocationsToLocal();
        }

        showCustomSnackbar(
            title: 'Sukses', message: 'Lokasi berhasil diperbarui');
        return true;
      }

      throw Exception(response.data['message'] ?? 'Gagal memperbarui lokasi');
    } catch (e) {
      showCustomSnackbar(title: 'Error', message: e.toString(), isError: true);
      return false;
    }
  }

  Future<bool> deleteUserLocation(int locationId) async {
    try {
      final token = _authService.getToken();
      if (token == null) throw Exception('Token tidak valid');

      final response =
          await _userLocationProvider.deleteUserLocation(token, locationId);

      if (response.statusCode == 200) {
        // Hapus lokasi dari daftar lokal
        userLocations.removeWhere((loc) => loc.id == locationId);

        // Perbarui lokasi default
        updateDefaultLocation();
        saveLocationsToLocal();

        showCustomSnackbar(title: 'Sukses', message: 'Lokasi berhasil dihapus');
        return true;
      }

      throw Exception(response.data['message'] ?? 'Gagal menghapus lokasi');
    } catch (e) {
      showCustomSnackbar(title: 'Error', message: e.toString(), isError: true);
      return false;
    }
  }

  Future<bool> setDefaultLocation(int locationId) async {
    try {
      final token = _authService.getToken();
      if (token == null) throw Exception('Token tidak valid');

      final response =
          await _userLocationProvider.setDefaultLocation(token, locationId);

      if (response.statusCode == 200) {
        // Perbarui status default untuk semua lokasi
        for (var loc in userLocations) {
          loc.isDefault = loc.id == locationId;
        }

        // Update lokasi default
        updateDefaultLocation();
        saveLocationsToLocal();

        showCustomSnackbar(
            title: 'Sukses', message: 'Lokasi default berhasil diubah');
        return true;
      }

      throw Exception(
          response.data['message'] ?? 'Gagal mengubah lokasi default');
    } catch (e) {
      showCustomSnackbar(title: 'Error', message: e.toString(), isError: true);
      return false;
    }
  }

// Metode untuk mendapatkan lokasi berdasarkan ID
  UserLocationModel? getLocationById(int id) {
    try {
      return userLocations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }

// Metode untuk menyinkronkan lokasi
  Future<void> syncLocations({bool forceRefresh = false}) async {
    try {
      await loadUserLocations(forceRefresh: forceRefresh);
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal menyinkronkan lokasi: ${e.toString()}',
          isError: true);
    }
  }

// Metode untuk mengecek apakah ada data lokal
  bool hasLocalData() {
    return userLocations.isNotEmpty;
  }

// Metode untuk membersihkan data lokal
  void clearLocalData() {
    userLocations.clear();
    defaultLocation.value = null;
    _storageService.remove(_userLocationsKey);
    _storageService.remove(_defaultLocationKey);
  }

  void updateDefaultLocation() {
    UserLocationModel? defaultLoc;

    // Coba temukan lokasi default
    defaultLoc = userLocations.firstWhereOrNull((loc) => loc.isDefault);

    // Jika tidak ada lokasi default, pilih lokasi pertama jika tersedia
    if (defaultLoc == null && userLocations.isNotEmpty) {
      defaultLoc = userLocations.first;
      // Secara otomatis set lokasi pertama sebagai default
      defaultLoc.isDefault = true;
    }

    // Update lokasi default
    if (defaultLoc != null) {
      defaultLocation.value = defaultLoc;
      _storageService.saveMap(_defaultLocationKey, defaultLoc.toJson());
    } else {
      // Jika tidak ada lokasi sama sekali, set default location ke null
      defaultLocation.value = null;
      _storageService.remove(_defaultLocationKey);
    }
  }

// Metode untuk menyimpan lokasi ke penyimpanan lokal
  void saveLocationsToLocal() {
    _storageService.saveList(
        _userLocationsKey, userLocations.map((loc) => loc.toJson()).toList());
  }
}
