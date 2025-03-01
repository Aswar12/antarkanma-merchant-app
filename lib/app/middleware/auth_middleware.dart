import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storageService = StorageService.instance;
    
    // Check if we have a valid token
    final token = storageService.getToken();
    if (token == null) {
      return const RouteSettings(name: Routes.login);
    }

    // Check if we have valid user data
    final userData = storageService.getUser();
    if (userData == null) {
      return const RouteSettings(name: Routes.login);
    }

    // Check if user is a merchant
    final userRole = userData['roles']?.toString().toUpperCase();
    if (userRole != 'MERCHANT') {
      return const RouteSettings(name: Routes.login);
    }

    // If all checks pass, allow access
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }
}
