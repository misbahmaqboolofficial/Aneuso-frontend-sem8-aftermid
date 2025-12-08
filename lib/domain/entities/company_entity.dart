class CompanyEntity {
  final int id;
  final String companyName;
  final int companyTypeId;
  final int businessTypeId;
  final String contactPhoneNumber;
  final String contactEmail;
  final String companyAddress;
  final bool isHeadquarter;
  final String wasteType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompanyEntity({
    required this.id,
    required this.companyName,
    required this.companyTypeId,
    required this.businessTypeId,
    required this.contactPhoneNumber,
    required this.contactEmail,
    required this.companyAddress,
    required this.isHeadquarter,
    required this.wasteType,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyEntity.fromJson(Map<String, dynamic> json) {
    return CompanyEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      companyName: json['company_name']?.toString() ?? '',
      companyTypeId: json['company_type_id'] is int
          ? json['company_type_id']
          : int.parse(json['company_type_id'].toString()),
      businessTypeId: json['business_type_id'] is int
          ? json['business_type_id']
          : int.parse(json['business_type_id'].toString()),
      contactPhoneNumber: json['contact_phone_number']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      companyAddress: json['company_address']?.toString() ?? '',
      isHeadquarter:
          (json['is_headquarter'] == 1) || (json['is_headquarter'] == true),
      wasteType: json['waste_type']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}
