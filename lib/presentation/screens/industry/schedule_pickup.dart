import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../presentation/providers/branch_provider.dart';

class SchedulePickup extends StatefulWidget {
  const SchedulePickup({super.key});

  @override
  State<SchedulePickup> createState() => _SchedulePickupState();
}

class _SchedulePickupState extends State<SchedulePickup> {
  final String baseUrl = AppConstants.baseUrl;
  int companyId = 1;
  int userId = 0;

  List<dynamic> pickups = [];
  bool isLoading = true;
  bool isSubmitting = false;

  // Form controllers
  final TextEditingController scheduledDateController = TextEditingController();
  final TextEditingController estimatedWeightController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController locationAddressController =
      TextEditingController();

  // Form values
  String selectedTimeSlot = '09:00-12:00';
  int selectedWasteType = 2;
  int selectedPriority = 1;
  double latitude = 0;
  double longitude = 0;

  int? selectedBranch;
  Map<int, String> _branchesMap = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  Future<void> _fetchAllBranchesForDropdown() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/branches?page=1&limit=1000'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];

          // Remove duplicates by ID
          final uniqueBranches = <Map<String, dynamic>>[];
          final seenIds = <int>{};

          for (final item in data) {
            final id = item['id'] as int;
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              uniqueBranches.add(item);
            }
          }

          // Create map for dropdown
          _branchesMap = {
            for (var branch in uniqueBranches)
              branch['id'] as int: branch['branch_name'] as String,
          };

          debugPrint('Loaded ${_branchesMap.length} branches for dropdown');
        } else {
          throw Exception('API Error: ${jsonData['message']}');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } on http.ClientException catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.message}';
      });
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = 'Data format error: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load branches: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final List<String> timeSlots = [
    '09:00-12:00',
    '12:00-15:00',
    '15:00-18:00',
    '18:00-21:00',
  ];

  final Map<int, String> wasteTypes = {
    1: 'Plastic Waste',
    2: 'Paper Waste',
    3: 'Metal Waste',
    4: 'Organic Waste',
  };

  final Map<int, String> priorityLevels = {1: 'High', 2: 'Medium', 3: 'Low'};

  late Map<int, String> branches;

  // Add a variable to track the current tab
  int _currentTab = 0; // 0 = Pickups, 1 = Schedule

  @override
  void initState() {
    super.initState();
    fetchPickups();

    userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllBranchesForDropdown();
    });
  }

  Future<void> fetchPickups() async {
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(
        Uri.parse('$baseUrl/industry/pickups/company/$companyId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pickups = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      showSnackBar('Failed to load pickups');
    }
  }

  Future<void> schedulePickup() async {
    if (scheduledDateController.text.isEmpty ||
        estimatedWeightController.text.isEmpty ||
        locationAddressController.text.isEmpty) {
      showSnackBar('Please fill all required fields');
      return;
    }

    setState(() => isSubmitting = true);

    final requestBody = {
      'company_id': companyId,
      'branch_id': selectedBranch,
      'scheduled_date': scheduledDateController.text,
      'time_slot': selectedTimeSlot,
      'estimated_weight_kg': int.parse(estimatedWeightController.text),
      'waste_type_id': selectedWasteType,
      'priority_level_id': selectedPriority,
      'notes': notesController.text,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'location_address': locationAddressController.text,
    };

    try {
      final token = StorageUtil.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/industry/pickups'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        showSnackBar(data['message'] ?? 'Pickup scheduled successfully');
        resetForm();
        fetchPickups();
        // Switch to pickups tab after successful submission
        setState(() => _currentTab = 0);
      } else {
        showSnackBar('Failed to schedule pickup');
      }
    } catch (e) {
      showSnackBar('Error scheduling pickup');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void resetForm() {
    scheduledDateController.clear();
    estimatedWeightController.clear();
    notesController.clear();
    locationAddressController.clear();
    selectedTimeSlot = '09:00-12:00';
    selectedWasteType = 2;
    selectedPriority = 1;
    selectedBranch = 1;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4E56C0),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header - Responsive
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 12 : 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF4E56C0), const Color(0xFF9B5DE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMobile ? 20 : 30),
                  bottomRight: Radius.circular(isMobile ? 20 : 30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          Text(
                            'Pickup Manager',
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule & Manage Waste Pickups',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.recycling,
                          color: Colors.white,
                          size: isMobile ? 26 : 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats - Responsive layout
                  if (isMobile) ...[
                    // Mobile: Grid layout for stats
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                      children: [
                        _buildStatCard(
                          'Total Pickups',
                          pickups.length.toString(),
                          Icons.list_alt,
                          const Color(0xFFFDCFFA),
                          isMobile: isMobile,
                        ),
                        _buildStatCard(
                          'Pending',
                          pickups
                              .where((p) => p['pickup_status_id'] == 1)
                              .length
                              .toString(),
                          Icons.pending_actions,
                          const Color(0xFFD78FEE),
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildStatCard(
                      'Weight (kg)',
                      pickups
                          .fold(
                            0.0,
                            (sum, p) =>
                                sum +
                                (double.tryParse(
                                      p['estimated_weight_kg'] ?? '0',
                                    ) ??
                                    0),
                          )
                          .toStringAsFixed(0),
                      Icons.scale,
                      const Color(0xFF9B5DE0),
                      isMobile: isMobile,
                    ),
                  ] else ...[
                    // Web: Row layout for stats
                    Row(
                      children: [
                        _buildStatCard(
                          'Total Pickups',
                          pickups.length.toString(),
                          Icons.list_alt,
                          const Color(0xFFFDCFFA),
                          isMobile: isMobile,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          'Pending',
                          pickups
                              .where((p) => p['pickup_status_id'] == 1)
                              .length
                              .toString(),
                          Icons.pending_actions,
                          const Color(0xFFD78FEE),
                          isMobile: isMobile,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          'Weight (kg)',
                          pickups
                              .fold(
                                0.0,
                                (sum, p) =>
                                    sum +
                                    (double.tryParse(
                                          p['estimated_weight_kg'] ?? '0',
                                        ) ??
                                        0),
                              )
                              .toStringAsFixed(0),
                          Icons.scale,
                          const Color(0xFF9B5DE0),
                          isMobile: isMobile,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Tab Bar for Mobile
            if (isMobile) ...[
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        index: 0,
                        icon: Icons.list_alt,
                        label: 'Pickups',
                        isMobile: isMobile,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        index: 1,
                        icon: Icons.add_circle_outline,
                        label: 'Schedule',
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Body - Responsive layout
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: isMobile ? _buildMobileContent() : _buildWebContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContent() {
    return IndexedStack(
      index: _currentTab,
      children: [
        // Tab 0: Pickup List
        _buildPickupList(isMobile: true),

        // Tab 1: Schedule Form
        _buildScheduleForm(isMobile: true),
      ],
    );
  }

  Widget _buildWebContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Pickup List
        Expanded(flex: 2, child: _buildPickupList(isMobile: false)),

        const SizedBox(width: 20),

        // Right: Schedule Form
        Expanded(flex: 1, child: _buildScheduleForm(isMobile: false)),
      ],
    );
  }

  Widget _buildPickupList({required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 10 : 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scheduled Pickups',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                IconButton(
                  onPressed: fetchPickups,
                  icon: const Icon(Icons.refresh),
                  color: const Color(0xFF4E56C0),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF4E56C0)),
                    ),
                  )
                : pickups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: isMobile ? 60 : 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No pickups scheduled',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: isMobile ? 80 : 20,
                      left: isMobile ? 8 : 0,
                      right: isMobile ? 8 : 0,
                    ),
                    itemCount: pickups.length,
                    itemBuilder: (context, index) {
                      final pickup = pickups[index];
                      return _buildPickupCard(pickup, isMobile: isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchDropdown() {
    // Loading state
    if (_isLoading) {
      return _buildFormField(
        label: 'Branch',
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading branches...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_errorMessage != null) {
      return _buildFormField(
        label: 'Branch',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed to load',
                      style: TextStyle(color: Colors.red[600], fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchAllBranchesForDropdown,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_branchesMap.isEmpty) {
      return _buildFormField(
        label: 'Branch',
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
              const SizedBox(width: 12),
              Text(
                'No branches available',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Success state with dropdown
    return _buildFormField(
      label: 'Branch',
      child: DropdownButtonFormField<int>(
        value: selectedBranch,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          hintText: 'Select Branch',
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: [
          DropdownMenuItem<int>(
            value: null,
            child: Text(
              'Select Branch',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          ..._branchesMap.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(entry.value, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        ],
        onChanged: (value) {
          setState(() {
            selectedBranch = value;
          });
          debugPrint('Selected branch ID: $value');
        },
        icon: const Icon(Icons.arrow_drop_down),
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Widget _buildScheduleForm({required bool isMobile}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 10 : 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4E56C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF4E56C0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Schedule New Pickup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ] else ...[
            const SizedBox(height: 10),
          ],

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Branch Selection
                  // _buildFormField(
                  //   label: 'Branch',
                  //   child: DropdownButtonFormField<int>(
                  //     initialValue: selectedBranch,
                  //     decoration: InputDecoration(
                  //       hintText: 'Select Branch',
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //         borderSide: BorderSide.none,
                  //       ),
                  //       filled: true,
                  //       fillColor: Colors.grey[50],
                  //     ),
                  //     items: branches.entries
                  //         .map(
                  //           (entry) => DropdownMenuItem(
                  //             value: entry.key,
                  //             child: Text(entry.value),
                  //           ),
                  //         )
                  //         .toList(),
                  //     onChanged: (value) {
                  //       setState(() => selectedBranch = value!);
                  //     },
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  // ),
                  _buildBranchDropdown(),
                  const SizedBox(height: 16),

                  // Date Picker
                  _buildFormField(
                    label: 'Scheduled Date',
                    child: TextFormField(
                      controller: scheduledDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          scheduledDateController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(date);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Time Slot
                  _buildFormField(
                    label: 'Time Slot',
                    child: DropdownButtonFormField<String>(
                      value: selectedTimeSlot,
                      decoration: InputDecoration(
                        hintText: 'Select Time Slot',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: timeSlots
                          .map(
                            (slot) => DropdownMenuItem(
                              value: slot,
                              child: Text(slot),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedTimeSlot = value!);
                      },
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Waste Type
                  _buildFormField(
                    label: 'Waste Type',
                    child: DropdownButtonFormField<int>(
                      value: selectedWasteType,
                      decoration: InputDecoration(
                        hintText: 'Select Waste Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: wasteTypes.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedWasteType = value!);
                      },
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Priority
                  _buildFormField(
                    label: 'Priority Level',
                    child: DropdownButtonFormField<int>(
                      value: selectedPriority,
                      decoration: InputDecoration(
                        hintText: 'Select Priority',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: priorityLevels.entries
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedPriority = value!);
                      },
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Estimated Weight
                  _buildFormField(
                    label: 'Estimated Weight (kg)',
                    child: TextFormField(
                      controller: estimatedWeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter weight in kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Address
                  _buildFormField(
                    label: 'Location Address',
                    child: TextFormField(
                      controller: locationAddressController,
                      decoration: InputDecoration(
                        hintText: 'Enter pickup location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  _buildFormField(
                    label: 'Notes',
                    child: TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : schedulePickup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E56C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.schedule, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Schedule Pickup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: resetForm,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD78FEE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: const Color(0xFF9B5DE0),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 10),
                          Text(
                            'Reset Form',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Extra space for mobile keyboard
                  if (isMobile) const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: _currentTab == index ? const Color(0xFF4E56C0) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: _currentTab == index
                  ? const Color(0xFF4E56C0)
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: _currentTab == index ? Colors.white : Colors.grey,
              size: isMobile ? 22 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: _currentTab == index ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: isMobile ? 18 : 20),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(
    Map<String, dynamic> pickup, {
    required bool isMobile,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 20,
        vertical: isMobile ? 6 : 8,
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: isMobile ? 6 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pickup['pickup_status_id']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pickup['status_name'] ?? 'Scheduled',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(pickup['priority_level_id']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pickup['priority_name'] ?? 'Medium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pickup['branch_name'] ?? 'N/A',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: isMobile ? 14 : 16,
                    color: const Color(0xFF9B5DE0),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(
                        DateTime.parse(pickup['scheduled_date']).toLocal(),
                      ),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: isMobile ? 14 : 16,
                    color: const Color(0xFF9B5DE0),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pickup['time_slot'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                Icons.scale,
                '${pickup['estimated_weight_kg'] ?? '0'} kg',
                const Color(0xFFFDCFFA),
                isMobile: isMobile,
              ),
              _buildInfoChip(
                Icons.category,
                pickup['waste_type'] ?? 'N/A',
                const Color(0xFFD78FEE),
                isMobile: isMobile,
              ),
            ],
          ),
          if (pickup['notes'] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Notes: ${pickup['notes']}',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF555555),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color color, {
    required bool isMobile,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return const Color(0xFF4E56C0); // industry/scheduled
      case 2:
        return const Color(0xFF4CAF50); // completed
      case 3:
        return const Color(0xFFFF9800); // in progress
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getPriorityColor(int priorityId) {
    switch (priorityId) {
      case 1:
        return const Color(0xFFFF5252); // high
      case 2:
        return const Color(0xFFFF9800); // medium
      case 3:
        return const Color(0xFF4CAF50); // low
      default:
        return const Color(0xFF9B5DE0);
    }
  }
}
