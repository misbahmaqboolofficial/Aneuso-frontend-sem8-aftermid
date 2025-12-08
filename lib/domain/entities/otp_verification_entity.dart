class OtpVerificationEntity {
  final String email;
  final String purpose;
  final bool verified;

  OtpVerificationEntity({
    required this.email,
    required this.purpose,
    required this.verified,
  });

  factory OtpVerificationEntity.fromJson(Map<String, dynamic> json) {
    return OtpVerificationEntity(
      email: json['email']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      verified: json['verified'] == true,
    );
  }
}
