import 'package:aneuso_app/core/constants/app_constants.dart';

import '../domain/entities/auth_response_entity.dart';
import '../domain/entities/user_entity.dart';
import '../domain/entities/otp_verification_entity.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/datasources/remote/auth_remote_data_source.dart';
import '../data/datasources/local/auth_local_data_source.dart';
import 'api_service.dart';
import 'dart:convert';

class AuthService {
  late AuthRepository _authRepository;

  AuthService() {
    final remoteDataSource = AuthRemoteDataSource();
    final localDataSource = AuthLocalDataSource();

    _authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  }

  // Login with email and password
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) async {
    return await _authRepository.login(email: email, password: password);
  }

  // Register new user
  Future<AuthResponseEntity> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int userTypeId,
    required int? designationId,
    String? industryName,
  }) async {
    return await _authRepository.register(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      userTypeId: userTypeId,
      designationId: designationId,
      industryName: industryName,
    );
  }

  // Test login with existing users (uses default password)
  // Future<AuthResponseEntity> testLogin({
  //   required String email,
  // }) async {
  //   return await _authRepository.testLogin(email: email);
  // }

  // Get user profile
  Future<UserEntity> getProfile() async {
    return await _authRepository.getProfile();
  }

  // Update user details
  Future<UserEntity> updateDetails({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    return await _authRepository.updateDetails(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  // Update profile with password change
  Future<Map<String, dynamic>> updateProfileWithPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String currentPassword,
    required String newPassword,
  }) async {
    final api = ApiService();
    final response = await api.put(
      ApiEndpoints.updateDetails,
      body: {
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['success'] == true) {
      return {
        'success': true,
        'user': _parseUserFromJson(body['user'] as Map<String, dynamic>),
        'message': body['message'] ?? 'Profile updated successfully',
      };
    } else {
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to update profile',
      };
    }
  }

  UserEntity _parseUserFromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      userTypeId: json['user_type_id'] as int,
      designationId: json['designation_id'] as int?,
      activeStatus: json['active_status'] as int? ?? 1,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'].toString())
          : null,
    );
  }

  // Logout
  Future<bool> logout() async {
    return await _authRepository.logout();
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    return await _authRepository.isUserLoggedIn();
  }

  // Get current user
  Future<UserEntity?> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  // Verify OTP for email confirmation
  Future<OtpVerificationEntity> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    try {
      final response = await ApiService().post(
        '/email/verify-otp',
        body: {'email': email, 'otp': otp, 'purpose': purpose},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return OtpVerificationEntity.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Failed to verify OTP');
        }
      } else {
        throw Exception('Failed to verify OTP: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<bool> resendOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      final response = await ApiService().post(
        '/email/resend-otp',
        body: {'email': email, 'purpose': purpose},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      } else {
        throw Exception('Failed to resend OTP: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
