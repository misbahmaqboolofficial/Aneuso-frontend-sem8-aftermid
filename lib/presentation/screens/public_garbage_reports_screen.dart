import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ==================== MODEL ====================
class GarbageReport {
  final int id;
  final int reportedByUserId;
  final String photoUrl;
  final String latitude;
  final String longitude;
  final String address;
  final String description;
  final String estimatedVolume;
  final int reportStatusId;
  final String fundingGoal;
  final String fundsCollected;
  final String? socialMediaPostIds;
  final String? cleanupScheduledDate;
  final String? cleanupCompletedDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String reportedByName;
  final String reportedByEmail;
  final String reportStatusName;

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
  });

  factory GarbageReport.fromJson(Map<String, dynamic> json) {
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
    );
  }
}

// ==================== API SERVICE ====================
class ApiService {
  static String apiBaseUrl = AppConstants.baseUrl;
  
  static void setBaseUrl(String url) {
    apiBaseUrl = url;
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
                  title: const Text(
                    'Garbage Reports',
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
                          const Color(0xFF4E56C0),
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
                          color: const Color(0xFF4E56C0).withOpacity(0.6),
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
                        ElevatedButton(
                          onPressed: _refreshReports,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4E56C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
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

  Widget _buildReportCard(GarbageReport report) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GarbageReportDetailsScreen(report: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E56C0).withOpacity(0.1),
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
                  report.photoUrl.isNotEmpty
                      ? Image.network(
                          report.photoUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: const Color(0xFFFDCFFA),
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          color: const Color(0xFFFDCFFA),
                          child: const Center(
                            child: Icon(Icons.photo_camera, size: 50, color: Colors.grey),
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
                                    color: Color(0xFF4E56C0),
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
                            colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
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
                                color: Color(0xFF4E56C0),
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
class GarbageReportDetailsScreen extends StatelessWidget {
  final GarbageReport report;

  const GarbageReportDetailsScreen({super.key, required this.report});

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
                  report.photoUrl.isNotEmpty
                      ? Image.network(
                          report.photoUrl,
                          fit: BoxFit.cover,
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
                          report.address,
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
                child: const Icon(Icons.arrow_back, color: Color(0xFF4E56C0)),
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
                    content: report.reportedByName,
                    subtitle: report.reportedByEmail,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    title: 'Description',
                    content: report.description,
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.attach_money,
                          title: 'Funding Goal',
                          value: 'Rs.${double.parse(report.fundingGoal).toStringAsFixed(0)}',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
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
                          value: '${report.estimatedVolume} kg',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: '${report.address}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Date Info
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Reported Date',
                    value: _formatFullDate(report.createdAt),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
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
                    color: Color(0xFF4E56C0),
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
            color: const Color(0xFF4E56C0).withOpacity(0.2),
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
                    color: Color(0xFF4E56C0),
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