import 'dart:io';
import 'package:antarkanma_merchant/app/data/models/order_model.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptService {
  static bool _isPrinting = false;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _charsPerLine = 30; // Optimized for 58mm printer
  static const String _separator = '------------------------------';
  static const String _shortSeparator = '---------------';

  static String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  static String _formatPrice(String price) {
    // Keep zeros but remove trailing .00 if present
    if (price.endsWith('.00')) {
      return price.substring(0, price.length - 3);
    }
    return price;
  }

  static String _padPrice(String label, String amount) {
    final spaces = _charsPerLine - label.length - amount.length;
    return '$label${' ' * spaces}$amount';
  }

  static Future<void> printReceipt(OrderModel order, MerchantModel merchant,
      Map<String, dynamic> printer) async {
    if (_isPrinting) {
      debugPrint('Already printing, please wait...');
      return;
    }

    try {
      _isPrinting = true;
      debugPrint('Connecting to printer: ${printer['name']}');

      final isConnected = await PrintBluetoothThermal.connect(
          macPrinterAddress: printer['address']);
      if (!isConnected) {
        throw Exception('Failed to connect to printer');
      }

      // Initialize printer for 58mm paper
      await PrintBluetoothThermal.writeBytes([
        0x1B, 0x40, // Initialize printer
        0x1B, 0x74, 0x00, // Select character code table
        0x1D, 0x4C, 0x00, 0x00, // Set left margin
        0x1B, 0x33, 0x00, // Set minimum line spacing
        0x1D, 0x57, 0x40, 0x01 // Set print area width for 58mm
      ]);

      // Print merchant header (compact)
      await _printWithStyle(merchant.name.toUpperCase(),
          size: 1, bold: true, align: 1);
      await _printWithStyle(_truncateText(merchant.address, _charsPerLine),
          align: 1);
      await _printWithStyle(
          _truncateText('Telp: ${merchant.phoneNumber}', _charsPerLine),
          align: 1);
      await _printWithStyle(_shortSeparator);

      // Print order info (compact)
      final dateStr = DateFormat('dd/MM/yy HH:mm').format(order.createdAt);
      await _printWithStyle('#${order.orderNumber}');
      await _printWithStyle(dateStr);
      await _printWithStyle('Status: ${order.statusDisplay}');
      await _printWithStyle(_shortSeparator);

      // Print customer info (compact)
      await _printWithStyle(order.customerName);
      await _printWithStyle(order.customerPhone);

      // Print delivery info if available (very compact)
      if (order.customer.deliveryAddress != null) {
        final address = order.customer.deliveryAddress!;
        await _printWithStyle('Kirim ke: ${address.customerName}');
        await _printWithStyle(_truncateText(address.address, _charsPerLine));
        await _printWithStyle('${address.district}, ${address.city}');
        if (address.notes?.isNotEmpty ?? false) {
          await _printWithStyle(
              'Note: ${_truncateText(address.notes!, _charsPerLine)}');
        }
      }
      await _printWithStyle(_shortSeparator);

      // Print items (compact)
      for (var item in order.items) {
        // Print item name and quantity
        await _printWithStyle(
            '${item.quantity}x ${_truncateText(item.product.name, _charsPerLine - 3)}');

        // Print variant and notes (if any) with indent
        if (item.variant != null) {
          await _printWithStyle(' +${item.variant!.name}');
        }
        if (item.customerNote?.isNotEmpty ?? false) {
          await _printWithStyle(
              ' *${_truncateText(item.customerNote!, _charsPerLine - 2)}');
        }

        // Print price right-aligned with padding
        await _printWithStyle(_padPrice('', _formatPrice(item.formattedPrice)));
      }
      await _printWithStyle(_shortSeparator);

      // Print payment details (compact, right-aligned with padding)
      await _printWithStyle(
          _padPrice('Subtotal', _formatPrice(order.formattedSubtotal)));
      await _printWithStyle(
          _padPrice('Ongkir', _formatPrice(order.formattedShippingCost)));
      if (order.discount != null && order.discount! > 0) {
        await _printWithStyle(
            _padPrice('Diskon', '-${_formatPrice(order.formattedDiscount)}'));
      }
      await _printWithStyle(_shortSeparator);

      // Print total and payment method in one line
      await _printWithStyle(
          _padPrice('TOTAL', _formatPrice(order.formattedTotal)),
          bold: true);
      await _printWithStyle(order.paymentMethod, align: 1);

      // Print footer
      await _printWithStyle(_separator);
      if (merchant.description?.isNotEmpty ?? false) {
        await _printWithStyle(
            _truncateText(merchant.description!, _charsPerLine),
            align: 1);
      }
      await _printWithStyle('Terima kasih', align: 1);

      // Feed and cut paper
      await PrintBluetoothThermal.writeBytes([
        0x1B, 0x64, 0x02, // Feed 2 lines
        0x1D, 0x56, 0x41, 0x10 // Partial cut
      ]);

      Get.snackbar(
        'Sukses',
        'Struk berhasil dicetak',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      Get.snackbar(
        'Error',
        'Gagal mencetak struk. Pastikan printer menyala dan dalam jangkauan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => Get.back(),
          child: const Text('Tutup', style: TextStyle(color: Colors.white)),
        ),
      );
      rethrow;
    } finally {
      try {
        await PrintBluetoothThermal.disconnect;
      } catch (e) {
        debugPrint('Error disconnecting printer: $e');
      }
      _isPrinting = false;
    }
  }

  static Future<void> _printWithStyle(
    String text, {
    int size = 1,
    bool bold = false,
    int align = 0,
  }) async {
    try {
      final bytes = <int>[];

      // Set alignment
      bytes.addAll([0x1B, 0x61, align]);

      // Set text size
      if (size > 1) {
        bytes.addAll([0x1D, 0x21, (size - 1) << 4 | (size - 1)]);
      }

      // Set bold
      if (bold) {
        bytes.addAll([0x1B, 0x45, 0x01]);
      }

      // Write bytes
      await PrintBluetoothThermal.writeBytes(bytes);

      // Write text
      await PrintBluetoothThermal.writeString(
        printText: PrintTextSize(size: 1, text: '$text\n'),
      );

      // Reset formatting
      if (size > 1 || bold) {
        await PrintBluetoothThermal.writeBytes([
          0x1D, 0x21, 0x00, // Reset size
          0x1B, 0x45, 0x00 // Reset bold
        ]);
      }
    } catch (e) {
      debugPrint('Error in _printWithStyle: $e');
      rethrow;
    }
  }

  // Rest of the code remains unchanged...
  static Future<void> shareReceipt(
      OrderModel order, MerchantModel merchant) async {
    try {
      final receiptText = await _generateReceiptText(order, merchant);
      final file = await _createTempFile(receiptText);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Struk Pesanan #${order.orderNumber}',
      );
      Get.snackbar(
        'Sukses',
        'Struk berhasil dibagikan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error sharing receipt: $e');
      Get.snackbar(
        'Error',
        'Gagal membagikan struk: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  static Future<String> _generateReceiptText(
      OrderModel order, MerchantModel merchant) async {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    // Merchant Header
    buffer.writeln(merchant.name.toUpperCase());
    buffer.writeln(merchant.address);
    buffer.writeln('Telp: ${merchant.phoneNumber}');
    buffer.writeln(_shortSeparator);

    // Order Info
    buffer.writeln('#${order.orderNumber}');
    buffer.writeln(dateFormat.format(order.createdAt));
    buffer.writeln('Status: ${order.statusDisplay}');
    buffer.writeln(_shortSeparator);

    // Customer Info
    buffer.writeln(order.customerName);
    buffer.writeln(order.customerPhone);

    // Delivery Info
    if (order.customer.deliveryAddress != null) {
      final address = order.customer.deliveryAddress!;
      buffer.writeln('Kirim ke: ${address.customerName}');
      buffer.writeln(address.address);
      buffer.writeln('${address.district}, ${address.city}');
      if (address.notes?.isNotEmpty ?? false) {
        buffer.writeln('Note: ${address.notes}');
      }
    }
    buffer.writeln(_shortSeparator);

    // Items
    for (var item in order.items) {
      buffer.writeln('${item.quantity}x ${item.product.name}');
      if (item.variant != null) {
        buffer.writeln(' +${item.variant!.name}');
      }
      if (item.customerNote?.isNotEmpty ?? false) {
        buffer.writeln(' *${item.customerNote}');
      }
      buffer.writeln(_padPrice('', _formatPrice(item.formattedPrice)));
    }
    buffer.writeln(_shortSeparator);

    // Payment Details
    buffer
        .writeln(_padPrice('Subtotal', _formatPrice(order.formattedSubtotal)));
    buffer.writeln(
        _padPrice('Ongkir', _formatPrice(order.formattedShippingCost)));
    if (order.discount != null && order.discount! > 0) {
      buffer.writeln(
          _padPrice('Diskon', '-${_formatPrice(order.formattedDiscount)}'));
    }
    buffer.writeln(_shortSeparator);
    buffer.writeln(_padPrice('TOTAL', _formatPrice(order.formattedTotal)));
    buffer.writeln(order.paymentMethod);

    // Footer
    buffer.writeln(_separator);
    if (merchant.description?.isNotEmpty ?? false) {
      buffer.writeln(merchant.description);
    }
    buffer.writeln('Terima kasih');

    return buffer.toString();
  }

  static Future<File> _createTempFile(String content) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/receipt_$timestamp.txt');
    await file.writeAsString(content);
    return file;
  }
}
