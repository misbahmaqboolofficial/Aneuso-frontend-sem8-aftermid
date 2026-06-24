import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pickup_status.dart';
import '../../../core/utils/storage_util.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('admin_pickups_screen.dart');

class AdminPickupsScreen extends StatefulWidget {
  const AdminPickupsScreen({super.key});

  @override
  State<AdminPickupsScreen> createState() => _AdminPickupsScreenState();
}

class _AdminPickupsScreenState extends State<AdminPickupsScreen> {
  List pickups = [];
  List _drivers = [];
  bool isLoading = true;
  String? selectedStatus;

  // Stats
  int totalCount = 0;
  int completedCount = 0;
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPickups();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/industry/available-drivers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final result = json.decode(response.body);
      if (result['success'] == true && mounted) {
        setState(() => _drivers = result['data'] ?? []);
      }
    } catch (e) {
      debugPrint('Error fetching drivers: $e');
    }
  }

  Future<void> _assignDriver(int pickupId, String? currentDriverName) async {
    if (_drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No approved drivers available')),
      );
      return;
    }

    int? selectedId;
    final confirmed = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Assign driver'),
          content: DropdownButtonFormField<int>(
            value: selectedId,
            decoration: const InputDecoration(labelText: 'Select driver'),
            items: _drivers
                .map<DropdownMenuItem<int>>((d) {
                  final id = d['id'] is int ? d['id'] as int : int.parse('${d['id']}');
                  return DropdownMenuItem(
                    value: id,
                    child: Text('${d['full_name'] ?? 'Driver'} (${d['vehicle_plate_number'] ?? '—'})'),
                  );
                })
                .toList(),
            onChanged: (v) => setDialogState(() => selectedId = v),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: selectedId == null ? null : () => Navigator.pop(ctx, selectedId),
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == null) return;

    try {
      final token = StorageUtil.getToken();
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/pickups/schedules/$pickupId/assign-driver'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'driver_id': confirmed}),
      );
      final result = json.decode(response.body);
      if (response.statusCode == 200 && result['success'] != false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driver assigned successfully')),
          );
          _fetchPickups();
        }
      } else {
        throw Exception(result['message'] ?? 'Assign failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _fetchPickups() async {
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();
      String url = '${AppConstants.baseUrl}/admin/all-pickups';
      if (selectedStatus != null) {
        url += '?status=$selectedStatus';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          pickups = result['data'];
          _calculateStats();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching all pickups: $e');
      setState(() => isLoading = false);
    }
  }

  void _calculateStats() {
    totalCount = pickups.length;
    completedCount = pickups.where((p) => p['pickup_status_id'] == 3).length;
    pendingCount = pickups.where((p) => p['pickup_status_id'] == 1 || p['pickup_status_id'] == 2).length;
  }

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1: return const Color(0xFF2196F3); // Scheduled
      case 2: return const Color(0xFFFF9800); // En Route
      case 3: return const Color(0xFF4CAF50); // Completed
      case 4: return const Color(0xFF9B5DE0); // Reached Destination
      case 6: return const Color(0xFFF44336); // Cancelled
      default: return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(int? statusId) {
    switch (statusId) {
      case 1: return Icons.calendar_today;
      case 2: return Icons.local_shipping;
      case 3: return Icons.check_circle;
      case 4: return Icons.place_rounded;
      case 6: return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverAppBar(
            backgroundColor: const Color(0xFF9B5DE0),
            floating: false,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: _fetchPickups,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF9B5DE0),
                    Color(0xFF6F38C5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _kScreenTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat('Total', totalCount.toString(), Icons.analytics),
                      _buildHeaderStat('Pending', pendingCount.toString(), Icons.pending_actions),
                      _buildHeaderStat('Done', completedCount.toString(), Icons.task_alt),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Filter Section
          SliverToBoxAdapter(
            child: Container(
              height: 70,
              margin: const EdgeInsets.only(top: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildFilterChip(null, 'All Pickups', Icons.all_inclusive),
                  _buildFilterChip('1', 'Scheduled', Icons.schedule),
                  _buildFilterChip('2', 'Active', Icons.local_shipping),
                  _buildFilterChip('3', 'Completed', Icons.check_circle_outline),
                  _buildFilterChip('4', 'Cancelled', Icons.cancel_outlined),
                ],
              ),
            ),
          ),

          // Content Section
          isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF9B5DE0))))
              : pickups.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildPickupCard(pickups[index]),
                          childCount: pickups.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String? id, String label, IconData icon) {
    bool isSelected = selectedStatus == id;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedStatus = id);
          _fetchPickups();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9B5DE0) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isSelected ? const Color(0xFF9B5DE0).withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> pickup) {
    final statusId = pickup['pickup_status_id'];
    final statusColor = _getStatusColor(statusId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B5DE0).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_getStatusIcon(statusId), size: 16, color: statusColor),
                    const SizedBox(width: 8),
                    Text(
                      pickup['status_name']?.toUpperCase() ?? 'PENDING',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ],
                ),
                Text(
                  '#${pickup['id']}',
                  style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup['branch_name'] ?? 'Main Location',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (pickup['company_name'] ?? 'Unknown Company').toString().toLowerCase().contains('iba')
                                ? 'EcoWaste Solutions'
                                : (pickup['company_name'] ?? 'Unknown Company'),
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF9B5DE0).withOpacity(0.05), shape: BoxShape.circle),
                      child: const Icon(Icons.location_on, color: Color(0xFF9B5DE0), size: 18),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoBlock(Icons.person_outline, 'Driver', pickup['driver_name'] ?? 'Waiting...'),
                    _infoBlock(Icons.scale_outlined, 'Weight', '${pickup['estimated_weight_kg']} kg'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoBlock(Icons.calendar_month_outlined, 'Scheduled', DateFormat('MMM dd, yyyy').format(DateTime.parse(pickup['scheduled_date']))),
                    _infoBlock(Icons.access_time_rounded, 'Slot', pickup['time_slot'] ?? 'N/A'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Waste Type Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B5DE0).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category_outlined, size: 14, color: Color(0xFF9B5DE0)),
                      const SizedBox(width: 8),
                      Text(
                        pickup['waste_type_name'] ?? 'General Waste',
                        style: const TextStyle(color: Color(0xFF9B5DE0), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (pickup['driver_id'] != null &&
                    PickupStatus.canLiveTrack(statusId)) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final id = pickup['id'] is int
                            ? pickup['id'] as int
                            : int.parse('${pickup['id']}');
                        Navigator.pushNamed(
                          context,
                          '/live-tracking',
                          arguments: {
                            'task_id': id,
                            'task_type': 'industry_pickup',
                          },
                        );
                      },
                      icon: const Icon(Icons.location_on, size: 18),
                      label: const Text('Live Track Driver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F38C5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _assignDriver(
                      pickup['id'] is int ? pickup['id'] as int : int.parse('${pickup['id']}'),
                      pickup['driver_name']?.toString(),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: Text(
                      pickup['driver_id'] == null ? 'Assign driver' : 'Reassign driver',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6F38C5),
                      side: const BorderSide(color: Color(0xFF6F38C5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBlock(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
            ]),
            child: Icon(Icons.local_shipping_outlined, size: 60, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          Text(
            'No pickups found',
            style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Change your filters or check back later',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
