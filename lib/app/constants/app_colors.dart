import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
  // lib/app/constants/app_colors.dart (lanjutan)
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondaryDark = Color(0xFF0288D1);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFB300);
  static const Color infoDark = Color(0xFF42A5F5);
  static const Color errorColor = Color(0xFFFF3B3B);
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1976D2),
    ],
  );

  // Status Colors
  static const Color orderPending = Color(0xFFFFA000);
  static const Color orderProcessing = Color(0xFF1E88E5);
  static const Color orderCompleted = Color(0xFF43A047);
  static const Color orderCanceled = Color(0xFFE53935);

  // Payment Status Colors
  static const Color paymentPending = Color(0xFFFFA000);
  static const Color paymentCompleted = Color(0xFF43A047);
  static const Color paymentFailed = Color(0xFFE53935);

  // Delivery Status Colors
  static const Color deliveryPending = Color(0xFFFFA000);
  static const Color deliveryInProgress = Color(0xFF1E88E5);
  static const Color deliveryCompleted = Color(0xFF43A047);
  static const Color deliveryCanceled = Color(0xFFE53935);

  // Rating Colors
  static const Color ratingLow = Color(0xFFE53935);
  static const Color ratingMedium = Color(0xFFFFA000);
  static const Color ratingHigh = Color(0xFF43A047);

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);
  static const Color twitter = Color(0xFF1DA1F2);

  // Transparency Colors
  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color black38 = Colors.black38;
  static const Color black45 = Colors.black45;
  static const Color black54 = Colors.black54;
  static const Color black87 = Colors.black87;

  static const Color white12 = Colors.white12;
  static const Color white24 = Colors.white24;
  static const Color white38 = Colors.white38;
  static const Color white54 = Colors.white54;
  static const Color white70 = Colors.white70;
}

// Lalu buat file untuk constants lainnya
// lib/app/constants/app_values.dart
