class MerchantModel {
  final int? id;
  final int ownerId;
  final String name;
  final String address;
  final String phoneNumber;
  final String? status;
  final String? description;
  final String? logo;
  final String? logoUrl;  // Added logoUrl field
  final String? openingTime;
  final String? closingTime;
  final List<String>? operatingDays;
  final DateTime createdAt; 
  final int? orderCount;
  final int? productsSold;
  final int? totalSales;
  final int? monthlyRevenue;
  final int? productCount;
  final DateTime updatedAt;

  MerchantModel({
    this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.status = 'ACTIVE',
    this.description,
    this.logo,
    this.logoUrl,  // Added to constructor
    required this.createdAt,
    this.productCount,
    required this.updatedAt,
    this.openingTime,
    this.closingTime,
    this.operatingDays,
    this.orderCount,
    this.productsSold,
    this.totalSales,
    this.monthlyRevenue,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    try {
      int? parseInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value == 0 ? null : value;
        if (value is double) return value.toInt();  // Handle double values
        if (value is String) {
          try {
            // First try parsing as double, then convert to int
            final doubleValue = double.parse(value);
            return doubleValue.toInt();
          } catch (e) {
            try {
              // If double parsing fails, try direct int parsing
              final parsed = int.parse(value);
              return parsed == 0 ? null : parsed;
            } catch (e) {
              print('Error parsing $value to int: $e');
              return null;
            }
          }
        }
        return null;
      }

      List<String>? parseOperatingDays(dynamic value) {
        if (value == null) return null;
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        if (value is String && value.isNotEmpty) {
          return value.split(',').map((e) => e.trim()).toList();
        }
        return [];
      }

      return MerchantModel(
        id: parseInt(json['id']),
        ownerId: parseInt(json['owner_id'].toString()) ?? 0,
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        phoneNumber: json['phone_number']?.toString() ?? '',
        status: json['status']?.toString() ?? 'ACTIVE',
        description: json['description']?.toString(),
        logo: json['logo']?.toString(),
        logoUrl: json['logo_url']?.toString(),  // Parse logo_url from JSON
        openingTime: json['opening_time']?.toString(),
        closingTime: json['closing_time']?.toString(),
        operatingDays: parseOperatingDays(json['operating_days']),
        productCount: parseInt(json['product_count']),
        orderCount: parseInt(json['order_count']),
        productsSold: parseInt(json['products_sold']),
        totalSales: parseInt(json['total_sales']),
        monthlyRevenue: parseInt(json['monthly_revenue']),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print('Error creating MerchantModel: $e');
      // Return a minimal valid merchant with null ID instead of 0
      return MerchantModel(
        id: null,
        ownerId: 0,
        name: '',
        address: '',
        phoneNumber: '',
        description: null,
        logo: null,
        logoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        productCount: 0,
        orderCount: 0,
        productsSold: 0,
        totalSales: 0,
        monthlyRevenue: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'status': status,
      'description': description,
      'logo': logo,
      'logo_url': logoUrl,  // Include logoUrl in JSON
      'product_count': productCount,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'operating_days': operatingDays,
      'order_count': orderCount,
      'products_sold': productsSold,
      'total_sales': totalSales,
      'monthly_revenue': monthlyRevenue,
    };
  }

  MerchantModel copyWith({
    int? id,
    int? ownerId,
    String? name,
    String? address,
    String? phoneNumber,
    String? status,
    String? description,
    String? logo,
    String? logoUrl,  // Added to copyWith
    int? productCount,
    String? openingTime,
    String? closingTime,
    List<String>? operatingDays,
    int? orderCount,
    int? productsSold,
    int? totalSales,
    int? monthlyRevenue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      logoUrl: logoUrl ?? this.logoUrl,  // Include in copyWith
      productCount: productCount ?? this.productCount,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      operatingDays: operatingDays ?? this.operatingDays,
      orderCount: orderCount ?? this.orderCount,
      productsSold: productsSold ?? this.productsSold,
      totalSales: totalSales ?? this.totalSales,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status?.toUpperCase() == 'ACTIVE';

  MerchantModel updateStatus(String newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  String get formattedPhoneNumber => phoneNumber;

  String get summary => '$name - $address';

  String? get merchantLogoUrl => logoUrl;  // Use the provided full URL
  String get merchantName => name;
  String get merchantContact => phoneNumber;
  String? get merchantOpeningHours => openingTime;
  List<String>? get merchantOperatingDays => operatingDays;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MerchantModel &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.name == name &&
        other.address == address &&
        other.phoneNumber == phoneNumber &&
        other.status == status &&
        other.description == description &&
        other.logo == logo &&
        other.logoUrl == logoUrl;  // Added to equality check
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ownerId.hashCode ^
        name.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        status.hashCode ^
        description.hashCode ^
        logo.hashCode ^
        logoUrl.hashCode;  // Added to hash
  }

  @override
  String toString() {
    return 'MerchantModel(id: $id, name: $name, status: $status, description: $description, logo: $logo, logoUrl: $logoUrl)';
  }
}
