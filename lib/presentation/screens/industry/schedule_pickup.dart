//  — search // <name> button|card|drawer item|dashboard card
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:aneuso_app/core/utils/location_util.dart';
import 'package:aneuso_app/core/utils/form_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/presentation/providers/driver_ratings_provider.dart';
import 'package:aneuso_app/presentation/screens/industry/industry_pickup_detail_screen.dart';
import 'package:aneuso_app/presentation/widgets/ratings/rate_driver_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final String _kScreenTitle = ScreenTitle.fromFile('schedule_pickup.dart');

class SchedulePickup extends StatefulWidget {
  const SchedulePickup({super.key});

  @override
  State<SchedulePickup> createState() => _SchedulePickupState();
}

class _SchedulePickupState extends State<SchedulePickup> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = AppConstants.baseUrl;
  int userId = 0;

  List<dynamic> pickups = [];
  bool isLoading = true;
  bool isSubmitting = false;
  String _statusFilter = 'All'; // 'All', 'Pending', 'Completed'

  // Form controllers
  final TextEditingController scheduledDateController = TextEditingController();
  final TextEditingController estimatedWeightController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController locationAddressController =
      TextEditingController();

  // Form values
  String selectedTimeSlot = '09:00-12:00';
  int selectedWasteType = 1;
  int selectedPriority = 1;
  double latitude = 0;
  double longitude = 0;
  bool _isLocatingPickup = false;

  int? selectedBranch;
  int? selectedCompany;
  int? selectedDriverId; // null = auto-assign
  List<dynamic> _availableDrivers = [];
  List<dynamic> _companies = [];
  List<dynamic> _branches = [];
  bool _companiesLoading = false;
  bool _isLoading = false;
  String? _companiesError;
  String? _errorMessage;

  Map<int, String> get _filteredBranchesMap {
    if (selectedCompany == null) return {};
    final map = <int, String>{};
    for (final branch in _branches) {
      if (branch is! Map) continue;
      final companyId = branch['company_id'];
      if (companyId == selectedCompany) {
        map[branch['id'] as int] = branch['branch_name'] as String;
      }
    }
    return map;
  }

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

  Future<void> _fetchCompaniesForDropdown() async {
    if (_companiesLoading) return;

    setState(() {
      _companiesLoading = true;
      _companiesError = null;
    });

    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/branches/companies/list'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final data = List<dynamic>.from(jsonData['data'] ?? []);
          final uniqueCompanies = <Map<String, dynamic>>[];
          final seenIds = <int>{};
          for (final item in data) {
            if (item is! Map) continue;
            final id = item['id'] as int;
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              uniqueCompanies.add(Map<String, dynamic>.from(item));
            }
          }
          if (mounted) {
            setState(() => _companies = uniqueCompanies);
          }
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to load companies');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _companiesError = 'Failed to load companies: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _companiesLoading = false);
      }
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

          _branches = uniqueBranches;

          debugPrint('Loaded ${_branches.length} branches for dropdown');
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

  // Add a variable to track the current tab
  int _currentTab = 0; // 0 = Pickups, 1 = Schedule

  @override
  void initState() {
    super.initState();
    userId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch pickups immediately (by user_id — no company dependency)
      fetchPickups();
      _fetchCompaniesForDropdown();
      _fetchAllBranchesForDropdown();
      _fetchAvailableDrivers();
    });
  }

  Future<void> _fetchAvailableDrivers() async {
    try {
      final token = StorageUtil.getToken();
      final date = scheduledDateController.text.isNotEmpty
          ? scheduledDateController.text
          : DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/industry/available-drivers?date=$date'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _availableDrivers = List<dynamic>.from(data['data'] ?? []);
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load drivers: $e');
    }
  }

  Future<void> fetchPickups() async {
    if (userId <= 0) return; // guard: userId must be known
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      final response = await http.get(
        Uri.parse('$baseUrl/industry/pickups/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pickups = List<dynamic>.from(data['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Failed to load pickups: $e');
    }
  }

  Future<void> _resolveBranchCoordinates(int? branchId) async {
    if (branchId == null) return;
    final branch = _branches.cast<Map<String, dynamic>?>().firstWhere(
          (b) => b?['id'] == branchId,
          orElse: () => null,
        );
    if (branch == null) return;

    final address = (branch['branch_address'] ?? '').toString().trim();
    if (locationAddressController.text.trim().isEmpty && address.isNotEmpty) {
      locationAddressController.text = address;
    }

    if (address.isEmpty) return;

    setState(() => _isLocatingPickup = true);
    final result = await LocationUtil.geocodeAddress(address);
    if (!mounted) return;
    setState(() {
      _isLocatingPickup = false;
      if (result != null) {
        latitude = result.lat;
        longitude = result.lng;
        if (locationAddressController.text.trim().isEmpty &&
            result.label != null) {
          locationAddressController.text = result.label!;
        }
      }
    });
  }

  Future<void> _getPickupGpsLocation() async {
    setState(() => _isLocatingPickup = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Enable GPS on this device.');
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied.');
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      final err = LocationUtil.validationError(pos.latitude, pos.longitude);
      if (err != null) throw Exception(err);
      final label = await LocationUtil.reverseGeocode(pos.latitude, pos.longitude);
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
        if (label != null) locationAddressController.text = label;
      });
    } catch (e) {
      showSnackBar('GPS: $e');
    } finally {
      if (mounted) setState(() => _isLocatingPickup = false);
    }
  }

  Future<void> schedulePickup() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCompany == null) {
      showSnackBar('Please select a company');
      return;
    }
    if (selectedBranch == null) {
      showSnackBar('Please select a branch');
      return;
    }

    if (!LocationUtil.isValidCoordinate(latitude, longitude)) {
      await _resolveBranchCoordinates(selectedBranch);
    }
    final locError = LocationUtil.validationError(latitude, longitude);
    if (locError != null) {
      showSnackBar('$locError Use "Use GPS at site" or check branch address.');
      return;
    }

    final weight = double.parse(estimatedWeightController.text.trim());

    setState(() => isSubmitting = true);

    final requestBody = {
      'company_id': selectedCompany,
      'branch_id': selectedBranch,
      'scheduled_date': scheduledDateController.text,
      'time_slot': selectedTimeSlot,
      'estimated_weight_kg': weight, // Using the parsed weight value
      'waste_type_id': selectedWasteType,
      'priority_level_id': selectedPriority,
      'notes': notesController.text.isEmpty ? null : notesController.text,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'location_address': locationAddressController.text,
      if (selectedDriverId != null) 'driver_id': selectedDriverId,
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

      debugPrint('Schedule pickup response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        showSnackBar(data['message'] ?? 'Pickup scheduled successfully');
        resetForm();
        fetchPickups();
        // Switch to pickups tab after successful submission
        setState(() => _currentTab = 0);
      } else {
        final errorData = jsonDecode(response.body);
        final msg = errorData['message'] ?? errorData['errors']?.toString() ?? 'Failed to schedule pickup';
        showSnackBar('Error: $msg (HTTP ${response.statusCode})');
      }
    } catch (e) {
      showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void resetForm() {
    scheduledDateController.clear();
    estimatedWeightController.clear();
    notesController.clear();
    locationAddressController.clear();
    setState(() {
      selectedTimeSlot = '09:00-12:00';
      selectedWasteType = 1;
      // selectedBranch = value;
      selectedPriority = 1;
      selectedCompany = null;
      selectedBranch = null;
      selectedDriverId = null;
      latitude = 0;
      longitude = 0;
      _isLocatingPickup = false;
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6F38C5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
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
                  colors: [const Color(0xFF6F38C5), const Color(0xFF9B5DE0)],
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
                            _kScreenTitle,
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule Waste Pickups',
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
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20),
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
                  color: const Color(0xFF6F38C5),
                ),
              ],
            ),
          ),
          
          // Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', isMobile),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', isMobile),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', isMobile),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6F38C5)),
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
                    itemCount: _getFilteredPickups().length,
                    itemBuilder: (context, index) {
                      final pickup = _getFilteredPickups()[index];
                      return _buildPickupCard(pickup, isMobile: isMobile);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    if (_companiesLoading) {
      return _buildFormField(
        label: 'Company',
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
                'Loading companies...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_companiesError != null) {
      return _buildFormField(
        label: 'Company',
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
                      'Failed to load companies',
                      style: TextStyle(color: Colors.red[600], fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchCompaniesForDropdown,
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

    if (_companies.isEmpty) {
      return _buildFormField(
        label: 'Company',
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
                'No companies available',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return _buildFormField(
      label: 'Company',
      child: DropdownButtonFormField<int>(
        value: selectedCompany,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          hintText: 'Select Company',
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
              'Select Company',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          ..._companies.map((company) {
            final id = company['id'] as int;
            final name = company['company_name']?.toString() ?? 'Company #$id';
            return DropdownMenuItem<int>(
              value: id,
              child: Text(name, style: const TextStyle(fontSize: 16)),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            selectedCompany = value;
            selectedBranch = null;
          });
        },
        validator: (value) => FormValidators.dropdown(value, field: 'a company'),
        icon: const Icon(Icons.arrow_drop_down),
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
        style: const TextStyle(color: Colors.black, fontSize: 16),
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

    // Company must be selected first
    if (selectedCompany == null) {
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
              Icon(Icons.business_outlined, color: Colors.grey[500], size: 20),
              const SizedBox(width: 12),
              Text(
                'Select a company first',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final branchOptions = _filteredBranchesMap;

    // Empty state for selected company
    if (branchOptions.isEmpty) {
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
              Expanded(
                child: Text(
                  'No branches for this company',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
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
        value: branchOptions.containsKey(selectedBranch) ? selectedBranch : null,
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
          ...branchOptions.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(entry.value, style: const TextStyle(fontSize: 16)),
            );
          }),
        ],
        onChanged: (value) {
          setState(() => selectedBranch = value);
          _resolveBranchCoordinates(value);
          debugPrint('Selected branch ID: $value');
        },
        validator: (value) => FormValidators.dropdown(value, field: 'a branch'),
        icon: const Icon(Icons.arrow_drop_down),
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Widget _buildDriverDropdown() {
    return _buildFormField(
      label: 'Driver (optional)',
      child: DropdownButtonFormField<int?>(
        value: selectedDriverId,
        decoration: InputDecoration(
          hintText: 'Auto-assign best available driver',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Auto-assign driver'),
          ),
          ..._availableDrivers.map((d) {
            final id = d['id'] is int ? d['id'] as int : int.parse('${d['id']}');
            final name = d['full_name'] ?? 'Driver #$id';
            final plate = d['vehicle_plate_number'] ?? '';
            return DropdownMenuItem<int?>(
              value: id,
              child: Text('$name${plate.isNotEmpty ? ' ($plate)' : ''}'),
            );
          }),
        ],
        onChanged: (value) => setState(() => selectedDriverId = value),
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
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
                    color: const Color(0xFF6F38C5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: Color(0xFF6F38C5),
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
              child: Form(
                key: _formKey,
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
                  _buildCompanyDropdown(),
                  const SizedBox(height: 16),
                  _buildBranchDropdown(),
                  const SizedBox(height: 16),
                  _buildDriverDropdown(),
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
                      validator: (v) =>
                          FormValidators.required(v, field: 'Scheduled date'),
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: 'Enter weight in kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: FormValidators.weightKg,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Address
                  _buildFormField(
                    label: 'Location Address',
                    child: TextFormField(
                      controller: locationAddressController,
                      decoration: InputDecoration(
                        hintText: 'Enter pickup location (e.g. Street, City)',
                        suffixIcon: _isLocatingPickup
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location_rounded),
                                tooltip: 'Use GPS at pickup site',
                                onPressed: _getPickupGpsLocation,
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (v) =>
                          FormValidators.address(v, requireComma: true),
                    ),
                  ),
                  if (LocationUtil.isValidCoordinate(latitude, longitude))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Pickup pin: ${LocationUtil.formatCoords(latitude, longitude)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Select a branch or tap GPS to set pickup coordinates.',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
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
                    // Schedule Pickup button
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : schedulePickup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F38C5),
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
                    ), // end Schedule Pickup button
                  ),

                  const SizedBox(height: 16),

                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    // Reset Form button
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
                    ), // end Reset Form button
                  ),

                  // Extra space for mobile keyboard
                  if (isMobile) const SizedBox(height: 40),
                ],
              ),
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
          color: _currentTab == index ? const Color(0xFF6F38C5) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: _currentTab == index
                  ? const Color(0xFF6F38C5)
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

  String _getStatusLabel(dynamic statusId) {
    final id = statusId is int ? statusId : int.tryParse(statusId?.toString() ?? '') ?? 1;
    return PickupStatus.label(id);
  }

  Color _getStatusColor(dynamic statusId) {
    final id = statusId is int ? statusId : int.tryParse(statusId?.toString() ?? '') ?? 1;
    switch (id) {
      case PickupStatus.scheduled:
        return const Color(0xFF9B5DE0);
      case PickupStatus.enRoute:
        return const Color(0xFF3A86FF);
      case PickupStatus.reachedDestination:
        return const Color(0xFF00B4D8);
      case PickupStatus.completed:
        return const Color(0xFF06D6A0);
      case PickupStatus.cancelled:
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFF9B5DE0);
    }
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
            color: Colors.black.withOpacity(0.2),
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
                    _getStatusLabel(pickup['pickup_status_id']),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // const SizedBox(width: 8),
              // Flexible(
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 8,
              //       vertical: 4,
              //     ),
              //     decoration: BoxDecoration(
              //       color: _getPriorityColor(pickup['priority_level_id']),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Text(
              //       pickup['priority_name'] ?? 'Medium',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: isMobile ? 10 : 12,
              //         fontWeight: FontWeight.bold,
              //       ),
              //       overflow: TextOverflow.ellipsis,
              //     ),
              //   ),
              // ),
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
                const Color(0xFFD78FEE),
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
          const SizedBox(height: 12),
          Row(
            children: [
              // Details button
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IndustryPickupDetailScreen(
                        pickup: Map<String, dynamic>.from(pickup),
                      ),
                    ),
                  );
                  await fetchPickups();
                },
                child: const Text('Details'),
              ), // end Details button
              // Live Track button — shown when driver is assigned and pickup is active
              if (pickup['driver_id'] != null &&
                  pickup['driver_id'] != 0 &&
                  PickupStatus.canLiveTrack(
                    pickup['pickup_status_id'] is int
                        ? pickup['pickup_status_id'] as int
                        : int.tryParse('${pickup['pickup_status_id']}'),
                  )) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    final pickupId = pickup['id'] is int
                        ? pickup['id'] as int
                        : int.tryParse(pickup['id']?.toString() ?? '') ?? 0;
                    Navigator.pushNamed(
                      context,
                      '/live-tracking',
                      arguments: {
                        'task_id': pickupId,
                        'task_type': 'industry_pickup',
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9B5DE0).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Live Track',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_canRatePickup(pickup)) ...[
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _openRateFromSchedule(pickup),
                  icon: const Icon(Icons.star_rate_rounded, size: 18),
                  label: const Text('Rate driver'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDeep,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _canRatePickup(dynamic p) {
    if (p is! Map) return false;
    final m = Map<String, dynamic>.from(p);
    final sid = m['pickup_status_id'];
    final status = sid is int ? sid : int.tryParse('$sid');
    final did = m['driver_id'];
    final driverId = did is int ? did : int.tryParse('$did');
    final rated = m['driver_rating_id'] != null;
    return status == PickupStatus.completed &&
        driverId != null &&
        driverId > 0 &&
        !rated;
  }

  Future<void> _openRateFromSchedule(dynamic p) async {
    final pickup = Map<String, dynamic>.from(p);
    final id = pickup['id'];
    final pickupId = id is int ? id : int.tryParse('$id');
    if (pickupId == null) return;
    final driverName = (pickup['driver_name'] ?? 'Driver').toString();
    final branch = (pickup['branch_name'] ?? '').toString();
    final rawDate = pickup['scheduled_date']?.toString();
    final date = rawDate != null ? DateTime.tryParse(rawDate) : null;
    final dateLabel =
        date != null ? DateFormat('MMM d, yyyy').format(date) : '—';
    final slot = (pickup['time_slot'] ?? '').toString();
    final summary = '$branch · $dateLabel · $slot';

    await RateDriverSheet.show(
      context,
      driverName: driverName,
      pickupSummary: summary,
      onSubmit: (rating, comment) async {
        final res =
            await context.read<DriverRatingsProvider>().submitIndustryRating(
                  pickupId: pickupId,
                  rating: rating,
                  reviewComment: comment,
                );
        return res['success'] == true;
      },
    );
    if (mounted) await fetchPickups();
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

  Widget _buildFilterChip(String label, bool isMobile) {
    bool isSelected = _statusFilter == label;
    // ChoiceChip button
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _statusFilter = label;
          });
        }
      },
      selectedColor: const Color(0xFF6F38C5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: isMobile ? 12 : 14,
      ),
      backgroundColor: Colors.grey[100],
      elevation: isSelected ? 2 : 0,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
    ); // end ChoiceChip button
  }

  List<dynamic> _getFilteredPickups() {
    if (_statusFilter == 'All') return pickups;
    if (_statusFilter == 'Pending') {
      return pickups.where((p) => p['pickup_status_id'] == 1).toList();
    }
    if (_statusFilter == 'Completed') {
      return pickups.where((p) => p['pickup_status_id'] == 3).toList();
    }
    return pickups;
  }
}
