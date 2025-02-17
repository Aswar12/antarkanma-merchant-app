import 'package:antarkanma_merchant/app/data/models/product_model.dart';
import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:intl/intl.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int? productVariantId;
  final int merchantId;
  final int quantity;
  final double price;
  final double subtotal;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductModel product;
  final MerchantModel merchant;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productVariantId,
    required this.merchantId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
    required this.merchant,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      productVariantId: json['product_variant_id'],
      merchantId: json['merchant_id'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      product: ProductModel.fromJson(json['product']),
      merchant: MerchantModel.fromJson(json['merchant']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_variant_id': productVariantId,
      'merchant_id': merchantId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product': product.toJson(),
      'merchant': merchant.toJson(),
    };
  }

  String get formattedPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  String get formattedTotalPrice {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(subtotal);
  }

  bool validate() {
    return quantity > 0 && price > 0;
  }
}
