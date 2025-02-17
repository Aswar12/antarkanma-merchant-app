import 'package:antarkanma_merchant/app/data/models/user_model.dart';
import 'package:antarkanma_merchant/app/data/providers/user_provider.dart';
import 'package:get/get.dart';

import './storage_service.dart';
import '../widgets/custom_snackbar.dart';

class UserService extends GetxService {
  final UserProvider _userProvider = UserProvider();
  final StorageService _storage = StorageService.instance;

  Future<UserModel?> getUserProfile() async {
    try {
      final token = _storage.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await _userProvider.getUserProfile(token);

      if (response.statusCode == 200) {
        final userData = response.data['data']['user'];
        return UserModel.fromJson(userData);
      }

      throw Exception(response.data['meta']['message']);
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Failed to get user profile: ${e.toString()}',
          isError: true);
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    String? email,
    String? phoneNumber,
    String? username,
    String? profileImageUrl, // Ensure this parameter is included
  }) async {
    try {
      final token = _storage.getToken();
      if (token == null) throw Exception('Token not found');

      final data = {
        'name': name,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (username != null) 'username': username,
        if (profileImageUrl != null)
          'profile_image_url': profileImageUrl, // Ensure this line is included
      };

      final response = await _userProvider.updateUserProfile(token, data);

      if (response.statusCode == 200) {
        showCustomSnackbar(
            title: 'Success', message: 'Profile updated successfully');
        return true;
      }

      throw Exception(response.data['meta']['message']);
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Failed to update profile: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final token = _storage.getToken();
      if (token == null) throw Exception('Token not found');

      final response = await _userProvider.uploadProfileImage(token, imagePath);

      if (response.statusCode == 200) {
        return response.data['data']
            ['imageUrl']; // Adjust based on your API response
      }

      throw Exception(response.data['meta']['message']);
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Failed to upload image: ${e.toString()}',
          isError: true);
      return '';
    }
  }
}
