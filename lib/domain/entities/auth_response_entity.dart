import 'user_entity.dart';

class AuthResponseEntity {
  final bool success;
  final String? token;
  final UserEntity? user;
  final String message;

  AuthResponseEntity({
    required this.success,
    this.token,
    required this.user,
    required this.message,
  });
}