import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class PermissionService {
  static Future<bool> requestBluetoothPermissions() async {
    try {
      // Request basic Bluetooth permissions
      final basicPermissions = await [
        Permission.bluetooth,
        Permission.locationWhenInUse,
      ].request();

      // Check if basic permissions are granted
      if (basicPermissions.values.any((status) => !status.isGranted)) {
        // Show dialog for basic permissions
        await _showPermissionDeniedDialog(
          'Bluetooth dan Lokasi',
          'Aplikasi membutuhkan izin Bluetooth dan Lokasi untuk mencari dan terhubung dengan printer thermal.',
        );
        return false;
      }

      // For Android 12 and above, request additional permissions
      if (GetPlatform.isAndroid) {
        final advancedPermissions = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        // Check if advanced permissions are granted
        if (advancedPermissions.values.any((status) => !status.isGranted)) {
          // Show dialog for advanced permissions
          await _showPermissionDeniedDialog(
            'Bluetooth',
            'Aplikasi membutuhkan izin tambahan untuk menggunakan Bluetooth pada Android 12 ke atas.',
          );
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat meminta izin: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  static Future<void> _showPermissionDeniedDialog(String title, String message) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Izin $title Diperlukan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Buka Pengaturan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      await openAppSettings();
    }
  }
}
