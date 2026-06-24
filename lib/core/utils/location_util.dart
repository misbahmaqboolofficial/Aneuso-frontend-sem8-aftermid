import 'dart:convert';

import 'package:http/http.dart' as http;

/// One address result from OpenStreetMap Nominatim.
class AddressSuggestion {
  const AddressSuggestion({
    required this.lat,
    required this.lng,
    required this.displayName,
  });

  final double lat;
  final double lng;
  final String displayName;

  @override
  bool operator ==(Object other) =>
      other is AddressSuggestion &&
      other.lat == lat &&
      other.lng == lng &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(lat, lng, displayName);
}

/// Shared GPS / geocoding helpers for reports, pickups, and live tracking.
class LocationUtil {
  LocationUtil._();

  static const _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const _userAgent = 'AneusoApp/1.0 (waste-report; contact@aneuso.com)';

  /// Nominatim public policy: max ~1 request / second.
  static DateTime? _lastNominatimAt;

  static Future<void> _throttleNominatim() async {
    final last = _lastNominatimAt;
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < const Duration(milliseconds: 1100)) {
        await Future.delayed(const Duration(milliseconds: 1100) - elapsed);
      }
    }
    _lastNominatimAt = DateTime.now();
  }

  static Map<String, String> get _nominatimHeaders => {
        'User-Agent': _userAgent,
        'Accept-Language': 'en',
      };

  /// Pakistan bounding box (generous) — rejects obvious wrong/global pins.
  static const double pakistanMinLat = 23.0;
  static const double pakistanMaxLat = 37.5;
  static const double pakistanMinLng = 60.0;
  static const double pakistanMaxLng = 78.0;

  static bool isValidCoordinate(double lat, double lng) {
    if (lat == 0 && lng == 0) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  static bool isPlausibleForPakistan(double lat, double lng) {
    if (!isValidCoordinate(lat, lng)) return false;
    return lat >= pakistanMinLat &&
        lat <= pakistanMaxLat &&
        lng >= pakistanMinLng &&
        lng <= pakistanMaxLng;
  }

  static String formatCoords(double lat, double lng) =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';

  static String? validationError(double lat, double lng) {
    if (!isValidCoordinate(lat, lng)) {
      return 'Location is missing. Tap "Locate Me" or pick a point on the map.';
    }
    if (!isPlausibleForPakistan(lat, lng)) {
      return 'This location looks wrong (outside Pakistan). '
          'Move the map pin to where the garbage actually is.';
    }
    return null;
  }

  static Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      await _throttleNominatim();
      final url = Uri.parse(
        '$_nominatimBase/reverse?format=json'
        '&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final res = await http.get(
        url,
        headers: _nominatimHeaders,
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      final data = json.decode(res.body) as Map<String, dynamic>;
      return data['display_name']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Forward geocode — returns up to [limit] suggestions (Pakistan-biased).
  static Future<List<AddressSuggestion>> searchAddresses(
    String query, {
    int limit = 5,
  }) async {
    final q = query.trim();
    if (q.length < 3) return [];

    try {
      await _throttleNominatim();
      final url = Uri.parse(
        '$_nominatimBase/search?format=json'
        '&q=${Uri.encodeComponent(q)}'
        '&countrycodes=pk'
        '&limit=$limit'
        '&addressdetails=1',
      );
      final res = await http.get(
        url,
        headers: _nominatimHeaders,
      ).timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return [];

      final list = json.decode(res.body) as List;
      final results = <AddressSuggestion>[];
      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final lat = double.tryParse('${raw['lat']}');
        final lng = double.tryParse('${raw['lon']}');
        final name = raw['display_name']?.toString();
        if (lat == null || lng == null || name == null || name.isEmpty) {
          continue;
        }
        if (!isPlausibleForPakistan(lat, lng)) continue;
        results.add(AddressSuggestion(lat: lat, lng: lng, displayName: name));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  static Future<({double lat, double lng, String? label})?> geocodeAddress(
    String address,
  ) async {
    final results = await searchAddresses(address, limit: 1);
    if (results.isEmpty) return null;
    final first = results.first;
    return (lat: first.lat, lng: first.lng, label: first.displayName);
  }
}
