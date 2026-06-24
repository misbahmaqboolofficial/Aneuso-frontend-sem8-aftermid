import 'dart:async';
import 'dart:convert';

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/core/utils/route_service.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/presentation/widgets/pickup_tracking_map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Compact live map for pickup/mission detail screens (Industry & Admin).
class EmbeddedLiveTrackingMap extends StatefulWidget {
  const EmbeddedLiveTrackingMap({
    super.key,
    required this.taskId,
    this.taskType = TrackingTaskType.industryPickup,
    this.height = 240,
    this.onOpenFullMap,
  });

  final int taskId;
  final String taskType;
  final double height;
  final VoidCallback? onOpenFullMap;

  @override
  State<EmbeddedLiveTrackingMap> createState() =>
      _EmbeddedLiveTrackingMapState();
}

class _EmbeddedLiveTrackingMapState extends State<EmbeddedLiveTrackingMap> {
  Timer? _pollTimer;
  Map<String, dynamic>? _pickup;
  Map<String, dynamic>? _driverLocation;
  List<LatLng> _routeHistory = [];
  List<LatLng> _navigationRoute = [];
  double? _startLat;
  double? _startLng;
  int? _routeEtaMinutes;
  double? _routeRemainingKm;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetch());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final token = StorageUtil.getToken();
      final res = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}/drivers/tracking/live'
          '?task_type=${widget.taskType}&task_id=${widget.taskId}',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200 || !mounted) return;
      final d = jsonDecode(res.body);
      if (d['success'] != true) return;

      final history = <LatLng>[];
      final raw = d['data']['location_history'];
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          final lat = double.tryParse(item['latitude']?.toString() ?? '');
          final lng = double.tryParse(item['longitude']?.toString() ?? '');
          if (lat != null && lng != null && !(lat == 0 && lng == 0)) {
            history.add(LatLng(lat, lng));
          }
        }
      }

      setState(() {
        _pickup = d['data']['pickup'];
        _driverLocation = d['data']['driver_location'];
        _routeHistory = history;
        _loading = false;
        if (history.isNotEmpty && _startLat == null) {
          _startLat = history.first.latitude;
          _startLng = history.first.longitude;
        }
      });
      await _updateRoute();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateRoute() async {
    final driverLat =
        double.tryParse(_driverLocation?['latitude']?.toString() ?? '');
    final driverLng =
        double.tryParse(_driverLocation?['longitude']?.toString() ?? '');
    final destLat = _pickupLat;
    final destLng = _pickupLng;
    if (driverLat == null ||
        driverLng == null ||
        destLat == null ||
        destLng == null) {
      return;
    }

    final result = await RouteService.fetchDrivingRoute(
      LatLng(driverLat, driverLng),
      LatLng(destLat, destLng),
    );
    if (!mounted || result == null) return;
    setState(() {
      _navigationRoute = result.points;
      _routeEtaMinutes = result.etaMinutes;
      _routeRemainingKm = result.distanceKm;
    });
  }

  double? get _pickupLat {
    final p = _pickup;
    final val = double.tryParse(p?['pickup_lat']?.toString() ?? '') ??
        double.tryParse(p?['dest_lat']?.toString() ?? '') ??
        double.tryParse(p?['latitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }

  double? get _pickupLng {
    final p = _pickup;
    final val = double.tryParse(p?['pickup_lng']?.toString() ?? '') ??
        double.tryParse(p?['dest_lng']?.toString() ?? '') ??
        double.tryParse(p?['longitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }

  double? get _driverLat {
    final val =
        double.tryParse(_driverLocation?['latitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }

  double? get _driverLng {
    final val =
        double.tryParse(_driverLocation?['longitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasDest = _pickupLat != null && _pickupLng != null;
    if (!hasDest && _driverLat == null) {
      return const SizedBox.shrink();
    }

    final remaining = _routeRemainingKm ??
        distanceKmBetween(
          driverLat: _driverLat,
          driverLng: _driverLng,
          destLat: _pickupLat,
          destLng: _pickupLng,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: PickupTrackingMap(
            driverLat: _driverLat,
            driverLng: _driverLng,
            destinationLat: _pickupLat,
            destinationLng: _pickupLng,
            startLat: _startLat,
            startLng: _startLng,
            height: widget.height,
            routeHistory: _routeHistory,
            navigationRoute:
                _navigationRoute.isNotEmpty ? _navigationRoute : null,
            etaMinutes: _routeEtaMinutes,
            remainingKm: remaining,
          ),
        ),
        if (widget.onOpenFullMap != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: widget.onOpenFullMap,
            icon: const Icon(Icons.open_in_full_rounded, size: 18),
            label: const Text('Open full live map'),
          ),
        ],
      ],
    );
  }
}
