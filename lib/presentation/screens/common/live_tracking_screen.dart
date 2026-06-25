import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/utils/route_service.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:aneuso_app/presentation/widgets/app_ui.dart';
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/core/utils/location_util.dart';
import 'package:aneuso_app/presentation/widgets/pickup_tracking_map.dart';
import 'package:latlong2/latlong.dart';

final String _kScreenTitle = ScreenTitle.fromFile('live_tracking_screen.dart');

/// Live tracking for industry pickups and admin cleanup missions.
class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({
    super.key,
    required this.taskId,
    this.taskType = TrackingTaskType.industryPickup,
  });

  final int taskId;
  final String taskType;

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  final String baseUrl = AppConstants.baseUrl;

  Map<String, dynamic>? _pickup;
  Map<String, dynamic>? _driverLocation;
  List<LatLng> _routeHistory = [];
  List<LatLng> _navigationRoute = [];
  bool _routeLoading = false;
  LatLng? _lastRouteOrigin;
  double? _routeRemainingKm;
  int? _routeEtaMinutes;
  int _routeRequestGen = 0;
  bool _trackingActive = false;
  bool _isLoading = true;
  bool _isLive = true;
  Timer? _pollTimer;
  DateTime? _lastUpdated;
  String? _errorMsg;
  double? _startLat;
  double? _startLng;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _fetchTracking();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isLive && mounted) _fetchTracking();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchTracking() async {
    try {
      final token = StorageUtil.getToken();
      final uri = Uri.parse(
        '$baseUrl/drivers/tracking/live?task_type=${widget.taskType}&task_id=${widget.taskId}',
      );
      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d['success'] == true && mounted) {
          setState(() {
            _pickup = d['data']['pickup'];
            _driverLocation = d['data']['driver_location'];
            _trackingActive = d['data']['tracking_active'] == true;
            _routeHistory = _parseLocationHistory(d['data']['location_history']);
            _isLoading = false;
            _lastUpdated = DateTime.now();
            _errorMsg = null;
          });
          _extractStartPoint();
          _updateNavigationRoute();
        }
      } else {
        final legacy = await _fetchLegacyPickup();
        if (!legacy && mounted) {
          setState(() {
            _isLoading = false;
            _errorMsg = 'Server error ${res.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Connection error. Retrying…';
        });
      }
    }
  }

  Future<bool> _fetchLegacyPickup() async {
    if (widget.taskType != TrackingTaskType.industryPickup) return false;
    try {
      final token = StorageUtil.getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/drivers/locations/for-pickup/${widget.taskId}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        if (d['success'] == true && mounted) {
          setState(() {
            _pickup = d['data']['pickup'];
            _driverLocation = d['data']['driver_location'];
            _isLoading = false;
            _lastUpdated = DateTime.now();
          });
          _extractStartPoint();
          _updateNavigationRoute();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  int _statusIdFromPickup(Map<String, dynamic>? pickup) {
    final v = pickup?['pickup_status_id'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? PickupStatus.scheduled;
  }

  List<LatLng> _parseLocationHistory(dynamic raw) {
    if (raw is! List) return [];
    final points = <LatLng>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final lat = double.tryParse(item['latitude']?.toString() ?? '');
      final lng = double.tryParse(item['longitude']?.toString() ?? '');
      if (lat != null && lng != null && !(lat == 0 && lng == 0)) {
        points.add(LatLng(lat, lng));
      }
    }
    return points;
  }

  int get _statusId => _statusIdFromPickup(_pickup);

  double? get _driverLat {
    final val = double.tryParse(_driverLocation?['latitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }
  double? get _driverLng {
    final val = double.tryParse(_driverLocation?['longitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }
  double? get _pickupLat {
    final val = double.tryParse(_pickup?['pickup_lat']?.toString() ?? '') ??
        double.tryParse(_pickup?['dest_lat']?.toString() ?? '') ??
        double.tryParse(_pickup?['latitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }
  double? get _pickupLng {
    final val = double.tryParse(_pickup?['pickup_lng']?.toString() ?? '') ??
        double.tryParse(_pickup?['dest_lng']?.toString() ?? '') ??
        double.tryParse(_pickup?['longitude']?.toString() ?? '');
    return (val == null || val == 0.0) ? null : val;
  }

  bool get _hasDriverLocation => _driverLat != null && _driverLng != null;

  double? get _distanceKm =>
      _routeRemainingKm ??
      distanceKmBetween(
        driverLat: _driverLat,
        driverLng: _driverLng,
        destLat: _pickupLat,
        destLng: _pickupLng,
      );

  Future<void> _updateNavigationRoute() async {
    final fromLat = _driverLat;
    final fromLng = _driverLng;
    final toLat = _pickupLat;
    final toLng = _pickupLng;
    if (fromLat == null || fromLng == null || toLat == null || toLng == null) {
      if (mounted) {
        setState(() {
          _navigationRoute = [];
          _routeRemainingKm = null;
          _routeEtaMinutes = null;
          _lastRouteOrigin = null;
        });
      }
      return;
    }

    final from = LatLng(fromLat, fromLng);
    if (!RouteService.shouldRecalculate(_lastRouteOrigin, from)) return;

    final gen = ++_routeRequestGen;
    if (mounted) setState(() => _routeLoading = true);

    final result = await RouteService.fetchDrivingRoute(
      from,
      LatLng(toLat, toLng),
    );

    if (!mounted || gen != _routeRequestGen) return;
    setState(() {
      _routeLoading = false;
      if (result != null) {
        _navigationRoute = result.points;
        _routeRemainingKm = result.distanceKm;
        _routeEtaMinutes = result.etaMinutes;
        _lastRouteOrigin = from;
      }
    });
  }

  /// Total trip distance: start location → destination (Point A → C)
  double? get _totalDistKm => distanceKmBetween(
        driverLat: _startLat ?? _driverLat,
        driverLng: _startLng ?? _driverLng,
        destLat: _pickupLat,
        destLng: _pickupLng,
      );

  /// Distance already covered: start → current driver (Point A → B)
  double? get _coveredDistKm =>
      (_startLat != null && _startLng != null && _hasDriverLocation)
          ? distanceKmBetween(
              driverLat: _startLat,
              driverLng: _startLng,
              destLat: _driverLat,
              destLng: _driverLng,
            )
          : null;

  /// Progress 0.0–1.0 (covered / total)
  double get _progressFraction {
    final total = _totalDistKm;
    final covered = _coveredDistKm;
    if (total == null || total == 0 || covered == null) return 0.0;
    return (covered / total).clamp(0.0, 1.0);
  }

  /// ETA from OSRM road route, or fallback estimate from GPS speed.
  int? get _etaMinutes {
    if (_routeEtaMinutes != null) return _routeEtaMinutes;
    final remaining = distanceKmBetween(
      driverLat: _driverLat,
      driverLng: _driverLng,
      destLat: _pickupLat,
      destLng: _pickupLng,
    );
    if (remaining == null || remaining == 0) return null;
    final rawSpeed = double.tryParse(
          _driverLocation?['speed']?.toString() ?? '',
        ) ??
        0.0;
    final speedKmh = rawSpeed > 3 ? rawSpeed : 30.0;
    return (remaining / speedKmh * 60).ceil();
  }

  Color _statusColor(int id) {
    switch (id) {
      case PickupStatus.enRoute:
        return AppColors.primaryVariant;
      case PickupStatus.reachedDestination:
        return AppColors.accent;
      case PickupStatus.completed:
        return AppColors.primaryMid;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: AppPageBackground(
        child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_errorMsg!, style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Loading tracking data...', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!_trackingActive && _statusId == PickupStatus.scheduled)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live tracking ended — waiting for driver to start again.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          _buildStatusBar(),
                      _buildMapCard(),
                      _buildProgressSection(),
                      _buildLocationPointsCard(),
                      _buildDriverCard(),
                      _buildJourneyStatsCard(),
                      _buildPickupDetails(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kScreenTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Pickup #${widget.taskId} · GPS every 2s',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isLive = !_isLive),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _isLive
                    ? AppColors.accentLight.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isLive ? AppColors.primary : Colors.grey,
                ),
              ),
              child: Text(
                _isLive ? 'LIVE' : 'PAUSED',
                style: TextStyle(
                  color: _isLive ? AppColors.primaryDark : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _fetchTracking,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final statusLabel = PickupStatus.label(_statusId);
    final statusColor = _statusColor(_statusId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF3EBFF),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          if (_hasDriverLocation && (_trackingActive || _statusId == PickupStatus.enRoute))
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Icon(
                Icons.gps_fixed,
                color: AppColors.primary.withValues(alpha: _pulseAnim.value),
                size: 16,
              ),
            ),
          if (_trackingActive && !_hasDriverLocation)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                'Driver en route — waiting for GPS…',
                style: TextStyle(color: AppColors.accent, fontSize: 10),
              ),
            ),
          const Spacer(),
          if (_distanceKm != null && _hasDriverLocation)
            Text(
              formatDistanceKm(_distanceKm),
              style: const TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          if (_lastUpdated != null) ...[
            const SizedBox(width: 8),
            Text(
              '${DateTime.now().difference(_lastUpdated!).inSeconds}s ago',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    final lat = _driverLat ?? _pickupLat ?? 24.8276;
    final lng = _driverLng ?? _pickupLng ?? 67.0268;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _hasDriverLocation
              ? const Color(0xFF9B5DE0).withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Stack(
        children: [
          PickupTrackingMap(
            driverLat: _driverLat,
            driverLng: _driverLng,
            destinationLat: _pickupLat,
            destinationLng: _pickupLng,
            startLat: _startLat,
            startLng: _startLng,
            height: 340,
            routeHistory: _routeHistory,
            navigationRoute:
                _navigationRoute.isNotEmpty ? _navigationRoute : null,
            etaMinutes: _routeEtaMinutes ?? _etaMinutes,
            remainingKm: _distanceKm,
          ),
          if (_routeLoading)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Updating route…',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          if (!_hasDriverLocation)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _trackingActive
                          ? 'Driver is moving.\nLive GPS will appear on the map as location updates arrive.'
                          : _statusId == PickupStatus.reachedDestination
                              ? 'Driver has reached the destination.\nFinal position is shown on the map.'
                              : 'Waiting for live GPS.\nDriver must tap “Start live GPS” on their phone (Daily Tasks).',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final micro = MediaQuery.sizeOf(context).width <= 360;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: micro ? 4 : 8,
                    runSpacing: 4,
                    children: [
                      _legendDot(const Color(0xFFFF6B6B), micro ? 'Dest.' : 'Destination'),
                      _legendDot(const Color(0xFFE53935), micro ? 'Route' : 'Route ahead'),
                      _legendDot(const Color(0xFF06D6A0), micro ? 'Done' : 'Route covered'),
                      _legendDot(const Color(0xFF9B5DE0), micro ? 'Trail' : 'Driver / GPS trail'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    final micro = MediaQuery.sizeOf(context).width <= 360;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: micro ? 6 : 8,
          height: micro ? 6 : 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: micro ? 3 : 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: micro ? 8 : 9,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard() {
    final driverName = _pickup?['driver_name'] ?? _driverLocation?['driver_name'];
    final vehiclePlate =
        _pickup?['vehicle_plate_number'] ?? _driverLocation?['vehicle_plate_number'];
    final hasDriver = _pickup?['driver_id'] != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: hasDriver
          ? Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF9B5DE0),
                  child: Text((driverName ?? 'D')[0].toUpperCase()),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName ?? 'Driver',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        vehiclePlate ?? '',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      if (_hasDriverLocation)
                        Text(
                          'Last GPS: ${_driverLat!.toStringAsFixed(5)}, ${_driverLng!.toStringAsFixed(5)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : const Text(
              'No driver assigned yet',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
    );
  }

  Widget _buildLocationPointsCard() {
    final hasDest = _pickupLat != null && _pickupLng != null;
    final hasStart = _startLat != null && _startLng != null;
    if (!hasDest && !hasStart && !_hasDriverLocation) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pin_drop_rounded, color: Color(0xFF3A86FF), size: 15),
              SizedBox(width: 6),
              Text(
                'Route points',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasStart)
            _detailRow(
              Icons.play_circle_fill_rounded,
              'Start (driver began)',
              LocationUtil.formatCoords(_startLat!, _startLng!),
            ),
          if (_hasDriverLocation)
            _detailRow(
              Icons.local_shipping_rounded,
              'Driver now',
              LocationUtil.formatCoords(_driverLat!, _driverLng!),
            ),
          if (hasDest)
            _detailRow(
              Icons.flag_rounded,
              'Destination',
              LocationUtil.formatCoords(_pickupLat!, _pickupLng!),
            )
          else
            _detailRow(
              Icons.warning_amber_rounded,
              'Destination',
              'Missing — report/pickup has no valid GPS',
            ),
        ],
      ),
    );
  }

  Widget _buildPickupDetails() {
    final p = _pickup;
    if (p == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduled pickup location',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (p['company_name'] != null)
            _detailRow(Icons.business, 'Company', p['company_name']),
          if (p['branch_name'] != null) _detailRow(Icons.store, 'Location', p['branch_name']),
          if (p['location_address'] != null)
            _detailRow(Icons.location_on, 'Address', p['location_address']),
          if (_pickupLat != null && _pickupLng != null)
            _detailRow(
              Icons.flag_rounded,
              'Destination GPS',
              LocationUtil.formatCoords(_pickupLat!, _pickupLng!),
            )
          else
            _detailRow(
              Icons.warning_amber_rounded,
              'Destination GPS',
              'Not set — reschedule pickup with GPS or branch pin',
            ),
          if (p['scheduled_date'] != null)
            _detailRow(Icons.calendar_today, 'Date', p['scheduled_date'].toString()),
          if (p['time_slot'] != null) _detailRow(Icons.schedule, 'Time slot', p['time_slot']),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Extract Point A (start) from GPS trail
  // ─────────────────────────────────────────────────────
  void _extractStartPoint() {
    if (_routeHistory.isEmpty || _startLat != null) return;
    final first = _routeHistory.first;
    if (!mounted) return;
    setState(() {
      _startLat = first.latitude;
      _startLng = first.longitude;
    });
  }

  // ─────────────────────────────────────────────────────
  // Journey Progress Bar
  // ─────────────────────────────────────────────────────
  Widget _buildProgressSection() {
    if (!_hasDriverLocation) return const SizedBox.shrink();
    final total = _totalDistKm;
    final covered = _coveredDistKm;
    final progress = _progressFraction;
    final hasStart = _startLat != null && _startLng != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.route_rounded, color: Color(0xFF9B5DE0), size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Journey Progress',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06D6A0).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}% Complete',
                  style: const TextStyle(
                    color: Color(0xFF06D6A0),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final clampedProgress = progress.clamp(0.0, 1.0);
              final dotLeft =
                  (barWidth * clampedProgress).clamp(9.0, barWidth - 9.0);
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Grey full-route track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Green covered portion
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    width: barWidth * clampedProgress,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3A86FF), Color(0xFF06D6A0)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Truck dot (animated)
                  Positioned(
                    left: dotLeft - 9,
                    top: -9,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06D6A0),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF06D6A0).withValues(alpha: 0.45),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ),
                  // Start circle
                  const Positioned(
                    left: -1,
                    top: -3,
                    child: Icon(
                      Icons.circle,
                      color: Color(0xFF3A86FF),
                      size: 10,
                    ),
                  ),
                  // Destination flag
                  const Positioned(
                    right: 0,
                    top: -9,
                    child: Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 9),
                  ),
                  Text(
                    hasStart
                        ? LocationUtil.formatCoords(_startLat!, _startLng!)
                        : 'Waiting for GPS…',
                    style: const TextStyle(
                      color: Color(0xFF3A86FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (hasStart && covered != null)
                Column(
                  children: [
                    const Text(
                      'Covered',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 9),
                    ),
                    Text(
                      formatDistanceKm(covered),
                      style: const TextStyle(
                        color: Color(0xFF06D6A0),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Destination',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 9),
                  ),
                  Text(
                    _pickupLat != null && _pickupLng != null
                        ? LocationUtil.formatCoords(_pickupLat!, _pickupLng!)
                        : 'Not set',
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Journey Stats Card (Total / Covered / Remaining / ETA)
  // ─────────────────────────────────────────────────────
  Widget _buildJourneyStatsCard() {
    if (!_hasDriverLocation) return const SizedBox.shrink();
    final total = _totalDistKm;
    final covered = _coveredDistKm;
    final remaining = _distanceKm;
    final eta = _etaMinutes;
    final progress = _progressFraction;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: Color(0xFF9B5DE0), size: 15),
              SizedBox(width: 6),
              Text(
                'Live Estimates',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCell(
                Icons.straighten_rounded,
                'Total Distance',
                formatDistanceKm(total),
                const Color(0xFF9B5DE0),
              ),
              const SizedBox(width: 8),
              _statCell(
                Icons.check_circle_outline_rounded,
                'Covered',
                formatDistanceKm(covered),
                const Color(0xFF06D6A0),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statCell(
                Icons.flag_outlined,
                'Remaining',
                formatDistanceKm(remaining),
                const Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 8),
              _statCell(
                Icons.timer_outlined,
                'ETA (road)',
                formatEtaMinutes(eta),
                const Color(0xFF3A86FF),
              ),
            ],
          ),
          if (progress > 0) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.speed_rounded,
                  color: AppColors.textSecondary,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% of journey completed',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCell(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9B5DE0), size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(color: Colors.purple, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
