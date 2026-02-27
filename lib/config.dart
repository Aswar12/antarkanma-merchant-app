class Config {
  // HOST CONFIGURATION:
  // 1. Localhost (ADB Reverse): 'http://localhost:8000/api' -> run: adb reverse tcp:8000 tcp:8000
  // 2. Android Emulator: 'http://10.0.2.2:8000/api'
  // 3. Physical Device (Local IP): 'http://192.168.x.x:8000/api'
  static const String baseUrl = 'http://localhost:8000/api';
  static const int receiveTimeout = 45000; // 45 seconds
  static const int connectTimeout = 45000; // 45 seconds

  // API Endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String orders = '/orders';
  static const String merchants = '/merchants';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerMerchant = '/register/merchant';
  static const String fcmToken = '/fcm/token';
}
