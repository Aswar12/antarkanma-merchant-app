// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/user_location_model.dart';
import 'package:antarkanma_merchant/app/services/user_location_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';

class UserLocationController extends GetxController {
  final UserLocationService _locationService;

  UserLocationController({required UserLocationService locationService})
      : _locationService = locationService;

  // Observable properties
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Observable list untuk memudahkan reaktivitas
  RxList<UserLocationModel> userLocations = <UserLocationModel>[].obs;
  Rx<UserLocationModel?> selectedLocation = Rx<UserLocationModel?>(null);

  // Getter
  List<UserLocationModel> get addresses => userLocations;
  UserLocationModel? get defaultAddress =>
      userLocations.firstWhereOrNull((loc) => loc.isDefault);

  @override
  void onInit() {
    super.onInit();
    // Load addresses dan set default location
    loadAddresses().then((_) {
      print('Addresses Loaded: ${userLocations.length}');
      print('Default Address: ${defaultAddress?.fullAddress}');
      _setInitialDefaultLocation();
    });
  }

  void _setInitialDefaultLocation() {
    if (userLocations.isNotEmpty) {
      // Pilih alamat default, jika tidak ada pilih alamat pertama
      selectedLocation.value = defaultAddress ?? userLocations.first;
    }
  }

  Future<void> loadAddresses() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _locationService.loadUserLocations();
      userLocations.value = _locationService.userLocations;
      update(); // Memanggil update untuk memperbarui UI
      print('User  locations loaded: ${userLocations.length}');
    } catch (e) {
      errorMessage.value = 'Gagal memuat alamat: $e';
      showCustomSnackbar(
          title: 'Error', message: errorMessage.value, isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAddress(UserLocationModel address) async {
    isLoading.value = true;
    try {
      final result = await _locationService.addUserLocation(address);
      if (result) {
        // Refresh daftar alamat setelah berhasil menambahkan
        await loadAddresses();

        showCustomSnackbar(
            title: 'Sukses', message: 'Alamat berhasil ditambahkan');

        // Jika ini alamat pertama, jadikan sebagai default
        if (userLocations.length == 1) {
          await setDefaultAddress(address.id!);
        }
      }
      return result;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      showCustomSnackbar(
          title: 'Error', message: errorMessage.value, isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAddress(UserLocationModel address) async {
    isLoading.value = true;
    try {
      final result = await _locationService.updateUserLocation(address);
      if (result) {
        // Refresh daftar alamat setelah berhasil update
        await loadAddresses();

        showCustomSnackbar(
            title: 'Sukses', message: 'Alamat berhasil diperbarui');
      }
      return result;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      showCustomSnackbar(
          title: 'Error', message: errorMessage.value, isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAddress(int addressId) async {
    isLoading.value = true;
    try {
      final result = await _locationService.deleteUserLocation(addressId);
      if (result) {
        // Refresh daftar alamat setelah berhasil hapus
        await loadAddresses();

        // Reset selected location jika perlu
        _setInitialDefaultLocation();

        showCustomSnackbar(title: 'Sukses', message: 'Alamat berhasil dihapus');
      }
      return result;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      showCustomSnackbar(
          title: 'Error', message: errorMessage.value, isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> setDefaultAddress(int addressId) async {
    isLoading.value = true;
    try {
      final result = await _locationService.setDefaultLocation(addressId);
      if (result) {
        // Refresh daftar alamat setelah berhasil set default
        await loadAddresses();

        // Update selected location
        selectedLocation.value = defaultAddress;

        showCustomSnackbar(
            title: 'Sukses', message: 'Alamat utama berhasil diatur');
      }
      return result;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      showCustomSnackbar(
          title: 'Error', message: errorMessage.value, isError: true);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Method untuk mencari dan filter lokasi
  List<UserLocationModel> searchLocations(String keyword) {
    return userLocations
        .where((loc) =>
            (loc.customerName?.toLowerCase().contains(keyword.toLowerCase()) ??
                false) ||
            (loc.address.toLowerCase().contains(keyword.toLowerCase())))
        .toList();
  }

  // Method untuk mendapatkan lokasi berdasarkan tipe
  List<UserLocationModel> getLocationsByType(String type) {
    return userLocations.where((loc) => loc.addressType == type).toList();
  }

  // Method untuk mendapatkan lokasi berdasarkan ID
  UserLocationModel? getLocationById(int id) {
    return userLocations.firstWhereOrNull((loc) => loc.id == id);
  }

  // Method untuk memilih lokasi
  void selectLocation(UserLocationModel location) {
    selectedLocation.value = location;
  }

  void setSelectedLocation(UserLocationModel location) {
    // Pastikan lokasi yang dipilih ada dalam daftar lokasi
    final existingLocation =
        userLocations.firstWhereOrNull((loc) => loc.id == location.id);

    if (existingLocation != null) {
      selectedLocation.value = existingLocation;
    } else {
      // Jika lokasi tidak ditemukan, tambahkan ke daftar
      addAddress(location).then((_) {
        // Set lokasi yang baru ditambahkan sebagai lokasi terpilih
        selectedLocation.value = location;
      });
    }
  }

  // Method tambahan untuk sinkronisasi dan pembersihan
  Future<void> syncLocations() async {
    await _locationService.syncLocations();
    await loadAddresses();
  }

  void clearLocalData() {
    _locationService.clearLocalData();
    userLocations.clear();
    selectedLocation.value = null;
  }
}
