import 'package:antarkanma_merchant/app/data/providers/profile_provider.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ProfileService extends GetxService {
  final ProfileProvider _profileProvider;
  final AuthService _authService;

  ProfileService({
    ProfileProvider? profileProvider,
    AuthService? authService,
  })  : _profileProvider = profileProvider ?? ProfileProvider(),
        _authService = authService ?? Get.find<AuthService>();

  Future<bool> updateMerchantProfile({
    required int merchantId,
    String? name,
    String? description,
    String? address,
    String? phoneNumber,
  }) async {
    try {
      final data = {
        if (name != null && name.isNotEmpty) 'name': name,
        if (description != null) 'description': description,
        if (address != null && address.isNotEmpty) 'address': address,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone_number': phoneNumber,
      };

      if (data.isEmpty) return false;

      final token = _authService.getToken();
      if (token == null) return false;

      final response = await _profileProvider.updateMerchantProfile(
        token,
        merchantId,
        data,
      );

      return response.statusCode == 200 &&
             response.data?['meta']?['status'] == 'success';
    } catch (e) {
      print('Error updating merchant profile: $e');
      return false;
    }
  }

  Future<bool> updateMerchantLocation({
    required int merchantId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = _authService.getToken();
      if (token == null) return false;

      final response = await _profileProvider.updateMerchantProfile(
        token,
        merchantId,
        {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return response.statusCode == 200 &&
             response.data?['meta']?['status'] == 'success';
    } catch (e) {
      print('Error updating merchant location: $e');
      return false;
    }
  }

  Future<bool> updateOperatingHours({
    required int merchantId,
    required String openingTime,
    required String closingTime,
    required List<String> operatingDays,
  }) async {
    try {
      final token = _authService.getToken();
      if (token == null) return false;

      final response = await _profileProvider.updateMerchantProfile(
        token,
        merchantId,
        {
          'opening_time': openingTime,
          'closing_time': closingTime,
          'operating_days': operatingDays.join(','),
        },
      );

      return response.statusCode == 200 &&
             response.data?['meta']?['status'] == 'success';
    } catch (e) {
      print('Error updating operating hours: $e');
      return false;
    }
  }

  Future<bool> updateMerchantLogo(int merchantId, String imagePath) async {
    try {
      final token = _authService.getToken();
      if (token == null) return false;

      final response = await _profileProvider.updateMerchantLogo(
        token,
        merchantId,
        imagePath,
      );

      return response.statusCode == 200 &&
             response.data?['meta']?['status'] == 'success';
    } catch (e) {
      print('Error updating merchant logo: $e');
      return false;
    }
  }
}
