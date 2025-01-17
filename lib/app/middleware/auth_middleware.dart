import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/routes/app_pages.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    if (authService.currentUser.value == null) {
      // User not logged in, redirect to login
      return RouteSettings(name: Routes.login);
    }

    // User logged in, allow access
    return null;
  }
}
