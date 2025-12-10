import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/branch_provider.dart';
import '../../domain/entities/branch_entity.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({Key? key}) : super(key: key);

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final _searchController = TextEditingController();
  final Color _primaryColor = const Color(0xFF4E56C0);
  final Color _secondaryColor = const Color(0xFF9B5DE0);
  final Color _accentColor = const Color(0xFFD78FEE);
  final Color _lightColor = const Color(0xFFFDCFFA);

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BranchProvider>(context, listen: false);
    provider.fetchCompaniesDropdown();
    provider.fetchBranches(refresh: true);
  }

  void _applyFilters(BranchProvider provider, int? companyId, bool? isMain) {
    provider.setCompanyFilter(companyId);
    provider.setIsMainFilter(isMain);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog(BranchProvider provider) async {
    final _formKey = GlobalKey<FormState>();
    int? companyId;
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool isMainBranch = false;
    String? codeError;
    String? nameError;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, _lightColor.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _secondaryColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_business, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'Create New Branch',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(
                              controller: codeCtrl,
                              label: 'Branch Code',
                              icon: Icons.qr_code,
                              errorText: codeError,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Branch code is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: nameCtrl,
                              label: 'Branch Name',
                              icon: Icons.storefront,
                              errorText: nameError,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Branch name is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    _lightColor.withOpacity(0.1)
                                  ],
                                ),
                                border: Border.all(
                                  color: _accentColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonFormField<int?>(
                                  isExpanded: true,
                                  value: companyId,
                                  decoration: InputDecoration(
                                    labelText: 'Company',
                                    labelStyle: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.business,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  items: provider.companies.map((c) {
                                    return DropdownMenuItem<int?>(
                                      value: c['id'] as int?,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          c['company_name'] ??
                                              c['name'] ??
                                              c['title'] ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setState(() => companyId = v),
                                  validator: (v) =>
                                      v == null ? 'Please select company' : null,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: phoneCtrl,
                              label: 'Contact Phone',
                              icon: Icons.phone_iphone,
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone number is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: emailCtrl,
                              label: 'Contact Email',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Email is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: addressCtrl,
                              label: 'Branch Address',
                              icon: Icons.location_pin,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Address is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _lightColor.withOpacity(0.3),
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _accentColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _secondaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.star_rate_rounded,
                                        color: _secondaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    const Expanded(
                                      child: Text(
                                        'Main Branch',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 1.3,
                                      child: Switch(
                                        value: isMainBranch,
                                        onChanged: (v) =>
                                            setState(() => isMainBranch = v),
                                        activeColor: _secondaryColor,
                                        activeTrackColor: _lightColor,
                                        thumbColor: MaterialStateProperty.all(Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: _primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_secondaryColor, _primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _secondaryColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) return;
                            final body = {
                              'branch_code': codeCtrl.text.trim(),
                              'branch_name': nameCtrl.text.trim(),
                              'company_id': companyId,
                              'contact_phone_number': phoneCtrl.text.trim(),
                              'contact_email': emailCtrl.text.trim(),
                              'branch_address': addressCtrl.text.trim(),
                              'is_main_branch': isMainBranch ? 1 : 0,
                            };
                            try {
                              await provider.createBranch(body);
                              Navigator.pop(context);
                            } catch (e) {
                              if (e is Exception) {
                                try {
                                  final Map<String, dynamic> resp =
                                      (e as dynamic).errors ?? {};
                                  setState(() {
                                    codeError =
                                        resp['errors']?['branch_code'] != null
                                            ? resp['errors']['branch_code'][0].toString()
                                            : null;
                                    nameError =
                                        resp['errors']?['branch_name'] != null
                                            ? resp['errors']['branch_name'][0].toString()
                                            : null;
                                  });
                                } catch (_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _primaryColor,
          fontWeight: FontWeight.w500,
        ),
        errorText: errorText,
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 15, right: 10),
          child: Icon(icon, color: _primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _accentColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _accentColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      ),
      validator: validator,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> _openEditDialog(
    BranchProvider provider,
    BranchEntity branch,
  ) async {
    final _formKey = GlobalKey<FormState>();
    int? companyId = branch.companyId;
    final codeCtrl = TextEditingController(text: branch.branchCode);
    final nameCtrl = TextEditingController(text: branch.branchName);
    final phoneCtrl = TextEditingController(text: branch.contactPhoneNumber);
    final emailCtrl = TextEditingController(text: branch.contactEmail);
    final addressCtrl = TextEditingController(text: branch.branchAddress);
    bool isMainBranch = branch.isMainBranch;
    String? codeError;
    String? nameError;

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, _lightColor.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _secondaryColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'Edit Branch',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(
                              controller: codeCtrl,
                              label: 'Branch Code',
                              icon: Icons.qr_code,
                              errorText: codeError,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Branch code is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: nameCtrl,
                              label: 'Branch Name',
                              icon: Icons.storefront,
                              errorText: nameError,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Branch name is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    _lightColor.withOpacity(0.1)
                                  ],
                                ),
                                border: Border.all(
                                  color: _accentColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButtonFormField<int?>(
                                  isExpanded: true,
                                  value: companyId,
                                  decoration: InputDecoration(
                                    labelText: 'Company',
                                    labelStyle: TextStyle(
                                      color: _primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    icon: Icon(
                                      Icons.business,
                                      color: _primaryColor,
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  items: provider.companies.map((c) {
                                    return DropdownMenuItem<int?>(
                                      value: c['id'] as int?,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          c['company_name'] ??
                                              c['name'] ??
                                              c['title'] ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) => setState(() => companyId = v),
                                  validator: (v) =>
                                      v == null ? 'Please select company' : null,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: phoneCtrl,
                              label: 'Contact Phone',
                              icon: Icons.phone_iphone,
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Phone number is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: emailCtrl,
                              label: 'Contact Email',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Email is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              controller: addressCtrl,
                              label: 'Branch Address',
                              icon: Icons.location_pin,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Address is required'
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _lightColor.withOpacity(0.3),
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _accentColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _secondaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.star_rate_rounded,
                                        color: _secondaryColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    const Expanded(
                                      child: Text(
                                        'Main Branch',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 1.3,
                                      child: Switch(
                                        value: isMainBranch,
                                        onChanged: (v) =>
                                            setState(() => isMainBranch = v),
                                        activeColor: _secondaryColor,
                                        activeTrackColor: _lightColor,
                                        thumbColor: MaterialStateProperty.all(Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: _primaryColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_secondaryColor, _primaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _secondaryColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(_formKey.currentState?.validate() ?? false)) return;
                            final body = {
                              'branch_code': codeCtrl.text.trim(),
                              'branch_name': nameCtrl.text.trim(),
                              'company_id': companyId,
                              'contact_phone_number': phoneCtrl.text.trim(),
                              'contact_email': emailCtrl.text.trim(),
                              'branch_address': addressCtrl.text.trim(),
                              'is_main_branch': isMainBranch ? 1 : 0,
                            };
                            try {
                              await provider.updateBranch(branch.id, body);
                              Navigator.pop(context);
                            } catch (e) {
                              if (e is Exception) {
                                try {
                                  final Map<String, dynamic> resp =
                                      (e as dynamic).errors ?? {};
                                  setState(() {
                                    codeError =
                                        resp['errors']?['branch_code'] != null
                                            ? resp['errors']['branch_code'][0].toString()
                                            : null;
                                    nameError =
                                        resp['errors']?['branch_name'] != null
                                            ? resp['errors']['branch_name'][0].toString()
                                            : null;
                                  });
                                } catch (_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
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
      ),
    );
  }

  Future<void> _openViewDetailsDialog(
    BranchProvider provider,
    BranchEntity branch,
  ) async {
    final company = provider.companies.firstWhere(
      (c) => c['id'] == branch.companyId,
      orElse: () => {},
    );

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, _lightColor.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _secondaryColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Branch Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (branch.isMainBranch)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 18),
                            const SizedBox(width: 5),
                            Text(
                              'Main Branch',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branch Code Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryColor.withOpacity(0.1), _secondaryColor.withOpacity(0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _accentColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.qr_code, color: _primaryColor, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Code: ${branch.branchCode}',
                            style: TextStyle(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Branch Name
                    Text(
                      branch.branchName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Company Name
                    if (company.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.business, color: _primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            company['company_name'] ??
                                company['name'] ??
                                company['title'] ??
                                'Unknown Company',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 25),

                    // Contact Details
                    _buildDetailItem(
                      icon: Icons.phone,
                      title: 'Contact Phone',
                      value: branch.contactPhoneNumber,
                      color: _primaryColor,
                    ),
                    const SizedBox(height: 15),

                    _buildDetailItem(
                      icon: Icons.email,
                      title: 'Contact Email',
                      value: branch.contactEmail,
                      color: _secondaryColor,
                    ),
                    const SizedBox(height: 15),

                    _buildDetailItem(
                      icon: Icons.location_on,
                      title: 'Branch Address',
                      value: branch.branchAddress,
                      color: _accentColor,
                      multiLine: true,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: _secondaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
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
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool multiLine = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: multiLine ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BranchProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _lightColor.withOpacity(0.05),
          body: CustomScrollView(
            slivers: [
              // App Bar with gradient
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 0.9],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: _lightColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Branch Management',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${provider.branches.length} Branches',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _openCreateDialog(provider),
                      tooltip: 'Add New Branch',
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      tooltip: 'View Stats',
                      icon: const Icon(Icons.analytics, color: Colors.white),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/branches/stats'),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            _lightColor.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search branches by name or code...',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primaryColor, _secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: _accentColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: _secondaryColor,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.search('');
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: _accentColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: PopupMenuButton<int?>(
                                  tooltip: 'Filters',
                                  icon: Icon(
                                    Icons.filter_alt,
                                    color: _primaryColor,
                                    size: 22,
                                  ),
                                  offset: const Offset(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      enabled: false,
                                      child: Container(
                                        width: 280,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              _lightColor.withOpacity(0.2),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.filter_list_alt,
                                                  color: _primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Filters',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: _primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'Company',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: _primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _accentColor,
                                                  width: 1.5,
                                                ),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    _lightColor.withOpacity(0.1)
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                ),
                                                child: DropdownButton<int?>(
                                                  isExpanded: true,
                                                  value: provider.companyFilter,
                                                  underline: const SizedBox(),
                                                  items: [
                                                    DropdownMenuItem<int?>(
                                                      value: null,
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(vertical: 10),
                                                        child: Text(
                                                          'All Companies',
                                                          style: TextStyle(
                                                            color: _secondaryColor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ...provider.companies.map(
                                                      (c) => DropdownMenuItem<int?>(
                                                        value: c['id'] as int?,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                  vertical: 10),
                                                          child: Text(
                                                            c['company_name'] ??
                                                                c['name'] ??
                                                                c['title'] ??
                                                                '',
                                                            style: const TextStyle(
                                                              color: Colors.black87,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (v) {
                                                    Navigator.pop(context);
                                                    _applyFilters(
                                                      provider,
                                                      v,
                                                      provider.isMainFilter,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _lightColor.withOpacity(0.2),
                                                    Colors.white,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: _accentColor,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.star_rate_rounded,
                                                    color: _secondaryColor,
                                                    size: 24,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      'Main Branch Only',
                                                      style: TextStyle(
                                                        color: _primaryColor,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Transform.scale(
                                                    scale: 1,
                                                    child: Switch(
                                                      value: provider
                                                              .isMainFilter ??
                                                          false,
                                                      onChanged: (v) {
                                                        Navigator.pop(context);
                                                        _applyFilters(
                                                          provider,
                                                          provider.companyFilter,
                                                          v == true ? true : null,
                                                        );
                                                      },
                                                      activeColor: _secondaryColor,
                                                      activeTrackColor: _lightColor,
                                                      thumbColor:
                                                          MaterialStateProperty.all(
                                                              Colors.white),
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
                            ],
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 0,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onSubmitted: (q) => provider.search(q),
                      ),
                    ),
                  ),
                ),
              ),
              // Branch List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, idx) {
                    if (idx >= provider.branches.length) {
                      provider.loadNextPage();
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: _secondaryColor,
                              backgroundColor: _lightColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      );
                    }

                    final b = provider.branches[idx];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            b.isMainBranch
                                ? _secondaryColor.withOpacity(0.08)
                                : _lightColor.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(b.isMainBranch ? 0.15 : 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.05),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: b.isMainBranch
                              ? _secondaryColor.withOpacity(0.3)
                              : _accentColor.withOpacity(0.2),
                          width: b.isMainBranch ? 2 : 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openViewDetailsDialog(provider, b),
                          borderRadius: BorderRadius.circular(20),
                          splashColor: _accentColor.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Avatar with gradient
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: b.isMainBranch
                                          ? [_secondaryColor, _primaryColor]
                                          : [_primaryColor, _accentColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      b.branchCode.substring(0, 2).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Branch Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              b.branchName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (b.isMainBranch)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _secondaryColor,
                                                    _primaryColor,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        _secondaryColor.withOpacity(0.3),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellow[100],
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Main',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Code: ${b.branchCode}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (b.contactPhoneNumber.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              size: 16,
                                              color: _primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                b.contactPhoneNumber,
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (b.contactEmail.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.email_outlined,
                                                size: 16,
                                                color: _secondaryColor,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  b.contactEmail,
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Action Menu
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color: _primaryColor,
                                    size: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  onSelected: (v) async {
                                    if (v == 'view') {
                                      return _openViewDetailsDialog(provider, b);
                                    }
                                    if (v == 'edit') return _openEditDialog(provider, b);
                                    if (v == 'delete') {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  _lightColor.withOpacity(0.3)
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius: BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      _secondaryColor.withOpacity(0.2),
                                                  blurRadius: 30,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [_primaryColor, _secondaryColor],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(25),
                                                      topRight: Radius.circular(25),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.white.withOpacity(0.2),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.warning,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      const Expanded(
                                                        child: Text(
                                                          'Confirm Delete',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 22,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(25),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 80,
                                                        height: 80,
                                                        decoration: BoxDecoration(
                                                          color: Colors.red.withOpacity(0.1),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.red.withOpacity(0.3),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red,
                                                          size: 40,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 20),
                                                      const Text(
                                                        'Are you sure you want to delete this branch?',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.black87,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        b.branchName,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: _primaryColor,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        'This action cannot be undone.',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[600],
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 25,
                                                    vertical: 15,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: const BorderRadius.only(
                                                      bottomLeft: Radius.circular(25),
                                                      bottomRight: Radius.circular(25),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.1),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () =>
                                                              Navigator.pop(c, false),
                                                          style: OutlinedButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 16,
                                                            ),
                                                            side: BorderSide(
                                                              color: _primaryColor,
                                                              width: 2,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(15),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color: _primaryColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      Expanded(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.red,
                                                                Colors.redAccent,
                                                              ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(15),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.red
                                                                    .withOpacity(0.4),
                                                                blurRadius: 10,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ElevatedButton(
                                                            onPressed: () =>
                                                                Navigator.pop(c, true),
                                                            style: ElevatedButton.styleFrom(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                              backgroundColor:
                                                                  Colors.transparent,
                                                              shadowColor:
                                                                  Colors.transparent,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(15),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                                color: Colors.white,
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
                                        ),
                                      );
                                      if (ok == true) {
                                        try {
                                          await provider.deleteBranch(b.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Branch deleted successfully',
                                              ),
                                              backgroundColor: _secondaryColor,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.visibility,
                                            color: _primaryColor,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
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
                                            Icons.edit,
                                            color: _secondaryColor,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
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
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: provider.branches.length + (provider.hasMore ? 1 : 0),
                ),
              ),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondaryColor, _primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _secondaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _openCreateDialog(provider),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }
}