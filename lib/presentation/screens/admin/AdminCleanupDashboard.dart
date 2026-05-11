import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'CleanupFinalizationScreen.dart';
import 'MissionAssignmentScreen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../public_garbage_reports_screen.dart';
import '../GarbageMissionDetailsScreen.dart';

class AdminCleanupDashboard extends StatefulWidget {
  const AdminCleanupDashboard({super.key});

  @override
  State<AdminCleanupDashboard> createState() => _AdminCleanupDashboardState();
}

class _AdminCleanupDashboardState extends State<AdminCleanupDashboard> {
  final String baseUrl = AppConstants.baseUrl;
  Map<String, dynamic> stats = {};
  List<dynamic> allCollections = [];
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
        allCollections = all.where((r) => [172, 204, 206, 207, 205, 208, 174].contains(r['report_status_id'])).toList();
      }
      setState(() => isLoading = false);
    } catch (e) { setState(() => isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed to white for lightness
      body: Stack(
        children: [
          // Dynamic Mesh Background Accents
          Positioned(top: -100, right: -100, child: _blurCircle(400, palePink.withOpacity(0.4))),
          Positioned(bottom: -50, left: -100, child: _blurCircle(350, softLilac.withOpacity(0.2))),
          
          isLoading
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
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)));

  Widget _buildWOWAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: const Text('CLEANUP COMMAND', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkPurple, letterSpacing: 3)),
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

  Widget _buildWOWCollectionCard(Map<String, dynamic> report) {
    final int statusId = report['report_status_id'] ?? 172;
    final bool isDone = statusId == 174;
    final String driver = report['driver_name']?.toString() ?? 'UNASSIGNED';

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
            _buildWOWMiniStepper(statusId),
            if (isDone)
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8), color: brightPurp, child: const Center(child: Text('MISSION SUCCESS', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)))),
          ],
        ),
      ),
    );
  }

  Widget _buildWOWMiniStepper(int statusId) {
    int cur = 0; // Default to 0 (Pending, completely grey)
    if (statusId == 172) cur = 1;
    else if (statusId == 206) cur = 2; 
    else if (statusId == 207) cur = 3; 
    else if (statusId == 205) cur = 4; 
    else if (statusId == 208 || statusId == 174) cur = 5;

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
