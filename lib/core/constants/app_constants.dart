class AppConstants {
  // static const String baseUrl = 'http://localhost:3000/api'; // on laptop 
  static const String baseUrl = 'http://172.16.154.248:3000/api'; // on local network mobile same wifi (lenovo laptop)
  // static const String baseUrl = 'http://aneusoapi.ashfaqalizardaristore.com/api'; // on live server
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
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
