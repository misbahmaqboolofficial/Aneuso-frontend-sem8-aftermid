import 'dart:convert';

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

class DriverRatingApiService {
  DriverRatingApiService._();
  static final DriverRatingApiService instance = DriverRatingApiService._();

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> submitIndustryRating({
    required String token,
    required int pickupId,
    required int rating,
    String? reviewComment,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}/industry/ratings/service/$pickupId',
    );
    final body = <String, dynamic>{
      'rating': rating,
      if (reviewComment != null && reviewComment.trim().isNotEmpty)
        'review_comment': reviewComment.trim(),
    };
    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    map['_statusCode'] = res.statusCode;
    return map;
  }

  Future<Map<String, dynamic>> getMyIndustryRatings({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/industry/driver-ratings/my')
        .replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });
    final res = await http.get(uri, headers: _headers(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDriverRatingsMe(String token) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/drivers/ratings/me');
    final res = await http.get(uri, headers: _headers(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDriverAverageMe(String token) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/drivers/ratings/me/average');
    final res = await http.get(uri, headers: _headers(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAdminRatings({
    required String token,
    int page = 1,
    int limit = 20,
    int? driverId,
    String? search,
    bool lowOnly = false,
    bool topDrivers = false,
  }) async {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (driverId != null) 'driver_id': '$driverId',
      if (search != null && search.isNotEmpty) 'search': search,
      if (lowOnly) 'low_only': 'true',
      if (topDrivers) 'top_drivers': 'true',
    };
    final uri =
        Uri.parse('${AppConstants.baseUrl}/admin/driver-ratings').replace(
              queryParameters: q,
            );
    final res = await http.get(uri, headers: _headers(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAdminAnalytics(String token) async {
    final uri =
        Uri.parse('${AppConstants.baseUrl}/admin/driver-ratings/analytics');
    final res = await http.get(uri, headers: _headers(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteAdminRating({
    required String token,
    required int ratingId,
  }) async {
    final uri =
        Uri.parse('${AppConstants.baseUrl}/admin/driver-ratings/$ratingId');
    final res = await http.delete(uri, headers: _headers(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
