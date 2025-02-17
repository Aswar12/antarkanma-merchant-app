// lib/app/data/models/variant_model.dart

import 'package:intl/intl.dart';

class VariantModel {
  final int? id;
  final int? productId;
  final String name;
  final String value;
  final double priceAdjustment;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VariantModel({
    this.id,
    this.productId,
    required this.name,
    required this.value,
    required this.priceAdjustment,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      name: json['name'] as String,
      value: json['value'] as String,
      priceAdjustment: double.parse(json['price_adjustment'].toString()),
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'value': value,
      'price_adjustment': priceAdjustment,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Menghitung total harga setelah penyesuaian
  double calculateAdjustedPrice(double basePrice) {
    return basePrice + priceAdjustment;
  }

  // Format harga penyesuaian
  String get formattedPriceAdjustment {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(priceAdjustment);
  }

  // Copy with method
  VariantModel copyWith({
    int? id,
    int? productId,
    String? name,
    String? value,
    double? priceAdjustment,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VariantModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      value: value ?? this.value,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
