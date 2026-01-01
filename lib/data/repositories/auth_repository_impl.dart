// import 'dart:convert';
import 'package:aneuso_app/core/constants/app_constants.dart';
// import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/local/auth_local_data_source.dart';
// import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthResponseEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      if (!response.success) {
        return AuthResponseEntity(
          success: response.success,
          token: null,
          message: response.message,
          user: null,
        );
      }

      if (response.token == null || response.token == "") {
        return AuthResponseEntity(
          success: false,
          token: null,
          message: "Login failed, token not issued to user.",
          user: null,
        );
      }
      // Save token and user data locally
      // if (response.token != null && response.token != "") {
      await localDataSource.saveToken(response.token!);
      // }
      await localDataSource.saveUser(response.data!.user);

      return AuthResponseEntity(
        success: response.success,
        token: response.token,
        message: response.message,
        user: UserEntity(
          id: response.data!.user.id,
          fullName: response.data!.user.fullName,
          email: response.data!.user.email,
          phoneNumber: response.data!.user.phoneNumber,
          userTypeId: response.data!.user.userTypeId,
          designationId: response.data!.user.designationId,
          activeStatus: response.data!.user.activeStatus,
          emailVerifiedAt: response.data!.user.emailVerifiedAt,
          driverId: response.data!.user.driverId,
        ),
      );
    } catch (e) {
      return AuthResponseEntity(
        success: false,
        token: null,
        message: AppConstants.isDevelopment
            ? e.toString()
            : "Login failed, error while login.", //e.toString(),
        user: null,
      );
    }
  }

  @override
  Future<AuthResponseEntity> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int userTypeId,
    required int? designationId,
  }) async {
    try {
      final response = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        userTypeId: userTypeId,
        designationId: designationId,
      );
      // // Save token and user data locally
      // if (response.token != null && response.token != "") {
      //   await localDataSource.saveToken(response.token!);
      // }
      // await localDataSource.saveToken(response.token);
      // await localDataSource.saveUser(response.data!.user);

      return AuthResponseEntity(
        success: response.success,
        token: response.token,
        message: response.message,
        user: UserEntity(
          id: response.data!.user.id,
          fullName: response.data!.user.fullName,
          email: response.data!.user.email,
          phoneNumber: response.data!.user.phoneNumber,
          userTypeId: response.data!.user.userTypeId,
          designationId: response.data!.user.designationId,
          activeStatus: response.data!.user.activeStatus,
          emailVerifiedAt: response.data!.user.emailVerifiedAt,
        ),
      );
    } catch (e) {
      return AuthResponseEntity(
        success: false,
        token: null,
        message: AppConstants.isDevelopment
            ? e.toString()
            : "Login failed, error while login.", //e.toString(),
        user: null,
      );
    }
  }

  // @override
  // Future<AuthResponseEntity> testLogin({
  //   required String email,
  // }) async {
  //   try {
  //     final response = await remoteDataSource.testLogin(email: email);

  //     // Save token and user data locally
  //     // await localDataSource.saveToken(response.token);
  //     if(response.token != null && response.token != ""){
  //       await localDataSource.saveToken(response.token!);
  //     }
  //     await localDataSource.saveUser(response.data.user);

  //     return AuthResponseEntity(
  //       success: response.success,
  //       token: response.token,
  //       user: UserEntity(
  //         id: response.data.user.id,
  //         fullName: response.data.user.fullName,
  //         email: response.data.user.email,
  //         phoneNumber: response.data.user.phoneNumber,
  //         userTypeId: response.data.user.userTypeId,
  //         designationId: response.data.user.designationId,
  //         activeStatus: response.data.user.activeStatus,
  //         emailVerifiedAt: response.data.user.emailVerifiedAt,
  //       ),
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  @override
  Future<UserEntity> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      return UserEntity(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        userTypeId: user.userTypeId,
        designationId: user.designationId,
        activeStatus: user.activeStatus,
        emailVerifiedAt: user.emailVerifiedAt,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> updateDetails({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final user = await remoteDataSource.updateDetails(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      return UserEntity(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        userTypeId: user.userTypeId,
        designationId: user.designationId,
        activeStatus: user.activeStatus,
        emailVerifiedAt: user.emailVerifiedAt,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await localDataSource.clearAuthData();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return await localDataSource.hasToken();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await localDataSource.getCurrentUser();
    if (user != null) {
      return UserEntity(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        userTypeId: user.userTypeId,
        designationId: user.designationId,
        activeStatus: user.activeStatus,
        emailVerifiedAt: user.emailVerifiedAt,
      );
    }
    return null;
  }
}
