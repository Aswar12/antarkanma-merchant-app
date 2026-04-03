import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';

enum SnackbarType { success, error, info, warning }

void showCustomSnackbar({
  required String title,
  required String message,
  bool isError = false,
  Color? backgroundColor,
  SnackPosition? snackPosition,
  Duration? duration,
  Widget? actionButton,
}) {
  // Ensure snackbar is shown after build phase
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition ?? SnackPosition.TOP,
      backgroundColor: backgroundColor ??
          (isError ? AppColors.error : AppColors.success).withValues(alpha: 0.95),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      mainButton: actionButton is TextButton ? actionButton : null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      duration: duration ?? const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: (backgroundColor ?? (isError ? AppColors.error : AppColors.success))
               .withValues(alpha: 0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      borderColor: backgroundColor ?? (isError ? AppColors.error : AppColors.success),
      borderWidth: 1,
      overlayBlur: 0.0,
      overlayColor: Colors.black.withValues(alpha: 0.1),
      onTap: (snack) {
        Get.closeCurrentSnackbar();
      },
      snackStyle: SnackStyle.FLOATING,
    );
  });
}

// Enhanced snackbar methods for more specific use cases
class CustomSnackbarX {
  static void showSuccess({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    Widget? actionButton,
  }) {
    showCustomSnackbar(
      title: title ?? 'Success',
      message: message,
      backgroundColor: AppColors.success,
      snackPosition: position,
      duration: duration,
      actionButton: actionButton,
    );
  }

  static void showError({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    Widget? actionButton,
  }) {
    showCustomSnackbar(
      title: title ?? 'Error',
      message: message,
      isError: true,
      backgroundColor: AppColors.error,
      snackPosition: position,
      duration: duration,
      actionButton: actionButton,
    );
  }

  static void showInfo({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    Widget? actionButton,
  }) {
    showCustomSnackbar(
      title: title ?? 'Information',
      message: message,
      backgroundColor: Colors.blueAccent,
      snackPosition: position,
      duration: duration,
      actionButton: actionButton,
    );
  }

  static void showWarning({
    required String message,
    String? title,
    Duration? duration,
    SnackPosition? position,
    Widget? actionButton,
  }) {
    showCustomSnackbar(
      title: title ?? 'Warning',
      message: message,
      backgroundColor: Colors.orange,
      snackPosition: position,
      duration: duration,
      actionButton: actionButton,
    );
  }
}
