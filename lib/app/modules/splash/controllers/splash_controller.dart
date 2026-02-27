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

    print('=== SPLASH CONTROLLER: Starting initialization ===');

    try {
      // Initialize services
      print('Initializing services...');
      _storageService = StorageService.instance;
      _authService = Get.find<AuthService>();
      _transactionService = Get.find<TransactionService>();
      _merchantService = Get.find<MerchantService>();
      _fcmTokenService = Get.find<FCMTokenService>();
      print('Services initialized successfully');

      // Add minimum delay for splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Check storage state
      print('=== Checking storage state ===');
      _storageService.printStorageState();

      // Check for valid token first
      final token = _storageService.getToken();
      final userData = _storageService.getUser();
      print('Token exists: ${token != null}');
      print('User data exists: ${userData != null}');

      if (token != null && userData != null) {
        print('Valid token found, restoring user...');
        // Restore user from stored data (don't verify token yet - let API calls fail naturally)
        _authService.currentUser.value = UserModel.fromJson(userData);

        // Validate role
        if (_authService.currentUser.value?.role != 'MERCHANT') {
          print('Invalid role: ${_authService.currentUser.value?.role}, clearing storage');
          await _storageService.clearAll();
          Get.offAllNamed(Routes.login);
          return;
        }

        _authService.isLoggedIn.value = true;
        print('User restored successfully, role: MERCHANT');

        // Register FCM token
        final fcmToken = _fcmTokenService.currentToken;
        if (fcmToken != null) {
          print('Registering FCM token...');
          await _fcmTokenService.registerFCMToken(fcmToken);
        }

        print('Loading merchant data...');
        await _loadMerchantData();

        // Check for pending notifications before navigation
        print('Checking pending notifications...');
        final pendingNotification =
            _storageService.getMap('pending_notification');
        if (pendingNotification != null) {
          print('Pending notification found, navigating with data');
          Get.offAllNamed(
            Routes.merchantMainPage,
            arguments: {'pending_notification': pendingNotification},
          );
          await _storageService.remove('pending_notification');
        } else {
          print('No pending notifications, navigating to main page');
          Get.offAllNamed(Routes.merchantMainPage);
        }
        return;
      }

      print('No valid token found, checking auto-login...');
      // If no valid token, check for auto-login
      print('=== Checking auto-login eligibility ===');
      final canAutoLogin = _storageService.canAutoLogin();
      print('Can auto-login: $canAutoLogin');

      if (canAutoLogin) {
        final credentials = _storageService.getSavedCredentials();
        print('Credentials retrieved: ${credentials != null}');

        if (credentials != null) {
          print(
              'Attempting auto-login with identifier: ${credentials['identifier']}');

          final authController = Get.find<AuthController>();

          // Check if auto-login is already in progress
          if (authController.isLoading.value) {
            print('Auto-login already in progress, waiting...');
            await Future.delayed(const Duration(seconds: 3));
            if (authController.isLoading.value) {
              print(
                  'Auto-login still in progress after wait, navigating to login');
              Get.offAllNamed(Routes.login);
              return;
            }
          }

          authController.identifierController.text = credentials['identifier']!;
          authController.passwordController.text = credentials['password']!;

          print('Calling authController.login(isAutoLogin: true)...');
          try {
            final loginSuccess = await authController.login(isAutoLogin: true).then((value) {
              print('Auto-login completed with result: $value');
              return value;
            }).catchError((error, stackTrace) {
              print('Auto-login error caught: $error');
              print('Stack trace: $stackTrace');
              return false;
            });
            print('Auto-login result: $loginSuccess');

            if (loginSuccess) {
              // Validate role after auto-login
              final userRole = _authService.currentUser.value?.role;
              print('Auto-login success, user role: $userRole');

              if (userRole != 'MERCHANT') {
                print(
                    'Auto-login user is not MERCHANT, clearing auth and going to login');
                await _storageService.clearAll();
                Get.offAllNamed(Routes.login);
                return;
              }

              // Register FCM token after successful auto-login
              final fcmToken = _fcmTokenService.currentToken;
              if (fcmToken != null) {
                print('Registering FCM token after auto-login...');
                await _fcmTokenService.registerFCMToken(fcmToken);
              }

              print('Loading merchant data after auto-login...');
              await _loadMerchantData();

              // Check for pending notifications before navigation
              print('Checking pending notifications...');
              final pendingNotification =
                  _storageService.getMap('pending_notification');
              if (pendingNotification != null) {
                print('Pending notification found, navigating with data');
                Get.offAllNamed(
                  Routes.merchantMainPage,
                  arguments: {'pending_notification': pendingNotification},
                );
                await _storageService.remove('pending_notification');
              } else {
                print('No pending notifications, navigating to main page');
                Get.offAllNamed(Routes.merchantMainPage);
              }
              return;
            } else {
              print('Auto-login failed, navigating to login page');
              // Clear invalid credentials
              await _storageService.clearCredentials();
            }
          } catch (e, stackTrace) {
            print('Exception during authController.login: $e');
            print('Full stack trace: $stackTrace');
            await _storageService.clearCredentials();
          }
        } else {
          print('ERROR: canAutoLogin=true but credentials is null!');
        }
      } else {
        print(
            'Cannot auto-login - rememberMe: ${_storageService.getRememberMe()}, hasCredentials: ${_storageService.getSavedCredentials() != null}');
      }

      print('=== Navigating to login page ===');
      // If we reach here, navigate to login page
      Get.offAllNamed(Routes.login);
    } catch (e, stackTrace) {
      print('❌ Error in splash controller: $e');
      print('Full stack trace: $stackTrace');
      // Try to clear any corrupted data
      try {
        await _storageService.clearAll();
      } catch (cleanupError) {
        print('Error clearing storage: $cleanupError');
      }
      Get.offAllNamed(Routes.login);
    } finally {
      _isInitializing = false;
      print('=== SPLASH CONTROLLER: Initialization complete ===');
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
      // Check if error is 401 (unauthorized)
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('401') || errorMessage.contains('unauthenticated')) {
        print('Token invalid during data load, clearing auth...');
        await _storageService.clearAuth();
        // Don't navigate here, let the app continue and handle it gracefully
      }
      // Continue even if some data fails to load
    }
  }
}
