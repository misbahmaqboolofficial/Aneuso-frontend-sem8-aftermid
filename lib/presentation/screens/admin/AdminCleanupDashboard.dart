import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'CleanupFinalizationScreen.dart';
import 'MissionAssignmentScreen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pickup_status.dart';
import '../../../core/utils/storage_util.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'public_garbage_reports_screen.dart';
import 'GarbageMissionDetailsScreen.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('AdminCleanupDashboard.dart');

class AdminCleanupDashboard extends StatefulWidget {
  const AdminCleanupDashboard({super.key});

  @override
  State<AdminCleanupDashboard> createState() => _AdminCleanupDashboardState();
}

class _AdminCleanupDashboardState extends State<AdminCleanupDashboard> {
  final String baseUrl = AppConstants.baseUrl;
  Map<String, dynamic> stats = {};
  List<dynamic> allCollections = [];
  List<dynamic> pendingDriverVerification = [];
  List<dynamic> newReports = [];
  bool isLoading = true;

  // ── Exclusive WOW Purple Palette (with White for Lightness) ──────────
  static const darkPurple  = Color(0xFF450693);
  static const mainPurple  = Color(0xFF6F38C5);
  static const brightPurp  = Color(0xFF9B5DE0);
  static const softLilac   = Color(0xFFD78FEE);
  static const palePink    = Color(0xFFFDCFFA);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();
      final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      final statsRes = await http.get(Uri.parse('$baseUrl/reports/cleanup/analytics'), headers: headers);
      final allReportsRes = await http.get(Uri.parse('$baseUrl/reports/public-garbage'), headers: headers);

