import 'merchant_model.dart';

class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String role; // 'USER', 'MERCHANT', 'COURIER'
  final String? username;
  final String? profilePhotoUrl;
  final String? profilePhotoPath;
  final MerchantModel? merchant; // Add merchant property

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    required this.role,
    this.username,
    this.profilePhotoUrl,
    this.profilePhotoPath,
    this.merchant, // Add to constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle profile photo URL
    String? photoUrl = json['profile_photo_url'];
    if (photoUrl == null || photoUrl.isEmpty) {
      // If no photo URL, check if there's a path and construct the URL
      final photoPath = json['profile_photo_path'];
      if (photoPath != null && photoPath.isNotEmpty) {
        photoUrl = 'storage/$photoPath';
      }
    }

    // Parse merchant data if available
    MerchantModel? merchantData;
    if (json['merchant'] != null) {
      merchantData = MerchantModel.fromJson(json['merchant']);
    }

    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: (json['roles'] is List)
          ? (json['roles'] as List).first.toString()
          : (json['roles']?.toString() ?? 'USER'),
      username: json['username'] as String?,
      profilePhotoUrl: photoUrl,
      profilePhotoPath: json['profile_photo_path'] as String?,
      merchant: merchantData, // Include merchant data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'roles': role,
      'username': username,
      'profile_photo_url': profilePhotoUrl,
      'profile_photo_path': profilePhotoPath,
      'merchant': merchant?.toJson(), // Include merchant in JSON
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.role == role &&
        other.username == username &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.profilePhotoPath == profilePhotoPath &&
        other.merchant == merchant;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        role.hashCode ^
        username.hashCode ^
        profilePhotoUrl.hashCode ^
        profilePhotoPath.hashCode ^
        merchant.hashCode;
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? username,
    String? profilePhotoUrl,
    String? profilePhotoPath,
    MerchantModel? merchant,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      username: username ?? this.username,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      merchant: merchant ?? this.merchant,
    );
  }
}
