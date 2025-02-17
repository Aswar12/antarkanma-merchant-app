import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/variant_model.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';

class CartItemModel {
  final ProductModel product;
  final MerchantModel merchant; // Tidak nullable
  int quantity;
  final VariantModel? selectedVariant;
  bool isSelected;

  CartItemModel({
    required this.product,
    required this.merchant,
    required this.quantity,
    this.selectedVariant,
    this.isSelected = false,
  });

  // Getter untuk harga per item
  double get price {
    double basePrice = product.price;
    if (selectedVariant != null) {
      basePrice += selectedVariant!.priceAdjustment;
    }
    return basePrice;
  }

  // Getter untuk total harga (harga × kuantitas)
  double get totalPrice => price * quantity;

  // Getter untuk variant ID
  int? get selectedVariantId => selectedVariant?.id;

  // Method untuk mengkonversi objek ke JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'merchant': merchant.toJson(),
      'quantity': quantity,
      'selectedVariant': selectedVariant?.toJson(),
      'isSelected': isSelected,
    };
  }

  // Factory constructor untuk membuat objek dari JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']),
      merchant: MerchantModel.fromJson(json['merchant']),
      quantity: json['quantity'] as int,
      selectedVariant: json['selectedVariant'] != null
          ? VariantModel.fromJson(json['selectedVariant'])
          : null,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  // Method untuk mengupdate quantity
  CartItemModel copyWithQuantity(int newQuantity) {
    return CartItemModel(
      product: product,
      merchant: merchant,
      quantity: newQuantity,
      selectedVariant: selectedVariant,
    );
  }

  // Method untuk mengupdate variant
  CartItemModel copyWithVariant(VariantModel? newVariant) {
    return CartItemModel(
      product: product,
      merchant: merchant,
      quantity: quantity,
      selectedVariant: newVariant,
    );
  }
}
