// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:crypto/crypto.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final _storage = GetStorage();

  // Keys
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';
  static const String _merchantKey = 'merchant';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedCredentialsKey = 'saved_credentials';
  static const String _userLocationsKey = 'user_locations';
  static const String _defaultLocationKey = 'default_location';
  static const String _ordersKey = 'orders_cache';
  static const String _reviewsKey = 'product_reviews_cache';

  // Cache duration (2 days in milliseconds)
  static const int _cacheDuration = 172800000; // 48 * 60 * 60 * 1000

  // Simple encryption key
  static const String _secretKey = 'your_secret_key_here';

  // Enkripsi sederhana
  String _encrypt(String text) {
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(text);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    final encrypted = base64Encode(bytes);
    return '$encrypted.${digest.toString()}';
  }

  // Dekripsi sederhana
  String? _decrypt(String? encryptedText) {
    try {
      if (encryptedText == null) return null;

      final parts = encryptedText.split('.');
      if (parts.length != 2) return null;

      final encrypted = parts[0];
      final hash = parts[1];

      final decrypted = base64Decode(encrypted);
      final text = utf8.decode(decrypted);

      // Verify hash
      final key = utf8.encode(_secretKey);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(utf8.encode(text));

      if (digest.toString() != hash) return null;

      return text;
    } catch (e) {
      print('Decryption error: $e');
      return null;
    }
  }

  // Token Methods
  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  String? getToken() {
    return _storage.read(_tokenKey);
  }

  // User Methods
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _storage.write(_userKey, userData);
  }

  Map<String, dynamic>? getUser() {
    return _storage.read(_userKey);
  }

  // Remember Me Methods
  Future<void> saveRememberMe(bool value) async {
    await _storage.write(_rememberMeKey, value);
  }

  bool getRememberMe() {
    return _storage.read(_rememberMeKey) ?? false;
  }

  // Saved Credentials Methods
  Future<void> saveCredentials(String identifier, String password) async {
    try {
      final credentials = {
        'identifier': _encrypt(identifier),
        'password': _encrypt(password),
      };
      await _storage.write(_savedCredentialsKey, credentials);
      print('Credentials saved successfully');
    } catch (e) {
      print('Error saving credentials: $e');
      rethrow;
    }
  }

  Map<String, String>? getSavedCredentials() {
    try {
      final encryptedData = _storage.read(_savedCredentialsKey);
      if (encryptedData == null) return null;

      final decryptedIdentifier = _decrypt(encryptedData['identifier']);
      final decryptedPassword = _decrypt(encryptedData['password']);

      if (decryptedIdentifier == null || decryptedPassword == null) {
        clearCredentials();
        return null;
      }

      return {
        'identifier': decryptedIdentifier,
        'password': decryptedPassword,
      };
    } catch (e) {
      print('Error getting saved credentials: $e');
      clearCredentials();
      return null;
    }
  }

  // Location Methods
  Future<void> saveList(String key, List<dynamic> data) async {
    final jsonString = json.encode(data);
    final encrypted = _encrypt(jsonString);
    await _storage.write(key, encrypted);
  }

  List<dynamic>? getList(String key) {
    try {
      final encrypted = _storage.read(key);
      if (encrypted == null) return null;

      final decrypted = _decrypt(encrypted);
      if (decrypted == null) return null;

      return json.decode(decrypted) as List<dynamic>;
    } catch (e) {
      print('Error getting list from storage: $e');
      return null;
    }
  }

  Future<void> saveMap(String key, Map<String, dynamic> data) async {
    final jsonString = json.encode(data);
    final encrypted = _encrypt(jsonString);
    await _storage.write(key, encrypted);
  }

  Map<String, dynamic>? getMap(String key) {
    try {
      final encrypted = _storage.read(key);
      if (encrypted == null) return null;

      final decrypted = _decrypt(encrypted);
      if (decrypted == null) return null;

      return json.decode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      print('Error getting map from storage: $e');
      return null;
    }
  }

  // User Location Specific Methods
  Future<void> saveUserLocations(List<Map<String, dynamic>> locations) async {
    await saveList(_userLocationsKey, locations);
  }

  List<Map<String, dynamic>>? getUserLocations() {
    final data = getList(_userLocationsKey);
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveDefaultLocation(Map<String, dynamic> location) async {
    await saveMap(_defaultLocationKey, location);
  }

  Map<String, dynamic>? getDefaultLocation() {
    return getMap(_defaultLocationKey);
  }

  // Auto Login Methods
  Future<void> setupAutoLogin({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      if (rememberMe) {
        await saveRememberMe(true);
        await saveCredentials(identifier, password);
      } else {
        await clearAutoLogin();
      }
    } catch (e) {
      print('Error setting up auto login: $e');
      await clearAutoLogin();
    }
  }

  bool canAutoLogin() {
    final rememberMe = getRememberMe();
    final hasCredentials = getSavedCredentials() != null;
    print(
        'Can auto login: RememberMe=$rememberMe, HasCredentials=$hasCredentials');
    return rememberMe && hasCredentials;
  }

  Future<void> clearAutoLogin() async {
    await clearCredentials();
  }

  Future<void> clearCredentials() async {
    await _storage.remove(_savedCredentialsKey);
    await _storage.remove(_rememberMeKey);
  }

  // Clear Methods
  Future<void> clearAuth() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_userKey);
    await _storage.remove(_merchantKey);
    await clearLocationData();
  }

  Future<void> clearLocationData() async {
    await _storage.remove(_userLocationsKey);
    await _storage.remove(_defaultLocationKey);
  }

  // Orders cache methods
  Future<void> saveOrders(List<Map<String, dynamic>> orders) async {
    await saveList(_ordersKey, orders);
  }

  List<Map<String, dynamic>>? getOrders() {
    final data = getList(_ordersKey);
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> clearOrders() async {
    await _storage.remove(_ordersKey);
  }

  // Reviews cache methods
  Future<void> saveProductReviews(
      int productId, List<Map<String, dynamic>> reviews) async {
    final key = '${_reviewsKey}_$productId';
    await saveList(key, reviews);
    // Save timestamp for cache invalidation
    await saveInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  List<Map<String, dynamic>>? getProductReviews(int productId) {
    final key = '${_reviewsKey}_$productId';
    final data = getList(key);
    if (data == null) return null;

    // Check if cache is older than 2 days
    final timestamp = getInt('${key}_timestamp') ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > _cacheDuration) {
      remove(key);
      remove('${key}_timestamp');
      return null;
    }

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> clearProductReviews(int productId) async {
    final key = '${_reviewsKey}_$productId';
    await remove(key);
    await remove('${key}_timestamp');
  }

  Future<void> clearAll() async {
    await _storage.erase();
  }

  // Utility Methods
  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  bool hasKey(String key) {
    return _storage.hasData(key);
  }

  // Utility Methods (lanjutan)
  List<String> getAllKeys() {
    return _storage.getKeys().toList();
  }

  int getStorageSize() {
    return _storage.getValues().length;
  }

  // Debug Methods
  void printStorageState() {
    print('Remember Me: ${getRememberMe()}');
    print('Has Credentials: ${getSavedCredentials() != null}');
    print('Has Token: ${getToken() != null}');
    print('Has User: ${getUser() != null}');
    print('Has User Locations: ${getUserLocations() != null}');
    print('Has Default Location: ${getDefaultLocation() != null}');
    print('Storage Size: ${getStorageSize()}');
    print('All Keys: ${getAllKeys()}');
  }

  // Additional utility methods
  Future<void> saveString(String key, String value) async {
    await _storage.write(key, _encrypt(value));
  }

  String? getString(String key) {
    final value = _storage.read(key);
    if (value is String) {
      return _decrypt(value);
    }
    return null;
  }

  Future<void> saveInt(String key, int value) async {
    await _storage.write(key, value);
  }

  int? getInt(String key) {
    return _storage.read(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _storage.write(key, value);
  }

  bool? getBool(String key) {
    return _storage.read(key);
  }

  // Method to check if storage is empty
  bool isEmpty() {
    return _storage.getKeys().isEmpty;
  }

  // Method to get all data as Map
  Map<String, dynamic> getAll() {
    final Map<String, dynamic> allData = {};
    for (var key in _storage.getKeys()) {
      if (key is String) {
        // Memastikan key adalah String
        var value = _storage.read(key);
        if (value != null) {
          if (value is String) {
            // Jika nilai adalah String, kita coba dekripsi
            value = _decrypt(value) ?? value;
          }
          allData[key] = value;
        }
      }
    }
    return allData;
  }

  // Method to save multiple key-value pairs at once
  Future<void> saveMultiple(Map<String, dynamic> data) async {
    for (var entry in data.entries) {
      if (entry.value is String) {
        await saveString(entry.key, entry.value as String);
      } else {
        await _storage.write(entry.key, entry.value);
      }
    }
  }

  // Method to get storage usage in bytes (approximate)
  int getStorageUsage() {
    int totalSize = 0;
    for (var key in _storage.getKeys()) {
      if (key is String) {
        // Memastikan key adalah String
        var value = _storage.read(key);
        if (value != null) {
          totalSize +=
              key.length; // Tidak perlu .toString() karena key sudah String
          if (value is String) {
            totalSize += value.length;
          } else {
            // Untuk tipe data lain, kita gunakan representasi string-nya
            totalSize += value.toString().length;
          }
        }
      }
    }
    return totalSize;
  }

  // Method to save merchant data
  Future<void> saveMerchantData(Map<String, dynamic> merchantData) async {
    await saveMap(_merchantKey, merchantData);
  }

  Map<String, dynamic>? getMerchantData() {
    return getMap(_merchantKey);
  }

  List<dynamic> getAllValues() {
    final values = _storage.getValues();
    return values.map((value) {
      final strValue = safeGetString(value);
      if (strValue != null) {
        return _decrypt(strValue) ?? strValue;
      }
      return value;
    }).toList();
  }

// Untuk mengambil String
  String? safeGetString(dynamic value) {
    if (value is String) {
      return value;
    }
    return null;
  }

// Untuk mengambil int
  int? safeGetInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return null;
  }

// Untuk mengambil bool
  bool? safeGetBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    return null;
  }

  // Method to clear all data except certain keys
  Future<void> clearExcept(List<String> keysToKeep) async {
    final allKeys = _storage.getKeys().toList();
    for (var key in allKeys) {
      if (!keysToKeep.contains(key.toString())) {
        await _storage.remove(key);
      }
    }
  }
}
