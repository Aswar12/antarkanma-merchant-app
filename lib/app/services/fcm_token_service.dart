import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../data/providers/auth_provider.dart';
import '../services/storage_service.dart';

class FCMTokenService extends GetxService {
  final AuthProvider _authProvider;
  final StorageService _storageService;
  String? _fcmToken;
  String? _deviceId;
  bool _isRegistering = false;
  final RxBool isTokenRegistered = false.obs;

  FCMTokenService({
    AuthProvider? authProvider,
    StorageService? storageService,
  })  : _authProvider = authProvider ?? AuthProvider(),
        _storageService = storageService ?? StorageService.instance {
    _deviceId = _getDeviceId();
  }

  String? get currentToken => _fcmToken;

  String _getDeviceId() {
    // Get stored device ID or generate a new one
    final savedDeviceId = _storageService.getString('device_id');
    if (savedDeviceId != null) {
      return savedDeviceId;
    }
    final newDeviceId = '${DateTime.now().millisecondsSinceEpoch}';
    _storageService.saveString('device_id', newDeviceId);
    return newDeviceId;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      // Check for saved FCM token first
      _fcmToken = _storageService.getString('fcm_token');
      
      // Only get new token if we don't have one saved
      if (_fcmToken == null) {
        _fcmToken = await FirebaseMessaging.instance.getToken();
        if (_fcmToken != null) {
          await _storageService.saveString('fcm_token', _fcmToken!);
        }
      }
      
      Get.log('FCM Token: $_fcmToken');

      // Don't listen for token refresh to keep token stable
    } catch (e) {
      Get.log('Error initializing FCM: $e', isError: true);
    }
  }

  Future<bool> registerFCMToken(String fcmToken) async {
    if (_isRegistering) {
      Get.log('FCM token registration already in progress, skipping');
      return false;
    }

    _isRegistering = true;
    try {
      final authToken = _storageService.getToken();
      if (authToken == null) {
        Get.log('No auth token found for FCM registration');
        _isRegistering = false;
        return false;
      }

      if (kDebugMode) {
        Get.log('Registering FCM token with data:', isError: false);
        Get.log('Auth Token: $authToken', isError: false);
        Get.log('FCM Token: $fcmToken', isError: false);
        Get.log('Device ID: $_deviceId', isError: false);
      }

      final data = {
        'token': fcmToken,
        'device_type': 'android',
        'device_id': _deviceId
      };

      final response = await _authProvider.registerFCMToken(authToken, data);

      if (response.statusCode == 200) {
        Get.log('FCM token registered successfully');
        _isRegistering = false;
        isTokenRegistered.value = true;
        return true;
      }

      Get.log('Failed to register FCM token: ${response.data}');
      _isRegistering = false;
      isTokenRegistered.value = false;
      return false;
    } catch (e) {
      Get.log('Error registering FCM token: $e', isError: true);
      _isRegistering = false;
      isTokenRegistered.value = false;
      return false;
    }
  }

  Future<bool> unregisterToken([String? specificToken]) async {
    try {
      final authToken = _storageService.getToken();
      final tokenToUnregister = specificToken ?? _fcmToken;
      
      if (authToken == null || tokenToUnregister == null) {
        Get.log('No auth token or FCM token found for unregistration');
        return false;
      }

      if (kDebugMode) {
        Get.log('Unregistering FCM token:', isError: false);
        Get.log('Auth Token: $authToken', isError: false);
        Get.log('FCM Token: $tokenToUnregister', isError: false);
      }

      final data = {'token': tokenToUnregister};
      final response = await _authProvider.unregisterFCMToken(authToken, data);

      if (response.statusCode == 200) {
        Get.log('FCM token unregistered successfully');
        if (specificToken == null) {
          isTokenRegistered.value = false;
        }
        return true;
      }

      Get.log('Failed to unregister FCM token: ${response.data}');
      return false;
    } catch (e) {
      Get.log('Error unregistering FCM token: $e', isError: true);
      return false;
    }
  }

  Future<void> handleLogin() async {
    try {
      // Use existing token if available
      if (_fcmToken == null) {
        _fcmToken = await FirebaseMessaging.instance.getToken();
        if (_fcmToken != null) {
          await _storageService.saveString('fcm_token', _fcmToken!);
        }
      }

      if (_fcmToken != null) {
        // Register the token
        await registerFCMToken(_fcmToken!);
      } else {
        Get.log('No FCM token available for registration');
      }
    } catch (e) {
      Get.log('Error handling login FCM token: $e', isError: true);
    }
  }

  Future<void> handleLogout() async {
    try {
      // Only unregister the token, don't clear it
      if (_fcmToken != null) {
        await unregisterToken(_fcmToken);
      }
      isTokenRegistered.value = false;
    } catch (e) {
      Get.log('Error handling logout FCM token: $e', isError: true);
    }
  }
}
