class UserEntity {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final int userTypeId;
  final int? designationId;
  final int activeStatus;
  final DateTime? emailVerifiedAt;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.userTypeId,
    this.designationId,
    required this.activeStatus,
    this.emailVerifiedAt,
  });

  String get userType {
    switch (userTypeId) {
      case 1:
        return 'Industry';
      case 2:
        return 'Driver';
      case 3:
        return 'Citizen';
      case 4:
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  bool get isAdmin => userTypeId == 4;
  bool get isIndustry => userTypeId == 1;
  bool get isDriver => userTypeId == 2;
  bool get isCitizen => userTypeId == 3;
  bool get isActive => activeStatus == 1;
  bool get isEmailVerified => emailVerifiedAt != null;
  
}