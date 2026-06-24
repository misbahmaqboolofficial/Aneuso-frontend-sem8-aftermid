import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/data/services/driver_rating_api_service.dart';
import 'package:flutter/foundation.dart';

/// Provider for driver ratings: driver self-view, industry submit, admin lists.
class DriverRatingsProvider extends ChangeNotifier {
  final DriverRatingApiService _api = DriverRatingApiService.instance;

  bool driverLoading = false;
  String? driverError;
  Map<String, dynamic>? driverBundle;

  bool adminLoading = false;
  String? adminError;
  List<dynamic> adminRows = [];
  int adminTotal = 0;
  int adminPage = 1;
  Map<String, dynamic>? adminAnalytics;

  Future<void> loadDriverMe() async {
    driverLoading = true;
    driverError = null;
    notifyListeners();
    try {
      final token = StorageUtil.getToken();
      if (token == null) {
        driverError = 'Not logged in';
        driverLoading = false;
        notifyListeners();
        return;
      }
      final res = await _api.getDriverRatingsMe(token);
      if (res['success'] == true) {
        driverBundle = res['data'] as Map<String, dynamic>?;
      } else {
        driverError = res['message']?.toString() ?? 'Failed to load ratings';
      }
    } catch (e) {
      driverError = e.toString();
    }
    driverLoading = false;
    notifyListeners();
  }

  Future<void> loadAdminRatings({
    int page = 1,
    int? driverId,
    String? search,
    bool lowOnly = false,
    bool topDrivers = false,
  }) async {
    adminLoading = true;
    adminError = null;
    adminPage = page;
    notifyListeners();
    try {
      final token = StorageUtil.getToken();
      if (token == null) {
        adminError = 'Not logged in';
        adminLoading = false;
        notifyListeners();
        return;
      }
      final res = await _api.getAdminRatings(
        token: token,
        page: page,
        driverId: driverId,
        search: search,
        lowOnly: lowOnly,
        topDrivers: topDrivers,
      );
      if (res['success'] == true) {
        if (res['mode'] == 'top_drivers') {
          adminRows = (res['data'] as List?) ?? [];
          adminTotal = adminRows.length;
        } else {
          adminRows = (res['data'] as List?) ?? [];
          final pag = res['pagination'] as Map<String, dynamic>?;
          adminTotal = pag?['total'] is int
              ? pag!['total'] as int
              : int.tryParse('${pag?['total']}') ?? adminRows.length;
        }
      } else {
        adminError = res['message']?.toString() ?? 'Failed';
      }
    } catch (e) {
      adminError = e.toString();
    }
    adminLoading = false;
    notifyListeners();
  }

  Future<void> loadAdminAnalytics() async {
    try {
      final token = StorageUtil.getToken();
      if (token == null) return;
      final res = await _api.getAdminAnalytics(token);
      if (res['success'] == true) {
        adminAnalytics = res['data'] as Map<String, dynamic>?;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> deleteRating(int id) async {
    final token = StorageUtil.getToken();
    if (token == null) return false;
    final res = await _api.deleteAdminRating(token: token, ratingId: id);
    if (res['success'] == true) {
      adminRows.removeWhere((e) => e is Map && e['id'] == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> submitIndustryRating({
    required int pickupId,
    required int rating,
    String? reviewComment,
  }) async {
    final token = StorageUtil.getToken();
    if (token == null) {
      return {'success': false, 'message': 'Not logged in'};
    }
    return _api.submitIndustryRating(
      token: token,
      pickupId: pickupId,
      rating: rating,
      reviewComment: reviewComment,
    );
  }
}
