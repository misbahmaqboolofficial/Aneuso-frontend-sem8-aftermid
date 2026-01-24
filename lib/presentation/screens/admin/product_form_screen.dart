import 'dart:convert';

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

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
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.baseUrl + '/product-categories'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            _categories = List<Map<String, dynamic>>.from(responseData['data']);
            if (_categories.isNotEmpty) {
              _selectedCategoryId = _selectedCategoryId <= 0
                  ? int.parse(_categories[0]['id'])
                  : _selectedCategoryId;
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProductProvider>(context);
    final error = provider.error;

    return Scaffold(
      backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
            ).createShader(bounds);
          },
          child: Text(
            _isEdit ? 'Edit Product' : 'New Product',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4E56C0).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF4E56C0),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4E56C0).withOpacity(0.9),
                      Color(0xFF9B5DE0).withOpacity(0.9),
                      Color(0xFFD78FEE).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4E56C0).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isEdit ? Icons.edit_rounded : Icons.add_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? 'Update Product' : 'Create New Product',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _isEdit
                                ? 'Modify product details below'
                                : 'Fill in the product information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Error Message
              if (error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Form Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Product Name
                      _buildStyledTextField(
                        controller: _nameCtrl,
                        label: 'Product Name',
                        icon: Icons.shopping_bag_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: 20),

                      // Product Code
                      _buildStyledTextField(
                        controller: _codeCtrl,
                        label: 'Product Code',
                        icon: Icons.code_rounded,
                      ),
                      SizedBox(height: 20),

                      // Description
                      _buildStyledTextField(
                        controller: _descriptionCtrl,
                        label: 'Description',
                        icon: Icons.description_rounded,
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),

                      // Price
                      _buildStyledTextField(
                        controller: _priceCtrl,
                        label: 'Price (Rs)',
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 20),

                      // Stock Quantity
                      _buildStyledTextField(
                        controller: _stockCtrl,
                        label: 'Stock Quantity',
                        icon: Icons.inventory_2_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 25),

                      // Category and Status Row
                      Row(
                        children: [
                          // Expanded(
                          //   child: _buildStyledDropdown(
                          //     value: _selectedCategoryId,
                          //     items: const [
                          //       DropdownMenuItem(
                          //         value: 1,
                          //         child: Text(
                          //           'Fertilizer',
                          //           style: TextStyle(color: Color(0xFF4E56C0)),
                          //         ),
                          //       ),
                          //       DropdownMenuItem(
                          //         value: 2,
                          //         child: Text(
                          //           'Pesticide',
                          //           style: TextStyle(color: Color(0xFF4E56C0)),
                          //         ),
                          //       ),
                          //       DropdownMenuItem(
                          //         value: 3,
                          //         child: Text(
                          //           'Seeds',
                          //           style: TextStyle(color: Color(0xFF4E56C0)),
                          //         ),
                          //       ),
                          //     ],
                          //     label: 'Category',
                          //     icon: Icons.category_rounded,
                          //     onChanged: (v) =>
                          //         setState(() => _selectedCategoryId = v ?? 1),
                          //   ),
                          // ),
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _buildStyledDropdown(
                                    value: _selectedCategoryId,
                                    items: _categories.map((category) {
                                      return DropdownMenuItem<int>(
                                        value: category['id'],
                                        child: Text(
                                          category['category_name'] ??
                                              'Unknown',
                                          style: const TextStyle(
                                            color: Color(0xFF4E56C0),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    label: 'Category',
                                    icon: Icons.category_rounded,
                                    onChanged: (v) => setState(
                                      () => _selectedCategoryId = v ?? 1,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: _buildStyledDropdown(
                              value: _selectedStatusId,
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    'Active',
                                    style: TextStyle(color: Color(0xFF4E56C0)),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(
                                    'Inactive',
                                    style: TextStyle(color: Color(0xFF4E56C0)),
                                  ),
                                ),
                              ],
                              label: 'Status',
                              icon: Icons.circle_rounded,
                              onChanged: (v) =>
                                  setState(() => _selectedStatusId = v ?? 1),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  setState(() => _isSubmitting = true);
                                  final body = {
                                    'product_name': _nameCtrl.text,
                                    'product_code': _codeCtrl.text,
                                    'description': _descriptionCtrl.text,
                                    'price':
                                        double.tryParse(_priceCtrl.text) ?? 0,
                                    'stock_quantity':
                                        int.tryParse(_stockCtrl.text) ?? 0,
                                    'category_id': _selectedCategoryId,
                                    'status_id': _selectedStatusId,
                                  };
                                  if (_isEdit) {
                                    final updated = await provider
                                        .updateProduct(widget.productId!, body);
                                    if (updated != null) {
                                      if (mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Product updated successfully!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      final msg =
                                          provider.error ?? 'Update failed';
                                      if (mounted)
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(msg),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                    }
                                  } else {
                                    final created = await provider
                                        .createProduct(body);
                                    if (created != null) {
                                      if (mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/admin/products',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Product created successfully!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      final msg =
                                          provider.error ?? 'Create failed';
                                      if (mounted)
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(msg),
                                            backgroundColor: Colors.red,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                    }
                                  }
                                  if (mounted)
                                    setState(() => _isSubmitting = false);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.zero,
                            disabledBackgroundColor: Colors.grey.withOpacity(
                              0.3,
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: _isSubmitting
                                  ? null
                                  : LinearGradient(
                                      colors: [
                                        Color(0xFF4E56C0),
                                        Color(0xFF9B5DE0),
                                        Color(0xFFD78FEE),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: _isSubmitting
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Color(
                                          0xFF4E56C0,
                                        ).withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _isEdit
                                              ? Icons.save_rounded
                                              : Icons.add_rounded,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          _isEdit
                                              ? 'UPDATE PRODUCT'
                                              : 'CREATE PRODUCT',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
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
              ),
              SizedBox(height: 30),

              // Info Card
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFDCFFA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xFFD78FEE).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: Color(0xFF4E56C0),
                      size: 24,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Fill in all required fields to ${_isEdit ? 'update' : 'create'} the product. Product code is optional.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4E56C0).withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4E56C0).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Color(0xFF4E56C0), fontSize: 16),
        keyboardType: keyboardType,
        maxLines: maxLines,
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
              color: Color(0xFF4E56C0).withOpacity(0.5),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red.withOpacity(0.5),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.red.withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildStyledDropdown({
    required int value,
    required List<DropdownMenuItem<int>> items,
    required String label,
    required IconData icon,
    required Function(int?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4E56C0).withOpacity(0.1),
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
              color: Color(0xFF4E56C0).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        style: TextStyle(color: Color(0xFF4E56C0), fontSize: 16),
        dropdownColor: Colors.white,
        onChanged: onChanged,
      ),
    );
  }
}
