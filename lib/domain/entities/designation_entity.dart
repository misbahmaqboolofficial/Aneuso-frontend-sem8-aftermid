class DesignationEntity {
  final int id;
  final String designationName;

  DesignationEntity({required this.id, required this.designationName});

  factory DesignationEntity.fromJson(Map<String, dynamic> json) {
    return DesignationEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      designationName: json['designation_name']?.toString() ?? '',
    );
  }
}
