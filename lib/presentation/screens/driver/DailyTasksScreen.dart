import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/core/utils/form_validators.dart';
import 'package:aneuso_app/core/utils/product_image_util.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/data/services/driver_tracking_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

final String _kScreenTitle = ScreenTitle.fromFile('DailyTasksScreen.dart');

class DriverTasksScreen extends StatefulWidget {
  const DriverTasksScreen({super.key});

  @override
  State<DriverTasksScreen> createState() => _DriverTasksScreenState();
}

class _DriverTasksScreenState extends State<DriverTasksScreen> {
  final String baseUrl = AppConstants.baseUrl;
  int driverId = 0;

  List<dynamic> tasks = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  // Statistics
  int totalTasks = 0;
  int pendingTasks = 0;
  int completedTasks = 0;
  double totalWeight = 0.0;
  String workingStatus = 'Free';
  bool isStatusLoading = false;
  String _statusFilter = 'All'; // 'All', 'Pending', 'Completed'
  String _sourceFilter = 'All'; // 'All', 'Industry', 'Admin'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    driverId = user?.driverId ?? 0;
    _bootstrapDriverSession();
  }

  Future<void> _bootstrapDriverSession() async {
    await _resolveDriverIdIfNeeded();
    fetchDriverTasks();
    fetchDriverProfile();
  }

  Future<void> _resolveDriverIdIfNeeded() async {
    if (driverId > 0) return;
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user?.driverId != null && user!.driverId! > 0) {
      driverId = user.driverId!;
      return;
    }
    try {
      final token = StorageUtil.getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final id = data['user']?['driver_id'];
        final parsed = id is int ? id : int.tryParse('$id');
        if (parsed != null && parsed > 0 && mounted) {
          setState(() => driverId = parsed);
        }
      }
    } catch (e) {
      debugPrint('Could not resolve driver id: $e');
    }
  }

  Future<void> fetchDriverProfile() async {
    try {
      final token = StorageUtil.getToken();
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final userId = user?.id ?? 0;
      
      final response = await http.get(
        Uri.parse('$baseUrl/drivers/profiles/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            workingStatus = data['data']['working_status'] ?? 'Free';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching driver profile: $e');
    }
  }

  Future<void> toggleWorkingStatus() async {
    setState(() => isStatusLoading = true);
    try {
      final token = StorageUtil.getToken();
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final userId = user?.id ?? 0;
      final newAvailable = workingStatus == 'Busy'; // If Busy, set available=true (Free)
      
      final response = await http.put(
        Uri.parse('$baseUrl/drivers/availability/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'available': newAvailable,
          'driver_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          workingStatus = data['working_status'] ?? (newAvailable ? 'Free' : 'Busy');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $workingStatus')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isStatusLoading = false);
    }
  }

  Future<void> fetchDriverTasks() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final token = StorageUtil.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final userId = user?.id ?? 0;
      
      // Fetch Industry Tasks
      final industryRes = await http.get(Uri.parse('$baseUrl/pickups/schedules/driver/$driverId'), headers: headers);
      
      // Fetch Admin Tasks (Garbage Reports)
      final adminRes = await http.get(
        Uri.parse('$baseUrl/reports/public-garbage?driver_id=$driverId&limit=100'),
        headers: headers,
      );

      List<dynamic> combinedTasks = [];

      if (industryRes.statusCode == 200) {
        final data = jsonDecode(industryRes.body);
        final industryTasks = (data['data'] as List).map((t) => <String, dynamic>{
          ...Map<String, dynamic>.from(t), 
          'source': 'Industry'
        }).toList();
        combinedTasks.addAll(industryTasks);
      }

      if (adminRes.statusCode == 200) {
        final data = jsonDecode(adminRes.body);
        final adminTasks = (data['data'] as List).map((t) => <String, dynamic>{
          ...Map<String, dynamic>.from(t),
          'source': 'Admin',
          'branch_name': t['address'],
          'company_name': 'Public Cleanup',
          'report_status_id': t['report_status_id'],
          'driver_marked_complete_at': t['driver_marked_complete_at'],
          'pickup_status_id': _mapAdminStatusToPickupStatus(
            t['report_status_id'],
            driverMarkedAt: t['driver_marked_complete_at'],
          ),
          'scheduled_date': t['created_at'],
          'estimated_weight_kg': t['estimated_volume'],
          'waste_type_name': t['urgency_name'] ?? 'Urgent',
          'location_address': t['address'],
        }).toList();
        combinedTasks.addAll(adminTasks);
      }

      if (!mounted) return;
      setState(() {
        tasks = combinedTasks;
        totalTasks = combinedTasks.length;
        calculateStatistics();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch tasks error: $e');
      if (!mounted) return;
      setState(() {
        hasError = true;
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  int _mapAdminStatusToPickupStatus(dynamic adminStatus, {dynamic driverMarkedAt}) {
    final s = adminStatus is int ? adminStatus : int.tryParse('$adminStatus') ?? 0;
    if (driverMarkedAt != null && driverMarkedAt.toString().isNotEmpty) {
      if (s != ReportStatus.collected && s != ReportStatus.cleaned) {
        return PickupStatus.completed;
      }
    }
    if (s == ReportStatus.enRoute) return PickupStatus.enRoute;
    if (s == ReportStatus.arrived) return PickupStatus.reachedDestination;
    if (s == ReportStatus.collected || s == ReportStatus.cleaned) {
      return PickupStatus.completed;
    }
    return PickupStatus.scheduled;
  }

  List<dynamic> _getFilteredTasks() {
    return tasks.where((task) {
      // 1. Status Filter
      bool statusMatch = true;
      final displayStatus = DriverTrackingService.displayStatusForTask(task);
      if (_statusFilter == 'Pending') {
        statusMatch = !PickupStatus.isTerminal(displayStatus);
      }
      if (_statusFilter == 'Completed') {
        statusMatch = displayStatus == PickupStatus.completed;
      }

      // 2. Source Filter
      bool sourceMatch = true;
      if (_sourceFilter == 'Industry') sourceMatch = task['source'] == 'Industry';
      if (_sourceFilter == 'Admin') sourceMatch = task['source'] == 'Admin';

      // 3. Search Filter
      bool searchMatch = true;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final branch = (task['branch_name'] ?? '').toString().toLowerCase();
        final company = (task['company_name'] ?? '').toString().toLowerCase();
        searchMatch = branch.contains(query) || company.contains(query);
      }

      return statusMatch && sourceMatch && searchMatch;
    }).toList();
  }

  void calculateStatistics() {
    pendingTasks = tasks
        .where((t) => !PickupStatus.isTerminal(DriverTrackingService.displayStatusForTask(t)))
        .length;
    completedTasks = tasks
        .where((t) => DriverTrackingService.displayStatusForTask(t) == PickupStatus.completed)
        .length;

    totalWeight = tasks.fold(0.0, (sum, task) {
      final weight =
          double.tryParse(task['estimated_weight_kg']?.toString() ?? '0') ?? 0;
      return sum + weight;
    });
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color getStatusColorForTask(Map<String, dynamic> task) {
    if (DriverTrackingService.isDriverPendingAdminVerification(task)) {
      return Colors.orange.shade700;
    }
    return getStatusColor(DriverTrackingService.displayStatusForTask(task));
  }

  String getStatusTextForTask(Map<String, dynamic> task) =>
      DriverTrackingService.displayStatusLabelForTask(task);

  Color getStatusColor(int statusId) {
    switch (statusId) {
      case PickupStatus.scheduled:
        return const Color(0xFF9B5DE0);
      case PickupStatus.enRoute:
        return const Color(0xFF3A86FF);
      case PickupStatus.reachedDestination:
        return const Color(0xFF00B4D8);
      case PickupStatus.completed:
        return const Color(0xFF4CAF50);
      case PickupStatus.cancelled:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String getStatusText(int statusId) => PickupStatus.label(statusId);

  Color getPriorityColor(int priorityId) {
    switch (priorityId) {
      case 1: // high
        return const Color(0xFFFF5252);
      case 2: // medium
        return const Color(0xFFFF9800);
      case 3: // low/citizen
        return const Color(0xFF6F38C5);
      default:
        return const Color(0xFF9B5DE0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderSection()),
            if (DriverTrackingService.instance.isActive)
              SliverToBoxAdapter(child: _buildTrackingBanner()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPickupsToolbar(filteredTasks.length),
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: _buildLoadingState(),
                        )
                      else if (hasError)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: _buildErrorState(),
                        )
                      else if (tasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: _buildEmptyState(),
                        )
                      else if (filteredTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: _buildNoMatchState(),
                        )
                      else
                        ...List.generate(filteredTasks.length, (index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              12,
                              index == 0 ? 4 : 0,
                              12,
                              index == filteredTasks.length - 1 ? 16 : 16,
                            ),
                            child: _buildTaskCard(filteredTasks[index]),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6F38C5), const Color(0xFF9B5DE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (route) => false,
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kScreenTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                        GestureDetector(
                          onTap: isStatusLoading ? null : toggleWorkingStatus,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: workingStatus == 'Free' ? Colors.green : Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: isStatusLoading
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    workingStatus,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: fetchDriverTasks,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildTrackingBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF06D6A0).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF06D6A0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed, color: Color(0xFF06D6A0), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Live tracking ON — task #${DriverTrackingService.instance.activeTaskId} (updates every 5s, works in background)',
              style: const TextStyle(
                color: Color(0xFF047857),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupsToolbar(int visibleCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pickups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6F38C5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$visibleCount tasks',
                  style: const TextStyle(
                    color: Color(0xFF6F38C5),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              hintStyle: const TextStyle(fontSize: 14),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildSourceChip('All'),
              _buildSourceChip('Industry'),
              _buildSourceChip('Admin'),
              Container(
                width: 1,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: Colors.grey[300],
              ),
              _buildFilterChip('All'),
              _buildFilterChip('Pending'),
              _buildFilterChip('Completed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoMatchState() {
    return Column(
      children: [
        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(
          'No tasks match your filters',
          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            setState(() {
              _statusFilter = 'All';
              _sourceFilter = 'All';
              _searchQuery = '';
              _searchController.clear();
            });
          },
          child: const Text('Clear filters'),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      (Icons.list_alt, totalTasks.toString(), 'Total Tasks', const Color(0xFFFDCFFA)),
      (Icons.pending_actions, pendingTasks.toString(), 'Pending', const Color(0xFFD78FEE)),
      (Icons.check_circle, completedTasks.toString(), 'Completed', const Color(0xFF4CAF50)),
      (Icons.scale, '${totalWeight.toStringAsFixed(0)} kg', 'Total Weight', const Color(0xFF9B5DE0)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final fourAcross = constraints.maxWidth >= 520;

        if (fourAcross) {
          return Row(
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    icon: stats[i].$1,
                    value: stats[i].$2,
                    label: stats[i].$3,
                    color: stats[i].$4,
                  ),
                ),
              ],
            ],
          );
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.35,
          children: stats
              .map(
                (s) => _buildStatCard(
                  icon: s.$1,
                  value: s.$2,
                  label: s.$3,
                  color: s.$4,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(String label) {
    bool isSelected = _sourceFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _sourceFilter = label);
      },
      selectedColor: const Color(0xFF9B5DE0).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF9B5DE0) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _statusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _statusFilter = label);
      },
      selectedColor: const Color(0xFF6F38C5).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6F38C5) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    bool isAdmin = task['source'] == 'Admin';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTaskDetails(task),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Priority Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColorForTask(task),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatusTextForTask(task),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin ? Colors.blue[50] : Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAdmin ? 'ADMIN TASK' : 'INDUSTRY TASK',
                        style: TextStyle(
                          color: isAdmin ? Colors.blue[800] : Colors.purple[800],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Company and Branch Info
                Text(
                  task['branch_name'] ?? 'Unknown Branch',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['company_name'] ?? 'Unknown Company',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(color: Colors.grey[200], height: 1),
                const SizedBox(height: 16),

                // Details Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.calendar_today,
                        label: 'Date & Time',
                        value: formatDate(task['scheduled_date']),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.access_time,
                        label: 'Time Slot',
                        value: task['time_slot'] ?? 'N/A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.scale,
                        label: 'Weight',
                        value: '${task['estimated_weight_kg']} kg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.category,
                        label: 'Waste Type',
                        value: task['waste_type_name'] ?? 'N/A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
                if (task['location_address'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: const Color(0xFF9B5DE0),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task['location_address']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Notes
                if (task['notes'] != null && task['notes'].isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDCFFA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: const Color(0xFF9B5DE0),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task['notes']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tap for details',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: Colors.grey[500]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDriverActionButtons(Map<String, dynamic> task) {
    final rawId = task['id'];
    final taskId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0;
    if (taskId == 0) return [];

    final isAdmin = task['source'] == 'Admin';
    final taskType = DriverTrackingService.taskTypeForSource(task['source'] ?? 'Industry');
    final statusId = DriverTrackingService.displayStatusForTask(task);
    final tracking = DriverTrackingService.instance;
    final isTrackingThis = tracking.isActive &&
        tracking.activeTaskId == taskId &&
        tracking.activeTaskType == taskType;

    final widgets = <Widget>[
      const SizedBox(height: 16),
      Divider(color: Colors.grey[200], height: 1),
      const SizedBox(height: 12),
    ];

    if (PickupStatus.canStartTracking(statusId) && !PickupStatus.isTerminal(statusId)) {
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () => _onToggleTracking(taskId, taskType, task, isTrackingThis),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTrackingThis
                      ? [const Color(0xFFFF6B6B), const Color(0xFFEE4444)]
                      : [const Color(0xFF6F38C5), const Color(0xFF9B5DE0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTrackingThis ? Icons.gps_fixed : Icons.play_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isTrackingThis ? 'End live GPS' : 'Start live GPS (phone background)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    final reportStatus = task['report_status_id'];
    final reportStatusId =
        reportStatus is int ? reportStatus : int.tryParse('$reportStatus');
    final driverMarkedComplete = task['driver_marked_complete_at'] != null &&
        task['driver_marked_complete_at'].toString().isNotEmpty;
    final canViewMap = isTrackingThis ||
        PickupStatus.canLiveTrack(statusId) ||
        (isAdmin && ReportStatus.canLiveTrack(reportStatusId));

    if (canViewMap) {
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/live-tracking',
                arguments: {
                  'task_id': taskId,
                  'task_type': taskType,
                },
              );
            },
            icon: const Icon(Icons.map_rounded, size: 18),
            label: const Text('View on map'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6F38C5),
              side: const BorderSide(color: Color(0xFF6F38C5)),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    if (PickupStatus.canMarkReached(statusId) || isTrackingThis) {
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _onReachedDestination(taskId, taskType, task),
            icon: const Icon(Icons.place, size: 18),
            label: const Text('Reached Destination'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6F38C5),
              side: const BorderSide(color: Color(0xFF6F38C5)),
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    if (!isAdmin && PickupStatus.canConfirmPickup(statusId)) {
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/driver/confirm_pickups');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF06D6A0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF06D6A0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF06D6A0), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Confirm Pickup',
                    style: TextStyle(
                      color: Color(0xFF06D6A0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (isAdmin &&
        !driverMarkedComplete &&
        reportStatusId != ReportStatus.collected &&
        reportStatusId != ReportStatus.cleaned &&
        (statusId == PickupStatus.reachedDestination ||
            reportStatusId == ReportStatus.arrived ||
            reportStatusId == ReportStatus.enRoute)) {
      widgets.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAdminCleanupCompletionSheet(taskId, task),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06D6A0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    if (isAdmin &&
        driverMarkedComplete &&
        reportStatusId != ReportStatus.collected &&
        reportStatusId != ReportStatus.cleaned) {
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Waiting for admin to verify your submission',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Future<String?> _uploadCleanupPhoto(XFile file) async {
    try {
      final token = StorageUtil.getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/photo'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: file.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url']?.toString();
      }
    } catch (e) {
      debugPrint('Cleanup photo upload error: $e');
    }
    return null;
  }

  Future<void> _submitAdminCleanupCollection({
    required int reportId,
    required String weightKg,
    required XFile afterPhoto,
  }) async {
    final afterUrl = await _uploadCleanupPhoto(afterPhoto);
    if (afterUrl == null || afterUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload after-cleanup photo')),
        );
      }
      return;
    }

    double? latitude;
    double? longitude;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      latitude = pos.latitude;
      longitude = pos.longitude;
    } catch (e) {
      debugPrint('GPS unavailable on cleanup completion: $e');
    }

    try {
      final token = StorageUtil.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/reports/cleanup/$reportId/submit-collection'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'actual_volume': weightKg,
          'after_photo_url': afterUrl,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completion submitted. Awaiting admin verification.'),
          ),
        );
        await fetchDriverTasks();
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        final body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message']?.toString() ?? 'Failed to submit cleanup')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showAdminCleanupCompletionSheet(int reportId, Map<String, dynamic> task) async {
    final initialWeight =
        task['estimated_weight_kg']?.toString() ?? task['estimated_volume']?.toString() ?? '';

    final result = await showModalBottomSheet<_CleanupCompletionResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _CleanupCompletionSheet(initialWeight: initialWeight),
        );
      },
    );

    if (!mounted || result == null) return;

    await _submitAdminCleanupCollection(
      reportId: reportId,
      weightKg: result.weightKg,
      afterPhoto: XFile.fromData(
        result.photoBytes,
        name: result.photoName,
        mimeType: 'image/jpeg',
      ),
    );
  }

  Future<void> _onToggleTracking(
    int taskId,
    String taskType,
    Map<String, dynamic> task,
    bool isTrackingThis,
  ) async {
    if (isTrackingThis) {
      await DriverTrackingService.instance.stop();
      if (mounted) {
        setState(() {
          task['pickup_status_id'] = PickupStatus.scheduled;
          if (task['source'] == 'Admin') {
            task['report_status_id'] = ReportStatus.assigned;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live tracking ended')),
        );
      }
      return;
    }
    await _onStartTracking(taskId, taskType, task);
  }

  Future<void> _onStartTracking(
    int taskId,
    String taskType,
    Map<String, dynamic> task,
  ) async {
    try {
      await DriverTrackingService.instance.start(
        taskType: taskType,
        taskId: taskId,
        driverId: driverId,
        onTick: ({required autoArrived, pickupStatusId}) {
          if (!mounted) return;
          setState(() {
            if (pickupStatusId != null) {
              task['pickup_status_id'] = pickupStatusId;
              if (task['source'] == 'Admin') {
                task['report_status_id'] = ReportStatus.arrived;
              }
            } else {
              task['pickup_status_id'] = PickupStatus.enRoute;
              if (task['source'] == 'Admin') {
                task['report_status_id'] = ReportStatus.enRoute;
              }
            }
          });
          if (autoArrived) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('You have arrived at the destination')),
            );
          }
        },
      );
      if (mounted) {
        setState(() {
          task['pickup_status_id'] = PickupStatus.enRoute;
          if (task['source'] == 'Admin') {
            task['report_status_id'] = ReportStatus.enRoute;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Live GPS is on. You can minimize the app or turn the screen off — '
              'keep the GPS notification visible. If you swipe the app away, '
              'reopen ANEUSO and tracking resumes automatically.',
            ),
            backgroundColor: Color(0xFF6F38C5),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _onReachedDestination(
    int taskId,
    String taskType,
    Map<String, dynamic> task,
  ) async {
    try {
      await DriverTrackingService.instance.markReached(
        taskType: taskType,
        taskId: taskId,
      );
      if (mounted) {
        setState(() {
          task['pickup_status_id'] = PickupStatus.reachedDestination;
          if (task['source'] == 'Admin') {
            task['report_status_id'] = ReportStatus.arrived;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as reached destination')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }


  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF9B5DE0)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F38C5).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF6F38C5),
                      ),
                      backgroundColor: const Color(0xFF9B5DE0).withOpacity(0.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading your tasks...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait a moment',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: const Color(0xFFFF5252),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: fetchDriverTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F38C5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6F38C5).withOpacity(0.1),
                    const Color(0xFF9B5DE0).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: const Color(0xFF6F38C5).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Tasks!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have completed all your scheduled pickups.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: fetchDriverTasks,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD78FEE)),
                foregroundColor: const Color(0xFF9B5DE0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Refresh',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    final isAdminTask = task['source'] == 'Admin';
    final statusLabel = getStatusTextForTask(task);
    final statusColor = getStatusColorForTask(task);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, setSheetState) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Task Details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAdminTask ? Colors.blue[50] : Colors.purple[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAdminTask ? 'ADMIN CLEANUP' : 'INDUSTRY PICKUP',
                                  style: TextStyle(
                                    color: isAdminTask ? Colors.blue[800] : Colors.purple[800],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task['branch_name'] ?? 'Unknown location',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[100]!),
                            ),
                            child: Column(
                              children: [
                                _buildSheetDetailRow(
                                  'Company',
                                  task['company_name'] ?? 'N/A',
                                  Icons.business,
                                ),
                                const SizedBox(height: 12),
                                _buildSheetDetailRow(
                                  'Location',
                                  task['location_address'] ?? task['address'] ?? 'N/A',
                                  Icons.location_on,
                                ),
                                const SizedBox(height: 12),
                                _buildSheetDetailRow(
                                  'Scheduled',
                                  formatDate(task['scheduled_date']?.toString() ?? ''),
                                  Icons.calendar_today,
                                ),
                                if (!isAdminTask) ...[
                                  const SizedBox(height: 12),
                                  _buildSheetDetailRow(
                                    'Time slot',
                                    task['time_slot']?.toString() ?? 'N/A',
                                    Icons.access_time,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSheetDetailRow(
                                        'Est. weight',
                                        '${task['estimated_weight_kg'] ?? task['estimated_volume'] ?? '0'} kg',
                                        Icons.scale,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSheetDetailRow(
                                        isAdminTask ? 'Urgency' : 'Waste type',
                                        task['waste_type_name']?.toString() ?? 'N/A',
                                        Icons.category,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isAdminTask &&
                                    task['description'] != null &&
                                    task['description'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildSheetDetailRow(
                                    'Description',
                                    task['description'].toString(),
                                    Icons.notes,
                                  ),
                                ],
                                if (task['notes'] != null && task['notes'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  _buildSheetDetailRow(
                                    'Notes',
                                    task['notes'].toString(),
                                    Icons.note,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          ..._buildTaskImagesSection(task, isAdminTask),
                          if (task['id'] != null) ..._buildDriverActionButtons(task),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) fetchDriverTasks();
        });
      }
    });
  }

  bool _isTaskComplete(Map<String, dynamic> task) {
    return DriverTrackingService.isDriverPendingAdminVerification(task) ||
        DriverTrackingService.isAdminVerifiedComplete(task);
  }

  List<String> _parsePhotoUrls(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return const [];
      if (trimmed.startsWith('[')) {
        try {
          final decoded = json.decode(trimmed);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
          }
        } catch (_) {}
      }
      return [trimmed];
    }
    return const [];
  }

  Future<List<String>> _loadIndustryAfterPhotoUrls(int scheduleId) async {
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/pickups/confirmations/schedule/$scheduleId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) return const [];
      final body = json.decode(response.body);
      final confirmation = body['data'];
      if (confirmation is! Map) return const [];
      return _parsePhotoUrls(confirmation['photos_urls'])
          .map(resolveProductImageUrl)
          .whereType<String>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<Widget> _buildTaskImagesSection(
    Map<String, dynamic> task,
    bool isAdminTask,
  ) {
    final isComplete = _isTaskComplete(task);
    final beforeUrl = isAdminTask
        ? resolveProductImageUrl(task['photo_url']?.toString())
        : null;
    final afterUrl = isAdminTask
        ? resolveProductImageUrl(task['after_photo_url']?.toString())
        : null;

    if (isComplete && isAdminTask && (beforeUrl != null || afterUrl != null)) {
      return [
        const SizedBox(height: 20),
        const Text(
          'Before & after cleanup',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTaskPhotoTile('Before', beforeUrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildTaskPhotoTile('After', afterUrl)),
          ],
        ),
      ];
    }

    if (isComplete && !isAdminTask) {
      final scheduleId = task['id'];
      final id = scheduleId is int ? scheduleId : int.tryParse('$scheduleId');
      if (id == null) return const [];

      return [
        const SizedBox(height: 20),
        const Text(
          'Pickup photos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<String>>(
          future: _loadIndustryAfterPhotoUrls(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final photos = snapshot.data ?? const [];
            if (photos.isEmpty) {
              return Text(
                'No pickup photos uploaded for this task.',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              );
            }
            if (photos.length == 1) {
              return _buildTaskPhotoTile('After pickup', photos.first, fullWidth: true);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTaskPhotoTile('Photo 1', photos[0])),
                if (photos.length > 1) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildTaskPhotoTile('Photo 2', photos[1])),
                ],
              ],
            );
          },
        ),
      ];
    }

    if (beforeUrl != null) {
      return [
        const SizedBox(height: 20),
        const Text(
          'Site photo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _buildTaskPhotoTile('Before cleanup', beforeUrl, fullWidth: true),
      ];
    }

    return const [];
  }

  Widget _buildTaskPhotoTile(String label, String? url, {bool fullWidth = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: fullWidth ? 160 : 130,
            color: const Color(0xFFF3EEFF),
            child: url != null && url.isNotEmpty
                ? Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(),
                  )
                : _buildPhotoPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Center(
      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 36),
    );
  }

  Widget _buildSheetDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9B5DE0)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CleanupCompletionResult {
  final String weightKg;
  final Uint8List photoBytes;
  final String photoName;

  const _CleanupCompletionResult({
    required this.weightKg,
    required this.photoBytes,
    required this.photoName,
  });
}

class _CleanupCompletionSheet extends StatefulWidget {
  final String initialWeight;

  const _CleanupCompletionSheet({required this.initialWeight});

  @override
  State<_CleanupCompletionSheet> createState() => _CleanupCompletionSheetState();
}

class _CleanupCompletionSheetState extends State<_CleanupCompletionSheet> {
  late final TextEditingController _weightController;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.initialWeight);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null || !mounted) return;
    final bytes = await photo.readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoBytes = bytes;
      _photoName = photo.name.isNotEmpty ? photo.name : 'after_cleanup.jpg';
    });
  }

  void _submit() {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an after-cleanup photo')),
      );
      return;
    }
    _isSubmitting = true;
    Navigator.pop(
      context,
      _CleanupCompletionResult(
        weightKg: _weightController.text.trim(),
        photoBytes: _photoBytes!,
        photoName: _photoName ?? 'after_cleanup.jpg',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Mark Cleanup as Completed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit weight and after photo. Admin will verify before the task is closed.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Actual weight collected (kg)',
                border: OutlineInputBorder(),
              ),
              validator: FormValidators.weightKg,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _pickPhoto,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(_photoBytes == null ? 'Add after photo' : 'Change after photo'),
            ),
            if (_photoBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _photoBytes!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text('Submit for verification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06D6A0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
