import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

final String _kScreenTitle = ScreenTitle.fromFile('view_deals_screen.dart');

class ViewDealsScreen extends StatefulWidget {
  const ViewDealsScreen({super.key});

  @override
  State<ViewDealsScreen> createState() => _ViewDealsScreenState();
}

class _ViewDealsScreenState extends State<ViewDealsScreen> {
  List<dynamic> deals = [];
  bool isLoading = true;

  String get _companyKey {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    return (user?.industryName?.trim().isNotEmpty == true)
        ? user!.industryName!.trim()
        : (user?.fullName ?? '');
  }

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      final companyId = Uri.encodeComponent(_companyKey);

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/industry/deals/company/$companyId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['success'] == true) {
        setState(() {
          deals = result['data'] as List<dynamic>? ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        title: Text(_kScreenTitle),
        backgroundColor: const Color(0xFF6F38C5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _fetchDeals,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/industry/create_deal')
            .then((_) => _fetchDeals()),
        backgroundColor: const Color(0xFF6F38C5),
        icon: const Icon(Icons.add),
        label: const Text('New Deal'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F38C5)))
          : deals.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.handshake_outlined, size: 64, color: Color(0xFF9B5DE0)),
                        const SizedBox(height: 16),
                        const Text(
                          'No deals yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a long-term waste collection deal for $_companyKey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: deals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    deal['waste_category_name']?.toString() ?? 'Waste deal',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF450693),
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    deal['bid_status_name']?.toString() ?? 'Pending',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: const Color(0xFFF3EBFF),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${deal['quantity_kg']} kg @ Rs ${deal['price_per_kg']}/kg'),
                            Text('Total: Rs ${deal['total_value']}'),
                            if (deal['special_conditions'] != null &&
                                deal['special_conditions'].toString().trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  deal['special_conditions'].toString(),
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Valid: ${deal['validity_start']} → ${deal['validity_end']}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
