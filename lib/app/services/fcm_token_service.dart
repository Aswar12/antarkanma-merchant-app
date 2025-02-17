import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/providers/notification_provider.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';

class FCMTokenService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationProvider _notificationProvider = NotificationProvider();
  final AuthService _authService = Get.find<AuthService>();

  final _currentToken = RxnString();
  final _isTokenRegistered = RxBool(false);

  String? get currentToken => _currentToken.value;
  bool get isTokenRegistered => _isTokenRegistered.value;

  Future<FCMTokenService> init() async {
    // Request permission for iOS
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get initial FCM token
    await _initializeFCMToken();

    // Listen to token refresh
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);

    // Listen to auth changes to handle token registration
    ever(_authService.currentUser, (user) {
      if (user != null && 
          _currentToken.value != null && 
          !_isTokenRegistered.value) {
        registerFCMToken(_currentToken.value!);
      }
    });

    return this;
  }

  Future<void> _initializeFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      print('Initializing FCM token: $token');

      if (token != null) {
        _currentToken.value = token;

        // Only register if user is already logged in
        final user = _authService.currentUser.value;
        if (user != null) {
          await registerFCMToken(token);
        }
      }
    } catch (e) {
      print('Error initializing FCM token: $e');
    }
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    try {
      print('Handling token refresh. Old: ${_currentToken.value}, New: $newToken');

      final oldToken = _currentToken.value;
      _currentToken.value = newToken;

      final user = _authService.currentUser.value;
      if (user != null) {
        // If we had an old token, unregister it first
        if (oldToken != null) {
          await _notificationProvider.unregisterFCMToken(oldToken);
        }
        // Register the new token
        await registerFCMToken(newToken);
      }
    } catch (e) {
      print('Error handling token refresh: $e');
    }
  }

  Future<void> registerFCMToken(String fcmtoken) async {
    try {
      final user = _authService.currentUser.value;
      if (user != null) {
        print('Registering FCM token for user ${user.id} with role ${user.role}');

        await _notificationProvider.registerFCMToken(
          fcmtoken,
          user.id.toString(),
          role: user.role,
        );

        _isTokenRegistered.value = true;
        print('FCM token registered successfully');
      } else {
        print('Cannot register FCM token: No user logged in');
      }
    } catch (e) {
      _isTokenRegistered.value = false;
      print('Error registering token with backend: $e');
    }
  }

  Future<void> unregisterToken() async {
    try {
      final token = _currentToken.value;
      if (token != null) {
        print('Unregistering FCM token: $token');

        await _notificationProvider.unregisterFCMToken(token);
        _currentToken.value = null;
        _isTokenRegistered.value = false;

        print('FCM token unregistered successfully');
      }
    } catch (e) {
      print('Error unregistering token: $e');
    }
  }
}
