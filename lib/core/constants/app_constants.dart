class AppConstants {
  /// Central API used by **all** devices (driver phone, admin phone, desktop).
  ///
  /// Live GPS works across mobile data / different Wi‑Fi when this points to a
  /// **public** server (not 127.0.0.1). Driver posts GPS → server DB → admin polls server.
  ///
  /// Local dev (emulator / Windows on same PC):
  ///   default below, or `flutter run`
  ///
  /// Phones anywhere (production or demo):
  ///   1) Deploy API + MySQL to a cloud host (Render, Railway, VPS, etc.), OR
  ///   2) Expose local API with Cloudflare tunnel, then set URL below.
  ///
  ///   flutter run --dart-define-from-file=api_config.json
  ///   flutter build apk --dart-define-from-file=api_config.json
  ///
  /// `api_config.json` example: { "API_BASE_URL": "https://api.yourdomain.com/api" }
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://nav-astronomy-synopsis-networking.trycloudflare.com/api',
  );

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  /// Persisted active driver GPS session (background tracking).
  static const String activeTrackingTaskTypeKey = 'active_tracking_task_type';
  static const String activeTrackingTaskIdKey = 'active_tracking_task_id';
  static const String activeTrackingDriverIdKey = 'active_tracking_driver_id';

  /// Per-user dashboard view: professional role vs citizen community/shop.
  static String dashboardCitizenModeKey(int userId) =>
      'dashboard_citizen_mode_$userId';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const bool isDevelopment = true;

  // User Types
  static const int userTypeIndustry = 1;
  static const int userTypeDriver = 2;
  static const int userTypeCitizen = 3;
  static const int userTypeAdmin = 4;
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';
  // static const String testLogin = '/auth/test-login';
  static const String updateDetails = '/auth/updatedetails';
}
