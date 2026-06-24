import 'dart:ui' as ui;

import 'package:aneuso_app/core/utils/route_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Map showing scheduled pickup destination, live driver position, and GPS trail.
class PickupTrackingMap extends StatefulWidget {
  const PickupTrackingMap({
    super.key,
    this.driverLat,
    this.driverLng,
    this.destinationLat,
    this.destinationLng,
    this.startLat,
    this.startLng,
    this.height = 260,
    this.gpsPoints,
    this.showCheckpointTracking = false,
    this.routeHistory,
    this.navigationRoute,
    this.etaMinutes,
    this.remainingKm,
    this.showEtaCallout = true,
  });

  final double? driverLat;
  final double? driverLng;
  final double? destinationLat;
  final double? destinationLng;
  final double? startLat;
  final double? startLng;
  final double height;
  final List<dynamic>? gpsPoints;
  final bool showCheckpointTracking;
  final List<LatLng>? routeHistory;
  /// Road route from driver → destination (OSRM).
  final List<LatLng>? navigationRoute;
  final int? etaMinutes;
  final double? remainingKm;
  final bool showEtaCallout;

  @override
  State<PickupTrackingMap> createState() => _PickupTrackingMapState();
}

class _PickupTrackingMapState extends State<PickupTrackingMap> {
  final MapController _mapController = MapController();
  LatLng? _lastDriverPoint;

  static const _routeBlue = Color(0xFF4285F4);
  static const _routeGreen = Color(0xFF34A853);
  static const _destRed = Color(0xFFEA4335);
  static const _startBlue = Color(0xFF1A73E8);

