//  — search // <name> button|card|drawer item|dashboard card
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:aneuso_app/presentation/providers/driver_ratings_provider.dart';
import 'package:aneuso_app/presentation/widgets/app_ui.dart';
import 'package:aneuso_app/presentation/widgets/embedded_live_tracking_map.dart';
import 'package:aneuso_app/presentation/widgets/ratings/rate_driver_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('industry_pickup_detail_screen.dart');

/// Pickup details for industry with optional "Rate driver" action.
class IndustryPickupDetailScreen extends StatefulWidget {
  const IndustryPickupDetailScreen({super.key, required this.pickup});

  final Map<String, dynamic> pickup;

  @override
  State<IndustryPickupDetailScreen> createState() =>
      _IndustryPickupDetailScreenState();
}

class _IndustryPickupDetailScreenState extends State<IndustryPickupDetailScreen> {
  late Map<String, dynamic> _pickup;

  @override
  void initState() {
    super.initState();
    _pickup = Map<String, dynamic>.from(widget.pickup);
  }

  int? _i(String key) {
    final v = _pickup[key];
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  bool get _canRate {
    final status = _i('pickup_status_id');
    final driverId = _i('driver_id');
    final rated = _pickup['driver_rating_id'] != null;
    return status == 3 && driverId != null && driverId > 0 && !rated;
  }

  bool get _canLiveTrack {
    final driverId = _i('driver_id');
    return driverId != null &&
        driverId > 0 &&
        PickupStatus.canLiveTrack(_i('pickup_status_id'));
  }

  void _openLiveTracking() {
    final pickupId = _i('id');
    if (pickupId == null) return;
    Navigator.pushNamed(
      context,
      '/live-tracking',
      arguments: {
        'task_id': pickupId,
        'task_type': TrackingTaskType.industryPickup,
      },
    );
  }

  Future<void> _openRate(String driverName, String summary) async {
    final pickupId = _i('id');
    if (pickupId == null) return;
    final provider = context.read<DriverRatingsProvider>();
    await RateDriverSheet.show(
      context,
      driverName: driverName,
      pickupSummary: summary,
      onSubmit: (rating, comment) async {
        final res = await provider.submitIndustryRating(
          pickupId: pickupId,
          rating: rating,
          reviewComment: comment,
        );
        final ok = res['success'] == true;
        if (ok && mounted) {
          setState(() => _pickup['driver_rating_id'] = -1);
        }
        return ok;
      },
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final driverName = (_pickup['driver_name'] ?? 'Driver').toString();
    final branch = (_pickup['branch_name'] ?? '').toString();
    final dateStr = _pickup['scheduled_date']?.toString();
    DateTime? date;
    if (dateStr != null) {
      date = DateTime.tryParse(dateStr);
    }
    final dateLabel =
        date != null ? DateFormat('MMM d, yyyy').format(date) : '—';
    final slot = (_pickup['time_slot'] ?? '').toString();
    final summary = '$branch · $dateLabel · $slot';

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        foregroundColor: Colors.white,
        title: Text(_kScreenTitle),
      ),
      body: AppPageBackground(
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Driver card
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.isEmpty ? 'Pickup' : branch,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _row(Icons.calendar_month_rounded, 'Scheduled', dateLabel),
                  _row(Icons.schedule_rounded, 'Time slot', slot.isEmpty ? '—' : slot),
                  _row(Icons.recycling_rounded, 'Waste type',
                      (_pickup['waste_type'] ?? '—').toString()),
                  _row(Icons.scale_rounded, 'Est. weight',
                      '${_pickup['estimated_weight_kg'] ?? '—'} kg'),
                  if (_pickup['actual_weight_kg'] != null)
                    _row(Icons.check_circle_outline_rounded, 'Collected',
                        '${_pickup['actual_weight_kg']} kg'),
                  const Divider(height: 28),
                  Text(
                    'Driver',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        driverName.isNotEmpty
                            ? driverName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primaryDeep,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(driverName),
                    subtitle: Text(
                      _canRate
                          ? 'You can rate this driver after service.'
                          : (_pickup['driver_rating_id'] != null
                              ? 'Already rated for this pickup.'
                              : 'Rating unlocks when pickup is completed.'),
                    ),
                  ),
                ],
              ),
            ),
          ), // end Driver card
          const SizedBox(height: 16),
          if (_canLiveTrack) ...[
            Text(
              'Live driver map',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            EmbeddedLiveTrackingMap(
              taskId: _i('id')!,
              onOpenFullMap: _openLiveTracking,
            ),
            const SizedBox(height: 16),
          ],
          if (_canLiveTrack)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _openLiveTracking,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Live Track Driver'),
            ),
          if (_canLiveTrack && _canRate) const SizedBox(height: 12),
          if (_canRate)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDeep,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _openRate(driverName, summary),
              icon: const Icon(Icons.star_rate_rounded),
              label: const Text('Rate driver'),
            ),
        ],
        ),
      ),
    );
  }
}
