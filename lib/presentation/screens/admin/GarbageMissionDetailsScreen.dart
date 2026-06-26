import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pickup_status.dart';
import '../../../core/utils/product_image_util.dart';
import '../../../core/utils/storage_util.dart';
import '../../providers/auth_provider.dart';
import 'public_garbage_reports_screen.dart';
import 'MissionAssignmentScreen.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/presentation/widgets/embedded_live_tracking_map.dart';

final String _kScreenTitle = ScreenTitle.fromFile('GarbageMissionDetailsScreen.dart');


class GarbageMissionDetailsScreen extends StatefulWidget {
  final GarbageReport report;

  const GarbageMissionDetailsScreen({super.key, required this.report});

  @override
  State<GarbageMissionDetailsScreen> createState() => _GarbageMissionDetailsScreenState();
}

class _GarbageMissionDetailsScreenState extends State<GarbageMissionDetailsScreen> {
  late GarbageReport currentReport;
  bool isRefreshing = false;

  // â”€â”€ Exclusive WOW Purple Palette (with White for Lightness) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const darkPurple  = Color(0xFF450693);
  static const mainPurple  = Color(0xFF6F38C5);
  static const brightPurp  = Color(0xFF9B5DE0);
  static const softLilac   = Color(0xFFD78FEE);
  static const palePink    = Color(0xFFFDCFFA);

  bool get _hasAssignedDriver {
    final id = currentReport.driverId;
    return id != null && id > 0;
  }

  String get _driverDisplayName {
    if (!_hasAssignedDriver) return 'DRIVER NOT YET ASSIGNED';
    final name = currentReport.driverName?.trim();
    if (name != null && name.isNotEmpty) return name.toUpperCase();
    return 'DRIVER ASSIGNED';
  }

