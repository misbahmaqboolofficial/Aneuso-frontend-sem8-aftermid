import 'dart:convert';

import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/form_validators.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aneuso_app/core/utils/storage_util.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/constants/stock_availability.dart';
import 'package:aneuso_app/core/utils/product_image_util.dart';
import 'package:aneuso_app/data/models/product_model.dart';
import 'package:aneuso_app/services/product_service.dart';

final String _kScreenTitle = ScreenTitle.fromFile('product_form_screen.dart');

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
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;
  bool _isUploadingImage = false;


  bool _isEdit = false;
  bool _isSubmitting = false;
  int _selectedCategoryId = 1;
  int _selectedStatusId = 1;
  int? _stockBeforeOutOfStock;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _categoriesLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _isEdit = true;
      _isLoading = true;
      _loadProduct(widget.productId!);
    }
    _fetchCategories();
  }

  void _populateForm(ProductModel p) {
    _nameCtrl.text = p.productName;
    _codeCtrl.text = p.productCode;
    _descriptionCtrl.text = p.description ?? '';
    _priceCtrl.text = p.price?.toString() ?? '';
    _stockCtrl.text = p.stockQuantity.toString();
    _selectedCategoryId = p.categoryId;
    _selectedStatusId = p.statusId;
    if (p.images.isNotEmpty) {
      _imageUrl = p.images.first;
    }
  }

  Future<void> _loadProduct(int id) async {
    try {
      final product = await ProductService().getProductById(id);
      if (!mounted) return;
      setState(() {
        _populateForm(product);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product: $e')),
      );
    }
  }

  void _onAvailabilityChanged(int? value) {
    final next = value ?? ProductAvailability.inStock;
    setState(() {
      if (next == ProductAvailability.outOfStock) {
        _stockBeforeOutOfStock = int.tryParse(_stockCtrl.text.trim());
        _stockCtrl.text = '0';
      } else if (_selectedStatusId == ProductAvailability.outOfStock &&
          next == ProductAvailability.inStock) {
        final restore = (_stockBeforeOutOfStock != null && _stockBeforeOutOfStock! > 0)
            ? _stockBeforeOutOfStock!
            : 1;
        _stockCtrl.text = restore.toString();
      }
      _selectedStatusId = next;
    });
  }

  int? _resolvedStockQuantity() {
    if (_selectedStatusId == ProductAvailability.outOfStock) {
      return 0;
    }
    return int.tryParse(_stockCtrl.text.trim());
  }

  String? _validateStockQuantity(String? value) {
    if (_selectedStatusId == ProductAvailability.outOfStock) {
      return null;
    }
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) {
      return 'Only numbers are allowed';
    }
    if (_selectedStatusId == ProductAvailability.inStock && parsed <= 0) {
      return 'In-stock products need stock greater than 0';
    }
    if (parsed < 0) {
      return 'Stock cannot be negative';
    }
    return null;
  }


  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      final imageBytes = await image.readAsBytes();
      final fileName = image.name;
      final extension = fileName.split('.').last.toLowerCase();

      String mimeType = 'image/jpeg';
      if (extension == 'png') mimeType = 'image/png';
      else if (extension == 'gif') mimeType = 'image/gif';

      final token = StorageUtil.getToken();
      final uploadUrl = Uri.parse('${AppConstants.baseUrl}/upload');

      var request = http.MultipartRequest('POST', uploadUrl);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      var multipartFile = http.MultipartFile.fromBytes(
        'photo',
        imageBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        setState(() {
          _imageUrl = jsonResponse['data']['url']?.toString();
          _isUploadingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully!')),
          );
        }
      } else {
        throw Exception(jsonResponse['message'] ?? 'Upload failed');
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e')),
        );
      }
    }
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
            if (_categories.isNotEmpty && !_isEdit) {
              _selectedCategoryId = _selectedCategoryId <= 0
                  ? int.parse(_categories[0]['id'])
                  : _selectedCategoryId;
            }
            _categoriesLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _categoriesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProductProvider>(context);
    final error = provider.error;

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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6F38C5)))
            : ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
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
                      Color(0xFF6F38C5).withOpacity(0.9),
                      Color(0xFF9B5DE0).withOpacity(0.9),
                      Color(0xFFD78FEE).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6F38C5).withOpacity(0.3),
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
                            FormValidators.name(v, field: 'Product name'),
                      ),
                      SizedBox(height: 20),

                      // Product Code
                      _buildStyledTextField(
                        controller: _codeCtrl,
                        label: 'Product Code',
                        icon: Icons.code_rounded,
                        validator: (v) =>
                            FormValidators.required(v, field: 'Product code'),
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
                        validator: FormValidators.price,
                      ),
                      SizedBox(height: 20),

                      // Stock Quantity
                      _buildStyledTextField(
                        key: ValueKey('stock-field-$_selectedStatusId'),
                        controller: _stockCtrl,
                        label: 'Stock Quantity',
                        icon: Icons.inventory_2_rounded,
                        keyboardType: TextInputType.number,
                        readOnly: _selectedStatusId == ProductAvailability.outOfStock,
                        inputFormatters: FormValidators.percentInputFormatters,
                        validator: _validateStockQuantity,
                      ),
                      SizedBox(height: 25),

                      // Product Image
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          border: Border.all(color: _imageUrl == null ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6F38C5).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Image *',
                              style: TextStyle(
                                color: const Color(0xFF9B5DE0).withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_imageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildImagePreview(_imageUrl!),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                                icon: _isUploadingImage 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.cloud_upload_outlined),
                                label: Text(_imageUrl == null ? 'Upload Image' : 'Change Image'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6F38C5),
                                  side: const BorderSide(color: Color(0xFF6F38C5)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _imageUrl ?? '',
                              decoration: InputDecoration(
                                labelText: 'Paste Image URL (e.g., from Google)',
                                prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF6F38C5)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFF6F38C5), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _imageUrl = val.isEmpty ? null : val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      // Category and Availability
                      _categoriesLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildStyledDropdown(
                              value: _selectedCategoryId,
                              items: _categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category['id'],
                                  child: Text(
                                    category['category_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Color(0xFF6F38C5),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              label: 'Category',
                              icon: Icons.category_rounded,
                              onChanged: (v) => setState(
                                () => _selectedCategoryId = v ?? 1,
                              ),
                            ),
                      const SizedBox(height: 15),
                      _buildStyledDropdown(
                        value: _selectedStatusId,
                        items: const [
                          DropdownMenuItem(
                            value: ProductAvailability.inStock,
                            child: Text(
                              'In Stock',
                              style: TextStyle(color: Color(0xFF6F38C5)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ProductAvailability.outOfStock,
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(color: Color(0xFF6F38C5)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ProductAvailability.inactive,
                            child: Text(
                              'Inactive',
                              style: TextStyle(color: Color(0xFF6F38C5)),
                            ),
                          ),
                        ],
                        label: 'Availability',
                        icon: Icons.circle_rounded,
                        onChanged: _onAvailabilityChanged,
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
                                  if (_imageUrl == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please upload a product image.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _isSubmitting = true);
                                  final stockQty = _resolvedStockQuantity();
                                  if (stockQty == null) {
                                    setState(() => _isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Enter a valid stock quantity.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  final body = {
                                    'product_name': _nameCtrl.text,
                                    'product_code': _codeCtrl.text,
                                    'description': _descriptionCtrl.text,
                                    'price':
                                        double.tryParse(_priceCtrl.text) ?? 0,
                                    'stock_quantity': stockQty,
                                    'category_id': _selectedCategoryId,
                                    'status_id': _selectedStatusId,
                                    'image_urls': [_imageUrl],
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
                                        Color(0xFF6F38C5),
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
                                          0xFF6F38C5,
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
                      color: Color(0xFF6F38C5),
                      size: 24,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Fill in all required fields to ${_isEdit ? 'update' : 'create'} the product. Product code is optional.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6F38C5).withOpacity(0.8),
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
    );
  }

  Widget _buildImagePreview(String rawUrl) {
    final resolved = resolveProductImageUrl(rawUrl);
    if (resolved == null) {
      return Container(
        height: 120,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
    return Image.network(
      resolved,
      height: 120,
      width: double.infinity,
      fit: BoxFit.contain,
      headers: kProductImageHeaders,
      errorBuilder: (c, e, s) => Container(
        height: 120,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      ),
    );
  }

  Widget _buildStyledTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      key: key,
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
        readOnly: readOnly,
        style: TextStyle(color: Color(0xFF6F38C5), fontSize: 16),
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
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
            color: Color(0xFF6F38C5).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: DropdownButtonFormField<int>(
        value: value,
        isExpanded: true,
        isDense: true,
        items: items,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF9B5DE0).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Color(0xFF9B5DE0)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
      ),
    );
  }
}
