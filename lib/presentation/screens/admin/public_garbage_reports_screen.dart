//  — search // <name> button|card|drawer item|dashboard card
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/constants/pickup_status.dart';
import 'package:aneuso_app/presentation/screens/admin/MissionAssignmentScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aneuso_app/presentation/screens/admin/CleanupFinalizationScreen.dart';
import 'package:aneuso_app/presentation/screens/admin/GarbageMissionDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/utils/product_image_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('public_garbage_reports_screen.dart');

// ==================== MODEL ====================
class GarbageReport {
  int id;
  int reportedByUserId;
  String photoUrl;
  String latitude;
  String longitude;
  String address;
  String description;
  String estimatedVolume;
  int reportStatusId;
  String fundingGoal;
  String fundsCollected;
  final String? socialMediaPostIds;
  final String? cleanupScheduledDate;
  final String? cleanupCompletedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String reportedByName;
  final String reportedByEmail;
  final String reportStatusName;
  String? driverName;
  String? urgencyName;
  String? afterPhotoUrl;
  double? fuelExpense;
  double? laborExpense;
  double? otherExpense;
  String? otherExpenseDescription;
  int? driverId;
  int? urgencyLevelId;
  String? adminNotes;
  DateTime? driverMarkedCompleteAt;

  GarbageReport({
    required this.id,
    required this.reportedByUserId,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    required this.estimatedVolume,
    required this.reportStatusId,
    required this.fundingGoal,
    required this.fundsCollected,
    this.socialMediaPostIds,
    this.cleanupScheduledDate,
    this.cleanupCompletedDate,
    required this.createdAt,
    this.updatedAt,
    required this.reportedByName,
    required this.reportedByEmail,
    required this.reportStatusName,
    this.driverName,
    this.urgencyName,
    this.afterPhotoUrl,
    this.fuelExpense,
    this.laborExpense,
    this.otherExpense,
    this.otherExpenseDescription,
    this.driverId,
    this.urgencyLevelId,
    this.adminNotes,
    this.driverMarkedCompleteAt,
  });

  factory GarbageReport.fromJson(Map<String, dynamic> json) {
    int? parseDriverId(dynamic value) {
      if (value == null) return null;
      final id = value is int ? value : int.tryParse('$value');
      if (id == null || id <= 0) return null;
      return id;
    }

    return GarbageReport(
      id: json['id'],
      reportedByUserId: json['reported_by_user_id'],
      photoUrl: json['photo_url'] ?? '',
      latitude: json['latitude'] ?? '0',
      longitude: json['longitude'] ?? '0',
      address: json['address'] ?? 'No address provided',
      description: json['description'] ?? 'No description',
      estimatedVolume: json['estimated_volume']?.toString() ?? '0',
      reportStatusId: json['report_status_id'],
      fundingGoal: json['funding_goal']?.toString() ?? '0',
      fundsCollected: json['funds_collected']?.toString() ?? '0',
      socialMediaPostIds: json['social_media_post_ids'],
      cleanupScheduledDate: json['cleanup_scheduled_date'],
      cleanupCompletedDate: json['cleanup_completed_date'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      reportedByName: json['reported_by_name'] ?? 'Anonymous',
      reportedByEmail: json['reported_by_email'] ?? 'No email',
      reportStatusName: json['report_status_name'] ?? 'Unknown',
      driverName: json['driver_name'],
      urgencyName: json['urgency_name'],
      afterPhotoUrl: json['after_photo_url'],
      fuelExpense: json['fuel_expense'] != null ? double.tryParse(json['fuel_expense'].toString()) : null,
      laborExpense: json['labor_expense'] != null ? double.tryParse(json['labor_expense'].toString()) : null,
      otherExpense: json['other_expense'] != null ? double.tryParse(json['other_expense'].toString()) : null,
      otherExpenseDescription: json['other_expense_description'],
      driverId: parseDriverId(json['driver_id']),
      urgencyLevelId: json['urgency_level_id'],
      adminNotes: json['admin_notes'],
      driverMarkedCompleteAt: json['driver_marked_complete_at'] != null
          ? DateTime.tryParse(json['driver_marked_complete_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reported_by_user_id': reportedByUserId,
      'address': address,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'report_status_id': reportStatusId,
      'report_status_name': reportStatusName,
      'created_at': createdAt.toIso8601String(),
      'reported_by_name': reportedByName,
      'funding_goal': fundingGoal,
      'funds_collected': fundsCollected,
      'urgency_level_id': urgencyLevelId,
      'urgency_name': urgencyName,
      'driver_id': driverId,
      'driver_name': driverName,
      'estimated_volume': estimatedVolume,
      'admin_notes': adminNotes,
      'after_photo_url': afterPhotoUrl,
      'fuel_expense': fuelExpense,
      'labor_expense': laborExpense,
      'other_expense': otherExpense,
      'other_expense_description': otherExpenseDescription,
      'driver_marked_complete_at': driverMarkedCompleteAt?.toIso8601String(),
    };
  }
}

// ==================== API SERVICE ====================
class ApiService {
  static String apiBaseUrl = AppConstants.baseUrl;
  
  static void setBaseUrl(String url) {
    apiBaseUrl = url;
  }
  
  Future<GarbageReport> fetchReportById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/reports/public-garbage/$id?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GarbageReport.fromJson(data['data']);
      } else { throw Exception('Report not found'); }
    } catch (e) { throw Exception('Error: $e'); }
  }

