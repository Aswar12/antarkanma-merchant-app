// lib/app/utils/helpers.dart

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:antarkanma_merchant/app/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format currency
  static String formatCurrency(num number) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(number);
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // Format datetime
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(dateTime);
  }

  // Show success snackbar
  static void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      colorText: Get.theme.primaryColor,
      duration: const Duration(seconds: 3),
    );
  }

  // Show error snackbar
  static void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorColor.withOpacity(0.1),
      colorText: AppColors.errorColor,
      duration: const Duration(seconds: 3),
    );
  }

  // Translate error messages
  static String getErrorMessage(String? message) {
    if (message == null) return 'Terjadi kesalahan';

    switch (message.toLowerCase()) {
      // Auth related errors
      case 'invalid credentials':
        return 'Email atau kata sandi salah';
      case 'user not found':
        return 'Pengguna tidak ditemukan';
      case 'invalid email format':
        return 'Format email tidak valid';
      case 'password is required':
        return 'Kata sandi harus diisi';
      case 'email is required':
        return 'Email harus diisi';
      case 'email already exists':
        return 'Email sudah terdaftar';
      case 'weak password':
        return 'Kata sandi terlalu lemah';
      case 'passwords do not match':
        return 'Konfirmasi kata sandi tidak cocok';

      // Network related errors
      case 'no internet connection':
        return 'Tidak ada koneksi internet';
      case 'server error':
        return 'Terjadi kesalahan pada server';
      case 'timeout':
        return 'Koneksi timeout';
      case 'failed to connect to server':
        return 'Gagal terhubung ke server';

      // Order related errors
      case 'order not found':
        return 'Pesanan tidak ditemukan';
      case 'insufficient stock':
        return 'Stok tidak mencukupi';
      case 'invalid order status':
        return 'Status pesanan tidak valid';
      case 'order already processed':
        return 'Pesanan sudah diproses';

      // Product related errors
      case 'product not found':
        return 'Produk tidak ditemukan';
      case 'invalid price':
        return 'Harga tidak valid';
      case 'product unavailable':
        return 'Produk tidak tersedia';
      case 'invalid product quantity':
        return 'Jumlah produk tidak valid';

      // Generic errors
      case 'not authorized':
        return 'Anda tidak memiliki akses';
      case 'forbidden':
        return 'Akses ditolak';
      case 'bad request':
        return 'Permintaan tidak valid';
      case 'not found':
        return 'Data tidak ditemukan'; // Validation errors
      case 'field required':
        return 'Bidang ini harus diisi';
      case 'invalid phone number':
        return 'Nomor telepon tidak valid';
      case 'invalid address':
        return 'Alamat tidak valid';

      // File related errors
      case 'file too large':
        return 'Ukuran file terlalu besar';
      case 'invalid file type':
        return 'Tipe file tidak didukung';
      case 'file upload failed':
        return 'Gagal mengunggah file';

      default:
        return message;
    }
  }

  // Get file extension from path
  static String getFileExtension(String path) {
    return path.split('.').last;
  }

  // Get file name from path
  static String getFileName(String path) {
    return path.split('/').last;
  }

  // Convert file size to readable format
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Check if string is valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if string is valid phone number
  static bool isValidPhone(String phone) {
    return RegExp(r'(^(?:[+0])?[0-9]{10,12}$)').hasMatch(phone);
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if it starts with '0' and replace with '+62'
    if (cleaned.startsWith('0')) {
      cleaned = '+62${cleaned.substring(1)}';
    }

    return cleaned;
  }

  // Check if datetime is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Get relative time (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun yang lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Format number with thousand separator
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Convert hex color string to Color
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Check if app is in dark mode
  static bool isDarkMode() {
    return Get.isDarkMode;
  }

  // Get platform name
  static String getPlatformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'MacOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }

  // Check if string contains only numbers
  static bool isNumeric(String str) {
    return RegExp(r'^-?[0-9]+$').hasMatch(str);
  }

  // Remove all html tags from string
  static String removeHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
