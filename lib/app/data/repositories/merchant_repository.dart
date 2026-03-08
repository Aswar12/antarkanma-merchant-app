import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/paginated_response.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:image_picker/image_picker.dart';

class MerchantRepository {
  final MerchantService _merchantService = Get.find<MerchantService>();

  /// Get current merchant info
  Future<MerchantModel?> getMerchantInfo() async {
    try {
      return await _merchantService.getMerchant();
    } catch (e) {
      debugPrint('❌ [MerchantRepository] getMerchantInfo error: $e');
      rethrow;
    }
  }

  /// Update merchant status (ACTIVE/INACTIVE)
  Future<bool> updateStatus(String status) async {
    try {
      return await _merchantService.updateStatus(status);
    } catch (e) {
      debugPrint('❌ [MerchantRepository] updateStatus error: $e');
      rethrow;
    }
  }

  /// Update merchant details (name, address, phone, description)
  Future<bool> updateMerchantDetails({
    String? name,
    String? address,
    String? phoneNumber,
    String? description,
  }) async {
    try {
      return await _merchantService.updateMerchantDetails(
        name: name,
        address: address,
        phoneNumber: phoneNumber,
        description: description,
      );
    } catch (e) {
      debugPrint('❌ [MerchantRepository] updateMerchantDetails error: $e');
      rethrow;
    }
  }

  /// Update operating hours
  Future<bool> updateOperationalHours(
    String openingTime,
    String closingTime,
    List<String> operatingDays,
  ) async {
    try {
      return await _merchantService.updateOperationalHours(
        openingTime,
        closingTime,
        operatingDays,
      );
    } catch (e) {
      debugPrint('❌ [MerchantRepository] updateOperationalHours error: $e');
      rethrow;
    }
  }

  /// Get merchant products (paginated)
  Future<PaginatedResponse<ProductModel>> getMerchantProducts({
    int page = 1,
    int pageSize = 10,
    String? query,
    String? category,
  }) async {
    try {
      return await _merchantService.getMerchantProducts(
        page: page,
        pageSize: pageSize,
        query: query,
        category: category,
      );
    } catch (e) {
      debugPrint('❌ [MerchantRepository] getMerchantProducts error: $e');
      rethrow;
    }
  }

  /// Create a new product — returns true on success
  Future<bool> createProduct(
    Map<String, dynamic> productData,
    List<XFile> images,
  ) async {
    try {
      return await _merchantService.createProduct(productData, images);
    } catch (e) {
      debugPrint('❌ [MerchantRepository] createProduct error: $e');
      rethrow;
    }
  }

  /// Update an existing product — returns true on success
  Future<bool> updateProduct(
    int productId,
    Map<String, dynamic> productData,
    List<XFile> newImages,
  ) async {
    try {
      return await _merchantService.updateProduct(
          productId, productData, newImages);
    } catch (e) {
      debugPrint('❌ [MerchantRepository] updateProduct error: $e');
      rethrow;
    }
  }

  /// Delete a product — returns {success: bool, message: String}
  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      return await _merchantService.deleteProduct(productId);
    } catch (e) {
      debugPrint('❌ [MerchantRepository] deleteProduct error: $e');
      rethrow;
    }
  }

  /// Clear product cache
  Future<void> clearCache() async {
    _merchantService.clearCache();
  }
}
