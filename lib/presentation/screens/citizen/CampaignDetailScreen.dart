//  — search // <name> button|card|drawer item|dashboard card
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/utils/screen_title_util.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pickup_status.dart';
import '../../../core/utils/storage_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('CampaignDetailScreen.dart');

class CampaignDetailScreen extends StatefulWidget {
  final int reportId;

  const CampaignDetailScreen({super.key, required this.reportId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  Map<String, dynamic>? campaign;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => isLoading = true);
    try {
      final token = StorageUtil.getToken();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/citizen/campaigns/${widget.reportId}'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          setState(() {
            campaign = body['data'] as Map<String, dynamic>?;
            isLoading = false;
          });
          return;
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error fetching campaign details: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _donate() async {
    if (campaign == null) return;
    final amountController = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contribute to cleanup'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (PKR)',
            prefixText: 'Rs ',
          ),
        ),
        actions: [
          // Cancel button
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), // end Cancel button
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amountController.text.trim());
              if (value == null || value <= 0) return;
              Navigator.pop(ctx, value);
            },
            child: const Text('Donate'),
          ),
        ],
      ),
    );
    amountController.dispose();
    if (amount == null || !mounted) return;

    try {
      final token = StorageUtil.getToken();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/reports/public-garbage/${widget.reportId}/donate'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'payment_method': 'app',
        }),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 201 && body['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thank you! Rs ${amount.toStringAsFixed(0)} contributed.')),
        );
        await _fetchDetails();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message']?.toString() ?? 'Donation failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (campaign == null) return const Scaffold(body: Center(child: Text('Campaign not found')));

    final statusId = campaign!['report_status_id'];
    final estVolume = campaign!['estimated_volume'] ?? '0';
    final actualVolume = campaign!['actual_volume'] ?? '0';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(statusId),
                  const SizedBox(height: 24),
                  _buildFundingSection(),
                  const SizedBox(height: 24),
                  _buildComparisonSection(estVolume, actualVolume),
                  const SizedBox(height: 24),
                  if (statusId == 174) _buildExpenseSection(),
                  const SizedBox(height: 24),
                  const Text('MISSION TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _buildTimeline(statusId),
                  const SizedBox(height: 24),
                  if (_canLiveTrackCleanup()) _buildLiveTrackButton(),
                  if (_canLiveTrackCleanup()) const SizedBox(height: 24),
                  _buildImpactCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF9B5DE0),
      title: Text(_kScreenTitle),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Color(0xFF9B5DE0), size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(campaign!['photo_url'] ?? '', fit: BoxFit.contain),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.7)]))),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campaign!['address'] ?? 'Location', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                      const SizedBox(width: 8),
                      Text('Reported on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(campaign!['created_at']))}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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

  Widget _buildFundingSection() {
    final goal = double.tryParse('${campaign!['funding_goal']}') ?? 0;
    final collected = double.tryParse('${campaign!['funds_collected']}') ?? 0;
    final progress = goal > 0 ? (collected / goal).clamp(0.0, 1.0) : 0.0;
    final statusId = campaign!['report_status_id'];
    final canDonate = statusId == 170 || statusId == 171 || statusId == 204;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('FUNDING PROGRESS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9B5DE0))),
            ],
          ),
          const SizedBox(height: 10),
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
          Text('Rs ${collected.toStringAsFixed(0)} collected of Rs ${goal.toStringAsFixed(0)} goal'),
          if (canDonate) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _donate,
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('Contribute to this cleanup'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6F38C5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusHeader(int statusId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF9B5DE0).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.info_outline, color: Color(0xFF9B5DE0))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CURRENT STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(_getStatusText(statusId).toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(String est, String actual) {
    return Row(
      children: [
        _comparisonCard('ESTIMATED', '$est kg', Icons.analytics_outlined, Colors.blue),
        const SizedBox(width: 16),
        _comparisonCard('ACTUAL', '$actual kg', Icons.scale_outlined, Colors.green),
      ],
    );
  }

  Widget _comparisonCard(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSection() {
    final total = (double.tryParse(campaign!['fuel_expense']?.toString() ?? '0') ?? 0) +
                  (double.tryParse(campaign!['labor_expense']?.toString() ?? '0') ?? 0) +
                  (double.tryParse(campaign!['other_expense']?.toString() ?? '0') ?? 0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EXPENSE SUMMARY', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text('Rs ${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white10, height: 24),
          _expenseRow('Fuel', 'Rs ${campaign!['fuel_expense'] ?? 0}'),
          _expenseRow('Labor', 'Rs ${campaign!['labor_expense'] ?? 0}'),
          _expenseRow('Misc', 'Rs ${campaign!['other_expense'] ?? 0}'),
        ],
      ),
    );
  }

  Widget _expenseRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white60)), Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildTimeline(int currentStatus) {
    final stages = [
      {'id': 204, 'label': 'Approved'},
      {'id': 206, 'label': 'Assigned'},
      {'id': 207, 'label': 'On the Way'},
      {'id': 205, 'label': 'Arrived'},
      {'id': 208, 'label': 'Collected'},
      {'id': 174, 'label': 'Cleaned'},
    ];

    return Column(
      children: stages.map((s) {
        final isCompleted = _isStageComplete(currentStatus, s['id'] as int);
        final isLast = stages.last == s;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: isCompleted ? const Color(0xFF9B5DE0) : Colors.grey[200], shape: BoxShape.circle),
                  child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                if (!isLast) Container(width: 2, height: 40, color: isCompleted ? const Color(0xFF9B5DE0) : Colors.grey[200]),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(s['label'] as String, style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, color: isCompleted ? Colors.black : Colors.grey)),
            ),
          ],
        );
      }).toList(),
    );
  }

  bool _isStageComplete(int current, int stage) {
    final order = [204, 206, 207, 205, 208, 174];
    return order.indexOf(current) >= order.indexOf(stage);
  }

  String _getStatusText(int id) {
    switch (id) {
      case 204: return 'Approved';
      case 206: return 'Driver Assigned';
      case 207: return 'Driver on the Way';
      case 205: return 'Cleaning Started';
      case 208: return 'Garbage Collected';
      case 174: return 'Area Cleaned';
      default: return 'Under Review';
    }
  }

  bool _canLiveTrackCleanup() {
    if (campaign == null) return false;
    final driverId = campaign!['driver_id'];
    final hasDriver = driverId != null && int.tryParse('$driverId') != null && int.parse('$driverId') > 0;
    final statusId = campaign!['report_status_id'] is int
        ? campaign!['report_status_id'] as int
        : int.tryParse('${campaign!['report_status_id']}') ?? 0;
    return hasDriver && (statusId == 206 || statusId == 207 || statusId == 205);
  }

  Widget _buildLiveTrackButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/live-tracking',
            arguments: {
              'task_id': widget.reportId,
              'task_type': TrackingTaskType.adminCleanup,
            },
          );
        },
        icon: const Icon(Icons.my_location_rounded),
        label: const Text('Live Track Cleanup Truck'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6F38C5),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9B5DE0), Color(0xFFD78FEE)]), borderRadius: BorderRadius.circular(24)),
      child: const Row(
        children: [
          Icon(Icons.eco, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(child: Text('Your report helped restore this area to its natural beauty. Thank you for being a responsible citizen!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
