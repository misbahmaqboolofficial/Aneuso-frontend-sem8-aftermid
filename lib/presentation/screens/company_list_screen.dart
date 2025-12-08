import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/company_provider.dart';
import '../widgets/loading_overlay.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({Key? key}) : super(key: key);

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CompanyProvider>(context, listen: false);
      provider.fetchCompanies();
      provider.fetchTypes();
    });
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
                return AlertDialog(
                  title: const Text('Add Company'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameCtl,
                            decoration: const InputDecoration(
                              labelText: 'Company Name',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailCtl,
                            decoration: const InputDecoration(
                              labelText: 'Contact Email',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: phoneCtl,
                            decoration: const InputDecoration(
                              labelText: 'Contact Phone',
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: addressCtl,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Company Type Dropdown
                          DropdownButtonFormField<int>(
                            value: selectedCompanyTypeId,
                            items: provider.companyTypes
                                .map(
                                  (t) => DropdownMenuItem<int>(
                                    value: t.id,
                                    child: Text(t.typeName),
                                  ),
                                )
                                .toList(),
                            decoration: const InputDecoration(
                              labelText: 'Company Type',
                            ),
                            onChanged: (v) =>
                                setState(() => selectedCompanyTypeId = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          // Business Type Dropdown
                          DropdownButtonFormField<int>(
                            value: selectedBusinessTypeId,
                            items: provider.businessTypes
                                .map(
                                  (t) => DropdownMenuItem<int>(
                                    value: t.id,
                                    child: Text(t.typeName),
                                  ),
                                )
                                .toList(),
                            decoration: const InputDecoration(
                              labelText: 'Business Type',
                            ),
                            onChanged: (v) =>
                                setState(() => selectedBusinessTypeId = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          // Waste Type Dropdown
                          DropdownButtonFormField<int>(
                            value: selectedWasteTypeId,
                            items: provider.wasteTypes
                                .map(
                                  (t) => DropdownMenuItem<int>(
                                    value: t.id,
                                    child: Text(t.typeName),
                                  ),
                                )
                                .toList(),
                            decoration: const InputDecoration(
                              labelText: 'Waste Type',
                            ),
                            onChanged: (v) =>
                                setState(() => selectedWasteTypeId = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        body['company_name'] = nameCtl.text.trim();
                        body['contact_email'] = emailCtl.text.trim();
                        body['contact_phone_number'] = phoneCtl.text.trim();
                        body['company_address'] = addressCtl.text.trim();
                        body['is_headquarter'] = true;

                        body['company_type_id'] = selectedCompanyTypeId ?? 1;
                        body['business_type_id'] = selectedBusinessTypeId ?? 1;
                        body['waste_type'] = (selectedWasteTypeId != null)
                            ? provider.wasteTypes
                                  .firstWhere(
                                    (w) => w.id == selectedWasteTypeId,
                                  )
                                  .typeName
                            : '';

                        final created = await Provider.of<CompanyProvider>(
                          context,
                          listen: false,
                        ).createCompany(body);
                        if (created && mounted) {
                          Navigator.pop(context);
                        } else {
                          // error handled by provider
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search companies...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {
                Provider.of<CompanyProvider>(
                  context,
                  listen: false,
                ).search(value.trim());
              },
            ),
          ),
        ),
      ),
      body: Consumer<CompanyProvider>(
        builder: (context, provider, child) {
          return LoadingOverlay(
            isLoading: provider.isLoading && provider.companies.isEmpty,
            child: RefreshIndicator(
              onRefresh: () => provider.fetchCompanies(page: 1),
              child: provider.companies.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: Center(
                            child: provider.error != null
                                ? Text(provider.error!)
                                : const Text('No companies found'),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount:
                          provider.companies.length +
                          (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= provider.companies.length) {
                          // Load more button
                          if (provider.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16,
                            ),
                            child: ElevatedButton(
                              onPressed: () => provider.loadNextPage(),
                              child: const Text('Load more'),
                            ),
                          );
                        }

                        final c = provider.companies[index];
                        return ListTile(
                          title: Text(c.companyName),
                          subtitle: Text(
                            '${c.contactEmail} • ${c.contactPhoneNumber}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                      'Are you sure you want to delete this company?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await provider.deleteCompany(c.id);
                                }
                              } else if (value == 'view') {
                                // show details
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(c.companyName),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Email: ${c.contactEmail}'),
                                        Text('Phone: ${c.contactPhoneNumber}'),
                                        Text('Address: ${c.companyAddress}'),
                                        Text('Waste: ${c.wasteType}'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (value == 'edit') {
                                // show edit dialog prefilled
                                final _formKey = GlobalKey<FormState>();
                                final nameCtl = TextEditingController(
                                  text: c.companyName,
                                );
                                final emailCtl = TextEditingController(
                                  text: c.contactEmail,
                                );
                                final phoneCtl = TextEditingController(
                                  text: c.contactPhoneNumber,
                                );
                                final addressCtl = TextEditingController(
                                  text: c.companyAddress,
                                );

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
                                        return AlertDialog(
                                          title: const Text('Edit Company'),
                                          content: SingleChildScrollView(
                                            child: Form(
                                              key: _formKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextFormField(
                                                    controller: nameCtl,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Company Name',
                                                        ),
                                                    validator: (v) =>
                                                        (v == null || v.isEmpty)
                                                        ? 'Required'
                                                        : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextFormField(
                                                    controller: emailCtl,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Contact Email',
                                                        ),
                                                    validator: (v) =>
                                                        (v == null || v.isEmpty)
                                                        ? 'Required'
                                                        : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextFormField(
                                                    controller: phoneCtl,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Contact Phone',
                                                        ),
                                                    validator: (v) =>
                                                        (v == null || v.isEmpty)
                                                        ? 'Required'
                                                        : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  TextFormField(
                                                    controller: addressCtl,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Address',
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  DropdownButtonFormField<int>(
                                                    value:
                                                        selectedCompanyTypeId,
                                                    items: provider.companyTypes
                                                        .map(
                                                          (t) =>
                                                              DropdownMenuItem<
                                                                int
                                                              >(
                                                                value: t.id,
                                                                child: Text(
                                                                  t.typeName,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Company Type',
                                                        ),
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          selectedCompanyTypeId =
                                                              v,
                                                    ),
                                                    validator: (v) => v == null
                                                        ? 'Required'
                                                        : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  DropdownButtonFormField<int>(
                                                    value:
                                                        selectedBusinessTypeId,
                                                    items: provider
                                                        .businessTypes
                                                        .map(
                                                          (t) =>
                                                              DropdownMenuItem<
                                                                int
                                                              >(
                                                                value: t.id,
                                                                child: Text(
                                                                  t.typeName,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Business Type',
                                                        ),
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          selectedBusinessTypeId =
                                                              v,
                                                    ),
                                                    validator: (v) => v == null
                                                        ? 'Required'
                                                        : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  DropdownButtonFormField<int>(
                                                    value: selectedWasteTypeId,
                                                    items: provider.wasteTypes
                                                        .map(
                                                          (t) =>
                                                              DropdownMenuItem<
                                                                int
                                                              >(
                                                                value: t.id,
                                                                child: Text(
                                                                  t.typeName,
                                                                ),
                                                              ),
                                                        )
                                                        .toList(),
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Waste Type',
                                                        ),
                                                    onChanged: (v) => setState(
                                                      () =>
                                                          selectedWasteTypeId =
                                                              v,
                                                    ),
                                                    validator: (v) => v == null
                                                        ? 'Required'
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (!_formKey.currentState!
                                                    .validate())
                                                  return;
                                                final Map<String, dynamic>
                                                body = {
                                                  'company_name': nameCtl.text
                                                      .trim(),
                                                  'contact_email': emailCtl.text
                                                      .trim(),
                                                  'contact_phone_number':
                                                      phoneCtl.text.trim(),
                                                  'company_address': addressCtl
                                                      .text
                                                      .trim(),
                                                  'is_headquarter': true,
                                                  'company_type_id':
                                                      selectedCompanyTypeId ??
                                                      c.companyTypeId,
                                                  'business_type_id':
                                                      selectedBusinessTypeId ??
                                                      c.businessTypeId,
                                                  'waste_type':
                                                      selectedWasteTypeId !=
                                                          null
                                                      ? provider.wasteTypes
                                                            .firstWhere(
                                                              (w) =>
                                                                  w.id ==
                                                                  selectedWasteTypeId,
                                                            )
                                                            .typeName
                                                      : c.wasteType,
                                                };

                                                final updated =
                                                    await Provider.of<
                                                          CompanyProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        )
                                                        .updateCompany(
                                                          c.id,
                                                          body,
                                                        );
                                                if (updated && mounted) {
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Company updated',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Update'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Text('View'),
                              ),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
