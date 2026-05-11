import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import 'AdminCleanupDashboard.dart';
import 'CleanupFinalizationScreen.dart';
import '../GarbageMissionDetailsScreen.dart';
import '../public_garbage_reports_screen.dart';

class MissionAssignmentScreen extends StatefulWidget {
  final int reportId;
  final Map<String, dynamic> report;

  const MissionAssignmentScreen({super.key, required this.reportId, required this.report});

  @override
  State<MissionAssignmentScreen> createState() => _MissionAssignmentScreenState();
}

class _MissionAssignmentScreenState extends State<MissionAssignmentScreen> {
  final String baseUrl = AppConstants.baseUrl;
  int selectedUrgency = 184;
  int selectedStatus = 204;
  int? selectedDriver;
  final fundingController = TextEditingController();
  final volumeController = TextEditingController(text: '20');
  final instructionsController = TextEditingController();
  List<dynamic> drivers = [];
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
    _initializeData();
    _fetchDrivers();
    _fetchReportData(); // Fetch fresh data to ensure we aren't using stale parent data
  }

  void _initializeData() {
    selectedStatus = widget.report['report_status_id'] ?? 204;
    selectedUrgency = widget.report['urgency_level_id'] ?? 183;
    selectedDriver = widget.report['driver_id'];
    volumeController.text = widget.report['estimated_volume']?.toString() ?? '';
    instructionsController.text = widget.report['admin_notes'] ?? '';
    fundingController.text = widget.report['funding_goal']?.toString() ?? '';
  }

  Future<void> _fetchReportData() async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/reports/public-garbage/${widget.reportId}?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (mounted) {
          setState(() {
            selectedStatus = data['report_status_id'];
            selectedUrgency = data['urgency_level_id'] ?? 183;
            selectedDriver = data['driver_id'];
            volumeController.text = data['estimated_volume']?.toString() ?? '';
            instructionsController.text = data['admin_notes'] ?? '';
            fundingController.text = data['funding_goal']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching fresh report data: $e");
    }
  }

  Future<void> _fetchDrivers() async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(Uri.parse('$baseUrl/admin/drivers?active_status=1&limit=100&t=${DateTime.now().millisecondsSinceEpoch}'), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] as List;
        setState(() { 
          drivers = data; 
          
          // Data Migration: Ensure selectedDriver matches a User ID in the new dropdown system
          if (selectedDriver != null) {
            bool existsAsUserId = drivers.any((d) => d['id'] == selectedDriver);
            if (!existsAsUserId) {
              // Try to find if it was an old drivers.id
              try {
                final match = drivers.firstWhere((d) => d['driver_profile_id'] == selectedDriver);
                selectedDriver = match['id'];
              } catch (_) {
                selectedDriver = null; // Clear if no match found
              }
            }
          }
          
          isLoading = false; 
        });
      } else { setState(() => isLoading = false); }
    } catch (e) { setState(() => isLoading = false); }
  }

  Future<void> _submitAssignment() async {
    if (selectedDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operational Error: A driver must be assigned.'), backgroundColor: brightPurp));
      return;
    }
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();
      final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
      await http.put(Uri.parse('$baseUrl/reports/cleanup/${widget.reportId}/approve'), headers: headers, body: json.encode({'urgency_level_id': selectedUrgency, 'funding_goal': fundingController.text, 'report_status_id': selectedStatus}));
      if (selectedStatus >= 172) {
        await http.put(Uri.parse('$baseUrl/reports/cleanup/${widget.reportId}/dispatch'), headers: headers, body: json.encode({'driver_id': selectedDriver, 'estimated_volume': volumeController.text, 'urgency_level_id': selectedUrgency, 'admin_notes': instructionsController.text, 'report_status_id': selectedStatus}));
      }
      if (mounted) {
        if (selectedStatus == 208) {
          // If status is "Collected", redirect to Finalization
          final updatedReport = Map<String, dynamic>.from(widget.report);
          updatedReport['report_status_id'] = selectedStatus;
          updatedReport['driver_id'] = selectedDriver;
          updatedReport['urgency_level_id'] = selectedUrgency;
          updatedReport['funding_goal'] = fundingController.text;
          updatedReport['admin_notes'] = instructionsController.text;
          updatedReport['estimated_volume'] = volumeController.text;

          // Use normal push and wait for result, then pop this screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CleanupFinalizationScreen(
                report: GarbageReport.fromJson(updatedReport),
              ),
            ),
          );
          
          if (mounted && result == true) {
            Navigator.pop(context, true); // Success: refresh dashboard
          }
        } else {
          Navigator.pop(context, true);
        }
      }
    } catch (e) { setState(() => isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: _blurCircle(300, palePink.withOpacity(0.4))),
          Positioned(bottom: -100, left: -100, child: _blurCircle(400, softLilac.withOpacity(0.2))),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: darkPurple),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: const Text('MISSION SETUP', style: TextStyle(fontWeight: FontWeight.w900, color: darkPurple, fontSize: 16, letterSpacing: 4)),
                  background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [palePink.withOpacity(0.5), Colors.white]))),
                ),
              ),
              
              SliverToBoxAdapter(
                child: isLoading
                    ? const Padding(padding: EdgeInsets.only(top: 100), child: Center(child: CircularProgressIndicator(color: brightPurp)))
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
                        child: Column(
                          children: [
                            _lightCard(child: _buildModernStepTracker()),
                            const SizedBox(height: 24),
                            
                            _lightCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionHeader('PRIORITY CORE', Icons.bolt_rounded),
                                  const SizedBox(height: 20),
                                  _buildUrgencyGrid(),
                                  const SizedBox(height: 24),
                                  _wowTextField('FUNDING TARGET (PKR)', fundingController, Icons.payments_rounded, isNum: true),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            _lightCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDriverDropdown(),
                                  const SizedBox(height: 32),
                                  _wowTextField('MASS VOLUME (KG)', volumeController, Icons.scale_rounded, isNum: true),
                                  const SizedBox(height: 32),
                                  _wowTextField('COMMAND NOTES', instructionsController, Icons.description_rounded, maxLines: 3),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            _buildActionBtn(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _blurCircle(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)));

  Widget _lightCard({required Widget child}) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: darkPurple.withOpacity(0.05)), boxShadow: [BoxShadow(color: darkPurple.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32), child: child));

  Widget _sectionHeader(String title, IconData icon) => Row(children: [Icon(icon, color: brightPurp, size: 18), const SizedBox(width: 12), Text(title, style: const TextStyle(color: darkPurple, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2))]);

  Widget _buildUrgencyGrid() {
    final options = [{'label': 'LOW', 'id': 183}, {'label': 'MEDIUM', 'id': 184}, {'label': 'CRITICAL', 'id': 186}];
    return Row(
      children: options.map((opt) {
        bool sel = selectedUrgency == opt['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedUrgency = opt['id'] as int),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: sel ? brightPurp : palePink.withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? brightPurp : darkPurple.withOpacity(0.05))),
              child: Center(child: Text(opt['label'] as String, style: TextStyle(color: sel ? Colors.white : darkPurple.withOpacity(0.4), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1))),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDriverDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('PERSONNEL SELECTION', Icons.local_shipping_rounded),
        const SizedBox(height: 20),
        DropdownButtonFormField<int>(
          value: selectedDriver,
          isExpanded: true,
          itemHeight: 80, 
          icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: brightPurp, size: 28),
          decoration: InputDecoration(
            filled: true,
            fillColor: palePink.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Larger box
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: darkPurple.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: brightPurp, width: 2)),
          ),
          hint: const Text('SELECT OPERATIONAL PERSONNEL', style: TextStyle(color: darkPurple, fontSize: 13, fontWeight: FontWeight.w700)),
          selectedItemBuilder: (context) {
            return drivers.map<Widget>((d) {
              final String name = d['full_name'] ?? 'Driver';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.delivery_dining_rounded, color: brightPurp, size: 24),
                  const SizedBox(width: 12),
                  Flexible(child: Text(name, style: const TextStyle(color: darkPurple, fontWeight: FontWeight.w900, fontSize: 15), overflow: TextOverflow.ellipsis)),
                ],
              );
            }).toList();
          },
          items: drivers.map<DropdownMenuItem<int>>((d) {
            final int userId = d['id'];
            final String name = d['full_name'] ?? 'Driver';
            final String vehicle = d['vehicle_name'] ?? 'ACTIVE PERSONNEL';
            
            return DropdownMenuItem<int>(
              value: userId,
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining_rounded, color: brightPurp, size: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name, style: const TextStyle(color: darkPurple, fontWeight: FontWeight.w900, fontSize: 15), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(vehicle.toUpperCase(), style: TextStyle(color: darkPurple.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => selectedDriver = val),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ],
    );
  }

  Widget _wowTextField(String label, TextEditingController controller, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: darkPurple.withOpacity(0.3), letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: darkPurple, fontSize: 15, fontWeight: FontWeight.w700),
          decoration: InputDecoration(prefixIcon: Icon(icon, color: brightPurp, size: 22), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), filled: true, fillColor: palePink.withOpacity(0.1), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: darkPurple.withOpacity(0.05))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: brightPurp, width: 2))),
        ),
      ],
    );
  }

  Widget _buildActionBtn() {
    return Container(
      width: double.infinity, height: 60,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [brightPurp, mainPurple]), boxShadow: [BoxShadow(color: brightPurp.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
      child: ElevatedButton(onPressed: _submitAssignment, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('INITIALIZE MISSION PROTOCOL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1))),
    );
  }

  Widget _buildModernStepTracker() {
    final steps = [
      {'label': 'Approved', 'id': 172},
      {'label': 'Assigned', 'id': 206},
      {'label': 'En Route', 'id': 207},
      {'label': 'In Progress', 'id': 205},
      {'label': 'Collected', 'id': 208},
    ];
    
    int cur = 0; // Default to 0 (Pending, completely grey)
    if (selectedStatus == 172) cur = 1;
    else if (selectedStatus == 206) cur = 2; 
    else if (selectedStatus == 207) cur = 3; 
    else if (selectedStatus == 205) cur = 4; 
    else if (selectedStatus == 208 || selectedStatus == 174) cur = 5;

    return Column(
      children: [
        Text('MISSION STAGE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: darkPurple.withOpacity(0.4), letterSpacing: 3)),
        const SizedBox(height: 20),
        SingleChildScrollView(
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
                width: 95, // Wider for better visibility
                child: GestureDetector(
                  onTap: () => setState(() => selectedStatus = steps[i]['id'] as int),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Container(height: 3, color: i == 0 ? Colors.transparent : leftLineColor)),
                          Container(
                            width: 22, height: 22, // Larger dots
                            decoration: BoxDecoration(
                              color: isDone ? brightPurp : Colors.white, 
                              shape: BoxShape.circle, 
                              border: Border.all(color: (isDone || isActive) ? brightPurp : darkPurple.withOpacity(0.1), width: 3),
                              boxShadow: isActive ? [BoxShadow(color: brightPurp.withOpacity(0.3), blurRadius: 10)] : null
                            ),
                            child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                          ),
                          Expanded(child: Container(height: 3, color: i == steps.length - 1 ? Colors.transparent : rightLineColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(steps[i]['label'] as String, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w900 : FontWeight.w600, color: (i + 1 <= cur) ? darkPurple : darkPurple.withOpacity(0.3))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
