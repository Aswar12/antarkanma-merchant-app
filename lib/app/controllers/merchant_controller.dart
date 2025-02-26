import 'package:get/get.dart';
import '../data/models/merchant_model.dart';
import '../services/merchant_service.dart';
import '../services/auth_service.dart';
import '../routes/app_pages.dart';

class MerchantController extends GetxController {
  final MerchantService _merchantService;
  final AuthService _authService;

  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var merchant = Rx<MerchantModel?>(null);
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var lastFetchTime = DateTime.now().obs;
  final cacheValidityDuration = const Duration(minutes: 5);
  bool _isInitialized = false;
  bool _isPageChangeInProgress = false;

  MerchantController({
    required MerchantService merchantService,
    required AuthService authService,
  })  : _merchantService = merchantService,
        _authService = authService;

  @override
  void onInit() {
    super.onInit();
    if (!_isInitialized) {
      print("MerchantController onInit called");
      _initializeData();
      _isInitialized = true;
    }
  }

  void _initializeData() {
    // Listen to auth changes
    ever(_authService.currentUser, (user) {
      if (user != null && merchant.value == null) {
        fetchMerchantData();
      }
    });

    // Initial fetch if user is already logged in
    if (_authService.currentUser.value != null) {
      fetchMerchantData();
    }
  }

  bool _shouldRefreshData() {
    if (merchant.value == null) return true;
    return DateTime.now().difference(lastFetchTime.value) >
        cacheValidityDuration;
  }

  Future<void> fetchMerchantData({bool forceRefresh = false}) async {
    // Return cached data if available and still valid
    if (!forceRefresh && !_shouldRefreshData()) {
      return;
    }

    if (isLoading.value) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await _merchantService.getMerchant();

      if (data != null) {
        merchant.value = data;
        lastFetchTime.value = DateTime.now();
        print("Merchant data fetched successfully: ${data.name}");
      } else {
        hasError.value = true;
        errorMessage.value = 'Tidak dapat memuat data merchant';
      }
    } catch (e) {
      print("Error fetching merchant data: $e");
      hasError.value = true;
      errorMessage.value = 'Terjadi kesalahan saat memuat data';
    } finally {
      isLoading.value = false;
    }
  }

  void changePage(int index) {
    if (!_isPageChangeInProgress && currentIndex.value != index) {
      print("MerchantController changing page to: $index");
      _isPageChangeInProgress = true;
      currentIndex.value = index;
      _isPageChangeInProgress = false;
      
      // Refresh data when switching to products tab
      if (index == 2 && _shouldRefreshData()) {
        fetchMerchantData();
      }
    }
  }

  // Getter for merchant name with loading state handling
  String get merchantName => merchant.value?.name ?? '';

  // Method to refresh data after updates
  Future<void> refreshData() async {
    await fetchMerchantData(forceRefresh: true);
  }

  @override
  void onClose() {
    _isInitialized = false;
    _isPageChangeInProgress = false;
    super.onClose();
  }
}
