import 'dart:convert';

import 'api_service.dart';
import '../domain/entities/tutorial_topic_entity.dart';
import '../domain/entities/tutorial_video_entity.dart';

class TutorialService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getTopics({
    int page = 1,
    int limit = 9999,
    String? search,
  }) async {
    final sb = StringBuffer('/tutorials/topics?page=$page&limit=$limit');
    if (search != null && search.isNotEmpty)
      sb.write('&search=${Uri.encodeComponent(search)}');
    final resp = await _api.get(sb.toString());
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      final data = (body['data'] as List)
          .map((e) => TutorialTopicEntity.fromJson(e))
          .toList();
      return {'data': data, 'pagination': body['pagination']};
    }
    throw Exception('Failed to fetch topics');
  }

  Future<TutorialTopicEntity> getTopic(
    int id, {
    bool includeVideos = false,
    int page = 1,
    int limit = 9999,
  }) async {
    final url =
        '/tutorials/topics/$id?include_videos=${includeVideos ? 'true' : 'false'}&page=$page&limit=$limit';
    final resp = await _api.get(url);
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      return TutorialTopicEntity.fromJson(body['data']);
    }
    throw Exception('Failed to fetch topic');
  }

  Future<Map<String, dynamic>> getVideos({
    int page = 1,
    int limit = 9999,
    int? topicId,
    String? search,
    int? isActive,
  }) async {
    final sb = StringBuffer('/tutorials/videos?page=$page&limit=$limit');
    if (topicId != null) sb.write('&topic_id=$topicId');
    if (search != null && search.isNotEmpty)
      sb.write('&search=${Uri.encodeComponent(search)}');
    if (isActive != null) sb.write('&is_active=$isActive');
    final resp = await _api.get(sb.toString());
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      final data = (body['data'] as List)
          .map((e) => TutorialVideoEntity.fromJson(e))
          .toList();
      return {'data': data, 'pagination': body['pagination']};
    }
    throw Exception('Failed to fetch videos');
  }

  Future<TutorialVideoEntity> getVideo(int id) async {
    final resp = await _api.get('/tutorials/videos/$id');
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      return TutorialVideoEntity.fromJson(body['data']);
    }
    throw Exception('Failed to fetch video');
  }

  Future<List<Map<String, dynamic>>> getSlider() async {
    final resp = await _api.get('/tutorials/slider');
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200 && body['success'] == true) {
      return List<Map<String, dynamic>>.from(body['data'] as List);
    }
    throw Exception('Failed to fetch slider');
  }
}
