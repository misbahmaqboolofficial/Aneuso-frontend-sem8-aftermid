class TutorialSliderEntity {
  final int id;
  final int videoId;
  final int position;
  final bool isActive;

  TutorialSliderEntity({
    required this.id,
    required this.videoId,
    required this.position,
    required this.isActive,
  });

  factory TutorialSliderEntity.fromJson(Map<String, dynamic> json) {
    return TutorialSliderEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      videoId: json['video_id'] is int
          ? json['video_id']
          : int.parse(json['video_id'].toString()),
      position: json['position'] is int
          ? json['position']
          : int.parse(json['position'].toString()),
      isActive: (json['is_active'] == 1) || (json['is_active'] == true),
    );
  }
}