  @override
  void initState() {
    super.initState();
    currentReport = widget.report;
    _refreshData(); // Auto-refresh on entry to ensure latest data
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/reports/public-garbage/${currentReport.id}?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentReport = GarbageReport.fromJson(data['data']);
          isRefreshing = false;
        });
      } else { throw Exception('Failed to load report'); }
    } catch (e) {
      setState(() => isRefreshing = false);
    }
  }

  void _openFullPhoto(String url) {
    final resolved = resolveProductImageUrl(url) ?? url;
    if (resolved.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.network(resolved, fit: BoxFit.contain, width: double.infinity, height: double.infinity, headers: kProductImageHeaders),
            ),
            Positioned(
              top: 40, right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isDriverPendingVerification => CleanupStatusUtil.isDriverPendingAdminVerification(
    reportStatusId: currentReport.reportStatusId,
    driverMarkedCompleteAt: currentReport.driverMarkedCompleteAt,
  );

  bool get _isAdminVerified => CleanupStatusUtil.isAdminVerifiedComplete(currentReport.reportStatusId);

  Future<void> _verifyDriverCollection() async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/reports/cleanup/${currentReport.id}/verify-collection'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final body = json.decode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Mission marked as completed'), backgroundColor: Colors.green),
        );
        await _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Verification failed'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not verify completion'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFinalized = _isAdminVerified;
    final bool showCompletionReport = _isDriverPendingVerification || isFinalized;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
            onRefresh: _refreshData,
            color: brightPurp,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildWOWAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
                    child: Column(
                      children: [
                        if (isRefreshing) const LinearProgressIndicator(backgroundColor: Colors.transparent, color: brightPurp),
                        if (_isDriverPendingVerification) _buildDriverPendingBanner(),
                        _buildWOWStatusHeader(isFinalized),
                        const SizedBox(height: 32),
                        _lightCard(child: _buildWOWStepper()),
                        const SizedBox(height: 32),
                        _wowSectionHeader('MISSION INTELLIGENCE', Icons.psychology_rounded),
                        const SizedBox(height: 16),
                        _buildWOWInfoCard(),
                        const SizedBox(height: 40),
                        if (showCompletionReport) _buildWOWCompletionReport() else _buildWOWLiveTracking(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildWOWAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: darkPurple),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(_kScreenTitle, style: TextStyle(fontWeight: FontWeight.w900, color: darkPurple, fontSize: 16, letterSpacing: 4)),
        background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palePink.withOpacity(0.5), Colors.white]))),
      ),
      actions: [
        if (currentReport.reportStatusId != 174 && Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin == true)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: isRefreshing ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => MissionAssignmentScreen(reportId: currentReport.id, report: currentReport.toMap()))).then((_) => _refreshData()),
              icon: Icon(Icons.edit_note_rounded, color: isRefreshing ? darkPurple.withOpacity(0.2) : brightPurp, size: 28),
            ),
          ),
      ],
    );
  }

  Widget _buildDriverPendingBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Completed marked by driver',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.orange.shade900,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Review the after photo below, then verify to mark this mission as Completed.',
            style: TextStyle(fontSize: 12, color: darkPurple.withOpacity(0.6), height: 1.4),
          ),
          if (Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin == true) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isRefreshing ? null : _verifyDriverCollection,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('VERIFY & MARK COMPLETED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWOWStatusHeader(bool isFinalized) {
    final statusLabel = CleanupStatusUtil.adminDisplayLabel(
      reportStatusId: currentReport.reportStatusId,
      driverMarkedCompleteAt: currentReport.driverMarkedCompleteAt,
    );
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDriverPendingVerification
                ? Colors.orange.withOpacity(0.08)
                : brightPurp.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isDriverPendingVerification
                  ? Colors.orange.withOpacity(0.2)
                  : brightPurp.withOpacity(0.1),
            ),
          ),
          child: Icon(
            isFinalized
                ? Icons.verified_rounded
                : _isDriverPendingVerification
                    ? Icons.hourglass_top_rounded
                    : Icons.radar_rounded,
            color: _isDriverPendingVerification ? Colors.orange.shade700 : brightPurp,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          statusLabel.toUpperCase(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: darkPurple, letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        Text(
          isFinalized
              ? 'Admin verified — mission completed'
              : _isDriverPendingVerification
                  ? 'Awaiting your verification'
                  : 'Live field intelligence tracking',
          style: TextStyle(color: darkPurple.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWOWStepper() {
    final cur = CleanupStatusUtil.stepperStep(
      reportStatusId: currentReport.reportStatusId,
      driverMarkedCompleteAt: currentReport.driverMarkedCompleteAt,
    );

    final steps = ['Report Approved', 'Driver Assigned', 'Driver on the Way', 'Cleaning Started', _isDriverPendingVerification ? 'Awaiting Verification' : 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (i) {
          bool isDone = i + 1 < cur; 
          bool isActive = i + 1 == cur; 
          
          Color leftLineColor = (i > 0 && i < cur) ? brightPurp : darkPurple.withOpacity(0.05);
          Color rightLineColor = (i < steps.length - 1 && i + 1 < cur) ? brightPurp : darkPurple.withOpacity(0.05);

          return SizedBox(
            width: 100, // Fixed width to allow text to fit nicely
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container(height: 3, color: i == 0 ? Colors.transparent : leftLineColor)),
                    Container(
                      width: 20, height: 20, 
                      decoration: BoxDecoration(
                        color: isDone ? brightPurp : Colors.white, 
                        shape: BoxShape.circle, 
                        border: Border.all(color: (isDone || isActive) ? brightPurp : darkPurple.withOpacity(0.1), width: 3),
                        boxShadow: isActive ? [BoxShadow(color: brightPurp.withOpacity(0.3), blurRadius: 8)] : null
                      ),
                      child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                    ),
                    Expanded(child: Container(height: 3, color: i == steps.length - 1 ? Colors.transparent : rightLineColor)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(steps[i], textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.w900 : FontWeight.w700, color: (i + 1 <= cur) ? darkPurple : darkPurple.withOpacity(0.3), height: 1.2)),
              ],
            ),
          );
        }),
      ),
    );
  }


  Widget _buildWOWInfoCard() {
    return _lightCard(
      child: Column(
        children: [
          _wowInfoRow(Icons.person_pin_rounded, 'ASSIGNED DRIVER', _driverDisplayName, brightPurp),
          _wowDivider(),
          _wowInfoRow(
            Icons.bolt_rounded, 
            'URGENCY LEVEL', 
            (currentReport.reportStatusId == 170 || currentReport.reportStatusId == 171) 
                ? 'NOT SET' 
                : (currentReport.urgencyName ?? 'NOT SET').toUpperCase(), 
            softLilac
          ),
          _wowDivider(),
          _wowInfoRow(Icons.inventory_2_rounded, 'ESTIMATED VOLUME', '${currentReport.estimatedVolume} KG', brightPurp),
          _wowDivider(),
          _wowInfoRow(Icons.map_rounded, 'LOCATION', currentReport.address, darkPurple.withOpacity(0.6)),
          const SizedBox(height: 24),
          if (currentReport.reportStatusId != 174 && Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin == true)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MissionAssignmentScreen(reportId: currentReport.id, report: currentReport.toMap()))).then((_) => _refreshData()),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 18),
                label: const Text('MODIFICATION PROTOCOL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                style: ElevatedButton.styleFrom(backgroundColor: brightPurp, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4, shadowColor: brightPurp.withOpacity(0.3)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWOWLiveTracking() {
    final canTrack =
        _hasAssignedDriver && ReportStatus.canLiveTrack(currentReport.reportStatusId);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: brightPurp.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brightPurp.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.stream_rounded, color: brightPurp, size: 28),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  canTrack
                      ? 'Driver is on mission. Open live tracking to see their position and mission status.'
                      : _hasAssignedDriver
                          ? 'Driver assigned. Set status to "On the Way" (207) or have the driver start live GPS from Daily Tasks.'
                          : 'Assign a driver using Modification Protocol, then enable live map updates.',
                  style: TextStyle(
                    fontSize: 13,
                    color: darkPurple.withOpacity(0.7),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (canTrack) ...[
            const SizedBox(height: 16),
            EmbeddedLiveTrackingMap(
              taskId: currentReport.id,
              taskType: TrackingTaskType.adminCleanup,
              onOpenFullMap: () {
                Navigator.pushNamed(
                  context,
                  '/live-tracking',
                  arguments: {
                    'task_id': currentReport.id,
                    'task_type': TrackingTaskType.adminCleanup,
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/live-tracking',
                  arguments: {
                    'task_id': currentReport.id,
                    'task_type': TrackingTaskType.adminCleanup,
                  },
                );
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Live Track Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: brightPurp,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWOWCompletionReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _wowSectionHeader('POST-MISSION INTEL', Icons.assignment_turned_in_rounded),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _wowSmartPhoto('INITIAL', currentReport.photoUrl)),
            const SizedBox(width: 16),
            Expanded(child: _wowSmartPhoto('RESTORED', currentReport.afterPhotoUrl ?? '')),
          ],
        ),
        const SizedBox(height: 32),
        _lightCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MISSION SUMMARY', style: TextStyle(fontWeight: FontWeight.w900, color: brightPurp, fontSize: 11, letterSpacing: 2)),
              const SizedBox(height: 16),
              Text(currentReport.otherExpenseDescription ?? 'Operational objective achieved. Full environmental restoration completed.', style: TextStyle(fontSize: 14, color: darkPurple.withOpacity(0.7), height: 1.6)),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _wowMiniStat('CARGO MASS', '${currentReport.estimatedVolume}KG'),
                _wowMiniStat('STATUS', _isDriverPendingVerification ? 'PENDING VERIFY' : 'COMPLETED'),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wowSmartPhoto(String label, String url) {
    final resolved = resolveProductImageUrl(url);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: darkPurple.withOpacity(0.3), letterSpacing: 2))),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _openFullPhoto(url),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24), 
              color: palePink.withOpacity(0.1), 
              border: Border.all(color: darkPurple.withOpacity(0.05))
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: (resolved != null && resolved.isNotEmpty)
                ? Image.network(
                    resolved,
                    fit: BoxFit.cover,
                    headers: kProductImageHeaders,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported_rounded, color: darkPurple.withOpacity(0.1), size: 40),
                  )
                : Icon(Icons.hide_image_rounded, color: darkPurple.withOpacity(0.1), size: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lightCard({required Widget child}) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: darkPurple.withOpacity(0.05)), boxShadow: [BoxShadow(color: darkPurple.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]), child: Padding(padding: const EdgeInsets.all(24), child: child));

  Widget _wowSectionHeader(String title, IconData icon) => Row(children: [Icon(icon, color: brightPurp, size: 18), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: darkPurple, letterSpacing: 2))]);

  Widget _wowInfoRow(IconData icon, String label, String value, Color color) => Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 18, color: color)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 9, color: darkPurple.withOpacity(0.3), fontWeight: FontWeight.w700, letterSpacing: 1)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: darkPurple))]))]);

  Widget _wowDivider() => Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: darkPurple.withOpacity(0.05), height: 1));

  Widget _wowMiniStat(String label, String val) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 9, color: darkPurple.withOpacity(0.3), fontWeight: FontWeight.w700)), Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: brightPurp))]);
}
