import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/transaction_service.dart';
import '../../../services/merchant_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/fcm_token_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/user_model.dart';
import '../../../controllers/auth_controller.dart';

class SplashController extends GetxController {
  late final AuthService _authService;
  late final TransactionService _transactionService;
  late final MerchantService _merchantService;
  late final FCMTokenService _fcmTokenService;
  late final StorageService _storageService;

  bool _isInitializing = false;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Initialize services
      _storageService = StorageService.instance;
      _authService = Get.find<AuthService>();
      _transactionService = Get.find<TransactionService>();
      _merchantService = Get.find<MerchantService>();
      _fcmTokenService = Get.find<FCMTokenService>();

      // Add minimum delay for splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Check for valid token first
      final token = _storageService.getToken();
      final userData = _storageService.getUser();

      if (token != null && userData != null) {
        // Try to verify token
        final isValid = await _authService.verifyToken(token);
        if (isValid) {
          _authService.currentUser.value = UserModel.fromJson(userData);
          if (_authService.currentUser.value?.role != 'MERCHANT') {
            await _storageService.clearAll();
            Get.offAllNamed(Routes.login);
            return;
          }
          _authService.isLoggedIn.value = true;

          // Register FCM token after successful token verification
          final fcmToken = _fcmTokenService.currentToken;
          if (fcmToken != null) {
            await _fcmTokenService.registerFCMToken(fcmToken);
          }

          await _loadMerchantData();

          // Check for pending notifications before navigation
          final pendingNotification =
              _storageService.getMap('pending_notification');
          if (pendingNotification != null) {
            Get.offAllNamed(
              Routes.merchantMainPage,
              arguments: {'pending_notification': pendingNotification},
            );
            await _storageService.remove('pending_notification');
          } else {
            Get.offAllNamed(Routes.merchantMainPage);
          }
          return;
        }

        // If token is invalid, clear auth data but keep remember me settings
        if (_storageService.getRememberMe()) {
          final credentials = _storageService.getSavedCredentials();
          await _storageService.clearAuth();
          if (credentials != null) {
            await _storageService.saveRememberMe(true);
            await _storageService.saveCredentials(
              credentials['identifier']!,
              credentials['password']!,
            );
          }
        } else {
          await _storageService.clearAll();
        }
      }

      // If no valid token, check for auto-login
      if (_storageService.canAutoLogin()) {
        final credentials = _storageService.getSavedCredentials();
        if (credentials != null) {
          final authController = Get.find<AuthController>();
          authController.identifierController.text = credentials['identifier']!;
          authController.passwordController.text = credentials['password']!;
          final loginSuccess = await authController.login(isAutoLogin: true);

          if (loginSuccess) {
            // Register FCM token after successful auto-login
            final fcmToken = _fcmTokenService.currentToken;
            if (fcmToken != null) {
              await _fcmTokenService.registerFCMToken(fcmToken);
            }

            await _loadMerchantData();

            // Check for pending notifications before navigation
            final pendingNotification =
                _storageService.getMap('pending_notification');
            if (pendingNotification != null) {
              Get.offAllNamed(
                Routes.merchantMainPage,
                arguments: {'pending_notification': pendingNotification},
              );
              await _storageService.remove('pending_notification');
            } else {
              Get.offAllNamed(Routes.merchantMainPage);
            }
            return;
          }
        }
      }

      // If we reach here, navigate to login page
      Get.offAllNamed(Routes.login);
    } catch (e) {
      print('Error in splash controller: $e');
      Get.offAllNamed(Routes.login);
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _loadMerchantData() async {
    try {
      await Future.wait([
        _merchantService.getMerchant(),
        _merchantService.getMerchantProducts(),
      ]);

      try {
        await _transactionService.getOrders(page: 1);
      } catch (e) {
        // Continue even if orders fail to load
      }
    } catch (e) {
      // Continue even if some data fails to load
    }
  }
}
