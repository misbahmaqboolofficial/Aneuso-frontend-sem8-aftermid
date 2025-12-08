import 'dart:convert';
import 'dart:async';

import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/data/models/user_model.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/master_type_entity.dart';
import '../../domain/entities/designation_entity.dart';
// import '../../domain/entities/otp_verification_entity.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  // Master data
  List<MasterTypeEntity> _userTypes = [];
  List<DesignationEntity> _designations = [];
  bool _isLoadingUserTypes = false;
  bool _isLoadingDesignations = false;

  // OTP verification state
  bool _isVerifyingOtp = false;
  bool _isResendingOtp = false;
  int _otpTimeoutSeconds = 600; // 10 minutes
  Timer? _otpTimer;
  String? _otpVerificationEmail;
  String? _otpVerificationPurpose;

  List<MasterTypeEntity> get userTypes => _userTypes;
  List<DesignationEntity> get designations => _designations;
  bool get isLoadingUserTypes => _isLoadingUserTypes;
  bool get isLoadingDesignations => _isLoadingDesignations;
  bool get isVerifyingOtp => _isVerifyingOtp;
  bool get isResendingOtp => _isResendingOtp;
  int get otpTimeoutSeconds => _otpTimeoutSeconds;
  String? get otpVerificationEmail => _otpVerificationEmail;
  String? get otpVerificationPurpose => _otpVerificationPurpose;

  // Getters
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isUserLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user types (master data)
  Future<void> fetchUserTypes() async {
    _isLoadingUserTypes = true;
    notifyListeners();

    try {
      final response = await ApiService().get('/master-types/user-types');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'] as List;
          _userTypes = data.map((e) => MasterTypeEntity.fromJson(e)).toList();
        } else {
          _error = 'Failed to load user types';
        }
      } else {
        _error = 'Failed to load user types: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingUserTypes = false;
      notifyListeners();
    }
  }

  // Fetch industry designations (master data)
  Future<void> fetchIndustryDesignations() async {
    _isLoadingDesignations = true;
    notifyListeners();

    try {
      final response = await ApiService().get(
        '/master-types/industry-designations',
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'] as List;
          _designations = data
              .map((e) => DesignationEntity.fromJson(e))
              .toList();
        } else {
          _error = 'Failed to load designations';
        }
      } else {
        _error = 'Failed to load designations: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDesignations = false;
      notifyListeners();
    }
  }

  // Login method
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );
      if (authResponse.success == false) {
        _error = authResponse.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _currentUser = authResponse.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register method
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int userTypeId,
    required int? designationId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        userTypeId: userTypeId,
        designationId: designationId,
      );
      // _currentUser = authResponse.user;
      // debugPrint(
      //   'existing user: ${jsonEncode(UserModel(id: authResponse.user!.id, fullName: authResponse.user!.fullName, email: authResponse.user!.email, phoneNumber: authResponse.user!.phoneNumber, userTypeId: authResponse.user!.userTypeId, designationId: authResponse.user!.designationId, activeStatus: authResponse.user!.activeStatus, emailVerifiedAt: authResponse.user!.emailVerifiedAt, emailVerified: authResponse.user!.emailVerifiedAt != null).toJson())}',
      // );
      await StorageUtil.setStringData(
        "temp_user",
        jsonEncode(
          UserModel(
            id: authResponse.user!.id,
            fullName: authResponse.user!.fullName,
            email: authResponse.user!.email,
            phoneNumber: authResponse.user!.phoneNumber,
            userTypeId: authResponse.user!.userTypeId,
            designationId: authResponse.user!.designationId,
            activeStatus: authResponse.user!.activeStatus,
            emailVerifiedAt: authResponse.user!.emailVerifiedAt,
            emailVerified: authResponse.user!.emailVerifiedAt != null,
          ).toJson(),
        ),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Test login method
  // Future<bool> testLogin({required String email}) async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     final authResponse = await _authService.testLogin(email: email);
  //     _currentUser = authResponse.user;
  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _error = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  // Update details method
  Future<bool> updateDetails({
    required String fullName,
    required String email,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.updateDetails(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // String token = StorageUtil.getToken() ?? "";
      // String user = StorageUtil.getUserData() ?? "";
      // print("Logout called token. $token ");
      // print("logout called user. $user");
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      // print("logout called error. $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Start OTP verification process
  void startOtpVerification({required String email, required String purpose}) {
    _otpVerificationEmail = email;
    _otpVerificationPurpose = purpose;
    _otpTimeoutSeconds = 600; // 10 minutes
    _startOtpCountdown();
    notifyListeners();
  }

  // Start countdown timer for OTP
  void _startOtpCountdown() {
    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimeoutSeconds > 0) {
        _otpTimeoutSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  // Verify OTP
  Future<bool> verifyOtp({required String otp, UserEntity? user}) async {
    if (_otpVerificationEmail == null || _otpVerificationPurpose == null) {
      _error = 'OTP verification session not initialized';
      notifyListeners();
      return false;
    }

    _isVerifyingOtp = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOtp(
        email: _otpVerificationEmail!,
        otp: otp,
        purpose: _otpVerificationPurpose!,
      );

      if (result.verified) {
        _otpTimer?.cancel();
        _otpVerificationEmail = null;
        _otpVerificationPurpose = null;
        _isVerifyingOtp = false;
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        _error = 'OTP verification failed';
        _isVerifyingOtp = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isVerifyingOtp = false;
      notifyListeners();
      return false;
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    if (_otpVerificationEmail == null || _otpVerificationPurpose == null) {
      _error = 'OTP verification session not initialized';
      notifyListeners();
      return false;
    }

    _isResendingOtp = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.resendOtp(
        email: _otpVerificationEmail!,
        purpose: _otpVerificationPurpose!,
      );

      if (success) {
        _otpTimeoutSeconds = 600; // Reset to 10 minutes
        _startOtpCountdown();
      } else {
        _error = 'Failed to resend OTP';
      }

      _isResendingOtp = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isResendingOtp = false;
      notifyListeners();
      return false;
    }
  }

  // Cancel OTP verification
  void cancelOtpVerification() {
    _otpTimer?.cancel();
    _otpVerificationEmail = null;
    _otpVerificationPurpose = null;
    _otpTimeoutSeconds = 600;
    notifyListeners();
  }

  // Update profile with password change
  Future<bool> updateProfileWithPassword({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.updateProfileWithPassword(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        _currentUser = result['user'] as UserEntity;
        _error = result['message'] as String?;
      } else {
        _error = result['message'] as String? ?? 'Failed to update profile';
      }

      _isLoading = false;
      notifyListeners();
      return result['success'] == true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
