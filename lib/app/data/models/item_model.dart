import 'package:intl/intl.dart';

class GalleryModel {
  final int id;
  final int productId;
  final String url;

  GalleryModel({
    required this.id,
    required this.productId,
    required this.url,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'url': url,
    };
  }
}

class ProductModel {
  final String name;
  final double price;
  final String? image;
  final List<GalleryModel> galleries;
  final String status;

  ProductModel({
    required this.name,
    required this.price,
    this.image,
    this.galleries = const [],
    this.status = 'ACTIVE',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: json['image'],
      galleries: (json['galleries'] as List?)
              ?.map((gallery) => GalleryModel.fromJson(gallery))
              .toList() ??
          [],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'galleries': galleries.map((gallery) => gallery.toJson()).toList(),
      'status': status,
    };
  }

  String? get firstImageUrl {
    if (image != null && image!.isNotEmpty) {
      return image;
    }
    if (galleries.isNotEmpty) {
      return galleries.first.url;
    }
    return null;
  }
}

class ItemModel {
  final int quantity;
  final double price;
  final ProductModel product;

  ItemModel({
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      product: ProductModel.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'price': price,
      'product': product.toJson(),
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
    ).format(price * quantity);
  }
}
