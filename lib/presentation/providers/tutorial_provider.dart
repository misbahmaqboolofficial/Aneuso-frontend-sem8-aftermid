import 'package:flutter/foundation.dart';

import '../../domain/entities/tutorial_topic_entity.dart';
import '../../domain/entities/tutorial_video_entity.dart';
import '../../services/tutorial_service.dart';

class TutorialProvider with ChangeNotifier {
  final TutorialService _service = TutorialService();

  List<TutorialTopicEntity> _topics = [];
  List<TutorialVideoEntity> _videos = [];
  List<Map<String, dynamic>> _slider = [];
  bool _isLoading = false;
  // bool _isLoadingMore = false;
  int _page = 1;
  int _limit = 20;

  List<TutorialTopicEntity> get topics => _topics;
  List<TutorialVideoEntity> get videos => _videos;
  List<Map<String, dynamic>> get slider => _slider;
  bool get isLoading => _isLoading;

  /// Convert slider data to video entities for easier UI consumption
  List<TutorialVideoEntity> get sliderVideos {
    return _slider.map((item) {
      return TutorialVideoEntity(
        id: item['video_id'] as int? ?? 0,
        topicId: item['topic_id'] as int? ?? 0,
        title: item['title'] as String? ?? 'Video',
        youtubeLink: item['youtube_link'] as String? ?? '',
        duration: item['duration'] as String?,
        description: item['description'] as String?,
        isActive: ((item['is_active'] as int?) ?? 1) == 1,
      );
    }).toList();
  }

  Future<void> fetchTopics({String? search, bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await _service.getTopics(
        page: refresh ? 1 : _page,
        limit: _limit,
        search: search,
      );
      final data = resp['data'] as List<TutorialTopicEntity>;
      if (refresh)
        _topics = data;
      else
        _topics.addAll(data);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVideos({
    int? topicId,
    String? search,
    bool refresh = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final resp = await _service.getVideos(
        page: refresh ? 1 : _page,
        limit: _limit,
        topicId: topicId,
        search: search,
      );
      final data = resp['data'] as List<TutorialVideoEntity>;
      if (refresh)
        _videos = data;
      else
        _videos.addAll(data);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSlider() async {
    try {
      _slider = await _service.getSlider();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
