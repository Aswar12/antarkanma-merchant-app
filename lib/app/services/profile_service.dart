import 'package:antarkanma_merchant/app/data/providers/profile_provider.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

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
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
      };

      if (data.isEmpty) return false;

      final token = _authService.getToken();
      if (token == null) {
        print('Error: No auth token available');
        return false;
      }

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
      if (token == null) {
        print('Error: No auth token available');
        return false;
      }

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
      if (token == null) {
        print('Error: No auth token available');
        return false;
      }

      // Validate operating days
      if (operatingDays.isEmpty) {
        print('Error: No operating days provided');
        return false;
      }

      // Ensure unique days and maximum of 7 days
      final uniqueDays = operatingDays.toSet().toList();
      if (uniqueDays.length > 7) {
        print('Error: More than 7 operating days provided');
        return false;
      }

      // Convert days to lowercase and sort them for consistency
      final formattedDays = uniqueDays
          .map((day) => day.toLowerCase().trim())
          .where((day) => day.isNotEmpty)
          .toList()
        ..sort();

      print('Updating operating hours:');
      print('- Opening time: $openingTime');
      print('- Closing time: $closingTime');
      print('- Operating days: $formattedDays');

      // Create the request data
      final data = {
        'opening_time': openingTime,
        'closing_time': closingTime,
        'operating_days': formattedDays, // Send as array
      };

      print('Request data: $data'); // Debug log

      final response = await _profileProvider.updateMerchantProfile(
        token,
        merchantId,
        data,
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response data: ${response.data}'); // Debug log

      final success = response.statusCode == 200 &&
          response.data?['meta']?['status'] == 'success';

      if (success) {
        print('Successfully updated operating hours');
      } else {
        print('Failed to update operating hours:');
        print('Status code: ${response.statusCode}');
        print('Response data: ${response.data}');

        if (response.statusCode != null && response.statusCode! >= 500) {
          throw 'Server error occurred. Please try again later.';
        }
      }

      return success;
    } catch (e) {
      print('Error updating operating hours: $e');
      throw e.toString(); // Propagate the error message
    }
  }

  Future<bool> updateMerchantLogo(int merchantId, String imagePath) async {
    try {
      final token = _authService.getToken();
      if (token == null) {
        print('Error: No auth token available');
        return false;
      }

      print('Attempting to upload logo for merchant $merchantId');
      print('Image path: $imagePath');

      final response = await _profileProvider.updateMerchantLogo(
        token,
        merchantId,
        imagePath,
      );

      // Log response details
      print('Logo upload response status: ${response.statusCode}');
      print('Logo upload response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data?['meta']?['status'] == 'success') {
          print('Logo upload successful');
          return true;
        } else {
          print('Logo upload failed: ${response.data?['meta']?['message']}');
          throw response.data?['meta']?['message'] ?? 'Unknown error occurred';
        }
      } else {
        print('Logo upload failed with status ${response.statusCode}');
        if (response.data is Map) {
          print('Error details: ${response.data}');
        }
        throw 'Server returned status code ${response.statusCode}';
      }
    } on DioException catch (e) {
      print('DioError during logo upload:');
      print('- Type: ${e.type}');
      print('- Message: ${e.message}');
      print('- Response: ${e.response?.data}');
      print('- Status code: ${e.response?.statusCode}');
      throw e.message ?? 'Network error occurred';
    } catch (e) {
      print('Unexpected error during logo upload: $e');
      throw e.toString();
    }
  }
}
