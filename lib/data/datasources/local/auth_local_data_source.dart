import 'dart:convert';

import '../../../core/utils/storage_util.dart';
import '../../models/user_model.dart';

class AuthLocalDataSource {
  Future<void> saveToken(String token) async {
    await StorageUtil.setToken(token);
  }

  Future<String?> getToken() async {
    return StorageUtil.getToken();
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await StorageUtil.setUserData(userJson);
  }

  Future<UserModel?> getCurrentUser() async {
    final userJson = StorageUtil.getUserData();
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await StorageUtil.clearAuthData();
  }
}