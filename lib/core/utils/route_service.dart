import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Road routing via OSRM (OpenStreetMap) — no Google/Firebase required.
class RouteResult {
  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  double get distanceKm => distanceMeters / 1000;

  int get etaMinutes {
    if (durationSeconds <= 0) return 0;
    return (durationSeconds / 60).ceil().clamp(1, 9999);
  }
}

class RouteService {
  RouteService._();

  static const _base = 'https://router.project-osrm.org/route/v1/driving';

  /// Best driving route between two points (OSRM picks optimal road path).
  static Future<RouteResult?> fetchDrivingRoute(LatLng from, LatLng to) async {
    if (!_valid(from) || !_valid(to)) return null;

    final uri = Uri.parse(
      '$_base/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson&alternatives=false&steps=false',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['code'] != 'Ok') return null;

      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List?;
      if (coords == null || coords.isEmpty) return null;

      final points = <LatLng>[];
      for (final c in coords) {
        if (c is List && c.length >= 2) {
          final lng = (c[0] as num).toDouble();
          final lat = (c[1] as num).toDouble();
          if (_valid(LatLng(lat, lng))) points.add(LatLng(lat, lng));
        }
      }
      if (points.length < 2) return null;

      final distance = (route['distance'] as num?)?.toDouble() ?? 0;
      final duration = (route['duration'] as num?)?.toDouble() ?? 0;

      return RouteResult(
        points: points,
        distanceMeters: distance,
        durationSeconds: duration,
      );
    } catch (_) {
      return null;
    }
  }

  static bool _valid(LatLng p) =>
      p.latitude.abs() <= 90 &&
      p.longitude.abs() <= 180 &&
      !(p.latitude == 0 && p.longitude == 0);

  /// Recalculate when driver moves more than [thresholdMeters] off last route origin.
  static bool shouldRecalculate(LatLng? lastOrigin, LatLng current,
      {double thresholdMeters = 45}) {
    if (lastOrigin == null) return true;
    return Geolocator.distanceBetween(
          lastOrigin.latitude,
          lastOrigin.longitude,
          current.latitude,
          current.longitude,
        ) >=
        thresholdMeters;
  }

  /// Closest point index on polyline to [point].
  static int nearestPointIndex(List<LatLng> polyline, LatLng point) {
    if (polyline.isEmpty) return 0;
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < polyline.length; i++) {
      final d = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        polyline[i].latitude,
        polyline[i].longitude,
      );
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  /// Split navigation route into covered (green) and remaining (red) at driver position.
  static ({List<LatLng> covered, List<LatLng> remaining}) splitAtDriver(
    List<LatLng> route,
    LatLng driver,
  ) {
    if (route.length < 2) {
      return (covered: <LatLng>[], remaining: route);
    }
    final idx = nearestPointIndex(route, driver);
    final covered = route.sublist(0, idx + 1);
    final remaining = route.sublist(idx);
    if (remaining.length < 2 && route.length >= 2) {
      return (covered: route.sublist(0, route.length - 1), remaining: route.sublist(route.length - 2));
    }
    return (covered: covered, remaining: remaining);
  }
}

String formatEtaMinutes(int? minutes) {
  if (minutes == null) return '—';
  if (minutes < 1) return 'Arriving soon';
  if (minutes >= 60) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m left' : '${h}h left';
  }
  return '$minutes min left';
}
