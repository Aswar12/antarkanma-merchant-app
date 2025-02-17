// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

class UserLocationModel {
  final int? id;
  final int userId;
  final String? customerName;
  final String address;
  final String city;
  final String district;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String addressType;
  final String phoneNumber;
  bool isDefault;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  // Konstanta untuk tipe alamat
  static const String TYPE_RUMAH = 'RUMAH';
  static const String TYPE_KANTOR = 'KANTOR';
  static const String TYPE_TOKO = 'TOKO';
  static const String TYPE_LAINNYA = 'LAINNYA';

  UserLocationModel({
    this.id,
    required this.userId,
    this.customerName,
    required this.address,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.addressType,
    required this.phoneNumber,
    this.isDefault = false,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      customerName: json['customer_name'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      postalCode: json['postal_code'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      addressType: json['address_type'] as String,
      phoneNumber: json['phone_number'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'address': address,
      'city': city,
      'district': district,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'address_type': addressType,
      'phone_number': phoneNumber,
      'is_default': isDefault,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  UserLocationModel copyWith({
    int? id,
    int? userId,
    String? customerName,
    String? address,
    String? city,
    String? district,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? addressType,
    String? phoneNumber,
    bool? isDefault,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return UserLocationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      city: city ?? this.city,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressType: addressType ?? this.addressType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  static List<String> get addressTypes => [
        TYPE_RUMAH,
        TYPE_KANTOR,
        TYPE_TOKO,
        TYPE_LAINNYA,
      ];

  String get formattedPhoneNumber {
    if (phoneNumber.startsWith('0')) {
      return '+62${phoneNumber.substring(1)}';
    }
    return phoneNumber;
  }

  String get fullAddress {
    return '$address, $district, $city,  $postalCode';
  }

  String get shortAddress {
    return '$district, $city';
  }

  bool get isDeleted => deletedAt != null;

  String get formattedCreatedAt {
    return createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(createdAt!)
        : '';
  }

  String get formattedUpdatedAt {
    return updatedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(updatedAt!)
        : '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserLocationModel &&
        other.id == id &&
        other.userId == userId &&
        other.customerName == customerName &&
        other.address == address &&
        other.city == city &&
        other.district == district &&
        other.postalCode == postalCode &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.addressType == addressType &&
        other.phoneNumber == phoneNumber &&
        other.isDefault == isDefault &&
        other.notes == notes &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      customerName,
      address,
      city,
      district,
      postalCode,
      latitude,
      longitude,
      addressType,
      phoneNumber,
      isDefault,
      notes,
      isActive,
      createdAt,
      updatedAt,
      deletedAt,
    );
  }

  UserLocationModel? get value => null;

  @override
  String toString() {
    return 'UserLocationModel(id: $id, userId: $userId, customerName: $customerName, address: $address, city: $city, district: $district, postalCode: $postalCode, latitude: $latitude, longitude: $longitude, addressType: $addressType, phoneNumber: $phoneNumber, isDefault: $isDefault, notes: $notes, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }
}

class UninitializedUserLocationModel extends UserLocationModel {
  UninitializedUserLocationModel()
      : super(
          userId: 0,
          customerName: null,
          address: '',
          city: '',
          district: '',
          postalCode: '',
          latitude: 0.0,
          longitude: 0.0,
          addressType: UserLocationModel.TYPE_RUMAH,
          phoneNumber: '',
        );
}

// Extension untuk List<UserLocationModel>
extension UserLocationListExtension on List<UserLocationModel> {
  // Mendapatkan alamat default
  UserLocationModel? get defaultLocation {
    try {
      return firstWhere((location) => location.isDefault);
    } catch (e) {
      return null;
    }
  }

  // Mendapatkan alamat aktif
  List<UserLocationModel> get activeLocations {
    return where((location) => location.isActive && location.deletedAt == null)
        .toList();
  }

  // Mendapatkan alamat berdasarkan tipe
  List<UserLocationModel> getLocationsByType(String type) {
    return where((location) =>
        location.addressType == type &&
        location.isActive &&
        location.deletedAt == null).toList();
  }

  // Mencari alamat berdasarkan keyword
  List<UserLocationModel> search(String keyword) {
    final lowercaseKeyword = keyword.toLowerCase();
    return where((location) {
      final searchableText = '''
        ${location.customerName ?? ''}
        ${location.address}
        ${location.city}
        ${location.district}
        ${location.postalCode}
      '''
          .toLowerCase();

      return searchableText.contains(lowercaseKeyword);
    }).toList();
  }

  // Mengurutkan berdasarkan created_at terbaru
  List<UserLocationModel> sortByNewest() {
    final sorted = [...this];
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return sorted;
  }

  // Mengurutkan dengan alamat default di awal
  List<UserLocationModel> sortWithDefaultFirst() {
    final sorted = [...this];
    sorted.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return 0;
    });
    return sorted;
  }
}

// Extension untuk validasi
extension UserLocationValidationExtension on UserLocationModel {
  bool get isValidPhoneNumber {
    // Validasi nomor telepon Indonesia
    final phoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  bool get isValidPostalCode {
    // Validasi kode pos Indonesia (5 digit)
    final postalRegex = RegExp(r'^\d{5}$');
    return postalRegex.hasMatch(postalCode);
  }

  bool get isValidCoordinates {
    // Validasi koordinat
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  String? validate() {
    if (address.isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    if (city.isEmpty) {
      return 'Kota tidak boleh kosong';
    }
    if (district.isEmpty) {
      return 'Kecamatan tidak boleh kosong';
    }
    if (!isValidPostalCode) {
      return 'Kode pos tidak valid';
    }
    if (!isValidPhoneNumber) {
      return 'Nomor telepon tidak valid';
    }
    if (!isValidCoordinates) {
      return 'Koordinat tidak valid';
    }
    if (!UserLocationModel.addressTypes.contains(addressType)) {
      return 'Tipe alamat tidak valid';
    }
    return null;
  }
}

// Extension untuk format dan manipulasi data tambahan
extension UserLocationFormattingExtension on UserLocationModel {
  String get addressLabel {
    if (customerName?.isNotEmpty ?? false) {
      return '$addressType - $customerName';
    }
    return addressType;
  }

  String get coordinatesString {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String get googleMapsUrl {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  Map<String, dynamic> toFormData() {
    return {
      'user_id': userId.toString(),
      'customer_name': customerName ?? '',
      'address': address,
      'city': city,
      'district': district,
      'postal_code': postalCode,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'address_type': addressType,
      'phone_number': phoneNumber,
      'is_default': isDefault.toString(),
      'notes': notes ?? '',
      'is_active': isActive.toString(),
    };
  }
}
