import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';

class CreateDealScreen extends StatefulWidget {
  @override
  _CreateDealScreenState createState() => _CreateDealScreenState();
}

class _CreateDealScreenState extends State<CreateDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _specialConditionsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _pickupTimeController = TextEditingController();
  
  String? _selectedWasteCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _submitDeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select start and end dates")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      // Replace with your actual API URL
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/industry/deals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'company_id': _companyIdController.text,
          'waste_category_id': _selectedWasteCategory,
          'quantity_kg': double.tryParse(_quantityController.text) ?? 0,
          'price_per_kg': double.tryParse(_priceController.text) ?? 0,
          'validity_start': _startDate!.toIso8601String(),
          'validity_end': _endDate!.toIso8601String(),
          'special_conditions': _specialConditionsController.text,
          'location_address': _locationController.text,
          'preferred_pickup_time': _pickupTimeController.text,
        }),
      );

      final result = json.decode(response.body);
      if (response.statusCode == 201) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deal Created Successfully")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "Error creating deal")));
          setState(() => _isLoading = false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "Error creating deal")));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isLoading = false);
    } finally {
      if (_isLoading) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Deal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _companyIdController,
                decoration: InputDecoration(labelText: "Company ID (Manual Input)"),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedWasteCategory,
                items: [
                  DropdownMenuItem(value: "1", child: Text("Plastic")),
                  DropdownMenuItem(value: "2", child: Text("Metal")),
                  // Add more based on waste_categories table
                ],
                onChanged: (val) => setState(() => _selectedWasteCategory = val),
                decoration: InputDecoration(labelText: "Waste Category"),
                validator: (v) => v == null ? 'Required' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: "Quantity (kg)"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Must be a number';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Price per kg"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Must be a number';
                  return null;
                },
              ),
              ListTile(
                title: Text(_startDate == null ? "Select Start Date" : "Start: ${_startDate.toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
              ),
              ListTile(
                title: Text(_endDate == null ? "Select End Date" : "End: ${_endDate.toString().split(' ')[0]}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _endDate = picked);
                },
              ),
              TextFormField(
                controller: _specialConditionsController,
                decoration: InputDecoration(labelText: "Special Conditions (Optional)"),
                maxLines: 3,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location Address (Optional)"),
              ),
              TextFormField(
                controller: _pickupTimeController,
                decoration: InputDecoration(labelText: "Preferred Pickup Time (Optional)"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitDeal,
                child: _isLoading ? CircularProgressIndicator() : Text("Submit Deal"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
