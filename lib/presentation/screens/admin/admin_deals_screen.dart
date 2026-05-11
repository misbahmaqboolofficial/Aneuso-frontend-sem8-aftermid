import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class AdminDealsScreen extends StatefulWidget {
  @override
  _AdminDealsScreenState createState() => _AdminDealsScreenState();
}

class _AdminDealsScreenState extends State<AdminDealsScreen> {
  List deals = [];
  List filteredDeals = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  String _sortBy = 'Value (High to Low)'; // Default: Best to Worst

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDeals() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/admin/deals'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          deals = result['data'];
          _applyFilters();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredDeals = deals.where((deal) {
        // Status Filter
        final status = (deal['bid_status_name'] ?? '').toLowerCase();
        bool matchesStatus = true;
        if (_selectedStatusFilter != 'All') {
          matchesStatus = status.contains(_selectedStatusFilter.toLowerCase());
        }

        // Search Filter
        final query = _searchController.text.toLowerCase();
        final companyName = (deal['company_name'] ?? 'ID: ${deal['company_id']}').toLowerCase();
        final category = (deal['waste_category_name'] ?? '').toLowerCase();
        bool matchesSearch = companyName.contains(query) || category.contains(query);

        return matchesStatus && matchesSearch;
      }).toList();

      // Apply Sorting
      if (_sortBy == 'Value (High to Low)') {
        filteredDeals.sort((a, b) {
          double valA = double.tryParse(a['total_value']?.toString() ?? '0') ?? 0;
          double valB = double.tryParse(b['total_value']?.toString() ?? '0') ?? 0;
          return valB.compareTo(valA);
        });
      } else if (_sortBy == 'Value (Low to High)') {
        filteredDeals.sort((a, b) {
          double valA = double.tryParse(a['total_value']?.toString() ?? '0') ?? 0;
          double valB = double.tryParse(b['total_value']?.toString() ?? '0') ?? 0;
          return valA.compareTo(valB);
        });
      }
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/admin/deals/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        _fetchDeals(); // refresh list
        Navigator.pop(context); // Close dialog if open
      }
    } catch (e) {
      print(e);
    }
  }

  void _showDealDetails(Map<String, dynamic> deal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Deal Details", style: TextStyle(color: Color(0xFF4E56C0), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow("Company", deal['company_name'] ?? "ID: ${deal['company_id']}"),
              _detailRow("Category", deal['waste_category_name'] ?? "N/A"),
              _detailRow("Quantity", "${deal['quantity_kg']} kg"),
              _detailRow("Price/kg", "\$${deal['price_per_kg']}"),
              _detailRow("Total Value", "\$${deal['total_value']}"),
              _detailRow("Start Date", deal['validity_start'].toString().split('T')[0]),
              _detailRow("End Date", deal['validity_end'].toString().split('T')[0]),
              _detailRow("Location", deal['location_address'] ?? "N/A"),
              _detailRow("Pickup Time", deal['preferred_pickup_time'] ?? "N/A"),
              _detailRow("Conditions", deal['special_conditions'] ?? "None"),
              SizedBox(height: 10),
              Divider(),
              _detailRow("Status", deal['bid_status_name'].toString().toUpperCase(), 
                color: _getStatusColor(deal['bid_status_name'])),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Close")),
          if (deal['bid_status_name'].toString().toLowerCase().contains('pending')) ...[
            ElevatedButton(
              onPressed: () => _updateStatus(deal['id'], 'accepted'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text("Accept"),
            ),
            ElevatedButton(
              onPressed: () => _updateStatus(deal['id'], 'rejected'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Reject"),
            ),
          ]
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    status = status?.toLowerCase() ?? '';
    if (status.contains('accepted')) return Colors.green;
    if (status.contains('rejected')) return Colors.red;
    if (status.contains('pending')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
          ).createShader(bounds),
          child: Text('Deal Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4E56C0)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded, color: Color(0xFF4E56C0)),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
                _applyFilters();
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Value (High to Low)', child: Text('Most Beneficial First')),
              PopupMenuItem(value: 'Value (Low to High)', child: Text('Least Beneficial First')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Color(0xFF4E56C0).withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: "Search by company or category...",
                      prefixIcon: Icon(Icons.search, color: Color(0xFF9B5DE0)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Pending', 'Accepted', 'Rejected'].map((status) {
                      bool isSelected = _selectedStatusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedStatusFilter = status;
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: Color(0xFF4E56C0),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Color(0xFF4E56C0),
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Colors.white,
                          elevation: isSelected ? 4 : 0,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: Color(0xFF4E56C0)))
                : RefreshIndicator(
                    onRefresh: _fetchDeals,
                    child: filteredDeals.isEmpty
                        ? Center(child: Text("No deals found"))
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredDeals.length,
                            itemBuilder: (context, index) {
                              final deal = filteredDeals[index];
                              final status = deal['bid_status_name'] ?? 'N/A';
                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 8)),
                                  ],
                                  border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  onTap: () => _showDealDetails(deal),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)]),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.handshake_rounded, color: Colors.white),
                                  ),
                                  title: Text(
                                    deal['company_name'] ?? "Company ID: ${deal['company_id']}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E56C0)),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${deal['waste_category_name']} | ${deal['quantity_kg']}kg"),
                                      SizedBox(height: 4),
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "\$${deal['total_value']}",
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E56C0), fontSize: 16),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