  Future<List<GarbageReport>> fetchPublicGarbageReports({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/reports/public-garbage?page=$page'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> reportsData = data['data'];
          return reportsData.map((json) => GarbageReport.fromJson(json)).toList();
        } else {
          throw Exception('API returned success false');
        }
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  Future<bool> updateReportStatus(int reportId, int statusId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);
      
      final response = await http.put(
        Uri.parse('$apiBaseUrl/reports/public-garbage/$reportId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'report_status_id': statusId,
          'cleanup_completed_date': statusId == 174 ? DateTime.now().toIso8601String() : null,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  Future<String?> uploadPhoto(dynamic fileSource) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);
      
      var request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/upload/photo'));
      request.headers['Authorization'] = 'Bearer $token';
      
      if (kIsWeb) {
        // For web, fileSource should be XFile or bytes
        if (fileSource is XFile) {
          final bytes = await fileSource.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            bytes,
            filename: fileSource.name,
          ));
        }
      } else {
        // For mobile/desktop
        if (fileSource is File) {
          request.files.add(await http.MultipartFile.fromPath('photo', fileSource.path));
        } else if (fileSource is XFile) {
          request.files.add(await http.MultipartFile.fromPath('photo', fileSource.path));
        }
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<bool> finalizeReport({
    required int reportId,
    required double fuel,
    required double labor,
    required double other,
    required String description,
    String? beforePhoto,
    String? afterPhoto,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);
      
      final response = await http.put(
        Uri.parse('$apiBaseUrl/reports/cleanup/$reportId/finalize'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fuel_expense': fuel,
          'labor_expense': labor,
          'other_expense': other,
          'other_expense_description': description,
          'photo_url': beforePhoto,
          'after_photo_url': afterPhoto,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Finalize error: $e');
      return false;
    }
  }
}

// ==================== MAIN LIST SCREEN ====================
class PublicGarbageReportsScreen extends StatefulWidget {
  const PublicGarbageReportsScreen({super.key});

  @override
  State<PublicGarbageReportsScreen> createState() => _PublicGarbageReportsScreenState();
}

class _PublicGarbageReportsScreenState extends State<PublicGarbageReportsScreen> {
  List<GarbageReport> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  
  // Add a scroll controller to detect when to load more
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReports();
    }
  }

  Future<void> _loadMoreReports() async {
    if (_hasMore && !_isLoadingMore && !_isLoading) {
      await _fetchReports(loadMore: true);
    }
  }

