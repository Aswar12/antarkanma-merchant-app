import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/cart_item_model.dart';

class OrderItemStatus {
  static const String pending = 'PENDING';
  static const String canceled = 'CANCELED';
  static const String accepted = 'ACCEPTED';
  static const String processing = 'PROCESSING';
  static const String readyForPickup = 'READY_FOR_PICKUP';
  static const String completed = 'COMPLETED';
  static const String partiallyCompleted = 'PARTIALLY_COMPLETED';
}

class OrderItemModel {
  final int? id;
  final int quantity;
  final double price;
  final ProductInfo product;
  final MerchantInfo merchant;
  final String status;
  final String? cancelReason;
  final DateTime? canceledAt;
  final bool? canCancel;

  OrderItemModel({
    this.id,
    required this.quantity,
    required this.price,
    required this.product,
    required this.merchant,
    this.status = OrderItemStatus.pending,
    this.cancelReason,
    this.canceledAt,
    this.canCancel,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    print('Creating OrderItemModel from JSON: $json');
    try {
      final double parsedPrice = _parsePrice(json['price']) ?? 0.0;

      // Handle response format (when receiving from API)
      if (json['product'] != null) {
        return OrderItemModel(
          id: _parseId(json['id']),
          quantity: _parseQuantity(json['quantity']),
          price: parsedPrice,
          product: ProductInfo.fromJson(json['product']),
          merchant: json['merchant'] != null
              ? MerchantInfo.fromJson(json['merchant'])
              : MerchantInfo.fromJson(json['product']['merchant'] ?? {}),
          status: json['status']?.toString() ?? OrderItemStatus.pending,
          cancelReason: json['cancel_reason']?.toString(),
          canceledAt: json['canceled_at'] != null ? DateTime.parse(json['canceled_at']) : null,
          canCancel: json['can_cancel'] as bool?,
        );
      }

      // Handle request format (when creating transaction)
      return OrderItemModel(
        quantity: _parseQuantity(json['quantity']),
        price: parsedPrice,
        product: ProductInfo(
          id: _parseId(json['product_id']) ?? 0,
          name: '',
          description: '',
          price: parsedPrice,
          galleries: [],
          category: CategoryInfo(id: 0, name: ''),
          merchant: json['merchant'] != null
              ? MerchantInfo.fromJson(json['merchant'])
              : null,
        ),
        merchant: MerchantInfo(
          id: json['merchant']?['id'] ?? 0,
          name: json['merchant']?['name'] ?? '',
          address: json['merchant']?['address'] ?? '',
          phoneNumber: json['merchant']?['phone'] ?? '',
        ),
      );
    } catch (e, stackTrace) {
      print('Error parsing OrderItemModel: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseQuantity(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory OrderItemModel.fromCartItem(CartItemModel cartItem, String orderId) {
    return OrderItemModel(
      quantity: cartItem.quantity,
      price: cartItem.price,
      product: ProductInfo(
        id: cartItem.product.id ?? 0,
        name: cartItem.product.name,
        description: cartItem.product.description,
        price: cartItem.product.price,
        galleries: cartItem.product.imageUrls,
        category: CategoryInfo(
          id: cartItem.product.category?.id ?? 0,
          name: cartItem.product.category?.name ?? '',
        ),
        merchant: null,
      ),
      merchant: MerchantInfo(
        id: cartItem.merchant.id ?? 0,
        name: cartItem.merchant.name,
        address: cartItem.merchant.address,
        phoneNumber: cartItem.merchant.phoneNumber,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
      'merchant': merchant.toJson(),
      'status': status,
      'cancel_reason': cancelReason,
      'canceled_at': canceledAt?.toIso8601String(),
      'can_cancel': canCancel,
    };
  }

  String get formattedPrice => 'Rp ${price.toStringAsFixed(0)}';
  double get totalPrice => quantity * price;
  String get formattedTotalPrice => 'Rp ${totalPrice.toStringAsFixed(0)}';
  String get merchantName => merchant.name;

  // Status helper methods
  bool get isCanceled => status.toUpperCase() == OrderItemStatus.canceled;
  bool get isPending => status.toUpperCase() == OrderItemStatus.pending;
  bool get isAccepted => status.toUpperCase() == OrderItemStatus.accepted;
  bool get isProcessing => status.toUpperCase() == OrderItemStatus.processing;
  bool get isReadyForPickup => status.toUpperCase() == OrderItemStatus.readyForPickup;
  bool get isCompleted => status.toUpperCase() == OrderItemStatus.completed;

  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Menunggu Konfirmasi';
      case 'ACCEPTED':
        return 'Diterima';
      case 'PROCESSING':
        return 'Sedang Diproses';
      case 'READY_FOR_PICKUP':
        return 'Siap Diambil';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  bool validate() {
    if (quantity <= 0) return false;
    if (price <= 0) return false;
    if (product.id <= 0) return false;
    if (merchant.id <= 0) return false;
    return true;
  }

  OrderItemModel copyWith({
    int? id,
    int? quantity,
    double? price,
    ProductInfo? product,
    MerchantInfo? merchant,
    String? status,
    String? cancelReason,
    DateTime? canceledAt,
    bool? canCancel,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      product: product ?? this.product,
      merchant: merchant ?? this.merchant,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
      canceledAt: canceledAt ?? this.canceledAt,
      canCancel: canCancel ?? this.canCancel,
    );
  }
}

class ProductInfo {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> galleries;
  final CategoryInfo category;
  final MerchantInfo? merchant;

  ProductInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.galleries,
    required this.category,
    this.merchant,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    try {
      final double parsedPrice = _parsePrice(json['price']) ?? 0.0;

      // Parse galleries from the API response format
      List<String> galleryUrls = [];
      if (json['galleries'] != null) {
        if (json['galleries'] is List) {
          galleryUrls = (json['galleries'] as List)
              .map((gallery) {
                if (gallery is Map && gallery['url'] != null) {
                  return gallery['url'].toString();
                } else if (gallery is String) {
                  return gallery;
                }
                return '';
              })
              .where((url) => url.isNotEmpty)
              .toList();
        }
      }

      return ProductInfo(
        id: _parseId(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: parsedPrice,
        galleries: galleryUrls,
        category: CategoryInfo.fromJson(json['category'] ?? {}),
        merchant: json['merchant'] != null
            ? MerchantInfo.fromJson(json['merchant'])
            : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing ProductInfo: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'galleries': galleries,
      'category': category.toJson(),
      if (merchant != null) 'merchant': merchant!.toJson(),
    };
  }

  String get firstImageUrl => galleries.isNotEmpty ? galleries.first : '';
}

class CategoryInfo {
  final int id;
  final String name;

  CategoryInfo({
    required this.id,
    required this.name,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    try {
      return CategoryInfo(
        id: _parseId(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing CategoryInfo: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class MerchantInfo {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;

  MerchantInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    try {
      return MerchantInfo(
        id: _parseId(json['id']) ?? 0,
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        phoneNumber:
            json['phone']?.toString() ?? json['phone_number']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing MerchantInfo: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
    };
  }
}
