class MasterTypeEntity {
  final int id;
  final String typeName;

  MasterTypeEntity({required this.id, required this.typeName});

  factory MasterTypeEntity.fromJson(Map<String, dynamic> json) {
    return MasterTypeEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      typeName: json['type_name']?.toString() ?? '',
    );
  }
}