  Future<void> _fetchReports({bool loadMore = false}) async {
    if (loadMore) {
      if (!_hasMore || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      List<GarbageReport> newReports = await ApiService().fetchPublicGarbageReports(page: _currentPage);
      
      setState(() {
        if (loadMore) {
          _reports.addAll(newReports);
        } else {
          _reports = newReports;
        }
        _hasMore = newReports.isNotEmpty;
        if (newReports.isNotEmpty) {
          _currentPage++;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _refreshReports() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _reports = [];
      _isLoading = true;
    });
    await _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshReports,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFDCFFA),
              ],
            ),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _kScreenTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6F38C5),
                          const Color(0xFF9B5DE0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Content
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B5DE0)),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: const Color(0xFF6F38C5).withOpacity(0.6),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // Retry button
                        ElevatedButton(
                          onPressed: _refreshReports,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6F38C5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('Retry'),
                        ), // end Retry button
                      ],
                    ),
                  ),
                )
              else if (_reports.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No garbage reports found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = _reports[index];
                        return _buildReportCard(report);
                      },
                      childCount: _reports.length,
                    ),
                  ),
                ),
              
              // Loading more indicator at the bottom
              if (_isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B5DE0)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCardImage(String photoUrl) {
    final imageUrl = resolveProductImageUrl(photoUrl);
    if (imageUrl == null) {
      return Container(
        height: 200,
        color: const Color(0xFFFDCFFA),
        child: const Center(
          child: Icon(Icons.photo_camera, size: 50, color: Colors.grey),
        ),
      );
    }
    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      headers: kProductImageHeaders,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: const Color(0xFFFDCFFA),
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildReportCard(GarbageReport report) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GarbageReportDetailsScreen(report: report),
          ),
        );
        _refreshReports();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6F38C5).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with gradient overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  _buildReportCardImage(report.photoUrl),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildStatusBadge(
                      report.reportStatusId,
                      report.reportStatusName,
                      driverMarkedCompleteAt: report.driverMarkedCompleteAt,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rs.${double.parse(report.fundingGoal).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6F38C5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.reportedByName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6F38C5),
                              ),
                            ),
                            Text(
                              report.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDCFFA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${report.estimatedVolume} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9B5DE0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(report.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Color(0xFF9B5DE0)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusName(int id, [String? fallbackName, DateTime? driverMarkedCompleteAt]) {
    return CleanupStatusUtil.adminDisplayLabel(
      reportStatusId: id,
      driverMarkedCompleteAt: driverMarkedCompleteAt,
      fallbackName: fallbackName,
    );
  }

  Widget _buildStatusBadge(
    int statusId,
    String statusName, {
    DateTime? driverMarkedCompleteAt,
  }) {
    final pending = CleanupStatusUtil.isDriverPendingAdminVerification(
      reportStatusId: statusId,
      driverMarkedCompleteAt: driverMarkedCompleteAt,
    );
    final verified = CleanupStatusUtil.isAdminVerifiedComplete(statusId);

    Color color;
    IconData icon;

    if (pending) {
      color = Colors.orange;
      icon = Icons.hourglass_top_rounded;
    } else if (verified || statusId == 204) {
      color = Colors.green;
      icon = Icons.check_circle_outline;
    } else if (statusId == 172) {
      color = Colors.blue;
      icon = Icons.volunteer_activism;
    } else {
      color = const Color(0xFF6F38C5);
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            _getStatusName(statusId, statusName, driverMarkedCompleteAt).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

// ==================== DETAILS SCREEN ====================
class GarbageReportDetailsScreen extends StatefulWidget {
  final GarbageReport report;

  const GarbageReportDetailsScreen({super.key, required this.report});

  @override
  State<GarbageReportDetailsScreen> createState() => _GarbageReportDetailsScreenState();
}

class _GarbageReportDetailsScreenState extends State<GarbageReportDetailsScreen> {
  late int _currentStatusId;

  @override
  void initState() {
    super.initState();
    _currentStatusId = widget.report.reportStatusId;
    _refreshReport();
  }

  Future<void> _refreshReport() async {
    try {
      final updated = await ApiService().fetchReportById(widget.report.id);
      if (mounted) {
        setState(() {
          _currentStatusId = updated.reportStatusId;
          widget.report.reportStatusId = updated.reportStatusId;
          widget.report.driverMarkedCompleteAt = updated.driverMarkedCompleteAt;
        });
      }
    } catch (e) { print(e); }
  }

  String _getStatusName(int id, [String? fallbackName]) {
    return CleanupStatusUtil.adminDisplayLabel(
      reportStatusId: id,
      driverMarkedCompleteAt: widget.report.driverMarkedCompleteAt,
      fallbackName: fallbackName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Hero Image Sliver
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.report.photoUrl.isNotEmpty
                      ? Image.network(
                          widget.report.photoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFDCFFA),
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFFDCFFA),
                          child: const Center(
                            child: Icon(Icons.photo_camera, size: 80, color: Colors.grey),
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          widget.report.address,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF6F38C5)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Details Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reporter Card
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: 'Reported By',
                    content: widget.report.reportedByName,
                    subtitle: widget.report.reportedByEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    title: 'Description',
                    content: widget.report.description,
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.attach_money,
                          title: 'Funding Goal',
                          value: 'Rs.${double.parse(widget.report.fundingGoal).toStringAsFixed(0)}',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Additional Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.calculate_outlined,
                          label: 'Estimated Volume',
                          value: '${widget.report.estimatedVolume} kg',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: '${widget.report.address}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Date Info
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Reported Date',
                    value: _formatFullDate(widget.report.createdAt),
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Status Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6F38C5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6F38C5).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF9B5DE0), size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Status',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _getStatusName(_currentStatusId),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6F38C5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mission Progress Button for Everyone
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GarbageMissionDetailsScreen(report: widget.report),
                          ),
                        );
                      },
                      icon: const Icon(Icons.timeline),
                      label: const Text('View Mission Progress & Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6F38C5),
                        side: const BorderSide(color: Color(0xFF6F38C5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  if (widget.report.driverId != null &&
                      ReportStatus.canLiveTrack(_currentStatusId)) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/live-tracking',
                            arguments: {
                              'task_id': widget.report.id,
                              'task_type': 'admin_cleanup',
                            },
                          );
                        },
                        icon: const Icon(Icons.location_on, color: Colors.white),
                        label: const Text('Track Cleanup / Driver Location', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B5DE0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Admin Action Section
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      if (auth.currentUser?.isAdmin == true && _currentStatusId != 204) {
                        return _buildAdminActions(context);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    // Determine if the report is already approved based on its status
    // Status 170 or 171 are typical for "New/Pending" reports
    bool isPending = _currentStatusId == 170 || _currentStatusId == 171;
    bool isApproved = !isPending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6F38C5).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6F38C5).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6F38C5),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MissionAssignmentScreen(
                      reportId: widget.report.id,
                      report: widget.report.toMap(),
                    ),
                  ),
                ).then((_) {
                  _refreshReport();
                });
              },
              icon: Icon(isApproved ? Icons.edit_note_rounded : Icons.check_circle_outline),
              label: Text(isApproved ? 'Update Mission' : 'Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproved ? const Color(0xFF9B5DE0) : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          if (_currentStatusId == 172) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markAsCollected(context),
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Mark as Collected — Dispatch Truck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final newStatusId = await showModalBottomSheet<int>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _UpdateStatusBottomSheet(report: widget.report, currentStatusId: _currentStatusId),
                );
                
                if (newStatusId != null) {
                  setState(() {
                    _currentStatusId = newStatusId;
                  });
                }
              },
              icon: const Icon(Icons.update),
              label: const Text('Update Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B5DE0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsCollected(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Collection'),
        content: const Text(
          'Mark this campaign as collected? Gulbahao will dispatch a cleanup truck to the location and citizens will be notified.',
        ),
        actions: [
          // Cancel button
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), // end Cancel button
          // Yes, Collected button
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Collected')), // end Yes, Collected button
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ApiService().updateReportStatus(widget.report.id, 204);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as Collected — cleanup truck will be dispatched!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status. Please try again.')),
        );
      }
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDCFFA).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6F38C5),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F38C5).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9B5DE0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6F38C5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ==================== UPDATE STATUS BOTTOM SHEET ====================
class _UpdateStatusBottomSheet extends StatefulWidget {
  final GarbageReport report;
  final int currentStatusId;

