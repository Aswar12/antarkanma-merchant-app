class Config {
  static String baseUrl = 'https://dev.antarkanmaa.my.id/api';
  static const int receiveTimeout = 15000;
  static const int connectTimeout = 15000;

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
