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
      builder: (ctx) => AlertDialog(
        title: const Text('Create Branch'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Branch Code',
                        errorText: codeError,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Branch code is required'
                          : null,
                    ),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Branch Name',
                        errorText: nameError,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Branch name is required'
                          : null,
                    ),
                    DropdownButtonFormField<int?>(
                      isExpanded: true,
                      value: companyId,
                      decoration: const InputDecoration(labelText: 'Company'),
                      items: provider.companies.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c['id'] as int?,
                          child: Text(
                            c['company_name'] ?? c['name'] ?? c['title'] ?? '',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => companyId = v),
                      validator: (v) =>
                          v == null ? 'Please select company' : null,
                    ),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Phone number is required'
                          : null,
                    ),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Email is required'
                          : null,
                    ),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Branch Address',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Address is required'
                          : null,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isMainBranch,
                          onChanged: (v) =>
                              setState(() => isMainBranch = v ?? false),
                        ),
                        const Text('Is Main Branch'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                      codeError = resp['errors']?['branch_code'] != null
                          ? resp['errors']['branch_code'][0].toString()
                          : null;
                      nameError = resp['errors']?['branch_name'] != null
                          ? resp['errors']['branch_name'][0].toString()
                          : null;
                    });
                  } catch (_) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
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
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Branch'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeCtrl,
                      decoration: InputDecoration(
                        labelText: 'Branch Code',
                        errorText: codeError,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Branch code is required'
                          : null,
                    ),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Branch Name',
                        errorText: nameError,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Branch name is required'
                          : null,
                    ),
                    DropdownButtonFormField<int?>(
                      isExpanded: true,
                      value: companyId,
                      decoration: const InputDecoration(labelText: 'Company'),
                      items: provider.companies.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c['id'] as int?,
                          child: Text(
                            c['company_name'] ?? c['name'] ?? c['title'] ?? '',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => companyId = v),
                      validator: (v) =>
                          v == null ? 'Please select company' : null,
                    ),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Phone number is required'
                          : null,
                    ),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Email is required'
                          : null,
                    ),
                    TextFormField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Branch Address',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Address is required'
                          : null,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isMainBranch,
                          onChanged: (v) =>
                              setState(() => isMainBranch = v ?? false),
                        ),
                        const Text('Is Main Branch'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                      codeError = resp['errors']?['branch_code'] != null
                          ? resp['errors']['branch_code'][0].toString()
                          : null;
                      nameError = resp['errors']?['branch_name'] != null
                          ? resp['errors']['branch_name'][0].toString()
                          : null;
                    });
                  } catch (_) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Save'),
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
          appBar: AppBar(
            title: const Text('Branch Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _openCreateDialog(provider),
              ),
              IconButton(
                tooltip: 'View Stats',
                icon: const Icon(Icons.bar_chart),
                onPressed: () =>
                    Navigator.pushNamed(context, '/branches/stats'),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search branches...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.search('');
                          },
                        ),
                        PopupMenuButton<int?>(
                          tooltip: 'Filters',
                          icon: const Icon(Icons.filter_list),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              enabled: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Company'),
                                  DropdownButton<int?>(
                                    isExpanded: true,
                                    value: provider.companyFilter,
                                    items: [
                                      const DropdownMenuItem<int?>(
                                        value: null,
                                        child: Text('All'),
                                      ),
                                      ...provider.companies.map(
                                        (c) => DropdownMenuItem<int?>(
                                          value: c['id'] as int?,
                                          child: Text(
                                            c['company_name'] ??
                                                c['name'] ??
                                                c['title'] ??
                                                '',
                                            style: const TextStyle(
                                              color: Colors.black,
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
                                  Row(
                                    children: [
                                      const Text('Main branch only'),
                                      Checkbox(
                                        value: provider.isMainFilter ?? false,
                                        onChanged: (v) {
                                          Navigator.pop(context);
                                          _applyFilters(
                                            provider,
                                            provider.companyFilter,
                                            v == true ? true : null,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (q) => provider.search(q),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.fetchBranches(refresh: true),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        provider.branches.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (ctx, idx) {
                      if (idx >= provider.branches.length) {
                        // load more
                        provider.loadNextPage();
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final b = provider.branches[idx];
                      return ListTile(
                        title: Text(b.branchName),
                        subtitle: Text(b.branchCode),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit')
                              return _openEditDialog(provider, b);
                            if (v == 'delete') {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Branch'),
                                  content: const Text(
                                    'Are you sure to delete this branch?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('No'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  await provider.deleteBranch(b.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Deleted')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
