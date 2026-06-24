import 'dart:convert';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/presentation/screens/citizen/CampaignDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('CleanupCampaignsScreen.dart');

class CleanupCampaignsScreen extends StatefulWidget {
  const CleanupCampaignsScreen({super.key});

  @override
  State<CleanupCampaignsScreen> createState() => _CleanupCampaignsScreenState();
}

class _CleanupCampaignsScreenState extends State<CleanupCampaignsScreen> {
  final String baseUrl = AppConstants.baseUrl;
  List<dynamic> campaigns = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/citizen/campaigns?limit=50&sort_by=urgent'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            campaigns = data['data'] as List<dynamic>? ?? [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load campaigns';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Text(
          _kScreenTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9B5DE0), Color(0xFFD78FEE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: fetchCampaigns,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : campaigns.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: campaigns.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildDisclaimerBanner();
                        return _buildCampaignCard(campaigns[index - 1]);
                      },
                    ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6F38C5).withOpacity(0.9), const Color(0xFF9B5DE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F38C5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'A Note from Gulbhao',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'We are trying to clean the best we can with the available funds. Sometimes, if funds are low, the entire garbage of a certain complaint might not get completely cleared.\n\nPlease don\'t be discouraged or discourage our team if an area isn\'t 100% spotless. We are still giving it our all! Support us by funding campaigns so we can keep making our city beautiful together. 💜',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cleaning_services_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No active cleanup campaigns',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text('Check back later for new cleanup efforts!', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final double fundingGoal = double.tryParse(campaign['funding_goal']?.toString() ?? '0') ?? 0;
    final double fundsCollected = double.tryParse(campaign['funds_collected']?.toString() ?? '0') ?? 0;
    final double progress = fundingGoal > 0 ? (fundsCollected / fundingGoal).clamp(0.0, 1.0) : 0.0;
    final int statusId = campaign['report_status_id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B5DE0).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Image.network(
                  campaign['photo_url'] ?? 'https://via.placeholder.com/400x200',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildStatusBadge(statusId),
                ),
                if (campaign['urgency_level_id'] == 186) // Urgent
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.priority_high, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          campaign['address'] ?? 'Unknown Location',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '#${campaign['id']}',
                        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    campaign['description'] ?? 'No description provided.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  
                  // Funding Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Funding Progress',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9B5DE0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[100],
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF9B5DE0)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(Icons.attach_money, 'PKR ${fundsCollected.toInt()}', 'Collected'),
                      _buildInfoItem(Icons.ads_click, 'PKR ${fundingGoal.toInt()}', 'Target'),
                      _buildInfoItem(Icons.scale, '${campaign['estimated_volume']}kg', 'Size'),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to detail screen
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => CampaignDetailScreen(reportId: campaign['id']),
                          )
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B5DE0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('View Campaign Details', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int statusId) {
    String text = 'UNKNOWN';
    Color color = Colors.grey;
    
    switch (statusId) {
      case 170:
      case 171:
        text = 'FUNDING ACTIVE';
        color = const Color(0xFF6F38C5);
        break;
      case 206:
        text = 'DRIVER ASSIGNED';
        color = const Color(0xFF6F38C5);
        break;
      case 207:
        text = 'Driver on the Way';
        color = Colors.orange;
        break;
      case 205:
        text = 'Cleaning Started';
        color = Colors.indigo;
        break;
      case 208:
        text = 'GARBAGE COLLECTED';
        color = Colors.green;
        break;
      case 174:
        text = 'AREA CLEANED';
        color = Colors.teal;
        break;
      case 204:
        text = 'APPROVED';
        color = const Color(0xFF9B5DE0);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      ],
    );
  }
}
