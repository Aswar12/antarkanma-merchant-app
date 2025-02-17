import 'package:antarkanma_merchant/app/controllers/merchant_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/app/data/models/variant_model.dart';
import 'package:antarkanma_merchant/app/data/models/product_category_model.dart';
import 'package:antarkanma_merchant/app/services/merchant_service.dart';
import 'package:antarkanma_merchant/app/services/category_service.dart';
import 'package:antarkanma_merchant/app/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:antarkanma_merchant/app/modules/merchant/views/merchant_main_page.dart';
import 'package:antarkanma_merchant/app/utils/thousand_separator_formatter.dart';

class MerchantProductFormController extends GetxController {
  final MerchantService merchantService;
  final CategoryService _categoryService = Get.find<CategoryService>();
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final selectedCategoryId = RxnInt();
  final selectedCategoryName = RxnString();
  final categories = <ProductCategory>[].obs;
  final variants = <VariantModel>[].obs;
  final isActive = true.obs;
  final images = <XFile>[].obs;
  final existingImages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final canSave = false.obs;
  final isEditing = false.obs;

  int? currentProductId;

  MerchantProductFormController({required this.merchantService});

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void _updateCanSave() {
    canSave.value = nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        (images.isNotEmpty || existingImages.isNotEmpty);
    update();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final loadedCategories = await _categoryService.fetchCategories();
      categories.assignAll(loadedCategories);
    } catch (e) {
      print('Error loading categories: $e');
      errorMessage.value = 'Failed to load categories: $e';
      CustomSnackbarX.showError(message: 'Failed to load categories');
    }
    isLoading.value = false;
    update();
  }

  void setInitialData(Map<String, dynamic>? product) {
    if (product != null) {
      isEditing.value = true;
      currentProductId = product['id'];
      nameController.text = product['name'] ?? '';
      descriptionController.text = product['description'] ?? '';

      if (product['price'] != null) {
        double price = (product['price'] is int)
            ? product['price'].toDouble()
            : product['price'];
        priceController.text =
            NumberFormat.decimalPattern('id_ID').format(price);
      }

      if (product['category'] != null) {
        selectedCategoryId.value = product['category']['id'];
        selectedCategoryName.value = product['category']['name'];
      }

      if (product['variants'] != null) {
        variants.assignAll(
          (product['variants'] as List)
              .map((v) => VariantModel.fromJson(v))
              .toList(),
        );
      }

      if (product['gallery'] != null) {
        final gallery = product['gallery'] as List;
        existingImages.assignAll(
          gallery
              .map((img) => {
                    'id': img['id'],
                    'url': img['url'],
                  })
              .toList(),
        );
      } else if (product['imageUrls'] != null) {
        final urls = List<String>.from(product['imageUrls']);
        existingImages.assignAll(
          urls.map((url) => {'url': url}).toList(),
        );
      }

      isActive.value = product['status'] ?? true;
      _updateCanSave();
    }
  }

  void setCategory(ProductCategory category) {
    selectedCategoryId.value = category.id;
    selectedCategoryName.value = category.name;
    update();
  }

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage();
      if (selectedImages.isNotEmpty) {
        images.addAll(selectedImages);
        _updateCanSave();
      }
    } catch (e) {
      print('Error picking images: $e');
      CustomSnackbarX.showError(message: 'Error picking images: $e');
    }
  }

  Future<void> removeImage(int index, {bool isExisting = false}) async {
    try {
      if (isExisting) {
        if (index >= 0 && index < existingImages.length) {
          final imageData = existingImages[index];
          if (imageData['id'] != null && currentProductId != null) {
            final result = await merchantService.deleteProductGallery(
              currentProductId!,
              imageData['id'],
            );
            if (result['success']) {
              existingImages.removeAt(index);
              CustomSnackbarX.showSuccess(
                  message: 'Image deleted successfully');
            } else {
              CustomSnackbarX.showError(message: result['message']);
              return;
            }
          } else {
            existingImages.removeAt(index);
          }
        }
      } else {
        if (index >= 0 && index < images.length) {
          images.removeAt(index);
        }
      }
      _updateCanSave();
    } catch (e) {
      print('Error removing image: $e');
      CustomSnackbarX.showError(message: 'Error removing image: $e');
    }
  }

  Future<bool> updateGalleryImage(int galleryId, String newImagePath) async {
    try {
      if (currentProductId == null) return false;

      final result = await merchantService.updateProductGallery(
        currentProductId!,
        galleryId,
        newImagePath,
      );

      if (result['success']) {
        final index =
            existingImages.indexWhere((img) => img['id'] == galleryId);
        if (index != -1 && result['data'] != null) {
          existingImages[index] = {
            'id': galleryId,
            'url': result['data']['url'],
          };
          update();
        }
        return true;
      } else {
        errorMessage.value = result['message'];
        return false;
      }
    } catch (e) {
      print('Error updating gallery image: $e');
      return false;
    }
  }

  void addVariant(VariantModel variant) {
    variants.add(variant);
    update();
  }

  void updateVariant(int index, VariantModel variant) {
    if (index >= 0 && index < variants.length) {
      variants[index] = variant;
      update();
    }
  }

  void removeVariant(VariantModel variant) {
    variants.remove(variant);
    update();
  }

  Future<void> _navigateToProductPage() async {
    // Schedule the state updates for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final merchantController = Get.find<MerchantController>();
      merchantController.currentIndex.value = 2;
      
      await Get.offAll(
        () => const MerchantMainPage(),
        transition: Transition.noTransition,
      );

      // Fetch data after navigation is complete
      await merchantController.fetchMerchantData(forceRefresh: true);
    });
  }

  Future<bool> saveProduct() async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedCategoryId.value == null) {
      errorMessage.value = 'Pilih kategori produk';
      CustomSnackbarX.showError(message: 'Pilih kategori produk');
      return false;
    }
    if (images.isEmpty && existingImages.isEmpty) {
      errorMessage.value = 'Tambahkan minimal 1 foto produk';
      CustomSnackbarX.showError(message: 'Tambahkan minimal 1 foto produk');
      return false;
    }

    try {
      isLoading.value = true;
      update();

      double price = ThousandsSeparatorInputFormatter.getNumericValue(
          priceController.text);

      final productData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'price': price,
        'category_id': selectedCategoryId.value,
        'status': isActive.value ? 'ACTIVE' : 'INACTIVE',
        'variants': variants.map((v) => v.toJson()).toList(),
      };

      bool result;
      if (isEditing.value && currentProductId != null) {
        productData['id'] = currentProductId;
        productData['existing_images'] =
            existingImages.map((img) => img['url']).toList();
        result = await merchantService.updateProduct(
            currentProductId!, productData, images);
      } else {
        result = await merchantService.createProduct(productData, images);
      }

      isLoading.value = false;
      update();

      if (result) {
        CustomSnackbarX.showSuccess(
            title: 'Sukses',
            message: isEditing.value
                ? 'Produk berhasil diperbarui'
                : 'Produk berhasil ditambahkan');
        
        // Navigate after showing success message
        await _navigateToProductPage();
        return true;
      } else {
        errorMessage.value = 'Gagal menyimpan produk';
        CustomSnackbarX.showError(
            title: 'Error', message: 'Gagal menyimpan produk');
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      update();
      errorMessage.value = 'Gagal menyimpan produk: $e';
      CustomSnackbarX.showError(
          title: 'Error', message: 'Gagal menyimpan produk: $e');
      return false;
    }
  }
}
