import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/user_model.dart';
import 'package:antarkanma_merchant/app/services/user_service.dart';

class UserRepository {
  final UserService _userService = Get.find<UserService>();

  /// Get current user profile
  Future<UserModel?> getProfile() async {
    try {
      return await _userService.getUserProfile();
    } catch (e) {
      debugPrint('❌ [UserRepository] getProfile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    String? email,
    String? phoneNumber,
    String? username,
    String? profileImageUrl,
  }) async {
    try {
      return await _userService.updateUserProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        username: username,
        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      debugPrint('❌ [UserRepository] updateProfile error: $e');
      rethrow;
    }
  }

  /// Upload profile image and return URL
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      return await _userService.uploadProfileImage(imagePath);
    } catch (e) {
      debugPrint('❌ [UserRepository] uploadProfileImage error: $e');
      rethrow;
    }
  }
}
