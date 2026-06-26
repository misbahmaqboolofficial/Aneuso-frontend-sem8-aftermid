import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/constants/pickup_status.dart';
import '../../../data/services/driver_tracking_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/storage_util.dart';

class DriverMissionScreen extends StatefulWidget {
  const DriverMissionScreen({super.key});

  @override
  State<DriverMissionScreen> createState() => _DriverMissionScreenState();
}

class _DriverMissionScreenState extends State<DriverMissionScreen> {
  final String baseUrl = AppConstants.baseUrl;
  List<dynamic> missions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/reports/cleanup/driver-missions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          missions = json.decode(response.body)['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> updateStatus(int reportId, String stage, {Map<String, dynamic>? extraData}) async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/reports/cleanup/$reportId/$stage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: extraData != null ? json.encode(extraData) : null,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated: $stage')));
        fetchMissions();
      }
    } catch (e) {
      debugPrint('Update error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: const Text('My Cleanup Missions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF9B5DE0),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : missions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchMissions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: missions.length,
                    itemBuilder: (context, index) => _buildMissionCard(missions[index]),
                  ),
                ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final statusId = mission['report_status_id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF9B5DE0).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MISSION #${mission['id']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9B5DE0))),
                _buildStatusChip(statusId),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem(Icons.location_on, 'Location', mission['address'] ?? 'Unknown'),
                const SizedBox(height: 12),
                _detailItem(Icons.priority_high, 'Urgency', mission['urgency_name'] ?? 'Medium'),
                const SizedBox(height: 12),
                _detailItem(Icons.scale, 'Est. Waste', '${mission['estimated_volume']} kg'),
                const SizedBox(height: 24),
                _buildActionButtons(mission),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int statusId) {
    String label = 'Assigned';
    Color color = Colors.blue;
    if (statusId == 207) { label = 'On the Way'; color = Colors.orange; }
    if (statusId == 205) { label = 'Arrived'; color = Colors.indigo; }
    if (statusId == 208) { label = 'Collected'; color = Colors.green; }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _detailItem(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> mission) {
    final statusId = mission['report_status_id'];
    
    if (statusId == ReportStatus.assigned) {
      return _btn('START TRACKING (ON THE WAY)', () => _startMissionTracking(mission), const Color(0xFF9B5DE0));
    }
    if (statusId == ReportStatus.enRoute) {
      return _btn('ARRIVED AT LOCATION', () => _markMissionArrived(mission['id']), const Color(0xFF6F38C5));
    }
    if (statusId == ReportStatus.arrived) {
      return _btn('MARK AS COLLECTED', () => _showCollectionDialog(mission['id']), Colors.green);
    }
    
    return const Center(child: Text('Waiting for Admin Review', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)));
  }

  Widget _btn(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Future<void> _startMissionTracking(Map<String, dynamic> mission) async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final dId = user?.driverId ?? 0;
    try {
      await DriverTrackingService.instance.start(
        taskType: TrackingTaskType.adminCleanup,
        taskId: mission['id'] as int,
        driverId: dId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking started')),
        );
        fetchMissions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _markMissionArrived(int reportId) async {
    try {
      await DriverTrackingService.instance.markReached(
        taskType: TrackingTaskType.adminCleanup,
        taskId: reportId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arrived at cleanup location')),
        );
        fetchMissions();
      }
    } catch (e) {
      await updateStatus(reportId, 'arrive');
    }
  }

  void _showCollectionDialog(int reportId) {
    final weight = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Submit Collection Evidence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Actual Weight Collected (kg)'),
              validator: FormValidators.weightKg,
            ),
            const SizedBox(height: 20),
            _btn('SUBMIT PROOF', () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              double? latitude;
              double? longitude;
              try {
                final pos = await Geolocator.getCurrentPosition(
                  locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
                );
                latitude = pos.latitude;
                longitude = pos.longitude;
              } catch (e) {
                debugPrint('Could not get location on submit-collection: $e');
              }
              updateStatus(reportId, 'submit-collection', extraData: {
                'actual_volume': weight.text,
                'after_photo_url': 'https://via.placeholder.com/400x300.png?text=After+Cleanup+Proof', // Placeholder for now
                if (latitude != null) 'latitude': latitude,
                if (longitude != null) 'longitude': longitude,
              });
            }, Colors.green),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No active missions assigned.'));
  }
}
