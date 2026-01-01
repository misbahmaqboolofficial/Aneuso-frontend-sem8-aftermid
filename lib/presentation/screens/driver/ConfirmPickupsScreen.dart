import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/storage_util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConfirmPickupsScreen extends StatefulWidget {
  const ConfirmPickupsScreen({super.key});

  @override
  State<ConfirmPickupsScreen> createState() => _ConfirmPickupsScreenState();
}

class _ConfirmPickupsScreenState extends State<ConfirmPickupsScreen> {
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

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    driverId = user?.driverId ?? 0;
    fetchDriverTasks();
  }

  Future<void> fetchDriverTasks() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/pickups/schedules/driver/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate loading

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            tasks = data['data'] ?? [];
            totalTasks = data['total'] ?? 0;
            calculateStatistics();
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = 'Failed to load tasks';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  void calculateStatistics() {
    pendingTasks = tasks.where((task) => task['pickup_status_id'] == 1).length;
    completedTasks = tasks
        .where((task) => task['pickup_status_id'] == 2)
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

  Color getStatusColor(int statusId) {
    switch (statusId) {
      case 1: // industry/pending
        return const Color(0xFFFF9800);
      case 2: // completed
        return const Color(0xFF4CAF50);
      case 3: // in-progress
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String getStatusText(int statusId) {
    switch (statusId) {
      case 1:
        return 'Pending';
      case 2:
        return 'Completed';
      case 3:
        return 'In Progress';
      default:
        return 'Unknown';
    }
  }

  Color getPriorityColor(int priorityId) {
    switch (priorityId) {
      case 1: // high
        return const Color(0xFFFF5252);
      case 2: // medium
        return const Color(0xFFFF9800);
      case 3: // low/citizen
        return const Color(0xFF4E56C0);
      default:
        return const Color(0xFF9B5DE0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4E56C0), const Color(0xFF9B5DE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/dashboard',
                        (route) => false,
                      );
                    },
                    color: Colors.white,
                  ),
                  // Title and Refresh
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm Pickups',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your pickup schedule',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: fetchDriverTasks,
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.list_alt,
                          value: totalTasks.toString(),
                          label: 'Total Tasks',
                          color: const Color(0xFFFDCFFA),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.pending_actions,
                          value: pendingTasks.toString(),
                          label: 'Pending',
                          color: const Color(0xFFD78FEE),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.check_circle,
                          value: completedTasks.toString(),
                          label: 'Completed',
                          color: const Color(0xFF4CAF50),
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          icon: Icons.scale,
                          value: '${totalWeight.toStringAsFixed(0)} kg',
                          label: 'Total Weight',
                          color: const Color(0xFF9B5DE0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // List Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pickups',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4E56C0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tasks.length} tasks',
                                style: const TextStyle(
                                  color: Color(0xFF4E56C0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tasks List
                      Expanded(
                        child: isLoading
                            ? _buildLoadingState()
                            : hasError
                            ? _buildErrorState()
                            : tasks.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  20,
                                ),
                                itemCount: tasks.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final task = tasks[index];
                                  return _buildTaskCard(task);
                                },
                              ),
                      ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
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
          onTap: () {
            // Handle task tap
            _showTaskDetails(task);
          },
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
                        color: getStatusColor(task['pickup_status_id']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getStatusText(task['pickup_status_id']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: getPriorityColor(
                          task['priority_level_id'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: getPriorityColor(task['priority_level_id']),
                        ),
                      ),
                      child: Text(
                        task['priority_level_name'] ?? 'Standard',
                        style: TextStyle(
                          color: getPriorityColor(task['priority_level_id']),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Company and Branch Info
                Text(
                  task['company_name'] ?? 'Unknown Company',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task['branch_name'] ?? 'Unknown Branch',
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
              ],
            ),
          ),
        ),
      ),
    );
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
                      color: const Color(0xFF4E56C0).withOpacity(0.1),
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
                        Color(0xFF4E56C0),
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
            'Loading your pickups...',
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
                backgroundColor: const Color(0xFF4E56C0),
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
                    const Color(0xFF4E56C0).withOpacity(0.1),
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
                color: const Color(0xFF4E56C0).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Tasks Today!',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
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
                      // Task details content...
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