  const _UpdateStatusBottomSheet({required this.report, required this.currentStatusId});

  @override
  State<_UpdateStatusBottomSheet> createState() => _UpdateStatusBottomSheetState();
}

class _UpdateStatusBottomSheetState extends State<_UpdateStatusBottomSheet> {
  late int selectedStatus;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.currentStatusId;
  }

  Future<void> _submitStatus() async {
    setState(() => isLoading = true);
    final success = await ApiService().updateReportStatus(widget.report.id, selectedStatus);
    setState(() => isLoading = false);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
        Navigator.pop(context, selectedStatus);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status.')),
        );
      }
    }
  }

  Widget _buildStepTracker() {
    int currentStatus = selectedStatus;
    int currentStep = 0;
    if (currentStatus == 172) currentStep = 1;
    else if (currentStatus == 206) currentStep = 2;
    else if (currentStatus == 207) currentStep = 3;
    else if (currentStatus == 205) currentStep = 4;
    else if (currentStatus == 208 || currentStatus == 174) currentStep = 5;
    else if (currentStatus > 171) currentStep = 1;
    
    final steps = [
      {'label': 'Report Approved', 'id': 172},
      {'label': 'Driver Assigned', 'id': 206},
      {'label': 'Driver on the Way', 'id': 207},
      {'label': 'Cleaning Started', 'id': 205},
      {'label': 'Garbage Collected', 'id': 208},
    ];

    const themeColor = Color(0xFF9B5DE0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          int stepNum = index + 1;
          bool isCompleted = stepNum < currentStep;
          bool isActive = stepNum == currentStep;
          bool isHighlight = stepNum <= currentStep;
          bool isLast = index == steps.length - 1;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0 ? Colors.transparent : (isHighlight ? themeColor : Colors.grey[300]),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        int newId = steps[index]['id'] as int;
                        if (newId == 208 || newId == 174) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CleanupFinalizationScreen(report: widget.report),
                            ),
                          );
                          if (result == true) {
                            Navigator.pop(context, 174); // Return Area Cleaned status
                          }
                        } else {
                          setState(() {
                            selectedStatus = newId;
                          });
                        }
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted ? themeColor : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isHighlight ? themeColor : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: isActive ? [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)] : null,
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isActive ? themeColor : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: isLast ? Colors.transparent : (stepNum < currentStep ? themeColor : Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index]['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    color: isHighlight ? themeColor : Colors.grey[400],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Update Report Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F38C5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStepTracker(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            // UPDATE STATUS button
            child: ElevatedButton(
              onPressed: isLoading ? null : _submitStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B5DE0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF9B5DE0).withOpacity(0.4),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'UPDATE STATUS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ), // end UPDATE STATUS button
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}