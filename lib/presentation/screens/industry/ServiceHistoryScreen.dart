import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/theme/app_colors.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/presentation/providers/driver_ratings_provider.dart';
import 'package:aneuso_app/presentation/widgets/ratings/rate_driver_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('ServiceHistoryScreen.dart');

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final String apiBaseUrl = AppConstants.baseUrl; // You'll provide the URL here
  List<ServiceHistory> serviceHistoryList = [];
  Map<String, dynamic>? statistics;
  bool isLoading = true;
  String errorMessage = '';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchServiceHistory();
  }

  Future<void> fetchServiceHistory() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/industry/service-history-all'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            serviceHistoryList = (data['data'] as List)
                .map((item) => ServiceHistory.fromJson(item))
                .toList();
            statistics = data['statistics'];
            hasError = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to fetch service history';
            hasError = true;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  String formatWeight(String weight) {
    final weightNum = double.tryParse(weight) ?? 0;
    return weightNum >= 1000
        ? '${(weightNum / 1000).toStringAsFixed(1)} tons'
        : '${weightNum.toStringAsFixed(0)} kg';
  }

  Widget _buildStatisticsCard() {
    if (statistics == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F38C5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assessment, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Overall Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  Icons.local_shipping,
                  'Total Pickups',
                  statistics!['total_pickups'].toString(),
                ),
                _buildStatItem(
                  Icons.scale,
                  'Total Weight',
                  formatWeight(statistics!['total_weight']),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  Icons.calendar_today,
                  'First Pickup',
                  DateFormat(
                    'MMM dd',
                  ).format(DateTime.parse(statistics!['first_pickup'])),
                ),
                _buildStatItem(
                  Icons.calendar_today,
                  'Last Pickup',
                  DateFormat(
                    'MMM dd',
                  ).format(DateTime.parse(statistics!['last_pickup'])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistoryCard(ServiceHistory history, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
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
                    gradient: index % 2 == 0
                        ? const LinearGradient(
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFD78FEE), Color(0xFFFDCFFA)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.recycling,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        history.branchName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    history.wasteCategory.replaceAll(' Waste', ''),
                    style: const TextStyle(
                      color: Color(0xFF6F38C5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(
                  Icons.person,
                  history.driverName,
                  color: const Color(0xFF6F38C5),
                ),
                const SizedBox(width: 16),
                _buildDetailItem(
                  Icons.scale,
                  formatWeight(history.collectedWeightKg),
                  color: const Color(0xFF9B5DE0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildDetailItem(
                  Icons.access_time,
                  formatDate(history.confirmationTime),
                  color: const Color(0xFFD78FEE),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: history.verificationStatusId == 1
                        ? const Color(0xFFD4EDDA)
                        : const Color(0xFFF8D7DA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        history.verificationStatusId == 1
                            ? Icons.verified
                            : Icons.pending,
                        size: 12,
                        color: history.verificationStatusId == 1
                            ? const Color(0xFF155724)
                            : const Color(0xFF721C24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        history.verificationStatusId == 1
                            ? 'Verified'
                            : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: history.verificationStatusId == 1
                              ? const Color(0xFF155724)
                              : const Color(0xFF721C24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_canRateServiceHistory(history)) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _openRateServiceHistory(context, history),
                  icon: const Icon(Icons.star_rate_rounded, size: 18),
                  label: const Text('Rate driver'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDeep,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canRateServiceHistory(ServiceHistory history) {
    return history.pickupStatusId == 3 &&
        history.scheduleDriverId != null &&
        history.scheduleDriverId! > 0 &&
        history.driverRatingId == null &&
        history.pickupScheduleId != null;
  }

  Future<void> _openRateServiceHistory(
    BuildContext context,
    ServiceHistory history,
  ) async {
    final pid = history.pickupScheduleId;
    if (pid == null) return;
    final driverName = history.driverName;
    final summary =
        '${history.branchName} · ${formatDate(history.confirmationTime)}';

    await RateDriverSheet.show(
      context,
      driverName: driverName,
      pickupSummary: summary,
      onSubmit: (rating, comment) async {
        final res =
            await context.read<DriverRatingsProvider>().submitIndustryRating(
                  pickupId: pid,
                  rating: rating,
                  reviewComment: comment,
                );
        return res['success'] == true;
      },
    );
    if (context.mounted) fetchServiceHistory();
  }

  Widget _buildDetailItem(IconData icon, String text, {Color? color}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? const Color(0xFF6B7280)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Service History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fetching your pickup records...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDCFFA), Color(0xFFD78FEE)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchServiceHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F38C5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.history_toggle_off,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Service History Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your service history will appear here once you start scheduling pickups',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchServiceHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6F38C5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _kScreenTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFFFFF),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: fetchServiceHistory,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh,
                color: Color(0xFF6F38C5),
                size: 20,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: isLoading
          ? _buildLoadingScreen()
          : hasError
          ? _buildErrorScreen()
          : serviceHistoryList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: fetchServiceHistory,
              color: const Color(0xFF6F38C5),
              backgroundColor: Colors.white,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Service Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        _buildStatisticsCard(),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Recent Pickups (${serviceHistoryList.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildServiceHistoryCard(
                        serviceHistoryList[index],
                        index,
                      );
                    }, childCount: serviceHistoryList.length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            ),
    );
  }
}

class ServiceHistory {
  final int id;
  final String confirmationTime;
  final String collectedWeightKg;
  final int verificationStatusId;
  final String companyName;
  final String branchName;
  final String wasteCategory;
  final String driverName;
  final int? pickupScheduleId;
  final int? pickupStatusId;
  final int? scheduleDriverId;
  final int? driverRatingId;

  ServiceHistory({
    required this.id,
    required this.confirmationTime,
    required this.collectedWeightKg,
    required this.verificationStatusId,
    required this.companyName,
    required this.branchName,
    required this.wasteCategory,
    required this.driverName,
    this.pickupScheduleId,
    this.pickupStatusId,
    this.scheduleDriverId,
    this.driverRatingId,
  });

  factory ServiceHistory.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return ServiceHistory(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      confirmationTime: json['confirmation_time']?.toString() ?? '',
      collectedWeightKg: json['collected_weight_kg']?.toString() ?? '0',
      verificationStatusId: json['verification_status_id'] is int
          ? json['verification_status_id'] as int
          : int.tryParse('${json['verification_status_id']}') ?? 0,
      companyName: json['company_name']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? '',
      wasteCategory: json['waste_category']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? '',
      pickupScheduleId: asInt(json['pickup_schedule_id']),
      pickupStatusId: asInt(json['pickup_status_id']),
      scheduleDriverId: asInt(json['schedule_driver_id']),
      driverRatingId: asInt(json['driver_rating_id']),
    );
  }
}
