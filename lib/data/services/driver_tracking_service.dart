import 'dart:async';
import 'dart:convert';

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

typedef TrackingTick = void Function({
  required bool autoArrived,
  required int? pickupStatusId,
});

/// Foreground + background GPS tracking for industry pickups and admin cleanup missions.
class DriverTrackingService {
  DriverTrackingService._();
  static final DriverTrackingService instance = DriverTrackingService._();

  final String _baseUrl = AppConstants.baseUrl;
  StreamSubscription<Position>? _positionSub;
  Timer? _heartbeatTimer;
  String? _activeTaskType;
  int? _activeTaskId;
  int? _driverId;
  DateTime? _lastPostAt;
  Position? _lastPostedPosition;
  TrackingTick? _onTick;

  static const Duration _minPostInterval = Duration(seconds: 3);
  static const double _minMoveMeters = 4;
  static const Duration _heartbeatInterval = Duration(seconds: 12);

  bool get isActive =>
      _activeTaskType != null &&
      _activeTaskId != null &&
      _positionSub != null;

  int? get activeTaskId => _activeTaskId;
  String? get activeTaskType => _activeTaskType;

  LocationSettings _locationSettings() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ANEUSO — Live GPS tracking',
          notificationText: 'Sharing your location while you move',
          notificationChannelName: 'Driver location tracking',
          enableWakeLock: true,
        ),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
  }

  bool _isDesktopWithoutGps() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Requests location (and background location on Android) plus notification permission for FGS.
  Future<bool> ensureLocationPermission({bool requireBackground = true}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return false;
    }

    if (requireBackground && perm == LocationPermission.whileInUse) {
      perm = await Geolocator.requestPermission();
    }

    if (requireBackground && !kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final bg = await Permission.locationAlways.status;
      if (!bg.isGranted) {
        await Permission.locationAlways.request();
      }
      final notif = await Permission.notification.status;
      if (!notif.isGranted) {
        await Permission.notification.request();
      }
      // Helps tracking survive screen-off / background on Samsung, Xiaomi, etc.
      final battery = await Permission.ignoreBatteryOptimizations.status;
      if (!battery.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }

    perm = await Geolocator.checkPermission();
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  Future<void> start({
    required String taskType,
    required int taskId,
    required int driverId,
    TrackingTick? onTick,
  }) async {
    await stop();
    if (_isDesktopWithoutGps()) {
      throw Exception(
        'Live GPS tracking only works on a physical Android or iPhone. Install the app on the driver phone and tap Start live GPS.',
      );
    }
    final ok = await ensureLocationPermission(requireBackground: true);
    if (!ok) {
      throw Exception(
        'Location permission is required. Allow "Always" or "While using" so tracking works in the background.',
      );
    }

    _activeTaskType = taskType;
    _activeTaskId = taskId;
    _driverId = driverId;
    _onTick = onTick;

    final token = StorageUtil.getToken();
    double? startLat;
    double? startLng;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      startLat = pos.latitude;
      startLng = pos.longitude;
    } catch (e) {
      debugPrint('Could not get current location for start: $e');
    }

    final startRes = await http.post(
      Uri.parse('$_baseUrl/drivers/tracking/start'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'task_type': taskType,
        'task_id': taskId,
        if (startLat != null) 'latitude': startLat,
        if (startLng != null) 'longitude': startLng,
      }),
    );
    if (startRes.statusCode < 200 || startRes.statusCode >= 300) {
      _activeTaskType = null;
      _activeTaskId = null;
      _driverId = null;
      final err = jsonDecode(startRes.body);
      throw Exception(err['message'] ?? 'Failed to start tracking');
    }

    final startData = jsonDecode(startRes.body);
    final resolvedDriverId = startData['data']?['driver_id'];
    if (resolvedDriverId != null) {
      final parsed = resolvedDriverId is int
          ? resolvedDriverId
          : int.tryParse('$resolvedDriverId');
      if (parsed != null && parsed > 0) {
        _driverId = parsed;
      }
    }

    await _persistSession();
    _lastPostAt = null;
    await _startPositionStream();
  }

  /// Resume GPS stream after app restart if a session was saved (driver still logged in).
  Future<void> restoreSessionIfNeeded() async {
    if (isActive) return;

    final taskType =
        StorageUtil.getStringData(AppConstants.activeTrackingTaskTypeKey);
    final taskIdStr =
        StorageUtil.getStringData(AppConstants.activeTrackingTaskIdKey);
    final driverIdStr =
        StorageUtil.getStringData(AppConstants.activeTrackingDriverIdKey);

    if (taskType == null || taskIdStr == null || driverIdStr == null) {
      return;
    }
    if (StorageUtil.getToken() == null) {
      await _clearPersistedSession();
      return;
    }

    final taskId = int.tryParse(taskIdStr);
    final driverId = int.tryParse(driverIdStr);
    if (taskId == null || driverId == null) {
      await _clearPersistedSession();
      return;
    }

    final ok = await ensureLocationPermission(requireBackground: true);
    if (!ok) return;

    _activeTaskType = taskType;
    _activeTaskId = taskId;
    _driverId = driverId;
    _onTick = null;

    try {
      final token = StorageUtil.getToken();
      final res = await http.post(
        Uri.parse('$_baseUrl/drivers/tracking/resume'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'task_type': taskType,
          'task_id': taskId,
        }),
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('Resume tracking rejected: ${res.body}');
        await _clearPersistedSession();
        return;
      }

      await _startPositionStream();
      debugPrint('Restored background tracking for $taskType #$taskId');
    } catch (e) {
      debugPrint('Failed to restore tracking: $e');
      await stop(notifyServer: false);
    }
  }

  Future<void> _startPositionStream() async {
    await _positionSub?.cancel();
    _positionSub = null;

    final settings = _locationSettings();
    _positionSub = Geolocator.getPositionStream(locationSettings: settings).listen(
      (pos) => _postPosition(pos),
      onError: (e) => debugPrint('Position stream error: $e'),
    );

    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) async {
      if (_activeTaskType == null) return;
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: settings,
        );
        await _postPosition(pos, force: true);
      } catch (e) {
        debugPrint('Heartbeat GPS error: $e');
      }
    });

    try {
      final initial = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );
      await _postPosition(initial);
    } catch (e) {
      debugPrint('Initial position error: $e');
    }
  }

  Future<void> _postPosition(Position pos, {bool force = false}) async {
    if (_activeTaskType == null || _activeTaskId == null || _driverId == null) {
      return;
    }

    final now = DateTime.now();
    final movedSinceLastPost = _lastPostedPosition == null
        ? true
        : Geolocator.distanceBetween(
              _lastPostedPosition!.latitude,
              _lastPostedPosition!.longitude,
              pos.latitude,
              pos.longitude,
            ) >=
            _minMoveMeters;
    final isMoving = pos.speed > 0.5;
    if (!force &&
        _lastPostAt != null &&
        now.difference(_lastPostAt!) < _minPostInterval &&
        !movedSinceLastPost &&
        !isMoving) {
      return;
    }
    _lastPostAt = now;
    _lastPostedPosition = pos;

    try {
      final token = StorageUtil.getToken();
      final res = await http.post(
        Uri.parse('$_baseUrl/drivers/tracking/location'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'task_type': _activeTaskType,
          'task_id': _activeTaskId,
          if (_driverId != null && _driverId! > 0) 'driver_id': _driverId,
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'speed': pos.speed >= 0 ? pos.speed * 3.6 : 0,
          'heading': pos.heading,
          'accuracy': pos.accuracy,
        }),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body);
        final auto = data['auto_arrived'] == true;
        int? status;
        if (auto) {
          status = PickupStatus.reachedDestination;
        }
        _onTick?.call(autoArrived: auto, pickupStatusId: status);
      }
    } catch (e) {
      debugPrint('Tracking location error: $e');
    }
  }

  Future<void> markReached({
    required String taskType,
    required int taskId,
  }) async {
    double? reachedLat;
    double? reachedLng;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      reachedLat = pos.latitude;
      reachedLng = pos.longitude;
    } catch (e) {
      debugPrint('Could not get current location for reached: $e');
    }

    final token = StorageUtil.getToken();
    final res = await http.post(
      Uri.parse('$_baseUrl/drivers/tracking/reached'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'task_type': taskType,
        'task_id': taskId,
        if (reachedLat != null) 'latitude': reachedLat,
        if (reachedLng != null) 'longitude': reachedLng,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final err = jsonDecode(res.body);
      throw Exception(err['message'] ?? 'Failed to mark arrived');
    }
    if (_activeTaskType == taskType && _activeTaskId == taskId) {
      await stop(notifyServer: false);
    }
  }

  Future<void> stop({bool notifyServer = true}) async {
    final taskType = _activeTaskType;
    final taskId = _activeTaskId;

    await _positionSub?.cancel();
    _positionSub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _lastPostAt = null;
    _lastPostedPosition = null;
    _onTick = null;
    _activeTaskType = null;
    _activeTaskId = null;
    _driverId = null;
    await _clearPersistedSession();

    if (notifyServer && taskType != null && taskId != null) {
      try {
        final token = StorageUtil.getToken();
        await http.post(
          Uri.parse('$_baseUrl/drivers/tracking/stop'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'task_type': taskType,
            'task_id': taskId,
          }),
        );
      } catch (e) {
        debugPrint('Stop tracking API error: $e');
      }
    }
  }

  Future<void> _persistSession() async {
    if (_activeTaskType == null ||
        _activeTaskId == null ||
        _driverId == null) {
      return;
    }
    await StorageUtil.setStringData(
      AppConstants.activeTrackingTaskTypeKey,
      _activeTaskType!,
    );
    await StorageUtil.setStringData(
      AppConstants.activeTrackingTaskIdKey,
      _activeTaskId!.toString(),
    );
    await StorageUtil.setStringData(
      AppConstants.activeTrackingDriverIdKey,
      _driverId!.toString(),
    );
  }

  Future<void> _clearPersistedSession() async {
    await StorageUtil.removeStringData(AppConstants.activeTrackingTaskTypeKey);
    await StorageUtil.removeStringData(AppConstants.activeTrackingTaskIdKey);
    await StorageUtil.removeStringData(AppConstants.activeTrackingDriverIdKey);
  }

  static String taskTypeForSource(String source) =>
      source == 'Admin'
          ? TrackingTaskType.adminCleanup
          : TrackingTaskType.industryPickup;

  static int displayStatusForTask(Map<String, dynamic> task) {
    if (task['source'] == 'Admin') {
      final rs = task['report_status_id'];
      final rid = rs is int ? rs : int.tryParse('$rs') ?? 0;
      if (rid == ReportStatus.enRoute) return PickupStatus.enRoute;
      if (rid == ReportStatus.arrived) return PickupStatus.reachedDestination;
      if (rid == ReportStatus.collected || rid == ReportStatus.cleaned) {
        return PickupStatus.completed;
      }
      return PickupStatus.scheduled;
    }
    final sid = task['pickup_status_id'];
    return sid is int ? sid : int.tryParse('$sid') ?? PickupStatus.scheduled;
  }
}
