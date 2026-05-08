import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';

class ViewDealsScreen extends StatefulWidget {
  final String companyId;
  ViewDealsScreen({required this.companyId});

  @override
  _ViewDealsScreenState createState() => _ViewDealsScreenState();
}

class _ViewDealsScreenState extends State<ViewDealsScreen> {
  List deals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/industry/deals/company/${widget.companyId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final result = json.decode(response.body);
      if (result['success']) {
        setState(() {
          deals = result['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Deals")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text("Date Created")),
                  DataColumn(label: Text("Category")),
                  DataColumn(label: Text("Quantity")),
                  DataColumn(label: Text("Total Value")),
                  DataColumn(label: Text("Status")),
                ],
                rows: deals.map<DataRow>((deal) {
                  return DataRow(cells: [
                    DataCell(Text(deal['created_at'].toString().split('T')[0])),
                    DataCell(Text(deal['waste_category_name'] ?? 'N/A')),
                    DataCell(Text("${deal['quantity_kg']} kg")),
                    DataCell(Text("\$${deal['total_value']}")),
                    DataCell(Text(deal['bid_status_name'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}
