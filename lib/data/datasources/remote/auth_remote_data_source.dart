import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final String baseUrl;

  AuthRemoteDataSource({this.baseUrl = AppConstants.baseUrl});

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl${ApiEndpoints.login}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return AuthResponseModel.fromJson(jsonResponse);
    }

    final error = jsonDecode(response.body);
    if (response.statusCode == 403 && error['requiresVerification'] == true) {
      final userJson = error['data']?['user'];
      return AuthResponseModel(
        success: false,
        message: error['message'] ?? 'Email verification required.',
        requiresVerification: true,
        data: userJson != null
            ? AuthData(user: UserModel.fromJson(userJson))
            : null,
      );
    }

    return AuthResponseModel(
      success: false,
      message: error['message'] ?? 'Login failed.',
      requiresVerification: false,
      data: AuthData(
        user: UserModel(
          id: 0,
          fullName: '',
          email: email,
          phoneNumber: '',
          userTypeId: 0,
          designationId: 0,
          activeStatus: 0,
          emailVerifiedAt: null,
          emailVerified: false,
        ),
      ),
    );
  }

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int userTypeId,
    required int? designationId,
    String? industryName,
  }) async {
    final url = Uri.parse('$baseUrl${ApiEndpoints.register}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'user_type_id': userTypeId,
        'designation_id': designationId,
        'industry_name': industryName,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      // debugPrint('Registration Response: $jsonResponse');
      return AuthResponseModel.fromJson(jsonResponse);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Registration failed');
    }
  }

  Future<UserModel> getProfile() async {
    final url = Uri.parse('$baseUrl${ApiEndpoints.profile}');
    final token = StorageUtil.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UserModel.fromJson(jsonResponse['user']);
    } else if (response.statusCode == 401) {
      await StorageUtil.clearAuthData();
      throw Exception('Authentication failed. Please login again.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get profile');
    }
  }

  Future<UserModel> updateDetails({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$baseUrl${ApiEndpoints.updateDetails}');
    final token = StorageUtil.getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return UserModel.fromJson(jsonResponse['user']);
    } else if (response.statusCode == 401) {
      await StorageUtil.clearAuthData();
      throw Exception('Authentication failed. Please login again.');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update details');
    }
  }
}
