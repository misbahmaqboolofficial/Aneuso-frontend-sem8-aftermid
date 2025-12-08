import 'package:aneuso_app/domain/entities/auth_response_entity.dart';
import 'package:aneuso_app/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  });
  
  Future<AuthResponseEntity> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int userTypeId,
    required int? designationId,
  });
  
  // Future<AuthResponseEntity> testLogin({
  //   required String email,
  // });
  
  Future<UserEntity> getProfile();
  
  Future<UserEntity> updateDetails({
    required String fullName,
    required String email,
    required String phoneNumber,
  });
  
  Future<bool> logout();
  
  Future<bool> isUserLoggedIn();
  
  Future<UserEntity?> getCurrentUser();
}