class TutorialTopicEntity {
  final int id;
  final String title;
  final String? slug;
  final String? description;
  final DateTime? createdAt;

  TutorialTopicEntity({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.createdAt,
  });

  factory TutorialTopicEntity.fromJson(Map<String, dynamic> json) {
    return TutorialTopicEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
