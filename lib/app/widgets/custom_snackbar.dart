import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          (isError ? Colors.red : Colors.green).withOpacity(0.95),
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
          color: (backgroundColor ?? (isError ? Colors.red : Colors.green))
              .withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      borderColor: backgroundColor ?? (isError ? Colors.red : Colors.green),
      borderWidth: 1,
      overlayBlur: 0.0,
      overlayColor: Colors.black.withOpacity(0.1),
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
      backgroundColor: Colors.green,
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
      backgroundColor: Colors.red,
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
      backgroundColor: Colors.blue,
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