  static bool _validCoord(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat == 0 && lng == 0) return false;
    return lat.abs() <= 90 && lng.abs() <= 180;
  }

  LatLng? get _driverPoint {
    if (!_validCoord(widget.driverLat, widget.driverLng)) return null;
    return LatLng(widget.driverLat!, widget.driverLng!);
  }

  LatLng? get _destPoint {
    if (!_validCoord(widget.destinationLat, widget.destinationLng)) return null;
    return LatLng(widget.destinationLat!, widget.destinationLng!);
  }

  LatLng? get _startPoint {
    if (!_validCoord(widget.startLat, widget.startLng)) return null;
    return LatLng(widget.startLat!, widget.startLng!);
  }

  @override
  void didUpdateWidget(PickupTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeFitCamera();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeFitCamera());
  }

  List<LatLng> _sampleTrail(List<LatLng> points, {int maxDots = 48}) {
    if (points.length <= maxDots) return points;
    final step = points.length / maxDots;
    final sampled = <LatLng>[];
    for (var i = 0; i < maxDots; i++) {
      sampled.add(points[(i * step).floor().clamp(0, points.length - 1)]);
    }
    if (sampled.last != points.last) sampled.add(points.last);
    return sampled;
  }

  void _maybeFitCamera() {
    final dest = _destPoint;

    if (widget.showCheckpointTracking) {
      final points = <LatLng>[];
      if (dest != null) points.add(dest);
      if (widget.gpsPoints != null && widget.gpsPoints!.isNotEmpty) {
        for (var point in widget.gpsPoints!) {
          final lat = double.tryParse(point['lat']?.toString() ?? '');
          final lng = double.tryParse(point['lng']?.toString() ?? '');
          if (_validCoord(lat, lng)) {
            points.add(LatLng(lat!, lng!));
          }
        }
      }

      if (points.isEmpty) return;
      if (points.length == 1) {
        _mapController.move(points.first, 15);
        return;
      }

      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
      return;
    }

    final driver = _driverPoint;
    final start = _startPoint;
    if (driver == null && dest == null) return;

    if (driver != null) {
      final moved = _lastDriverPoint == null ||
          (_lastDriverPoint!.latitude != driver.latitude ||
              _lastDriverPoint!.longitude != driver.longitude);
      _lastDriverPoint = driver;
      if (moved && widget.routeHistory != null && widget.routeHistory!.length >= 2) {
        _mapController.move(driver, 15);
        return;
      } else if (!moved && _mapController.camera.zoom > 0) {
        return;
      }
    }

    final allPoints = <LatLng>[
      if (start != null) start,
      if (driver != null) driver,
      if (dest != null) dest,
      if (widget.routeHistory != null) ...widget.routeHistory!,
      if (widget.navigationRoute != null) ...widget.navigationRoute!,
    ];

    if (allPoints.isEmpty) return;
    if (allPoints.length == 1) {
      _mapController.move(allPoints.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(allPoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(56)),
    );
  }

  List<CircleMarker> _buildTrailDots() {
    if (widget.showCheckpointTracking) return [];

    final history = widget.routeHistory;
    if (history == null || history.isEmpty) return [];

    final dots = _sampleTrail(history);
    return dots.map((p) {
      return CircleMarker(
        point: p,
        radius: 7,
        useRadiusInMeter: false,
        color: _routeBlue.withValues(alpha: 0.92),
        borderColor: const Color(0xFF1A1A1A).withValues(alpha: 0.55),
        borderStrokeWidth: 1.5,
      );
    }).toList();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    final dest = _destPoint;
    final start = _startPoint;
    final driver = _driverPoint;

    if (start != null && !widget.showCheckpointTracking) {
      markers.add(
        Marker(
          point: start,
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: const _StartDot(),
        ),
      );
    }

    if (dest != null) {
      markers.add(
        Marker(
          point: dest,
          width: 44,
          height: 52,
          alignment: Alignment.bottomCenter,
          child: const _DestinationPin(),
        ),
      );
    }

    if (widget.showCheckpointTracking) {
      if (widget.gpsPoints != null && widget.gpsPoints!.isNotEmpty) {
        for (var point in widget.gpsPoints!) {
          try {
            final lat = double.tryParse(point['lat']?.toString() ?? '');
            final lng = double.tryParse(point['lng']?.toString() ?? '');
            final event = point['event']?.toString() ?? '';
            if (_validCoord(lat, lng)) {
              final pos = LatLng(lat!, lng!);

              IconData icon;
              Color color;
              String label;

              if (event == 'en_route') {
                icon = Icons.play_arrow_rounded;
                color = _startBlue;
                label = 'Start';
              } else if (event == 'arrived') {
                icon = Icons.hail_rounded;
                color = const Color(0xFFFFD166);
                label = 'Arrived';
              } else if (event == 'completed') {
                icon = Icons.check_rounded;
                color = _routeGreen;
                label = 'Done';
              } else {
                icon = Icons.location_pin;
                color = Colors.white;
                label = 'Point';
              }

              markers.add(
                Marker(
                  point: pos,
                  width: 44,
                  height: 44,
                  child: _MapPin(icon: icon, color: color, label: label),
                ),
              );
            }
          } catch (e) {
            debugPrint('Error parsing gps_point marker: $e');
          }
        }
      }
    } else if (driver != null) {
      if (widget.showEtaCallout &&
          widget.etaMinutes != null &&
          widget.remainingKm != null) {
        markers.add(
          Marker(
            point: driver,
            width: 130,
            height: 72,
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, -58),
              child: _EtaCallout(
                minutes: widget.etaMinutes!,
                distanceKm: widget.remainingKm!,
              ),
            ),
          ),
        );
      }

      markers.add(
        Marker(
          point: driver,
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: const _DriverMarker(),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    final dest = _destPoint;

    if (widget.showCheckpointTracking) {
      final points = <LatLng>[];
      if (widget.gpsPoints != null && widget.gpsPoints!.isNotEmpty) {
        for (var point in widget.gpsPoints!) {
          final lat = double.tryParse(point['lat']?.toString() ?? '');
          final lng = double.tryParse(point['lng']?.toString() ?? '');
          if (_validCoord(lat, lng)) {
            points.add(LatLng(lat!, lng!));
          }
        }
      }
      if (points.length < 2) return [];
      return [
        Polyline(
          points: points,
          color: _routeGreen.withValues(alpha: 0.75),
          strokeWidth: 5,
          borderColor: Colors.white.withValues(alpha: 0.6),
          borderStrokeWidth: 1.5,
        ),
      ];
    }

    final driver = _driverPoint;
    final start = _startPoint;
    final polylines = <Polyline>[];

    // Full planned path: start → destination (road route or straight)
    final planned = widget.navigationRoute;
    if (planned != null && planned.length >= 2) {
      polylines.add(
        Polyline(
          points: planned,
          color: _routeBlue.withValues(alpha: 0.18),
          strokeWidth: 10,
        ),
      );

      if (driver != null) {
        final split = RouteService.splitAtDriver(planned, driver);
        if (split.covered.length >= 2) {
          polylines.add(
            Polyline(
              points: split.covered,
              color: _routeGreen,
              strokeWidth: 6,
              borderColor: Colors.white.withValues(alpha: 0.85),
              borderStrokeWidth: 2,
            ),
          );
        }
        if (split.remaining.length >= 2) {
          polylines.add(
            Polyline(
              points: split.remaining,
              color: _routeBlue,
              strokeWidth: 6,
              borderColor: Colors.white.withValues(alpha: 0.85),
              borderStrokeWidth: 2,
            ),
          );
        }
      } else {
        polylines.add(
          Polyline(
            points: planned,
            color: _routeBlue,
            strokeWidth: 6,
            borderColor: Colors.white.withValues(alpha: 0.85),
            borderStrokeWidth: 2,
          ),
        );
      }
    } else {
      final pathEnds = <LatLng>[
        if (start != null) start,
        if (driver != null) driver,
        if (dest != null) dest,
      ];
      if (pathEnds.length >= 2) {
        polylines.add(
          Polyline(
            points: pathEnds,
            color: _routeBlue.withValues(alpha: 0.35),
            strokeWidth: 5,
            borderColor: Colors.white.withValues(alpha: 0.5),
            borderStrokeWidth: 1.5,
          ),
        );
      } else if (driver != null && dest != null) {
        polylines.add(
          Polyline(
            points: [driver, dest],
            color: _routeBlue.withValues(alpha: 0.45),
            strokeWidth: 5,
            borderColor: Colors.white.withValues(alpha: 0.5),
            borderStrokeWidth: 1.5,
          ),
        );
      }
    }

    // Subtle connector along actual GPS trail (under the dots)
    final history = widget.routeHistory;
    if (history != null && history.length >= 2) {
      polylines.add(
        Polyline(
          points: history,
          color: _routeBlue.withValues(alpha: 0.35),
          strokeWidth: 3,
        ),
      );
    }

    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    final dest = _destPoint;
    LatLng center;
    if (widget.showCheckpointTracking) {
      LatLng? firstPoint;
      if (widget.gpsPoints != null && widget.gpsPoints!.isNotEmpty) {
        for (var point in widget.gpsPoints!) {
          final lat = double.tryParse(point['lat']?.toString() ?? '');
          final lng = double.tryParse(point['lng']?.toString() ?? '');
          if (_validCoord(lat, lng)) {
            firstPoint = LatLng(lat!, lng!);
            break;
          }
        }
      }
      center = firstPoint ?? dest ?? const LatLng(24.8276, 67.0268);
    } else {
      final driver = _driverPoint;
      center = driver ?? dest ?? const LatLng(24.8276, 67.0268);
    }

    final polylines = _buildPolylines();
    final trailDots = _buildTrailDots();

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.aneuso.aneuso_app',
                ),
                if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                if (trailDots.isNotEmpty) CircleLayer(circles: trailDots),
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),
            if (dest != null || _driverPoint != null)
              Positioned(
                left: 12,
                bottom: 12,
                child: _MapLegend(hasDriver: _driverPoint != null),
              ),
          ],
        ),
      ),
    );
  }
}

