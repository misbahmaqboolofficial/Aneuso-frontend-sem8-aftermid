import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/form_validators.dart';
import '../../providers/company_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../services/branch_service.dart';
import '../../../domain/entities/branch_entity.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('company_list_screen.dart');

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      provider.fetchCompanies();
      provider.fetchTypes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final Map<String, dynamic> body = {};
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final addressCtl = TextEditingController();

    int? selectedCompanyTypeId;
    int? selectedBusinessTypeId;
    int? selectedWasteTypeId;

    await showDialog(
      context: context,
      builder: (_) {
        return Consumer<CompanyProvider>(
          builder: (context, provider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dialog Header
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.business_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  'Add New Company',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(25),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStyledTextField(
                                    controller: nameCtl,
                                    label: 'Company Name',
                                    icon: Icons.business_rounded,
                                    validator: (v) => FormValidators.name(v, field: 'Company name'),
                                  ),
                                  SizedBox(height: 15),
                                  _buildStyledTextField(
                                    controller: emailCtl,
                                    label: 'Contact Email',
                                    icon: Icons.email_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: FormValidators.email,
                                  ),
                                  SizedBox(height: 15),
                                  _buildStyledTextField(
                                    controller: phoneCtl,
                                    label: 'Contact Phone',
                                    icon: Icons.phone_rounded,
                                    keyboardType: TextInputType.phone,
                                    validator: FormValidators.phone,
                                  ),
                                  SizedBox(height: 15),
                                  _buildStyledTextField(
                                    controller: addressCtl,
                                    label: 'Address',
                                    icon: Icons.location_on_rounded,
                                    validator: FormValidators.address,
                                  ),
                                  SizedBox(height: 15),
                                  // Company Type Dropdown
                                  _buildStyledDropdown(
                                    value: selectedCompanyTypeId,
                                    items: provider.companyTypes
                                        .map(
                                          (t) => DropdownMenuItem<int>(
                                            value: t.id,
                                            child: Text(
                                              t.typeName,
                                              style: TextStyle(
                                                color: Color(0xFF6F38C5),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    label: 'Company Type',
                                    icon: Icons.category_rounded,
                                    onChanged: (v) => setState(
                                      () => selectedCompanyTypeId = v,
                                    ),
                                    validator: (v) =>
                                        FormValidators.dropdown(v, field: 'company type'),
                                  ),
                                  SizedBox(height: 15),
                                  // Business Type Dropdown
                                  _buildStyledDropdown(
                                    value: selectedBusinessTypeId,
                                    items: provider.businessTypes
                                        .map(
                                          (t) => DropdownMenuItem<int>(
                                            value: t.id,
                                            child: Text(
                                              t.typeName,
                                              style: TextStyle(
                                                color: Color(0xFF6F38C5),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    label: 'Business Type',
                                    icon: Icons.work_rounded,
                                    onChanged: (v) => setState(
                                      () => selectedBusinessTypeId = v,
                                    ),
                                    validator: (v) =>
                                        FormValidators.dropdown(v, field: 'business type'),
                                  ),
                                  SizedBox(height: 15),
                                  // Waste Type Dropdown
                                  _buildStyledDropdown(
                                    value: selectedWasteTypeId,
                                    items: provider.wasteTypes
                                        .map(
                                          (t) => DropdownMenuItem<int>(
                                            value: t.id,
                                            child: Text(
                                              t.typeName,
                                              style: TextStyle(
                                                color: Color(0xFF6F38C5),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    label: 'Waste Type',
                                    icon: Icons.delete_rounded,
                                    onChanged: (v) =>
                                        setState(() => selectedWasteTypeId = v),
                                    validator: (v) =>
                                        FormValidators.dropdown(v, field: 'waste type'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Dialog Actions
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    body['company_name'] = nameCtl.text.trim();
                                    body['contact_email'] = emailCtl.text
                                        .trim();
                                    body['contact_phone_number'] = phoneCtl.text
                                        .trim();
                                    body['company_address'] = addressCtl.text
                                        .trim();
                                    body['is_headquarter'] = true;

                                    body['company_type_id'] =
                                        selectedCompanyTypeId ?? 1;
                                    body['business_type_id'] =
                                        selectedBusinessTypeId ?? 1;
                                    body['waste_type'] =
                                        (selectedWasteTypeId != null)
                                        ? provider.wasteTypes
                                              .firstWhere(
                                                (w) =>
                                                    w.id == selectedWasteTypeId,
                                              )
                                              .typeName
                                        : '';

                                    final created =
                                        await Provider.of<CompanyProvider>(
                                          context,
                                          listen: false,
                                        ).createCompany(body);
                                    if (created && mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Company created successfully!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6F38C5),
                                          Color(0xFF9B5DE0),
                                          Color(0xFFD78FEE),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF6F38C5,
                                          ).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Create',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    dynamic c,
    CompanyProvider provider,
  ) async {
    final _formKey = GlobalKey<FormState>();
    final Map<String, dynamic> body = {};
    final nameCtl = TextEditingController(text: c.companyName);
    final emailCtl = TextEditingController(text: c.contactEmail);
    final phoneCtl = TextEditingController(text: c.contactPhoneNumber);
    final addressCtl = TextEditingController(text: c.companyAddress);

    int? selectedCompanyTypeId = c.companyTypeId;
    int? selectedBusinessTypeId = c.businessTypeId;
    int? selectedWasteTypeId;

    // derive waste type id from name if available
    if (provider.wasteTypes.isNotEmpty) {
      final match = provider.wasteTypes.firstWhere(
        (w) => w.typeName == c.wasteType,
        orElse: () => provider.wasteTypes.first,
      );
      selectedWasteTypeId = match.id;
    }

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog Header
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Edit Company',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(25),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStyledTextField(
                                controller: nameCtl,
                                label: 'Company Name',
                                icon: Icons.business_rounded,
                                validator: (v) =>
                                    FormValidators.name(v, field: 'Company name'),
                              ),
                              SizedBox(height: 15),
                              _buildStyledTextField(
                                controller: emailCtl,
                                label: 'Contact Email',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: FormValidators.email,
                              ),
                              SizedBox(height: 15),
                              _buildStyledTextField(
                                controller: phoneCtl,
                                label: 'Contact Phone',
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                validator: FormValidators.phone,
                              ),
                              SizedBox(height: 15),
                              _buildStyledTextField(
                                controller: addressCtl,
                                label: 'Address',
                                icon: Icons.location_on_rounded,
                                validator: FormValidators.address,
                              ),
                              SizedBox(height: 15),
                              // Company Type Dropdown
                              _buildStyledDropdown(
                                value: selectedCompanyTypeId,
                                items: provider.companyTypes
                                    .map(
                                      (t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text(
                                          t.typeName,
                                          style: TextStyle(
                                            color: Color(0xFF6F38C5),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                label: 'Company Type',
                                icon: Icons.category_rounded,
                                onChanged: (v) =>
                                    setState(() => selectedCompanyTypeId = v),
                                validator: (v) =>
                                    FormValidators.dropdown(v, field: 'company type'),
                              ),
                              SizedBox(height: 15),
                              // Business Type Dropdown
                              _buildStyledDropdown(
                                value: selectedBusinessTypeId,
                                items: provider.businessTypes
                                    .map(
                                      (t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text(
                                          t.typeName,
                                          style: TextStyle(
                                            color: Color(0xFF6F38C5),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                label: 'Business Type',
                                icon: Icons.work_rounded,
                                onChanged: (v) =>
                                    setState(() => selectedBusinessTypeId = v),
                                validator: (v) =>
                                    FormValidators.dropdown(v, field: 'business type'),
                              ),
                              SizedBox(height: 15),
                              // Waste Type Dropdown
                              _buildStyledDropdown(
                                value: selectedWasteTypeId,
                                items: provider.wasteTypes
                                    .map(
                                      (t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text(
                                          t.typeName,
                                          style: TextStyle(
                                            color: Color(0xFF6F38C5),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                label: 'Waste Type',
                                icon: Icons.delete_rounded,
                                onChanged: (v) =>
                                    setState(() => selectedWasteTypeId = v),
                                validator: (v) =>
                                    FormValidators.dropdown(v, field: 'waste type'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Dialog Actions
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;
                                body['company_name'] = nameCtl.text.trim();
                                body['contact_email'] = emailCtl.text.trim();
                                body['contact_phone_number'] = phoneCtl.text
                                    .trim();
                                body['company_address'] = addressCtl.text
                                    .trim();
                                body['is_headquarter'] = true;
                                body['company_type_id'] =
                                    selectedCompanyTypeId ?? c.companyTypeId;
                                body['business_type_id'] =
                                    selectedBusinessTypeId ?? c.businessTypeId;
                                body['waste_type'] = selectedWasteTypeId != null
                                    ? provider.wasteTypes
                                          .firstWhere(
                                            (w) => w.id == selectedWasteTypeId,
                                          )
                                          .typeName
                                    : c.wasteType;

                                final updated =
                                    await Provider.of<CompanyProvider>(
                                      context,
                                      listen: false,
                                    ).updateCompany(c.id, body);
                                if (updated && mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Company updated successfully!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6F38C5),
                                      Color(0xFF9B5DE0),
                                      Color(0xFFD78FEE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF6F38C5).withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Update',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
            ).createShader(bounds);
          },
          child: Text(
            _kScreenTitle,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF6F38C5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF6F38C5),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CompanyProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading && provider.companies.isEmpty,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6F38C5).withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search companies...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(15),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF9B5DE0),
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              provider.search(value.trim());
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              _searchController.clear();
                              provider.search('');
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Stats Card
                if (provider.companies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6F38C5).withOpacity(0.9),
                            Color(0xFF9B5DE0).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF6F38C5).withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            'Total Companies',
                            provider.companies.length.toString(),
                            Icons.business_rounded,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          // _buildStatItem(
                          //   'Active',
                          //   '${provider.companies.where((c) => c.activeStatus == 1).length}',
                          //   Icons.check_circle_rounded,
                          // ),
                          // Container(
                          //   height: 40,
                          //   width: 1,
                          //   color: Colors.white.withOpacity(0.3),
                          // ),
                          // _buildStatItem(
                          //   'Inactive',
                          //   '${provider.companies.where((c) => c.activeStatus == 0).length}',
                          //   Icons.pause_circle_rounded,
                          // ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 20),

                // Company List
                Expanded(
                  child: RefreshIndicator(
                    color: Color(0xFF6F38C5),
                    onRefresh: () => provider.fetchCompanies(page: 1),
                    child: provider.companies.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFFFDCFFA,
                                          ).withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.business_rounded,
                                          size: 50,
                                          color: Color(0xFF9B5DE0),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        provider.error != null
                                            ? provider.error!
                                            : 'No companies found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF6F38C5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      if (provider.error == null)
                                        Text(
                                          'Tap the + button to add a company',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount:
                                provider.companies.length +
                                (provider.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= provider.companies.length) {
                                if (provider.isLoading) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF6F38C5),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Container(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () => provider.loadNextPage(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Color(
                                              0xFF6F38C5,
                                            ).withOpacity(0.2),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Load More Companies',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF6F38C5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final c = provider.companies[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(20),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6F38C5).withOpacity(0.9),
                                          Color(0xFF9B5DE0).withOpacity(0.9),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        c.companyName.isNotEmpty
                                            ? c.companyName[0]
                                            : 'C',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    c.companyName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6F38C5),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_rounded,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              c.contactEmail,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone_rounded,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            c.contactPhoneNumber,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(height: 8),
                                      // Container(
                                      //   padding: EdgeInsets.symmetric(
                                      //     horizontal: 10,
                                      //     vertical: 4,
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     color: c.activeStatus == 1
                                      //         ? Colors.green.withOpacity(0.1)
                                      //         : Colors.red.withOpacity(0.1),
                                      //     borderRadius: BorderRadius.circular(
                                      //       20,
                                      //     ),
                                      //     border: Border.all(
                                      //       color: c.activeStatus == 1
                                      //           ? Colors.green
                                      //           : Colors.red,
                                      //       width: 1,
                                      //     ),
                                      //   ),
                                      //   child: Text(
                                      //     c.activeStatus == 1
                                      //         ? 'Active'
                                      //         : 'Inactive',
                                      //     style: TextStyle(
                                      //       fontSize: 12,
                                      //       fontWeight: FontWeight.w600,
                                      //       color: c.activeStatus == 1
                                      //           ? Colors.green
                                      //           : Colors.red,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF6F38C5).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: Color(0xFF6F38C5),
                                      ),
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          final ok = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => CompanyDeleteDialog(company: c),
                                          );
                                          if (ok == true && mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Company and its branches deleted successfully!',
                                                  style: TextStyle(fontWeight: FontWeight.w600),
                                                ),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        } else if (value == 'view') {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Container(
                                                padding: EdgeInsets.all(25),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF6F38C5,
                                                                    ),
                                                                    Color(
                                                                      0xFF9B5DE0,
                                                                    ),
                                                                  ],
                                                                ),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              c
                                                                      .companyName
                                                                      .isNotEmpty
                                                                  ? c.companyName[0]
                                                                  : 'C',
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 15),
                                                        Expanded(
                                                          child: Text(
                                                            c.companyName,
                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: Color(
                                                                0xFF6F38C5,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 25),
                                                    _buildDetailItem(
                                                      Icons.email_rounded,
                                                      'Email',
                                                      c.contactEmail,
                                                    ),
                                                    SizedBox(height: 15),
                                                    _buildDetailItem(
                                                      Icons.phone_rounded,
                                                      'Phone',
                                                      c.contactPhoneNumber,
                                                    ),
                                                    SizedBox(height: 15),
                                                    _buildDetailItem(
                                                      Icons.location_on_rounded,
                                                      'Address',
                                                      c.companyAddress,
                                                    ),
                                                    SizedBox(height: 15),
                                                    _buildDetailItem(
                                                      Icons.delete_rounded,
                                                      'Waste Type',
                                                      c.wasteType,
                                                    ),
                                                    SizedBox(height: 25),
                                                    Container(
                                                      height: 48,
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        ),
                                                        child: Ink(
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF6F38C5,
                                                                    ),
                                                                    Color(
                                                                      0xFF9B5DE0,
                                                                    ),
                                                                  ],
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              'Close',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (value == 'edit') {
                                          await _showEditDialog(
                                            context,
                                            c,
                                            provider,
                                          );
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.visibility_rounded,
                                                color: Color(0xFF6F38C5),
                                                size: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'View Details',
                                                style: TextStyle(
                                                  color: Color(0xFF6F38C5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                color: Color(0xFF6F38C5),
                                                size: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                  color: Color(0xFF6F38C5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: Color(0xFF6F38C5),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6F38C5).withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6F38C5).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Color(0xFF6F38C5), fontSize: 16),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF9B5DE0).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Color(0xFF9B5DE0)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Color(0xFF6F38C5).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildStyledDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required String label,
    required IconData icon,
    required Function(int?) onChanged,
    required String? Function(int?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6F38C5).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        items: items,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF9B5DE0).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Color(0xFF9B5DE0)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Color(0xFF6F38C5).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        style: TextStyle(color: Color(0xFF6F38C5), fontSize: 16),
        dropdownColor: Colors.white,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Color(0xFF9B5DE0)),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6F38C5),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}

class CompanyDeleteDialog extends StatefulWidget {
  final dynamic company;
  const CompanyDeleteDialog({Key? key, required this.company}) : super(key: key);

  @override
  State<CompanyDeleteDialog> createState() => _CompanyDeleteDialogState();
}

class _CompanyDeleteDialogState extends State<CompanyDeleteDialog> {
  final BranchService _branchService = BranchService();
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _error;
  List<BranchEntity> _branches = [];

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final result = await _branchService.getBranches(companyId: widget.company.id);
      if (mounted) {
        setState(() {
          _branches = (result['branches'] as List).cast<BranchEntity>();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        padding: EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F38C5)),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Checking company branches...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else if (_error != null && !_isDeleting) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Error occurred',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6F38C5),
                ),
              ),
              SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6F38C5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Confirm Delete',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6F38C5),
                ),
              ),
              SizedBox(height: 10),
              if (_branches.isEmpty)
                Text(
                  'Are you sure you want to delete ${widget.company.companyName}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                )
              else ...[
                Text(
                  'Are you sure you want to delete ${widget.company.companyName}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'This company has the following branches. Even those branches will be deleted with this:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  constraints: BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: _branches.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final b = _branches[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_city_rounded,
                              color: Color(0xFF9B5DE0),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.branchName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (b.branchAddress.isNotEmpty)
                                    Text(
                                      b.branchAddress,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              SizedBox(height: 25),
              if (_isDeleting)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Deleting...',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isDeleting = true;
                            });
                            try {
                              // Delete company (database will automatically cascade delete branches and other references)
                              final provider = Provider.of<CompanyProvider>(
                                context,
                                listen: false,
                              );
                              final success = await provider.deleteCompany(widget.company.id);
                              if (mounted) {
                                if (success) {
                                  Navigator.pop(context, true);
                                } else {
                                  setState(() {
                                    _error = provider.error ?? 'Failed to delete company.';
                                    _isDeleting = false;
                                  });
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  _error = e.toString();
                                  _isDeleting = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.redAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
