import 'user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final AuthData? data;
  final String? token;
  final bool requiresVerification;

  AuthResponseModel({
    required this.success,
    required this.message,
    required this.requiresVerification,
    this.data,
    this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'],
      message: json['message'],
      requiresVerification: json['requiresVerification'] == true,
      data: AuthData.fromJson(json['data']),
      token: json['token'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data!.toJson(),
      'token': token ?? "",
      'requiresVerification': requiresVerification,
    };
  }
}

class AuthData {
  final UserModel user;
  // final bool requiresVerification;

  AuthData({required this.user/*, required this.requiresVerification*/});

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: UserModel.fromJson(json['user']),
      // requiresVerification: json['requiresVerification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      // 'requiresVerification': requiresVerification,
    };
  }
}