/// Red teardrop destination pin (Google Maps style).
class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: _PickupTrackingMapState._destRed, size: 44),
        Container(
          width: 10,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ],
    );
  }
}

class _StartDot extends StatelessWidget {
  const _StartDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: _PickupTrackingMapState._startBlue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: _PickupTrackingMapState._startBlue.withValues(alpha: 0.45),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _DriverMarker extends StatefulWidget {
  const _DriverMarker();

  @override
  State<_DriverMarker> createState() => _DriverMarkerState();
}

class _DriverMarkerState extends State<_DriverMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _pulse = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 44 + 18 * _pulse.value,
              height: 44 + 18 * _pulse.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9B5DE0)
                    .withValues(alpha: 0.18 * (1 - _pulse.value)),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF9B5DE0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9B5DE0).withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EtaCallout extends StatelessWidget {
  const _EtaCallout({
    required this.minutes,
    required this.distanceKm,
  });

  final int minutes;
  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final distLabel = formatDistanceKm(distanceKm);
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDADCE0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car_filled_rounded,
                    size: 18, color: Color(0xFF5F6368)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$minutes min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202124),
                      ),
                    ),
                    Text(
                      distLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5F6368),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(14, 8),
            painter: _CalloutArrowPainter(),
          ),
        ],
      ),
    );
  }
}

class _CalloutArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
    final border = Paint()
      ..color = const Color(0xFFDADCE0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.hasDriver});

  final bool hasDriver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _legendRow(const Color(0xFF4285F4), 'Planned route'),
          const SizedBox(height: 4),
          _legendRow(const Color(0xFF34A853), 'Covered'),
          if (hasDriver) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A1A1A), width: 1),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Driver path',
                  style: TextStyle(fontSize: 10, color: Color(0xFF5F6368)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF5F6368))),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxHeight: 56,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Distance in km between driver and scheduled pickup, if both coordinates exist.
double? distanceKmBetween({
  required double? driverLat,
  required double? driverLng,
  required double? destLat,
  required double? destLng,
}) {
  if (driverLat == null ||
      driverLng == null ||
      destLat == null ||
      destLng == null) {
    return null;
  }
  if (driverLat == 0 && driverLng == 0) return null;
  if (destLat == 0 && destLng == 0) return null;
  return Geolocator.distanceBetween(driverLat, driverLng, destLat, destLng) /
      1000;
}

String formatDistanceKm(double? km) {
  if (km == null) return '—';
  if (km < 0.001) return '< 1 m';
  if (km < 1) {
    final meters = km * 1000;
    if (meters < 10) return '${meters.toStringAsFixed(1)} m';
    return '${meters.round()} m';
  }
  return '${km.toStringAsFixed(1)} km';
}
