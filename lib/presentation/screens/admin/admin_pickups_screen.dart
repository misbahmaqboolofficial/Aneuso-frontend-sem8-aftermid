import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';

class AdminPickupsScreen extends StatefulWidget {
  const AdminPickupsScreen({super.key});

  @override
  State<AdminPickupsScreen> createState() => _AdminPickupsScreenState();
}

class _AdminPickupsScreenState extends State<AdminPickupsScreen> {
  List pickups = [];
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
      case 2: return const Color(0xFFFF9800); // In Progress
      case 3: return const Color(0xFF4CAF50); // Completed
      case 4: return const Color(0xFFF44336); // Cancelled
      default: return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(int? statusId) {
    switch (statusId) {
      case 1: return Icons.calendar_today;
      case 2: return Icons.local_shipping;
      case 3: return Icons.check_circle;
      case 4: return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        slivers: [
          // Header Section
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Pickup Management',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9B5DE0), Color(0xFFD78FEE), Color(0xFFFDCFFA)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat('Total', totalCount.toString(), Icons.analytics),
                      _buildHeaderStat('Pending', pendingCount.toString(), Icons.pending_actions),
                      _buildHeaderStat('Done', completedCount.toString(), Icons.task_alt),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _fetchPickups,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              ),
            ],
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
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.7))),
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
                            pickup['company_name'] ?? 'Unknown Company',
                            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500),
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
