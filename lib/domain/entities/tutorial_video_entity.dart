class TutorialVideoEntity {
  final int id;
  final int topicId;
  final String title;
  final String youtubeLink;
  final String? duration;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  TutorialVideoEntity({
    required this.id,
    required this.topicId,
    required this.title,
    required this.youtubeLink,
    this.duration,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory TutorialVideoEntity.fromJson(Map<String, dynamic> json) {
    return TutorialVideoEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      topicId: json['topic_id'] is int
          ? json['topic_id']
          : int.parse(json['topic_id'].toString()),
      title: json['title']?.toString() ?? '',
      youtubeLink: json['youtube_link']?.toString() ?? '',
      duration: json['duration']?.toString(),
      description: json['description']?.toString(),
      isActive: (json['is_active'] == 1) || (json['is_active'] == true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
