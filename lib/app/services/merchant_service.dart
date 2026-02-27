import 'dart:convert';
import 'package:antarkanma_merchant/app/data/providers/merchant_provider.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/paginated_response.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:antarkanma_merchant/app/services/product_service.dart';
import 'package:antarkanma_merchant/config.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class MerchantService {
  final MerchantProvider _merchantProvider;
  final AuthService _authService;
  final StorageService _storageService;
  final ProductService _productService;
  final GetStorage _storage;
  final Dio _dio;

  // Storage keys
  static const String _merchantProductsKey = 'merchant_products_by_page';
  static const String _merchantProductsMetadataKey =
      'merchant_products_metadata';
  static const String _lastRefreshKey = 'merchant_last_refresh';

  // Optimization constants
  static const int maxStoredPages = 20;
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration requestThrottle = Duration(milliseconds: 500);

  DateTime? _lastRequestTime;
  final Map<int, DateTime> _pageLastAccess = {};
  bool _prefetchInProgress = false;

  MerchantService({
    MerchantProvider? merchantProvider,
    AuthService? authService,
    StorageService? storageService,
    ProductService? productService,
    GetStorage? storage,
  })  : _merchantProvider = merchantProvider ?? MerchantProvider(),
        _authService = authService ?? Get.find<AuthService>(),
        _storageService = storageService ?? StorageService.instance,
        _productService = productService ?? Get.find<ProductService>(),
        _storage = storage ?? GetStorage(),
        _dio = Dio(BaseOptions(baseUrl: Config.baseUrl));

  get token => _authService.getToken();
  Map<String, dynamic>? get user => _storageService.getUser();
  int? get ownerId =>
      user != null ? int.tryParse(user!['id'].toString()) : null;

  MerchantModel? _currentMerchant;

  // New methods for order approval/rejection
  Future<bool> approveOrder(String orderId) async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) {
          throw Exception('Failed to get merchant information');
        }
      }

      final response = await _dio.put(
        '/api/merchants/orders/$orderId/approve',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'merchant_id': _currentMerchant!.id,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error approving order: $e');
      return false;
    }
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) {
          throw Exception('Failed to get merchant information');
        }
      }

      final response = await _dio.put(
        '/api/merchants/orders/$orderId/reject',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'merchant_id': _currentMerchant!.id,
          'reason': reason,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error rejecting order: $e');
      return false;
    }
  }

  Future<MerchantModel?> getMerchant() async {
    try {
      // First check if we have valid user data
      final userData = _storageService.getUser();
      print('=== getMerchant() called ===');
      print('User data from storage: $userData');

      if (userData == null) {
        print(
            "User data is null. User not logged in, skipping merchant fetch.");
        return null;
      }

      // Get owner ID from user data - check multiple possible keys
      int? ownerId;
      final userId = userData['id'];
      final ownerIdFromUser = userData['owner_id'] ?? userData['ownerId'];

      if (userId != null) {
        ownerId = int.tryParse(userId.toString());
        print('Using user ID as owner ID: $ownerId');
      } else if (ownerIdFromUser != null) {
        ownerId = int.tryParse(ownerIdFromUser.toString());
        print('Using owner_id: $ownerId');
      }
      
      if (ownerId == null) {
        print("Owner ID is null. Cannot fetch merchant data.");
        print("Available user data keys: ${userData.keys.toList()}");
        return null;
      }

      print('Fetching merchant data for owner ID: $ownerId');
      
      final response =
          await _merchantProvider.getMerchantsByOwnerId(token, ownerId);

      print('Merchant API response status: ${response.statusCode}');
      print('Merchant API response data: ${response.data}');

      if (response.statusCode != 200) {
        print('Failed to fetch merchant: HTTP ${response.statusCode}');
        return null;
      }

      if (response.data == null) {
        print('Response data is null');
        return null;
      }

      // Handle both array and single object responses
      var merchantData;
      final responseData = response.data['data'];

      if (responseData == null) {
        print('No merchant data in response');
        return null;
      }

      if (responseData is List) {
        if (responseData.isEmpty) {
          print('Empty merchant list returned');
          return null;
        }
        merchantData = responseData[0];
      } else if (responseData is Map) {
        merchantData = responseData;
      } else {
        print('Unexpected merchant data format: ${response.data}');
        return null;
      }

      try {
        _currentMerchant = MerchantModel.fromJson(merchantData);
        print('Merchant loaded successfully: ${_currentMerchant?.name}');
        return _currentMerchant;
      } catch (e) {
        print('Error parsing merchant data: $e');
        print('Merchant data: $merchantData');
        return null;
      }
    } catch (e) {
      print('Error fetching merchant: $e');
      return null;
    }
  }

  Future<PaginatedResponse<ProductModel>> getMerchantProducts({
    int page = 1,
    int pageSize = 10,
    String? query,
    String? category,
  }) async {
    try {
      // Try to get merchant if not cached
      if (_currentMerchant?.id == null) {
        print('No cached merchant, attempting to fetch...');
        final merchant = await getMerchant();
        if (merchant == null) {
          print('Could not fetch merchant - returning empty response');
          // Return empty response instead of throwing exception
          return PaginatedResponse(data: [], hasMore: false);
        }
      }

      if (_lastRequestTime != null) {
        final timeSinceLastRequest =
            DateTime.now().difference(_lastRequestTime!);
        if (timeSinceLastRequest < requestThrottle) {
          await Future.delayed(requestThrottle - timeSinceLastRequest);
        }
      }

      // Only use cache if no filters are applied
      if (query == null && category == null) {
        final cachedProducts = _getPageFromStorage(page);
        if (cachedProducts != null) {
          print('Loading merchant products page $page from cache');
          _prefetchNextPage(page, pageSize);
          return PaginatedResponse(
            data: cachedProducts,
            currentPage: page,
            hasMore: true,
          );
        }
      }

      Map<String, dynamic>? queryParams;
      if (query != null || category != null) {
        queryParams = {};
        if (query != null && query.isNotEmpty) {
          queryParams['name'] = query;
        }
        if (category != null && category != 'Semua') {
          queryParams['category'] = category;
        }
      }

      final response = await _merchantProvider.getMerchantProducts(
        token,
        _currentMerchant!.id!,
        page: page,
        pageSize: pageSize,
        queryParams: queryParams,
      );

      final paginatedResponse = PaginatedResponse<ProductModel>.fromJson(
        response.data,
        (json) => ProductModel.fromJson(json),
      );

      // Only cache if no filters are applied
      if (query == null && category == null) {
        await _savePageToStorage(page, paginatedResponse.data);
        _prefetchNextPage(page, pageSize);
      }

      return paginatedResponse;
    } catch (e) {
      print('Error fetching merchant products: $e');
      return PaginatedResponse(data: [], hasMore: false);
    } finally {
      _lastRequestTime = DateTime.now();
    }
  }

  Future<bool> createProduct(
      Map<String, dynamic> productData, List<XFile> images) async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) {
          throw Exception('Failed to get merchant information');
        }
      }

      final productResponse = await _merchantProvider.createProduct(
        token,
        _currentMerchant!.id!,
        productData,
      );

      if (productResponse.data == null ||
          productResponse.data['meta'] == null ||
          productResponse.data['meta']['status'] != 'success') {
        throw Exception(productResponse.data?['meta']?['message'] ??
            'Failed to create product');
      }

      final createdProductData = productResponse.data['data'];
      final productId = createdProductData['id'];

      if (images.isNotEmpty) {
        final imagePaths = images.map((image) => image.path).toList();
        final galleryResponse = await _merchantProvider.uploadProductGallery(
          token,
          productId,
          imagePaths,
        );

        if (galleryResponse.data == null ||
            galleryResponse.data['meta'] == null ||
            galleryResponse.data['meta']['status'] != 'success') {
          throw Exception(galleryResponse.data?['meta']?['message'] ??
              'Failed to upload gallery');
        }

        if (galleryResponse.data['data'] != null) {
          createdProductData['gallery'] = galleryResponse.data['data'];
        }
      }

      final product = ProductModel.fromJson(createdProductData);
      _productService.addProductToLocal(product);
      await clearCache();
      return true;
    } catch (e) {
      print('Error creating product: $e');
      return false;
    }
  }

  Future<bool> updateProduct(int productId, Map<String, dynamic> productData,
      List<XFile> newImages) async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) {
          throw Exception('Failed to get merchant information');
        }
      }

      final productResponse = await _merchantProvider.updateProduct(
        token,
        productId,
        productData,
      );

      if (productResponse.data == null ||
          productResponse.data['meta'] == null ||
          productResponse.data['meta']['status'] != 'success') {
        throw Exception(productResponse.data?['meta']?['message'] ??
            'Failed to update product');
      }

      if (newImages.isNotEmpty) {
        final imagePaths = newImages.map((image) => image.path).toList();
        final galleryResponse = await _merchantProvider.uploadProductGallery(
          token,
          productId,
          imagePaths,
        );

        if (galleryResponse.data == null ||
            galleryResponse.data['meta'] == null ||
            galleryResponse.data['meta']['status'] != 'success') {
          throw Exception(galleryResponse.data?['meta']?['message'] ??
              'Failed to upload gallery');
        }
      }

      await clearCache(); // Clear cache to force refresh of merchant products
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> updateProductGallery(
      int productId, int galleryId, String imagePath) async {
    try {
      final response = await _merchantProvider.updateProductGallery(
        token,
        productId,
        galleryId,
        imagePath,
      );

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        await clearCache(); // Clear cache to force refresh
        return {
          'success': true,
          'message': response.data['meta']['message'] ??
              'Gallery image updated successfully',
          'data': response.data['data']
        };
      } else {
        return {
          'success': false,
          'message': response.data?['meta']?['message'] ??
              'Failed to update gallery image'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error updating gallery image: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteProductGallery(
      int productId, int galleryId) async {
    try {
      final response = await _merchantProvider.deleteProductGallery(
        token,
        productId,
        galleryId,
      );

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        await clearCache(); // Clear cache to force refresh
        return {
          'success': true,
          'message': response.data['meta']['message'] ??
              'Gallery image deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data?['meta']?['message'] ??
              'Failed to delete gallery image'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting gallery image: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final response = await _merchantProvider.deleteProduct(token, productId);

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        await clearCache(); // Clear cache to force refresh
        return {
          'success': true,
          'message':
              response.data['meta']['message'] ?? 'Product deleted successfully'
        };
      } else {
        return {
          'success': false,
          'message':
              response.data?['meta']?['message'] ?? 'Failed to delete product'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error deleting product: $e'};
    }
  }

  Future<bool> updateOperationalHours(String openingTime, String closingTime,
      List<String> operatingDays) async {
    try {
      if (openingTime.isEmpty || closingTime.isEmpty || operatingDays.isEmpty) {
        print('Validation error: All fields must be filled');
        return false;
      }

      final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
      if (!timeRegex.hasMatch(openingTime) ||
          !timeRegex.hasMatch(closingTime)) {
        print('Validation error: Invalid time format. Use HH:mm');
        return false;
      }

      if (_currentMerchant?.id == null) {
        print('Error: Merchant ID not found');
        return false;
      }

      final payload = {
        'opening_time': openingTime,
        'closing_time': closingTime,
        'operating_days': operatingDays,
      };

      final response = await _merchantProvider.updateMerchant(
          token, _currentMerchant!.id!, payload);

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        print('Operational hours updated successfully');
        return true;
      } else {
        print(
            'Failed to update operational hours: ${response.data?['meta']?['message']}');
        return false;
      }
    } catch (e) {
      print('Error updating operational hours: $e');
      return false;
    }
  }

  Future<bool> updateMerchantDetails({
    String? name,
    String? address,
    String? phoneNumber,
    String? description,
  }) async {
    try {
      if (_currentMerchant?.id == null) {
        print('Error: Merchant ID not found');
        return false;
      }

      final payload = {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (description != null) 'description': description,
      };

      if (payload.isEmpty) {
        print('No data to update');
        return false;
      }

      final response = await _merchantProvider.updateMerchant(
          token, _currentMerchant!.id!, payload);

      if (response.data != null &&
          response.data['meta'] != null &&
          response.data['meta']['status'] == 'success') {
        print('Merchant details updated successfully');
        return true;
      } else {
        print(
            'Failed to update merchant details: ${response.data?['meta']?['message']}');
        return false;
      }
    } catch (e) {
      print('Error updating merchant details: $e');
      return false;
    }
  }

  Future<void> _prefetchNextPage(int currentPage, int pageSize) async {
    if (_prefetchInProgress) return;

    try {
      _prefetchInProgress = true;
      final nextPage = currentPage + 1;

      if (_getPageFromStorage(nextPage) != null) return;

      await getMerchantProducts(page: nextPage, pageSize: pageSize);
    } finally {
      _prefetchInProgress = false;
    }
  }

  List<ProductModel>? _getPageFromStorage(int page) {
    try {
      final Map<String, dynamic>? allPages =
          _storage.read(_merchantProductsKey);
      if (allPages != null && allPages.containsKey(page.toString())) {
        final String compressedData = allPages[page.toString()];
        final List<dynamic> pageProducts = jsonDecode(compressedData);

        _updatePageMetadata(page);

        return pageProducts
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error getting page $page from storage: $e');
    }
    return null;
  }

  Future<void> _savePageToStorage(int page, List<ProductModel> products) async {
    try {
      final Map<String, dynamic> allPages =
          _storage.read(_merchantProductsKey) ?? {};

      final String compressedData =
          jsonEncode(products.map((p) => p.toJson()).toList());
      allPages[page.toString()] = compressedData;

      if (allPages.length > maxStoredPages) {
        _removeOldestPage(allPages);
      }

      await _storage.write(_merchantProductsKey, allPages);
      await _updatePageMetadata(page);
    } catch (e) {
      print('Error saving page $page from storage: $e');
    }
  }

  Future<void> _updatePageMetadata(int page) async {
    try {
      final Map<String, dynamic> metadata =
          _storage.read(_merchantProductsMetadataKey) ?? {};
      metadata[page.toString()] = {
        'lastAccess': DateTime.now().toIso8601String(),
        'accessCount': (metadata[page.toString()]?['accessCount'] ?? 0) + 1,
      };
      await _storage.write(_merchantProductsMetadataKey, metadata);
      _pageLastAccess[page] = DateTime.now();
    } catch (e) {
      print('Error updating page metadata: $e');
    }
  }

  void _removeOldestPage(Map<String, dynamic> allPages) {
    if (_pageLastAccess.isEmpty) return;

    final oldestPage = _pageLastAccess.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key
        .toString();

    allPages.remove(oldestPage);
    _pageLastAccess.remove(int.parse(oldestPage));
  }

  Future<bool> updateStatus(String status) async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) throw Exception('Merchant ID not found');
      }

      final response = await _dio.put(
        '/api/merchant/${_currentMerchant!.id}/status',
        data: {'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  Future<bool> extendOperatingHours() async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) throw Exception('Merchant ID not found');
      }

      final response = await _dio.put(
        '/api/merchant/${_currentMerchant!.id}/extend',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error extending hours: $e');
      return false;
    }
  }

  Future<bool> updateProductAvailability(
      List<Map<String, dynamic>> products) async {
    try {
      if (_currentMerchant?.id == null) {
        final merchant = await getMerchant();
        if (merchant == null) throw Exception('Merchant ID not found');
      }

      final response = await _dio.put(
        '/api/merchant/${_currentMerchant!.id}/products/availability',
        data: {'products': products},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating product availability: $e');
      return false;
    }
  }

  Future<void> clearCache() async {
    await _storage.remove(_merchantProductsKey);
    await _storage.remove(_merchantProductsMetadataKey);
    await _storage.remove(_lastRefreshKey);
    _pageLastAccess.clear();
  }
}
