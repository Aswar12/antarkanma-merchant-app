class ProductGalleryModel {
  final int? id;
  final int productId;
  final String url;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  ProductGalleryModel({
    this.id,
    required this.productId,
    required this.url,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ProductGalleryModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse product ID with validation
      int parseProductId(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is String) {
          return int.tryParse(value) ?? 0;
        }
        return 0;
      }

      // Parse URL with validation
      String parseUrl(dynamic value) {
        if (value == null) return '';
        if (value is String) return value;
        return value.toString();
      }

      // Parse datetime with validation
      DateTime? parseDateTime(dynamic value) {
        if (value == null) return null;
        if (value is String) {
          return DateTime.tryParse(value);
        }
        return null;
      }

      return ProductGalleryModel(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        productId: parseProductId(json['product_id']),
        url: parseUrl(json['url']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
        deletedAt: parseDateTime(json['deleted_at']),
      );
    } catch (e) {
      // Return a gallery model with default values if parsing fails
      return ProductGalleryModel(
        productId: 0,
        url: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductGalleryModel &&
        other.id == id &&
        other.productId == productId &&
        other.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ productId.hashCode ^ url.hashCode;

  ProductGalleryModel copyWith({
    int? id,
    int? productId,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ProductGalleryModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  String toString() {
    return 'ProductGalleryModel(id: $id, productId: $productId, url: $url)';
  }
}
