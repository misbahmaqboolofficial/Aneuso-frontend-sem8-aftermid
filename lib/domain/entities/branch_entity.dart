class BranchEntity {
  final int id;
  final String branchName;
  final String branchCode;
  final int companyId;
  final String contactPhoneNumber;
  final String contactEmail;
  final String branchAddress;
  final bool isMainBranch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BranchEntity({
    required this.id,
    required this.branchName,
    required this.branchCode,
    required this.companyId,
    required this.contactPhoneNumber,
    required this.contactEmail,
    required this.branchAddress,
    required this.isMainBranch,
    this.createdAt,
    this.updatedAt,
  });

  factory BranchEntity.fromJson(Map<String, dynamic> json) {
    return BranchEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      branchName: json['branch_name']?.toString() ?? '',
      branchCode: json['branch_code']?.toString() ?? '',
      companyId: json['company_id'] is int
          ? json['company_id']
          : int.parse(json['company_id'].toString()),
      contactPhoneNumber: json['contact_phone_number']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      branchAddress: json['branch_address']?.toString() ?? '',
      isMainBranch:
          (json['is_main_branch'] == 1) || (json['is_main_branch'] == true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
