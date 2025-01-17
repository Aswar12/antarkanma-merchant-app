import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';

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

  MerchantController({
    required MerchantService merchantService,
    required AuthService authService,
  })  : _merchantService = merchantService,
        _authService = authService;

  @override
  void onInit() {
    super.onInit();
    print("MerchantController onInit called");
    _initializeData();
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
    currentIndex.value = index;
    // Only fetch data when switching to products tab and data needs refresh
    if (index == 2 && _shouldRefreshData()) {
      fetchMerchantData();
    }
  }

  // Getter for merchant name with loading state handling
  String get merchantName => merchant.value?.name ?? '';

  // Method to refresh data after updates
  Future<void> refreshData() async {
    await fetchMerchantData(forceRefresh: true);
  }
}
