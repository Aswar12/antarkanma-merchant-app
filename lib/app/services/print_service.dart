import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';
import '../data/models/order_model.dart';
import '../data/models/pos_transaction_model.dart';

/// PrintService - Handle thermal printing for receipts
class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  final _storage = GetStorage();
  static const String _printerKey = 'last_printer_address';

  final _isConnected = false.obs;
  final _printerName = RxnString();

  bool get isConnected => _isConnected.value;
  String? get printerName => _printerName.value;

  final _numberFormat = NumberFormat('#,##0', 'id_ID');

  /// Connect to Bluetooth printer
  Future<bool> connect({String? macAddress}) async {
    try {
      final hasPermission = await PermissionService.requestBluetoothPermissions();
      if (!hasPermission) return false;

      final isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothEnabled) {
        Get.snackbar(
          'Bluetooth Mati',
          'Silakan nyalakan Bluetooth Anda terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final address = macAddress ?? _storage.read(_printerKey);
      if (address == null) {
        debugPrint('⚠️ No printer address provided or saved');
        // Auto-scan for printers
        final printers = await scanPrinters();
        debugPrint('📱 Scanned printers: ${printers.length}');
        for (var p in printers) {
          debugPrint('  - ${p.name}: ${p.macAdress}');
        }
        if (printers.isEmpty) {
          Get.snackbar(
            'Printer Tidak Ditemukan',
            'Pastikan printer thermal Bluetooth sudah:\n1. Menyala (lampu indikator berkedip)\n2. Dipairing di Bluetooth settings\n3. Tidak terhubung ke device lain',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
          showPrinterSetupDialog();
          return false;
        }
        // Use first available printer
        final printer = printers.first;
        _storage.write(_printerKey, printer.macAdress);
        debugPrint('📍 Using printer: ${printer.name} (${printer.macAdress})');
      }

      final finalAddress = macAddress ?? _storage.read(_printerKey);
      if (finalAddress == null) {
        debugPrint('❌ No printer address available');
        return false;
      }

      debugPrint('🔵 Attempting to connect to: $finalAddress');
      
      // Disconnect first to ensure clean connection
      await PrintBluetoothThermal.disconnect;
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isConnected.value = await PrintBluetoothThermal.connect(
        macPrinterAddress: finalAddress,
      );

      debugPrint('🔗 Connection result: ${_isConnected.value}');

      if (_isConnected.value) {
        _storage.write(_printerKey, finalAddress);
        final devices = await PrintBluetoothThermal.pairedBluetooths;
        debugPrint('📋 Paired devices: ${devices.length}');
        final currentDevice = devices.firstWhere(
          (d) => d.macAdress == finalAddress,
          orElse: () => BluetoothInfo(name: 'Printer', macAdress: finalAddress),
        );
        _printerName.value = currentDevice.name;
        debugPrint('✅ Connected to printer: ${_printerName.value} ($finalAddress)');

        Get.snackbar(
          'Terhubung',
          'Printer ${_printerName.value} siap digunakan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        debugPrint('❌ Failed to connect to: $finalAddress');
        debugPrint('💡 Possible causes:');
        debugPrint('  - Printer is connected to another device');
        debugPrint('  - Printer is out of range');
        debugPrint('  - Printer battery is low');
        debugPrint('  - MAC address format is incorrect');
        
        Get.snackbar(
          'Gagal Koneksi',
          'Tidak dapat terhubung ke printer.\n\nCoba:\n• Putus koneksi dari device lain\n• Restart printer (matikan & nyalakan)\n• Unpair & pair ulang di Bluetooth settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }

      return _isConnected.value;
    } catch (e, stackTrace) {
      debugPrint('❌ Printer connection error: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar(
        'Error Koneksi',
        'Gagal terhubung ke printer: ${e.toString()}\n\nPastikan:\n• Printer sudah dipairing\n• Bluetooth aktif\n• Printer tidak terhubung ke device lain',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return false;
    }
  }

  /// Disconnect from printer
  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    _isConnected.value = false;
    _printerName.value = null;
  }

  // ═══════════════════════════════════════════════════════════
  //  ONLINE ORDER PRINTING
  // ═══════════════════════════════════════════════════════════

  /// Print order receipt
  Future<bool> printReceipt({
    required OrderModel order,
    String? merchantName,
    String? merchantAddress,
    String? merchantPhone,
    String? logoUrl,
  }) async {
    try {
      if (!_isConnected.value) {
        final connected = await connect();
        if (!connected) {
          // No need to show snackbar here if address was null, it's handled in connect()
          return false;
        }
      }

      final receipt = _generateReceiptContent(
        order: order,
        merchantName: merchantName,
        merchantAddress: merchantAddress,
        merchantPhone: merchantPhone,
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: receipt),
      );
      await PrintBluetoothThermal.writeBytes([0x1D, 0x56, 0x42, 0x00]);

      Get.snackbar('Success', 'Receipt berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return true;
    } catch (e) {
      debugPrint('❌ Print error: $e');
      Get.snackbar('Error', 'Gagal mencetak receipt: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
  }

  String _generateReceiptContent({
    required OrderModel order,
    String? merchantName,
    String? merchantAddress,
    String? merchantPhone,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    StringBuffer receipt = StringBuffer();

    // Header - 38 chars width (standard 58mm thermal printer)
    receipt.writeln('======================================');
    receipt.writeln('  ${merchantName ?? 'MERCHANT'}');
    if (merchantAddress != null && merchantAddress.isNotEmpty) {
      receipt.writeln('  $merchantAddress');
    }
    if (merchantPhone != null && merchantPhone.isNotEmpty) {
      receipt.writeln('  Telp: $merchantPhone');
    }
    receipt.writeln('======================================');
    receipt.writeln('');
    receipt.writeln('ORDER #ANTAR-${order.id}');
    receipt.writeln(dateFormat.format(order.createdAt));
    receipt.writeln('Status: ${_getStatusText(order.orderStatus)}');
    receipt.writeln('======================================');
    receipt.writeln('');
    receipt.writeln('Customer: ${order.customer.name ?? '-'}');
    if (order.customer.phone != null && order.customer.phone!.isNotEmpty) {
      receipt.writeln('Phone: ${order.customer.phone}');
    }
    receipt.writeln('');
    receipt.writeln('--------------------------------------');
    receipt.writeln('ITEMS');
    receipt.writeln('--------------------------------------');

    for (var item in order.orderItems) {
      receipt.writeln('${item.quantity}x ${item.product.name}');
      if (item.price > 0) {
        receipt
            .writeln('   ${_numberFormat.format(item.price * item.quantity)}');
      }
      if (item.customerNote != null && item.customerNote!.isNotEmpty) {
        receipt.writeln('   Note: ${item.customerNote}');
      }
    }

    receipt.writeln('');
    receipt.writeln('--------------------------------------');
    receipt.writeln('Subtotal: Rp ${_numberFormat.format(order.subtotal)}');
    if (order.shippingCost > 0) {
      receipt.writeln('Ongkir: Rp ${_numberFormat.format(order.shippingCost)}');
    }
    if (order.discount != null && order.discount! > 0) {
      receipt.writeln('Discount: -Rp ${_numberFormat.format(order.discount!)}');
    }
    receipt.writeln('======================================');
    receipt.writeln('TOTAL: Rp ${_numberFormat.format(order.totalAmount)}');
    receipt.writeln('Payment: ${order.paymentMethod}');
    receipt.writeln('======================================');
    receipt.writeln('');
    receipt.writeln('Terima kasih atas pesanan Anda!');
    receipt.writeln('Order ID: ${order.id}');
    receipt.writeln('Transaction ID: ${order.transactionId}');
    receipt.writeln('\n\n\n');

    return receipt.toString();
  }

  /// Print kitchen receipt (online order)
  Future<bool> printKitchenReceipt({
    required OrderModel order,
    String? merchantName,
  }) async {
    try {
      if (!_isConnected.value) {
        final connected = await connect();
        if (!connected) return false;
      }

      final receipt =
          _generateKitchenReceipt(order: order, merchantName: merchantName);
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: receipt),
      );
      await PrintBluetoothThermal.writeBytes([0x1D, 0x56, 0x42, 0x00]);

      Get.snackbar('Success', 'Kitchen receipt dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return true;
    } catch (e) {
      debugPrint('❌ Kitchen print error: $e');
      Get.snackbar('Error', 'Gagal mencetak: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
  }

  String _generateKitchenReceipt({
    required OrderModel order,
    String? merchantName,
  }) {
    final dateFormat = DateFormat('HH:mm');
    StringBuffer receipt = StringBuffer();

    // Kitchen receipt - 38 chars width
    receipt.writeln('======================================');
    receipt.writeln('  ${merchantName ?? 'KITCHEN'}');
    receipt.writeln('======================================');
    receipt.writeln('');
    receipt.writeln('ORDER #ANTAR-${order.id}');
    receipt.writeln(dateFormat.format(order.createdAt));
    receipt.writeln('');
    receipt.writeln('--------------------------------------');

    for (var item in order.orderItems) {
      receipt.writeln('${item.quantity}x ${item.product.name}');
      if (item.customerNote != null && item.customerNote!.isNotEmpty) {
        receipt.writeln('   NOTE: ${item.customerNote}');
      }
    }

    receipt.writeln('');
    receipt.writeln('--------------------------------------');
    receipt.writeln('Customer: ${order.customer.name ?? '-'}');
    receipt.writeln('\n\n\n');

    return receipt.toString();
  }

  // ═══════════════════════════════════════════════════════════
  //  POS TRANSACTION PRINTING
  // ═══════════════════════════════════════════════════════════

  /// Print POS transaction receipt (customer copy)
  Future<bool> printPosReceipt({
    required PosTransactionModel tx,
    String? merchantName,
    String? merchantAddress,
    String? merchantPhone,
  }) async {
    try {
      if (!_isConnected.value) {
        final connected = await connect();
        if (!connected) {
          return false;
        }
      }

      final receipt = _generatePosReceiptContent(
        tx: tx,
        merchantName: merchantName,
        merchantAddress: merchantAddress,
        merchantPhone: merchantPhone,
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: receipt),
      );
      await PrintBluetoothThermal.writeBytes([0x1D, 0x56, 0x42, 0x00]);

      Get.snackbar('Berhasil', 'Struk berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return true;
    } catch (e) {
      debugPrint('❌ POS print error: $e');
      Get.snackbar('Error', 'Gagal mencetak struk: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
  }

  /// Generate POS receipt content
  String _generatePosReceiptContent({
    required PosTransactionModel tx,
    String? merchantName,
    String? merchantAddress,
    String? merchantPhone,
  }) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    StringBuffer r = StringBuffer();

    // Header - 38 chars width (standard 58mm thermal printer)
    r.writeln('======================================');
    r.writeln('  ${merchantName ?? 'MERCHANT'}');
    if (merchantAddress != null && merchantAddress.isNotEmpty) {
      r.writeln('  $merchantAddress');
    }
    if (merchantPhone != null && merchantPhone.isNotEmpty) {
      r.writeln('  Telp: $merchantPhone');
    }
    r.writeln('======================================');
    r.writeln('');

    // Transaction Info
    r.writeln('No: ${tx.transactionCode ?? '#${tx.id}'}');
    if (tx.createdAt != null) {
      r.writeln(dateFormat.format(tx.createdAt!));
    }
    r.writeln('Tipe: ${tx.orderTypeDisplay}');
    if (tx.tableNumber != null && tx.tableNumber!.isNotEmpty) {
      r.writeln('Meja: ${tx.tableNumber}');
    }
    if (tx.customerName != null && tx.customerName!.isNotEmpty) {
      r.writeln('Pelanggan: ${tx.customerName}');
    }
    r.writeln('======================================');
    r.writeln('');

    // Items
    for (var item in tx.items) {
      r.writeln('${item.quantity}x ${item.name}');
      r.writeln(
          '   Rp ${_numberFormat.format(item.price)} = Rp ${_numberFormat.format(item.subtotal)}');
      if (item.notes != null && item.notes!.isNotEmpty) {
        r.writeln('   Catatan: ${item.notes}');
      }
    }

    r.writeln('');
    r.writeln('--------------------------------------');

    // Totals - 38 chars width
    r.writeln('Subtotal    Rp ${_numberFormat.format(tx.subtotal)}');
    if (tx.discount > 0) {
      r.writeln('Diskon     -Rp ${_numberFormat.format(tx.discount)}');
    }
    if (tx.tax > 0) {
      r.writeln('Pajak       Rp ${_numberFormat.format(tx.tax)}');
    }
    r.writeln('======================================');
    r.writeln('TOTAL       Rp ${_numberFormat.format(tx.total)}');
    r.writeln('======================================');
    r.writeln('');

    // Payment
    r.writeln('Bayar: ${tx.paymentMethodDisplay}');
    if (tx.paymentMethod == 'CASH') {
      r.writeln('Tunai       Rp ${_numberFormat.format(tx.amountPaid)}');
      r.writeln('Kembali     Rp ${_numberFormat.format(tx.changeAmount)}');
    }
    r.writeln('');

    // Footer
    r.writeln('----------------------------------------');
    r.writeln('  Terima Kasih!');
    r.writeln('  Selamat Menikmati');
    r.writeln('----------------------------------------');
    r.writeln('\n\n\n');

    return r.toString();
  }

  /// Print POS kitchen/bar ticket (order queue for preparation)
  Future<bool> printPosKitchenTicket({
    required PosTransactionModel tx,
    String? merchantName,
    String? station, // e.g. "DAPUR", "BAR", "KITCHEN"
  }) async {
    try {
      if (!_isConnected.value) {
        final connected = await connect();
        if (!connected) {
          return false;
        }
      }

      final ticket = _generatePosKitchenTicket(
        tx: tx,
        merchantName: merchantName,
        station: station,
      );

      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: ticket),
      );
      await PrintBluetoothThermal.writeBytes([0x1D, 0x56, 0x42, 0x00]);

      Get.snackbar('Berhasil', 'Tiket ${station ?? 'dapur'} berhasil dicetak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return true;
    } catch (e) {
      debugPrint('❌ POS kitchen ticket error: $e');
      Get.snackbar('Error', 'Gagal mencetak tiket: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    }
  }

  /// Generate POS kitchen/bar ticket (simplified: large order #, items only)
  String _generatePosKitchenTicket({
    required PosTransactionModel tx,
    String? merchantName,
    String? station,
  }) {
    final timeFormat = DateFormat('HH:mm');
    StringBuffer t = StringBuffer();

    // Kitchen ticket - 38 chars width
    t.writeln('======================================');
    t.writeln('  ${station ?? 'DAPUR'}');
    t.writeln('  ${merchantName ?? ''}');
    t.writeln('======================================');
    t.writeln('');

    // Large order info for kitchen visibility
    t.writeln('ORDER: ${tx.transactionCode ?? '#${tx.id}'}');
    if (tx.createdAt != null) {
      t.writeln('JAM: ${timeFormat.format(tx.createdAt!)}');
    }
    t.writeln('TIPE: ${tx.orderTypeDisplay}');
    if (tx.tableNumber != null && tx.tableNumber!.isNotEmpty) {
      t.writeln('MEJA: ${tx.tableNumber}');
    }
    if (tx.customerName != null && tx.customerName!.isNotEmpty) {
      t.writeln('PELANGGAN: ${tx.customerName}');
    }
    t.writeln('');
    t.writeln('======================================');

    // Items — large and clear for kitchen staff
    for (var item in tx.items) {
      t.writeln('');
      t.writeln('  ${item.quantity}x ${item.name}');
      if (item.notes != null && item.notes!.isNotEmpty) {
        t.writeln('  >> ${item.notes}');
      }
    }

    t.writeln('');
    t.writeln('======================================');
    t.writeln('Total Item: ${tx.totalItems}');
    t.writeln('======================================');
    t.writeln('\n\n\n');

    return t.toString();
  }

  // ═══════════════════════════════════════════════════════════
  //  PRINTER SETUP DIALOG
  // ═══════════════════════════════════════════════════════════

  /// Show printer setup dialog — scan, select, connect
  Future<void> showPrinterSetupDialog() async {
    final printers = <BluetoothInfo>[].obs;
    final isScanning = false.obs;
    final isConnecting = false.obs;

    isScanning.value = true;
    try {
      printers.value = await scanPrinters();
    } finally {
      isScanning.value = false;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Setup Printer Thermal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Obx(() => isScanning.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            isScanning.value = true;
                            printers.value = await scanPrinters();
                            isScanning.value = false;
                          },
                        )),
                ],
              ),
              const SizedBox(height: 8),
              // Pairing instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                          'Cara Pairing:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1. Buka Settings → Bluetooth\n'
                      '2. Scan & pair printer thermal (PIN: 0000/1234)\n'
                      '3. Tekan tombol refresh di atas\n'
                      '4. Tap printer untuk connect',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Current status
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isConnected.value
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isConnected.value
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          size: 18,
                          color: _isConnected.value ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isConnected.value
                                ? 'Terhubung: ${_printerName.value ?? 'Printer'}'
                                : 'Tidak terhubung',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isConnected.value ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
              const Text(
                'Printer Tersedia:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              // Printer list
              Obx(() {
                if (printers.isEmpty && !isScanning.value) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.bluetooth_disabled, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada printer ditemukan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pastikan printer sudah dipairing\ndi Bluetooth Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: printers.length,
                    itemBuilder: (_, i) {
                      final printer = printers[i];
                      final isCurrent =
                          _printerName.value == printer.name && _isConnected.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.green.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.print,
                              color: isCurrent ? Colors.green : Colors.grey),
                          title: Text(printer.name,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                          subtitle: Text(printer.macAdress,
                              style: const TextStyle(fontSize: 11)),
                          trailing: Obx(() => isConnecting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : isCurrent
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green, size: 22)
                                  : const Icon(Icons.arrow_forward_ios,
                                      size: 14)),
                          onTap: () async {
                            isConnecting.value = true;
                            final success =
                                await connect(macAddress: printer.macAdress);
                            isConnecting.value = false;
                            if (success) {
                              Get.back();
                              Get.snackbar('Terhubung',
                                  'Printer ${printer.name} berhasil terhubung',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2));
                            } else {
                              Get.snackbar('Gagal',
                                  'Tidak bisa terhubung ke ${printer.name}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  UTILITIES
  // ═══════════════════════════════════════════════════════════

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
      return {'error': e.toString()};
    }
  }

  Future<void> openBluetoothSettings() async {
    await openAppSettings();
  }

  Future<List<BluetoothInfo>> scanPrinters() async {
    try {
      final hasPermission = await PermissionService.requestBluetoothPermissions();
      if (!hasPermission) return [];

      final allDevices = await PrintBluetoothThermal.pairedBluetooths;
      
      // Filter the list to only show likely printers based on common names
      final printerKeywords = [
        'print', 'pos', 'mtp', 'mpt', 'bt', 'rp', 'pt', 
        '58', '80', 'blue', 'zj', 'ther', 'receipt', 
        'bill', 'mini', 'sunmi', 'inner'
      ];
      
      return allDevices.where((d) {
        final name = d.name.toLowerCase();
        return printerKeywords.any((k) => name.contains(k));
      }).toList();
    } catch (e) {
      debugPrint('❌ Scan error: $e');
      return [];
    }
  }
}