      if (statsRes.statusCode == 200) stats = json.decode(statsRes.body)['data'];
      if (allReportsRes.statusCode == 200) {
        final all = json.decode(allReportsRes.body)['data'] as List;
        newReports = all.where((r) => r['report_status_id'] == 170 || r['report_status_id'] == 171).toList();
        pendingDriverVerification = all.where((r) =>
          CleanupStatusUtil.isDriverPendingAdminVerification(
            reportStatusId: r['report_status_id'],
            driverMarkedCompleteAt: r['driver_marked_complete_at'],
          )).toList();
        allCollections = all.where((r) {
          if ([172, 204, 206, 207, 205, 208, 174].contains(r['report_status_id'])) {
            return !CleanupStatusUtil.isDriverPendingAdminVerification(
              reportStatusId: r['report_status_id'],
              driverMarkedCompleteAt: r['driver_marked_complete_at'],
            );
          }
          return false;
        }).toList();
      }
      setState(() => isLoading = false);
    } catch (e) { setState(() => isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white for lightness
      body: isLoading
              ? const Center(child: CircularProgressIndicator(color: brightPurp))
              : RefreshIndicator(
                  color: brightPurp,
                  backgroundColor: Colors.white,
                  onRefresh: fetchData,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildWOWAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildWOWStats(),
                            const SizedBox(height: 40),
                            if (newReports.isNotEmpty) ...[
                              _wowSectionHeader('NEW COMMANDS', newReports.length),
                              const SizedBox(height: 16),
                              ...newReports.map((r) => _buildWOWReportCard(r)),
                              const SizedBox(height: 40),
                            ],
                            if (pendingDriverVerification.isNotEmpty) ...[
                              _wowSectionHeader('DRIVER COMPLETION REVIEW', pendingDriverVerification.length),
                              const SizedBox(height: 16),
                              ...pendingDriverVerification.map((r) => _buildWOWPendingVerificationCard(r)),
                              const SizedBox(height: 40),
                            ],
                            _wowSectionHeader('ACTIVE OPERATIONS', allCollections.length),
                            const SizedBox(height: 16),
                            if (allCollections.isNotEmpty) 
                              ...allCollections.map((r) => _buildWOWCollectionCard(r))
                            else
                              _buildWOWEmptyState(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildWOWAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: Text(_kScreenTitle, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkPurple, letterSpacing: 3)),
        background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palePink.withOpacity(0.5), Colors.white]))),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          child: IconButton(onPressed: fetchData, icon: const Icon(Icons.refresh_rounded, color: darkPurple, size: 24)),
        ),
      ],
    );
  }

  Widget _buildWOWStats() {
    return _lightCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _wowStatItem('ACTIVE', stats['active_count']?.toString() ?? '0', brightPurp),
          _wowStatItem('CLEANED', stats['cleaned_count']?.toString() ?? '0', mainPurple),
          _wowStatItem('TOTAL', stats['total_campaigns']?.toString() ?? '0', darkPurple),
        ],
      ),
    );
  }

  Widget _wowStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: darkPurple.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _wowSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: darkPurple, letterSpacing: 2)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: brightPurp.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(count.toString(), style: const TextStyle(color: brightPurp, fontWeight: FontWeight.w900, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildWOWReportCard(Map<String, dynamic> report) {
    return _lightCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GarbageMissionDetailsScreen(report: GarbageReport.fromJson(report)))).then((_) => fetchData());
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildWOWSmartImage(report['photo_url'], 60, 60, 16),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report['address'] ?? 'COMMAND LOCATION', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: darkPurple, letterSpacing: -0.2)),
                    const SizedBox(height: 6),
                    _wowPill('PENDING AUTH', brightPurp.withOpacity(0.1), brightPurp),
                  ],
                ),
              ),
              if (Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin == true)
                _wowBtn('APPROVE', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MissionAssignmentScreen(reportId: report['id'], report: report))).then((_) => fetchData());
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWOWPendingVerificationCard(Map<String, dynamic> report) {
    return _lightCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GarbageMissionDetailsScreen(report: GarbageReport.fromJson(report)))).then((_) => fetchData());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildWOWSmartImage(report['photo_url'], 64, 64, 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report['address'] ?? 'SECTOR UNKNOWN', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: darkPurple, letterSpacing: -0.3)),
                        const SizedBox(height: 8),
                        _wowPill('COMPLETED MARKED BY DRIVER', Colors.orange.withOpacity(0.15), Colors.orange.shade800),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin == true)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyDriverCollection(report['id']),
                    icon: const Icon(Icons.verified_rounded, size: 18),
                    label: const Text('VERIFY COMPLETION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyDriverCollection(int reportId) async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/reports/cleanup/$reportId/verify-collection'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final body = json.decode(response.body);
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'] ?? 'Mission marked as completed'), backgroundColor: Colors.green),
        );
        fetchData();
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

  Widget _buildWOWCollectionCard(Map<String, dynamic> report) {
    final int statusId = report['report_status_id'] ?? 172;
    final bool isDone = statusId == 174;
    final bool isCompleted = CleanupStatusUtil.isAdminVerifiedComplete(statusId);
    final String driver = report['driver_name']?.toString() ?? 'UNASSIGNED';
    final String statusLabel = CleanupStatusUtil.adminDisplayLabel(
      reportStatusId: statusId,
      driverMarkedCompleteAt: report['driver_marked_complete_at'],
    );

    return _lightCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GarbageMissionDetailsScreen(report: GarbageReport.fromJson(report)))).then((_) => fetchData());
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildWOWSmartImage(report['photo_url'], 64, 64, 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report['address'] ?? 'SECTOR UNKNOWN', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: darkPurple, letterSpacing: -0.3)),
                        const SizedBox(height: 6),
                        Text('DRIVER: $driver'.toUpperCase(), style: TextStyle(color: darkPurple.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        const SizedBox(height: 6),
                        _wowPill(
                          statusLabel.toUpperCase(),
                          isCompleted ? Colors.green.withOpacity(0.12) : brightPurp.withOpacity(0.1),
                          isCompleted ? Colors.green.shade800 : brightPurp,
                        ),
                      ],
                    ),
                  ),
                  if (!isDone && Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin == true) 
                    _wowBtn('UPDATE', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MissionAssignmentScreen(reportId: report['id'], report: report))).then((_) => fetchData());
                    }),
                ],
              ),
            ),
            _buildWOWMiniStepper(report),
            if (ReportStatus.canLiveTrack(statusId) && report['driver_id'] != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/live-tracking',
                        arguments: {
                          'task_id': report['id'],
                          'task_type': TrackingTaskType.adminCleanup,
                        },
                      );
                    },
                    icon: const Icon(Icons.location_on_rounded, color: Colors.white),
                    label: const Text(
                      'Live Track Cleanup',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brightPurp,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            if (isDone)
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), color: brightPurp, child: const Center(child: Text('MISSION SUCCESS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)))),
          ],
        ),
      ),
    );
  }

  Widget _buildWOWMiniStepper(Map<String, dynamic> report) {
    final cur = CleanupStatusUtil.stepperStep(
      reportStatusId: report['report_status_id'],
      driverMarkedCompleteAt: report['driver_marked_complete_at'],
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: palePink.withOpacity(0.1)),
      child: Row(
        children: List.generate(5, (i) {
          bool isDone = i + 1 < cur; 
          bool isActive = i + 1 == cur; 
          
          Color leftLineColor = (i > 0 && i < cur) ? brightPurp : darkPurple.withOpacity(0.05);
          Color rightLineColor = (i < 4 && i + 1 < cur) ? brightPurp : darkPurple.withOpacity(0.05);

          return Expanded(
            child: Row(
              children: [
                Expanded(child: Container(height: 1.5, color: i == 0 ? Colors.transparent : leftLineColor)),
                Container(
                  width: 8, height: 8, 
                  decoration: BoxDecoration(
                    color: isDone ? brightPurp : Colors.white, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: (isDone || isActive) ? brightPurp : darkPurple.withOpacity(0.05), width: 1.5)
                  ),
                  child: isDone ? const Icon(Icons.check, size: 4, color: Colors.white) : null,
                ),
                Expanded(child: Container(height: 1.5, color: i == 4 ? Colors.transparent : rightLineColor)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _lightCard({required Widget child, EdgeInsetsGeometry? margin, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: darkPurple.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: darkPurple.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }

  Widget _buildWOWSmartImage(String? url, double w, double h, double r) {
    return GestureDetector(
      onTap: () => _openWOWPhoto(url),
      child: Container(
        width: w, height: h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(r), color: palePink.withOpacity(0.3), border: Border.all(color: darkPurple.withOpacity(0.05))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r - 1),
          child: (url != null && url.isNotEmpty)
            ? Image.network(url, fit: BoxFit.contain)
            : Icon(Icons.broken_image_rounded, color: darkPurple.withOpacity(0.1), size: w / 3),
        ),
      ),
    );
  }

  Widget _wowBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [brightPurp, mainPurple])),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _wowPill(String label, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: txt, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  void _openWOWPhoto(String? url) {
    if (url == null || url.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(child: Image.network(url, fit: BoxFit.contain, width: double.infinity, height: double.infinity)),
            Positioned(top: 40, right: 20, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32))),
          ],
        ),
      ),
    );
  }

  Widget _buildWOWEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.only(top: 60), child: Column(children: [Icon(Icons.auto_awesome_mosaic_rounded, size: 48, color: darkPurple.withOpacity(0.05)), const SizedBox(height: 16), Text('OPERATIONS CLEAR', style: TextStyle(color: darkPurple.withOpacity(0.1), fontWeight: FontWeight.w900, letterSpacing: 2))])));
  }
}
