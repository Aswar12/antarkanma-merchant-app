import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/models/order_model.dart';

/// PrintService - Handle thermal printing for receipts
class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  final _storage = GetStorage();
  static const String _printerKey = 'last_printer_address';

  bool _isConnected = false;
  String? _printerName;

  bool get isConnected => _isConnected;
  String? get printerName => _printerName;

  /// Connect to Bluetooth printer
  Future<bool> connect({String? macAddress}) async {
    try {
      // Check if Bluetooth is enabled
      final isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothEnabled) {
        await openAppSettings();
        return false;
      }

      // Use provided macAddress or last saved one
      final address = macAddress ?? _storage.read(_printerKey);
      if (address == null) {
        debugPrint('⚠️ No printer address provided or saved');
        return false;
      }

      // Connect to printer
      _isConnected = await PrintBluetoothThermal.connect(
        macPrinterAddress: address,
      );

      if (_isConnected) {
        _storage.write(_printerKey, address);
        // In the new API, we might not have a direct printerName getter
        // We can try to find the name from paired devices if needed
        final devices = await PrintBluetoothThermal.pairedBluetooths;
        final currentDevice = devices.firstWhere(
          (d) => d.macAdress == address,
          orElse: () => BluetoothInfo(name: 'Printer', macAdress: address),
        );
        _printerName = currentDevice.name;
        debugPrint('✅ Connected to printer: $_printerName');
      }

      return _isConnected;
    } catch (e) {
      debugPrint('❌ Printer connection error: $e');
      return false;
    }
  }

  /// Disconnect from printer
  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    _isConnected = false;
    _printerName = null;
  }

  /// Print order receipt
  Future<bool> printReceipt({
    required OrderModel order,
    String? merchantName,
    String? merchantAddress,
    String? merchantPhone,
    String? logoUrl,
  }) async {
    try {
      if (!_isConnected) {
        final connected = await connect();
        if (!connected) {
          Get.snackbar(
            'Error',
            'Printer tidak terhubung. Silakan cek Bluetooth.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      }

      // Generate receipt content
      final receipt = _generateReceiptContent(
        order: order,
        merchantName: merchantName,
        merchantAddress: merchantAddress,
        merchantPhone: merchantPhone,
      );

      // Print via Bluetooth
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: receipt),
      );

      // Cut paper (ESC m or ESC i depending on printer, standard is GS V 66 0)
      await PrintBluetoothThermal.writeBytes([0x1D, 0x56, 0x42, 0x00]);

      Get.snackbar(
        'Success',
        'Receipt berhasil dicetak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Print error: $e');
      Get.snackbar(
        'Error',
        'Gagal mencetak receipt: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Generate receipt text content
  String _generateReceiptContent({
    required OrderModel order,
    String? merchantName,
    String? merchantAddress,
    String? merchantPhone,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final numberFormat = NumberFormat('#,##0', 'id_ID');

    StringBuffer receipt = StringBuffer();

    // Header - Merchant Info (centered, bold)
    receipt.writeln('================================');
    receipt.writeln(merchantName ?? 'MERCHANT');
    receipt.writeln(merchantAddress ?? '');
    receipt.writeln('Telp: ${merchantPhone ?? '-'}');
    receipt.writeln('================================');
    receipt.writeln('');

    // Order Info
    receipt.writeln('ORDER #$order.id');
    receipt.writeln(dateFormat.format(order.createdAt));
    receipt.writeln('Status: ${_getStatusText(order.orderStatus)}');
    receipt.writeln('================================');
    receipt.writeln('');

    // Customer Info
    receipt.writeln('Customer: ${order.customer.name ?? '-'}');
    if (order.customer.phone != null && order.customer.phone!.isNotEmpty) {
      receipt.writeln('Phone: ${order.customer.phone}');
    }
    receipt.writeln('');

    // Order Items
    receipt.writeln('--------------------------------');
    receipt.writeln('ITEMS');
    receipt.writeln('--------------------------------');

    for (var item in order.orderItems) {
      receipt.writeln('${item.quantity}x ${item.product.name}');
      if (item.price > 0) {
        receipt
            .writeln('   ${numberFormat.format(item.price * item.quantity)}');
      }
      if (item.customerNote != null && item.customerNote!.isNotEmpty) {
        receipt.writeln('   Note: ${item.customerNote}');
      }
    }

    receipt.writeln('');
    receipt.writeln('--------------------------------');

    // Totals
    receipt.writeln('Subtotal: Rp ${numberFormat.format(order.subtotal)}');

    if (order.shippingCost > 0) {
      receipt.writeln('Ongkir: Rp ${numberFormat.format(order.shippingCost)}');
    }

    if (order.discount != null && order.discount! > 0) {
      receipt.writeln('Discount: -Rp ${numberFormat.format(order.discount!)}');
    }

    receipt.writeln('================================');
    receipt.writeln('TOTAL: Rp ${numberFormat.format(order.totalAmount)}');
    receipt.writeln('Payment: ${order.paymentMethod}');
    receipt.writeln('================================');
    receipt.writeln('');

    // Footer
    receipt.writeln('Terima kasih atas pesanan Anda!');
    receipt.writeln('Simpan receipt ini sebagai bukti');
    receipt.writeln('');
    receipt.writeln('Order ID: $order.id');
    receipt.writeln('Transaction ID: ${order.transactionId}');
    receipt.writeln('');

    // Cut command
    receipt.writeln('\n\n\n');

    return receipt.toString();
  }

  /// Generate kitchen receipt (simplified for barista/kitchen)
  String _generateKitchenReceipt({
    required OrderModel order,
    String? merchantName,
  }) {
    final dateFormat = DateFormat('HH:mm');
    StringBuffer receipt = StringBuffer();

    receipt.writeln('================================\n');
    receipt.writeln('  ${merchantName ?? 'KITCHEN'}\n');
    receipt.writeln('================================\n\n');

    // Large order number for visibility
    receipt.writeln('ORDER #$order.id\n');
    receipt.writeln('${dateFormat.format(order.createdAt)}\n\n');

    receipt.writeln('--------------------------------\n');

    // Items with quantities
    for (var item in order.orderItems) {
      receipt.writeln('${item.quantity}x ${item.product.name}\n');
      if (item.customerNote != null && item.customerNote!.isNotEmpty) {
        receipt.writeln('   NOTE: ${item.customerNote}\n');
      }
    }

    receipt.writeln('\n--------------------------------\n\n');
    receipt.writeln('Customer: ${order.customer.name ?? '-'}\n\n');
    receipt.writeln('\n\n\n');

    return receipt.toString();
  }

  /// Print kitchen receipt
  Future<bool> printKitchenReceipt({
    required OrderModel order,
    String? merchantName,
  }) async {
    try {
      if (!_isConnected) {
        final connected = await connect();
        if (!connected) return false;
      }

      final receipt = _generateKitchenReceipt(
        order: order,
        merchantName: merchantName,
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: receipt),
      );
      // Cut paper (ESC m or ESC i depending on printer, standard is GS V 66 0)
      await PrintBluetoothThermal.writeBytes([0x1D, 0x56, 0x42, 0x00]);

      Get.snackbar(
        'Success',
        'Kitchen receipt dicetak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Kitchen print error: $e');
      Get.snackbar(
        'Error',
        'Gagal mencetak: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Get status text
  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
      case 'WAITING_APPROVAL':
        return 'Menunggu Persetujuan';
      case 'PROCESSING':
        return 'Sedang Diproses';
      case 'READY_FOR_PICKUP':
        return 'Siap Diambil';
      case 'PICKED_UP':
        return 'Dalam Pengantaran';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  /// Check printer status
  Future<Map<String, dynamic>> checkPrinterStatus() async {
    try {
      final isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      final isConnected = await PrintBluetoothThermal.connectionStatus;

      String? name;
      if (isConnected) {
        final address = _storage.read(_printerKey);
        if (address != null) {
          final devices = await PrintBluetoothThermal.pairedBluetooths;
          final currentDevice = devices.firstWhere(
            (d) => d.macAdress == address,
            orElse: () => BluetoothInfo(name: 'Printer', macAdress: address),
          );
          name = currentDevice.name;
        }
      }

      return {
        'bluetooth_enabled': isBluetoothEnabled,
        'printer_name': name,
        'is_connected': isConnected,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Open Bluetooth settings
  Future<void> openBluetoothSettings() async {
    await openAppSettings();
  }

  /// Scan for available printers
  Future<List<BluetoothInfo>> scanPrinters() async {
    try {
      final printers = await PrintBluetoothThermal.pairedBluetooths;
      return printers;
    } catch (e) {
      debugPrint('❌ Scan error: $e');
      return [];
    }
  }
}
