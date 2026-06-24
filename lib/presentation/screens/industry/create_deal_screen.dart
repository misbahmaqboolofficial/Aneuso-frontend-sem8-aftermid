import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/form_validators.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('create_deal_screen.dart');

class CreateDealScreen extends StatefulWidget {
  const CreateDealScreen({super.key});

  @override
  State<CreateDealScreen> createState() => _CreateDealScreenState();
}

class _CreateDealScreenState extends State<CreateDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _monthlyQuantityController = TextEditingController();
  final TextEditingController _contractMonthsController = TextEditingController(text: '12');
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _specialConditionsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String? _selectedWasteCategory;
  String? _selectedDay;
  TimeOfDay? _selectedTime;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  // Modern Color Palette
  final Color primaryColor = const Color(0xFF450693);
  final Color accentColor = const Color(0xFF9B5DE0);
  final Color lightColor = const Color(0xFFD78FEE);
  final Color bgColor = const Color(0xFFFDCFFA);

  Future<void> _submitDeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select start and end dates")));
      return;
    }

    String preferredTime = "Flexible";
    if (_selectedDay != null && _selectedTime != null) {
      final timeStr = _selectedTime!.format(context);
      preferredTime = "$_selectedDay at $timeStr";
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(AppConstants.tokenKey);

      final monthlyKg = double.tryParse(_monthlyQuantityController.text.trim()) ?? 0;
      final months = int.tryParse(_contractMonthsController.text.trim()) ?? 0;
      final totalKg = monthlyKg > 0 && months > 0
          ? monthlyKg * months
          : (double.tryParse(_quantityController.text) ?? 0);

      final monthlyNote = monthlyKg > 0 && months > 0
          ? 'Monthly contract: ${monthlyKg.toStringAsFixed(0)} kg/month for $months months. '
          : '';
      final conditions = '$monthlyNote${_specialConditionsController.text.trim()}'.trim();

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/industry/deals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'company_id': Provider.of<AuthProvider>(context, listen: false).currentUser?.industryName ?? "",
          'waste_category_id': _selectedWasteCategory,
          'quantity_kg': totalKg,
          'price_per_kg': double.tryParse(_priceController.text) ?? 0,
          'validity_start': _startDate!.toIso8601String(),
          'validity_end': _endDate!.toIso8601String(),
          'special_conditions': conditions.isEmpty ? null : conditions,
          'location_address': _locationController.text,
          'preferred_pickup_time': preferredTime,
        }),
      );

      final result = json.decode(response.body);
      if (response.statusCode == 201) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deal Created Successfully")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "Error creating deal")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? "Error creating deal")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                _buildIndustryHeader(),
                                const SizedBox(height: 24),
                                _buildGlassContainer(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Deal Details', Icons.category_outlined),
                                      const SizedBox(height: 16),
                                      _buildWasteDropdown(),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller: _monthlyQuantityController,
                                              label: 'Monthly quantity',
                                              hint: '0',
                                              icon: Icons.calendar_month_outlined,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              suffix: ' kg/mo',
                                              validator: (v) {
                                                if ((v == null || v.trim().isEmpty) &&
                                                    _quantityController.text.trim().isEmpty) {
                                                  return 'Enter monthly or total quantity';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildTextField(
                                              controller: _contractMonthsController,
                                              label: 'Contract months',
                                              hint: '12',
                                              icon: Icons.date_range_outlined,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              suffix: ' mo',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller: _quantityController,
                                              label: 'Total quantity (optional)',
                                              hint: 'Auto from monthly',
                                              icon: Icons.scale_outlined,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                              suffix: ' kg',
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: _buildTextField(
                                              controller: _priceController,
                                              label: 'Price per kg',
                                              hint: '0.00',
                                              icon: Icons.attach_money_rounded,
                                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                                              prefix: r'Rs ',
                                              validator: FormValidators.price,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildGlassContainer(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Validity Period', Icons.calendar_today_outlined),
                                      const SizedBox(height: 16),
                                      _buildDateRangePicker(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildGlassContainer(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Logistics', Icons.local_shipping_outlined),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _locationController,
                                        label: 'Pickup Location',
                                        hint: 'Enter warehouse address...',
                                        icon: Icons.location_on_outlined,
                                        validator: FormValidators.address,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPreferredTimeSelector(),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        controller: _specialConditionsController,
                                        label: 'Special Conditions',
                                        hint: 'Any specific requirements?',
                                        icon: Icons.note_alt_outlined,
                                        maxLines: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                _buildSubmitButton(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            _kScreenTitle,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.industryName ?? "Your Industry";
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryColor, accentColor]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.business_rounded, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PUBLISHING AS", style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    Text(name, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lightColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: accentColor),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: accentColor),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            suffixText: suffix,
            prefixIcon: Icon(icon, color: accentColor, size: 18),
            filled: true,
            fillColor: bgColor.withOpacity(0.15),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: lightColor.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildWasteDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Waste Category', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedWasteCategory,
          items: const [
            DropdownMenuItem(value: "1", child: Text("Plastic")),
            DropdownMenuItem(value: "2", child: Text("Metal")),
            DropdownMenuItem(value: "3", child: Text("Paper")),
            DropdownMenuItem(value: "4", child: Text("Glass")),
          ],
          onChanged: (val) => setState(() => _selectedWasteCategory = val),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.recycling_rounded, color: accentColor, size: 18),
            filled: true,
            fillColor: bgColor.withOpacity(0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          validator: (v) => FormValidators.dropdown(v, field: 'a waste category'),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: _buildDateTile(
            label: 'Start Date',
            date: _startDate,
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
              if (picked != null) setState(() => _startDate = picked);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateTile(
            label: 'End Date',
            date: _endDate,
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: _startDate ?? DateTime.now(), lastDate: DateTime(2030));
              if (picked != null) setState(() => _endDate = picked);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile({required String label, required DateTime? date, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lightColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: accentColor),
                const SizedBox(width: 10),
                Text(
                  date == null ? 'Select' : DateFormat('MMM dd').format(date),
                  style: GoogleFonts.poppins(fontSize: 14, color: date == null ? Colors.grey[400] : Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferredTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferred Pickup Window', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDay,
                hint: const Text("Select Day"),
                items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                onChanged: (val) => setState(() => _selectedDay = val),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.today_rounded, color: accentColor, size: 18),
                  filled: true,
                  fillColor: bgColor.withOpacity(0.15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (picked != null) setState(() => _selectedTime = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: lightColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime == null ? "Select Time" : _selectedTime!.format(context),
                        style: GoogleFonts.poppins(fontSize: 13, color: _selectedTime == null ? Colors.grey[400] : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [primaryColor, accentColor]),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitDeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : Text('PUBLISH DEAL', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
      ),
    );
  }
}
