//  — search // <name> button|card|drawer item|dashboard card
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../data/models/job_vacancy.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('jobs_list_screen.dart');

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({Key? key}) : super(key: key);

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Add job form fields
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCategoryFilter = '';
  final List<String> _categories = [
    'Tuition / Tutor',
    'Teacher / Professor',
    'Accountant / Bookkeeper',
    'IT / Software Engineer',
    'Web / Graphic Designer',
    'House Help / Maid',
    'Driver / Chauffeur',
    'Cook / Chef',
    'Office Assistant / Clerk',
    'Sales / Marketing Executive',
    'Customer Support Agent',
    'Delivery Rider / Courier',
    'Security Guard',
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Nurse / Caretaker',
    'Tailor / Dressmaker',
    'Barber / Beautician',
    'Real Estate Agent',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<JobProvider>(context, listen: false).fetchAllJobs();
    Provider.of<JobProvider>(context, listen: false).fetchMyJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _categoryController.clear();
    _descriptionController.clear();
    _salaryController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
  }

  void _showAddJobDialog() {
    String selectedDialogCategory = _categories.first;
    _categoryController.text = selectedDialogCategory;

    final List<String> countries = ['Pakistan', 'United States', 'United Kingdom', 'Canada', 'United Arab Emirates', 'Saudi Arabia', 'Australia', 'Other'];
    String selectedCountry = countries.first;

    // Prefill user contact details if available
    final authUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (authUser != null) {
      _emailController.text = authUser.email;
      _phoneController.text = authUser.phoneNumber;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: AppColors.border, width: 1.5),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMid.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work_rounded, color: AppColors.primaryMid, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Post Job Vacancy',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _dialogInputDecoration('Job Title', hint: 'e.g. Need Home Tutor'),
                          validator: (v) => FormValidators.required(v, field: 'Job title'),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: selectedDialogCategory,
                          dropdownColor: AppColors.surface,
                          iconEnabledColor: AppColors.primaryMid,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _dialogInputDecoration('Category'),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedDialogCategory = val;
                                _categoryController.text = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _dialogInputDecoration('Description', hint: 'Specify timings, requirements, etc.'),
                          validator: (v) =>
                              FormValidators.description(v, minLength: 10),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _salaryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _dialogInputDecoration('Salary / Compensation', hint: 'Numeric values only (e.g. 25000)'),
                          validator: (v) => FormValidators.positiveInt(v, field: 'Salary'),
                        ),
                        const SizedBox(height: 18),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Contact Information',
                            style: TextStyle(
                              color: AppColors.primaryMid,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _dialogInputDecoration('Contact Email', hint: 'e.g. contact@firm.com'),
                          validator: FormValidators.email,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]'))],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _dialogInputDecoration('Contact Phone', hint: 'Numeric only (e.g. 03001234567)'),
                          validator: FormValidators.phone,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          value: selectedCountry,
                          dropdownColor: AppColors.surface,
                          iconEnabledColor: AppColors.primaryMid,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _dialogInputDecoration('Country'),
                          items: countries.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCountry = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _dialogInputDecoration('Location / Address', hint: 'e.g. Phase 5, DHA'),
                          validator: FormValidators.address,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // Cancel button
                TextButton(
                  onPressed: () {
                    _clearForm();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.primaryMid,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ), // end Cancel button
                // Post Vacancy button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A39E1),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF8A39E1).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await Provider.of<JobProvider>(context, listen: false).createJob({
                        'title': _titleController.text.trim(),
                        'category': _categoryController.text.trim(),
                        'description': _descriptionController.text.trim(),
                        'salary': _salaryController.text.trim(),
                        'contact_email': _emailController.text.trim(),
                        'contact_phone': _phoneController.text.trim(),
                        'contact_address': '${_addressController.text.trim()}, $selectedCountry',
                      });
                      if (success) {
                        _clearForm();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job vacancy posted successfully!'),
                            backgroundColor: Color(0xFF6F38C5),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Post Vacancy', style: TextStyle(fontWeight: FontWeight.bold)),
                ), // end Post Vacancy button
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primaryMid),
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85)),
      filled: true,
      fillColor: AppColors.scaffold,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryMid, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFD78FEE)),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFF6F38C5).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFF6F38C5).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8A39E1), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBE0FF),
              Colors.white,
            ],
            stops: [0.0, 0.45],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Gorgeous Glassmorphic Header
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: const Color(0xFFEBE0FF).withOpacity(0.85),
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _kScreenTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900, 
                    color: Colors.white, 
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF450693), Color(0xFF8A39E1)],
                        ),
                      ),
                    ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A39E1), Color(0xFFA555EC)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A39E1).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                  onPressed: _showAddJobDialog,
                ),
                const SizedBox(width: 16),
              ],
            ),
            
            // Search Bar & Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  children: [
                    // Glassmorphic Search Input
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search roles, accountant, tutor...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFD78FEE)),
                          suffixIcon: _searchController.text.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white60),
                                  onPressed: () {
                                    _searchController.clear();
                                    jobProvider.fetchAllJobs(category: _selectedCategoryFilter);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20), 
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20), 
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Color(0xFFA555EC), width: 1.5),
                          ),
                        ),
                        onSubmitted: (val) {
                          jobProvider.fetchAllJobs(category: _selectedCategoryFilter, search: val);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Categories horizontal slider
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1,
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final category = isAll ? 'All Categories' : _categories[index - 1];
                          final isSelected = isAll 
                              ? _selectedCategoryFilter.isEmpty 
                              : _selectedCategoryFilter == category;
 
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            // ChoiceChip button
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategoryFilter = isAll ? '' : category;
                                });
                                jobProvider.fetchAllJobs(
                                  category: _selectedCategoryFilter,
                                  search: _searchController.text,
                                );
                              },
                              selectedColor: const Color(0xFF8A39E1),
                              backgroundColor: Colors.white.withOpacity(0.04),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFD78FEE),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected 
                                      ? const Color(0xFFA555EC) 
                                      : const Color(0xFF6F38C5).withOpacity(0.3)
                                ),
                              ),
                            ), // end ChoiceChip button
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
 
            // Premium Custom Tabs Headers
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFFD78FEE).withOpacity(0.6),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6F38C5), Color(0xFF8A39E1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A39E1).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  tabs: const [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Explore Vacancies', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dashboard_customize_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('My Job Posts', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab content
            SliverFillRemaining(
              hasScrollBody: true,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobsList(jobProvider.allJobs, isMyJobs: false, authUserId: authUser?.id),
                  _buildJobsList(jobProvider.myJobs, isMyJobs: true, authUserId: authUser?.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(List<JobVacancyModel> jobs, {required bool isMyJobs, int? authUserId}) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (jobProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFA555EC)));
    }

    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.work_off_outlined, size: 54, color: const Color(0xFFD78FEE).withOpacity(0.4)),
            ),
            const SizedBox(height: 16),
            Text(
              isMyJobs ? 'You haven\'t posted any job vacancies' : 'No job vacancies found',
              style: TextStyle(color: const Color(0xFFD78FEE).withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6F38C5).withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6F38C5).withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.pushNamed(context, '/jobs/detail', arguments: {'id': job.id}).then((_) => _loadData());
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A39E1).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF8A39E1).withOpacity(0.2)),
                          ),
                          child: Text(
                            job.category,
                            style: const TextStyle(
                              color: Color(0xFF450693), 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusIndicator(job.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    job.title,
                    style: const TextStyle(
                      color: Color(0xFF450693), 
                      fontSize: 19, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87.withOpacity(0.7), fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.wallet, size: 16, color: Color(0xFF8A39E1)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.salary != null && job.salary!.isNotEmpty ? job.salary! : 'Negotiable',
                          style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF8A39E1)),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(job.createdAt),
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  if (isMyJobs) ...[
                    const SizedBox(height: 8),
                    const Divider(color: Colors.black12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (job.status == 'active') ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6F38C5).withOpacity(0.2),
                              foregroundColor: Colors.greenAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.greenAccent.withOpacity(0.4)),
                              ),
                            ),
                            onPressed: () async {
                              final done = await jobProvider.updateJob(job.id, {'status': 'completed'});
                              if (done) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vacancy marked as Completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Mark Completed', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                        ],
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                          onPressed: () async {
                            final deleted = await jobProvider.deleteJob(job.id);
                            if (deleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vacancy removed!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color bg = const Color(0xFF8A39E1).withOpacity(0.15);
    Color fg = const Color(0xFFD78FEE);
    String text = 'Active';

    if (status == 'completed') {
      bg = Colors.green.withOpacity(0.12);
      fg = Colors.greenAccent;
      text = 'Completed';
    } else if (status == 'removed') {
      bg = Colors.red.withOpacity(0.12);
      fg = Colors.redAccent;
      text = 'Removed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
