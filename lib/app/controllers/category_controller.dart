import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/product_category_model.dart';
import 'package:antarkanma_merchant/app/data/providers/category_provider.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';

class CategoryController extends GetxController {
  final CategoryProvider _provider = CategoryProvider();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storage = StorageService.instance;

  static const String CATEGORIES_STORAGE_KEY = 'categories';
  final RxList<ProductCategory> categories = <ProductCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = "Semua".obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  void updateSelectedCategory(String category) {
    selectedCategory.value = category;
    update();
  }

  Future<List<ProductCategory>> getCategories() async {
    // Try to load from local storage first
    final storedCategories = _storage.getList(CATEGORIES_STORAGE_KEY);
    if (storedCategories != null) {
      categories.value =
          storedCategories.map((json) => ProductCategory.fromJson(json)).toList();
    }

    try {
      isLoading.value = true;
      final token = _authService.getToken();
      if (token == null) return [];

      final response = await _provider.getCategories(token);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<ProductCategory> newCategories =
            data.map((json) => ProductCategory.fromJson(json)).toList();

        categories.value = newCategories;

        // Save to local storage
        await _storage.saveList(CATEGORIES_STORAGE_KEY,
            newCategories.map((cat) => cat.toJson()).toList());
      }
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
    return categories;
  }

  Future<void> refreshCategories() async {
    await getCategories();
  }

  ProductCategory? findCategoryById(int id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  ProductCategory? findCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  void resetSelection() {
    selectedCategory.value = "Semua";
    update();
  }

  bool isCategorySelected(String categoryName) {
    return selectedCategory.value == categoryName;
  }
}
