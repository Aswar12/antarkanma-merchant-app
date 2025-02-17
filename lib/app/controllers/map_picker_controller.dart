// ignore_for_file: avoid_print

import 'dart:async';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/location_permission_handler.dart';

class MapPickerController extends GetxController {
  final selectedLocation = const LatLng(-4.6275392, 119.5871827).obs;
  final isLoading = false.obs;
  final currentAddress = ''.obs;
  final Rx<MapController> mapController = MapController().obs;
  bool _disposed = false;
  Timer? _locationTimer;

  // Add a getter for currentLocation
  LatLng get currentLocation => selectedLocation.value;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  @override
  void onClose() {
    _disposed = true;
    _locationTimer?.cancel();
    mapController.value.dispose();
    super.onClose();
  }

  void _showSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    if (!_disposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackbar(
          title: title,
          message: message,
          isError: isError,
        );
      });
    }
  }

  Future<void> _initializeLocation() async {
    if (_disposed) return;
    await getCurrentLocation();
  }

  void _safeUpdate(VoidCallback callback) {
    if (!_disposed) {
      try {
        callback();
      } catch (e) {
        print('Safe update error: $e');
      }
    }
  }

  Future<Position?> _getPositionWithTimeout() async {
    if (_disposed) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          throw TimeoutException('Waktu mendapatkan lokasi habis');
        },
      );
    } catch (e) {
      if (e is TimeoutException && !_disposed) {
        return await Geolocator.getLastKnownPosition();
      }
      rethrow;
    }
  }

  Future<void> getCurrentLocation() async {
    if (_disposed) return;

    try {
      _safeUpdate(() => isLoading.value = true);

      bool hasPermission =
          await LocationPermissionHandler.handleLocationPermission();
      if (!hasPermission || _disposed) {
        _showSnackbar(
          title: 'Peringatan',
          message: 'Izin lokasi diperlukan untuk menggunakan fitur ini',
          isError: true,
        );
        return;
      }

      bool serviceEnabled =
          await LocationPermissionHandler.checkAndRequestLocationService();
      if (!serviceEnabled || _disposed) {
        _showSnackbar(
          title: 'Peringatan',
          message: 'Layanan lokasi perlu diaktifkan',
          isError: true,
        );
        return;
      }

      Position? position = await _getPositionWithTimeout();
      if (_disposed) return;

      if (position == null) {
        _showSnackbar(
          title: 'Error',
          message: 'Tidak dapat mendapatkan lokasi saat ini',
          isError: true,
        );
        return;
      }

      final newLocation = LatLng(position.latitude, position.longitude);
      await updateLocation(newLocation);

      if (_disposed) return;

      try {
        mapController.value.move(newLocation, 15);
        _showSnackbar(
          title: 'Sukses',
          message: 'Lokasi berhasil diperbarui',
          isError: false,
        );
      } catch (e) {
        print('Error moving map: $e');
      }
    } catch (e) {
      if (!_disposed) {
        String errorMessage = 'Gagal mendapatkan lokasi';
        if (e is TimeoutException) {
          errorMessage = 'Waktu mendapatkan lokasi habis. Silakan coba lagi';
        }
        _showSnackbar(
          title: 'Error',
          message: errorMessage,
          isError: true,
        );
      }
    } finally {
      if (!_disposed) {
        _safeUpdate(() => isLoading.value = false);
      }
    }
  }

  Future<void> updateLocation(LatLng newLocation) async {
    if (_disposed) return;

    try {
      _safeUpdate(() => selectedLocation.value = newLocation);
      await getAddressFromLatLng(newLocation);
    } catch (e) {
      if (!_disposed) {
        print('Error updating location: $e');
        _showSnackbar(
          title: 'Error',
          message: 'Gagal memperbarui lokasi',
          isError: true,
        );
      }
    }
  }

  Future<void> getAddressFromLatLng(LatLng location) async {
    if (_disposed) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw TimeoutException('Waktu mendapatkan alamat habis'),
      );

      if (_disposed) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _safeUpdate(() {
          currentAddress.value = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country,
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');
        });
      }
    } catch (e) {
      if (!_disposed) {
        _safeUpdate(
            () => currentAddress.value = 'Tidak dapat mendapatkan alamat');
        print('Error getting address: $e');
      }
    }
  }

  void confirmLocation() {
    if (_disposed) return;

    if (Get.isRegistered<MapPickerController>()) {
      Get.back(result: {
        'location': selectedLocation.value,
        'address': currentAddress.value,
      });
    } else {
      Navigator.pop(Get.context!, {
        'location': selectedLocation.value,
        'address': currentAddress.value,
      });
    }
  }

  void initializeMap() {
    // Inisialisasi peta dengan lokasi default atau lokasi terakhir yang diketahui
    selectedLocation.value =
        const LatLng(-4.6275392, 119.5871827); // Contoh koordinat default
    mapController.value.move(selectedLocation.value, 15.0);

    // Kemudian coba dapatkan lokasi saat ini
    getCurrentLocation();
  }

  String get formattedLocation {
    return '${selectedLocation.value.latitude.toStringAsFixed(6)}, '
        '${selectedLocation.value.longitude.toStringAsFixed(6)}';
  }
}
