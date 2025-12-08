import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final int? productId;
  const ProductFormScreen({Key? key, this.productId}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  bool _isEdit = false;
  bool _isSubmitting = false;
  int _selectedCategoryId = 1;
  int _selectedStatusId = 1;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdminProductProvider>(context, listen: false);
    if (widget.productId != null) {
      _isEdit = true;
      final p = provider.products.firstWhere((e) => e.id == widget.productId);
      _nameCtrl.text = p.productName;
      _codeCtrl.text = p.productCode;
      _descriptionCtrl.text = p.description ?? '';
      _priceCtrl.text = p.price?.toString() ?? '';
      _stockCtrl.text = p.stockQuantity.toString();
      _selectedCategoryId = p.categoryId;
      _selectedStatusId = p.statusId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProductProvider>(context);
    final error = provider.error;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Product' : 'New Product')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                if (error != null) ...[
                  Text(error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Fertilizer')),
                          DropdownMenuItem(value: 2, child: Text('Pesticide')),
                          DropdownMenuItem(value: 3, child: Text('Seeds')),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v ?? 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedStatusId,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Active')),
                          DropdownMenuItem(value: 0, child: Text('Inactive')),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedStatusId = v ?? 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _isSubmitting = true);
                          final body = {
                            'product_name': _nameCtrl.text,
                            'product_code': _codeCtrl.text,
                            'description': _descriptionCtrl.text,
                            'price': double.tryParse(_priceCtrl.text) ?? 0,
                            'stock_quantity':
                                int.tryParse(_stockCtrl.text) ?? 0,
                            'category_id': _selectedCategoryId,
                            'status_id': _selectedStatusId,
                          };
                          if (_isEdit) {
                            final updated = await provider.updateProduct(
                              widget.productId!,
                              body,
                            );
                            if (updated != null) {
                              if (mounted) Navigator.pop(context);
                            } else {
                              final msg = provider.error ?? 'Update failed';
                              if (mounted)
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg)));
                            }
                          } else {
                            final created = await provider.createProduct(body);
                            if (created != null) {
                              if (mounted) Navigator.pop(context);
                            } else {
                              final msg = provider.error ?? 'Create failed';
                              if (mounted)
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(msg)));
                            }
                          }
                          if (mounted) setState(() => _isSubmitting = false);
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
