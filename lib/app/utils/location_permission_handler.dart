// lib/app/utils/location_permission_handler.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationPermissionHandler {
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Tampilkan dialog untuk mengaktifkan layanan lokasi
      bool? openSettings = await Get.dialog(
        AlertDialog(
          title: const Text('Layanan Lokasi Nonaktif'),
          content: const Text(
              'Layanan lokasi dibutuhkan untuk menggunakan fitur ini. '
              'Aktifkan layanan lokasi di pengaturan?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('BATAL'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('PENGATURAN'),
            ),
          ],
        ),
      );

      if (openSettings == true) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    // Cek dan minta izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Izin Ditolak',
          'Izin lokasi diperlukan untuk menggunakan fitur ini',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Tampilkan dialog untuk membuka pengaturan aplikasi
      bool? openAppSettings = await Get.dialog(
        AlertDialog(
          title: const Text('Izin Lokasi Diperlukan'),
          content:
              const Text('Izin lokasi diperlukan untuk menggunakan fitur ini. '
                  'Buka pengaturan aplikasi untuk mengaktifkan izin lokasi?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('BATAL'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('PENGATURAN'),
            ),
          ],
        ),
      );

      if (openAppSettings == true) {
        openAppSettings;
      }
      return false;
    }

    return true;
  }

  static Future<bool> checkAndRequestLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool? result = await Get.dialog(
        AlertDialog(
          title: const Text('Aktifkan Layanan Lokasi'),
          content: const Text(
              'Untuk menggunakan fitur ini, Anda perlu mengaktifkan layanan lokasi. '
              'Apakah Anda ingin mengaktifkannya sekarang?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('TIDAK'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('YA'),
            ),
          ],
        ),
      );

      if (result == true) {
        await Geolocator.openLocationSettings();
        // Cek lagi setelah user kembali dari pengaturan
        return await Geolocator.isLocationServiceEnabled();
      }
      return false;
    }
    return true;
  }
}
