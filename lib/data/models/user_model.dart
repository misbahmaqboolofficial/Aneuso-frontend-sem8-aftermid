import '../../core/constants/app_constants.dart';

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int userTypeId;
  final int? designationId;
  final int activeStatus;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userTypeId,
    this.designationId,
    required this.emailVerified,
    this.emailVerifiedAt,
    required this.activeStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      userTypeId: json['user_type_id'],
      designationId: json['designation_id'],
      emailVerified: json['email_verified'],
      emailVerifiedAt: _parseDateTime(json['email_verified_at']),
      activeStatus: json['active_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'user_type_id': userTypeId,
      'designation_id': designationId,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'active_status': activeStatus,
    };
  }

  String get userType {
    switch (userTypeId) {
      case AppConstants.userTypeIndustry:
        return 'Industry';
      case AppConstants.userTypeDriver:
        return 'Driver';
      case AppConstants.userTypeCitizen:
        return 'Citizen';
      case AppConstants.userTypeAdmin:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  bool get isAdmin => userTypeId == AppConstants.userTypeAdmin;
  bool get isIndustry => userTypeId == AppConstants.userTypeIndustry;
  bool get isDriver => userTypeId == AppConstants.userTypeDriver;
  bool get isCitizen => userTypeId == AppConstants.userTypeCitizen;
  bool get isActive => activeStatus == 1;

  static DateTime? _parseDateTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) return null;

    try {
      if (dateTimeValue is DateTime) {
        return dateTimeValue;
      } else if (dateTimeValue is String) {
        return parseAnyFormat(dateTimeValue);
      }
      return null;
    } catch (e) {
      print('Error parsing datetime: $e');
      return null;
    }
  }

  // Different MySQL datetime formats you might encounter
  // String format1 = "2025-11-25T15:33:07.000Z"; // ISO with timezone
  // String format2 = "2025-11-25 15:33:07"; // MySQL standard
  // String format3 = "2025-11-25"; // Date only
  // String format4 = "2025-11-25T15:33:07"; // ISO without timezone

  // Parse them all safely
  static DateTime? parseAnyFormat(String dateString) {
    try {
      if (dateString.contains('T') && dateString.contains('Z')) {
        return DateTime.parse(dateString);
      } else if (dateString.contains('T')) {
        return DateTime.parse(dateString + 'Z');
      } else if (dateString.contains(' ')) {
        return DateTime.parse(dateString.replaceAll(' ', 'T') + 'Z');
      } else {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      return null;
    }
  }
}
