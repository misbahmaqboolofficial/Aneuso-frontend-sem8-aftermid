//  — search // <name> button|card|drawer item|dashboard card
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import '../../../data/models/special_offer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../services/special_offer_service.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import '../../../core/constants/stock_availability.dart';
import '../../../core/utils/offer_bundle_util.dart';
import '../../../core/utils/product_image_util.dart';
import '../../../core/utils/form_validators.dart';
import '../../../services/product_service.dart';
import '../../widgets/bundle_offer_image_strip.dart';

final String _kScreenTitle = ScreenTitle.fromFile('offer_form_screen.dart');

class OfferFormScreen extends StatefulWidget {
  final SpecialOfferModel? offer;
  const OfferFormScreen({super.key, this.offer});

  @override
  State<OfferFormScreen> createState() => _OfferFormScreenState();
}

class _OfferFormScreenState extends State<OfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SpecialOfferService _offerService = SpecialOfferService();
  final ProductService _productService = ProductService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;
  late TextEditingController _originalPriceController;
  late TextEditingController _discountedPriceController;
  late TextEditingController _imageUrlController;

  List<int> _selectedProductIds = [];
  final Map<int, TextEditingController> _perProductDiscountControllers = {};
  bool _isBundleMode = false;
  List<ProductModel> _products = [];
  bool _isLoadingProducts = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _syncingSingleEditPrices = false;
  int _offerAvailabilityId = OfferAvailability.available;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.offer != null;
  bool get _isEditingBundle =>
      _isEditing && isBundleOffer(widget.offer!);
  bool get _isEditingSingleOffer => _isEditing && !_isEditingBundle;

  // Modern Color Palette
  final Color primaryColor = const Color(0xFF450693);
  final Color accentColor = const Color(0xFF9B5DE0);
  final Color lightColor = const Color(0xFFD78FEE);
  final Color bgColor = const Color(0xFFFDCFFA);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.offer?.title);
    _descriptionController = TextEditingController(text: widget.offer?.description);
    _discountController = TextEditingController(text: widget.offer?.discountPercentage?.toString());
    _originalPriceController = TextEditingController(text: widget.offer?.originalPrice?.toString());
    _discountedPriceController = TextEditingController(text: widget.offer?.discountedPrice?.toString());
    _imageUrlController = TextEditingController(text: widget.offer?.imageUrl);
    if (widget.offer?.productsData != null) {
      final parsed = parseOfferProductsData(widget.offer!.productsData);
      if (parsed != null) {
        _selectedProductIds = parsed
            .map((p) => (p['id'] as num).toInt())
            .toList();
      }
    } else if (widget.offer?.productId != null) {
      _selectedProductIds = [widget.offer!.productId!];
    }
    if (_isEditingBundle) {
      _isBundleMode = true;
    }
    _offerAvailabilityId = widget.offer?.statusId ?? OfferAvailability.available;
    _startDate = widget.offer?.startDate ?? DateTime.now();
    _endDate = widget.offer?.endDate;

    _loadProducts();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _imageUrlController.dispose();
    for (final controller in _perProductDiscountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _discountControllerFor(int productId) {
    return _perProductDiscountControllers.putIfAbsent(
      productId,
      () => TextEditingController(),
    );
  }

  double? _effectiveDiscountForProduct(int productId) {
    final rowText = _discountControllerFor(productId).text.trim();
    if (rowText.isNotEmpty) {
      return double.tryParse(rowText);
    }
    return double.tryParse(_discountController.text.trim());
  }

  void _syncBulkDiscountToSelected() {
    final pct = _discountController.text.trim();
    for (final id in _selectedProductIds) {
      _discountControllerFor(id).text = pct;
    }
  }

  void _onBulkDiscountChanged(String _) {
    setState(_syncBulkDiscountToSelected);
  }

  void _toggleProductSelection(ProductModel product, bool selected) {
    final id = product.id;
    if (id == null) return;
    setState(() {
      if (selected) {
        if (!_selectedProductIds.contains(id)) {
          _selectedProductIds.add(id);
        }
        final rowController = _discountControllerFor(id);
        if (rowController.text.trim().isEmpty && _discountController.text.trim().isNotEmpty) {
          rowController.text = _discountController.text.trim();
        }
      } else {
        _selectedProductIds.remove(id);
      }
      if (_selectedProductIds.length > 3 && _imageUrlController.text.startsWith('[')) {
        _imageUrlController.clear();
      }
      _updatePrices();
    });
  }

  Future<void> _loadProducts() async {
    try {
      await Future.delayed(Duration.zero); // Wait for initState to complete
      if (!mounted) return;
      setState(() => _isLoadingProducts = true);
      final provider = Provider.of<AdminProductProvider>(context, listen: false);
      if (provider.products.isEmpty) {
        await provider.loadProducts();
      }
      if (!mounted) return;
      setState(() {
        _products = provider.products;
        for (final p in _products) {
          final id = p.id;
          if (id == null) continue;
          final existing = widget.offer?.discountPercentage;
          final initial = _selectedProductIds.contains(id) && existing != null
              ? existing.toString()
              : '';
          _perProductDiscountControllers.putIfAbsent(
            id,
            () => TextEditingController(text: initial),
          );
        }
        _isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint('Error loading products: ');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  void _updatePrices() {
    double totalOriginal = 0;
    for (int id in _selectedProductIds) {
      final p = _products.firstWhere((e) => e.id == id);
      totalOriginal += p.price ?? 0;
    }
    _originalPriceController.text = totalOriginal.toStringAsFixed(2);
    
    final discountPct = double.tryParse(_discountController.text) ?? 0.0;
    if (discountPct >= 0 && discountPct <= 100) {
      final newPrice = totalOriginal - (totalOriginal * (discountPct / 100));
      _discountedPriceController.text = newPrice.toStringAsFixed(2);
    }
    setState(() {});
  }

  void _insertOriginalImages() {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select products first.')));
      return;
    }
    final List<String> urls = [];
    for (final id in _selectedProductIds.take(3)) {
      final p = _products.firstWhere((e) => e.id == id);
      if (p.images.isNotEmpty) {
        urls.add(p.images.first);
      }
    }
    if (urls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected products have no images.')));
      return;
    }
    _imageUrlController.text = jsonEncode(urls);
    setState(() {});
  }

  void _onOriginalPriceChanged(String val) {
    final origPrice = double.tryParse(val);
    if (origPrice == null || origPrice <= 0) return;

    if (_discountController.text.isNotEmpty) {
      final discountPct = double.tryParse(_discountController.text);
      if (discountPct != null && discountPct >= 0 && discountPct <= 100) {
        final newPrice = origPrice - (origPrice * (discountPct / 100));
        _discountedPriceController.text = newPrice.toStringAsFixed(newPrice % 1 == 0 ? 0 : 2);
      }
    } else if (_discountedPriceController.text.isNotEmpty) {
      final newPrice = double.tryParse(_discountedPriceController.text);
      if (newPrice != null && newPrice > 0 && newPrice <= origPrice) {
        final diff = origPrice - newPrice;
        final pct = (diff / origPrice) * 100;
        _discountController.text = pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1);
      }
    }
  }

  void _onDiscountedPriceChanged(String val) {
    final origPrice = double.tryParse(_originalPriceController.text);
    if (origPrice == null || origPrice <= 0) return;

    final newPrice = double.tryParse(val);
    if (newPrice == null || newPrice <= 0) return;

    if (newPrice > origPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discounted price cannot be higher than the original price.')),
      );
      setState(() {});
      return;
    }

    final diff = origPrice - newPrice;
    final pct = (diff / origPrice) * 100;
    _discountController.text = pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1);
    setState(() {});
  }

  String _formatOfferPrice(double value) {
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
  }

  void _onSingleEditDiscountChanged(String val) {
    if (_syncingSingleEditPrices) return;
    final origPrice = widget.offer?.originalPrice ?? 0.0;
    if (origPrice <= 0) {
      setState(() {});
      return;
    }
    final parsed = double.tryParse(val.trim());
    if (parsed == null || parsed < 0 || parsed > 100) {
      setState(() {});
      return;
    }
    _syncingSingleEditPrices = true;
    final sale = origPrice - (origPrice * (parsed / 100));
    _discountedPriceController.text = _formatOfferPrice(sale);
    _syncingSingleEditPrices = false;
    setState(() {});
  }

  void _onSingleEditSalePriceChanged(String val) {
    if (_syncingSingleEditPrices) return;
    final origPrice = widget.offer?.originalPrice ?? 0.0;
    if (origPrice <= 0) {
      setState(() {});
      return;
    }
    final sale = double.tryParse(val.trim());
    if (sale == null || sale <= 0) {
      setState(() {});
      return;
    }
    if (sale > origPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale price cannot be higher than the original price.')),
      );
      setState(() {});
      return;
    }
    _syncingSingleEditPrices = true;
    final pct = ((origPrice - sale) / origPrice) * 100;
    _discountController.text = pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1);
    _syncingSingleEditPrices = false;
    setState(() {});
  }

  String? _validateSingleEditSalePrice(String? value, double origPrice) {
    if (value == null || value.trim().isEmpty) {
      return 'Sale price is required';
    }
    if (RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Only numbers are allowed';
    }
    if (parsed <= 0) {
      return 'Sale price must be greater than 0';
    }
    if (parsed > origPrice) {
      return 'Sale price cannot exceed original price';
    }
    return null;
  }

  void _onDiscountPercentageChanged(String val) {
    final parsed = double.tryParse(val);
    if (val.isNotEmpty && parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only numbers are allowed')),
      );
      return;
    }
    if (parsed != null && parsed > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount must be between 0 and 100')),
      );
      _discountController.text = '100';
      _discountController.selection = const TextSelection.collapsed(offset: 3);
    }
    _updatePrices();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditingSingleOffer) {
      final offer = widget.offer!;
      final origPrice = offer.originalPrice ?? 0.0;
      final salePrice = double.tryParse(_discountedPriceController.text.trim());
      if (salePrice == null || salePrice <= 0 || salePrice > origPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid sale price (greater than 0 and not above original price).')),
        );
        return;
      }
      final discountPct = origPrice > 0 ? ((origPrice - salePrice) / origPrice) * 100 : 0.0;
      if (_endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select the last day of sale.')));
        return;
      }

      setState(() => _isLoading = true);
      try {
        final productLabel = offer.productName ?? 'Item';

        await _offerService.updateOffer(offer.id!, {
          'product_id': offer.productId,
          'title': '${discountPct % 1 == 0 ? discountPct.toStringAsFixed(0) : discountPct.toStringAsFixed(1)}% OFF on $productLabel',
          'description': offer.description,
          'discount_percentage': discountPct,
          'original_price': origPrice,
          'discounted_price': salePrice,
          'image_url': offer.imageUrl,
          'start_date': _startDate?.toIso8601String(),
          'end_date': _endDate?.toIso8601String(),
          'status_id': _offerAvailabilityId,
        });

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
      return;
    }

    if (_isBundleMode && _imageUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a Banner Image.')));
      return;
    }
    if (_isBundleMode && _selectedProductIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 products to create a bundle offer.')),
      );
      return;
    }
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one product.')));
      return;
    }
    if (!_isBundleMode) {
      for (final id in _selectedProductIds) {
        final p = _products.firstWhere((e) => e.id == id);
        final discountPct = _effectiveDiscountForProduct(id);
        if (discountPct == null || discountPct < 0 || discountPct > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only numbers are allowed. Enter a valid discount (0–100%) for ${p.productName ?? 'selected product'}.',
              ),
            ),
          );
          return;
        }
      }
    }
    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select the last day of sale.')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      if (_isBundleMode) {
        final productsData = _selectedProductIds.map((id) {
          final p = _products.firstWhere((element) => element.id == id);
          final origPrice = p.price ?? 0.0;
          final discountPct = double.tryParse(_discountController.text) ?? 0.0;
          final newPrice = origPrice - (origPrice * (discountPct / 100));
          return {
            'id': p.id,
            'product_name': p.productName,
            'original_price': origPrice,
            'discounted_price': newPrice,
          };
        }).toList();

        final bundleTitle = _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'Bundle Offer (${productsData.length} items)';

        final data = {
          'product_id': _selectedProductIds.isNotEmpty ? _selectedProductIds.first : null,
          'products_data': productsData,
          'title': bundleTitle,
          'description': _descriptionController.text,
          'discount_percentage': double.tryParse(_discountController.text),
          'original_price': double.tryParse(_originalPriceController.text),
          'discounted_price': double.tryParse(_discountedPriceController.text),
          'image_url': _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          'start_date': _startDate?.toIso8601String(),
          'end_date': _endDate?.toIso8601String(),
          'status_id': _offerAvailabilityId,
        };

        if (widget.offer == null) {
          await _offerService.createOffer(data);
        } else {
          await _offerService.updateOffer(widget.offer!.id!, data);
        }
      } else {
        // Bulk Individual Mode — one offer per product, each with its own discount and product image.
        for (final id in _selectedProductIds) {
          final p = _products.firstWhere((element) => element.id == id);
          final origPrice = p.price ?? 0.0;
          final discountPct = _effectiveDiscountForProduct(id) ?? 0.0;
          final newPrice = origPrice - (origPrice * (discountPct / 100));

          final pImage = p.images.isNotEmpty ? p.images.first : null;

          final singleData = {
            'product_id': p.id,
            'title': _titleController.text.isNotEmpty
                ? _titleController.text
                : '${discountPct.toStringAsFixed(0)}% OFF on ${p.productName ?? "Item"}',
            'description': _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : 'Special discount! Grab ${p.productName ?? "this item"} before the offer ends.',
            'discount_percentage': discountPct,
            'original_price': origPrice,
            'discounted_price': newPrice,
            'image_url': pImage,
            'start_date': _startDate?.toIso8601String(),
            'end_date': _endDate?.toIso8601String(),
            'status_id': _offerAvailabilityId,
          };

          await _offerService.createOffer(singleData);
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
                                const SizedBox(height: 20),
                                if (!_isEditing) _buildModeToggle(),
                                if (_isEditingSingleOffer) ...[
                                  _buildSingleProductEditView(),
                                ] else ...[
                                if (_isBundleMode) ...[
                                  _buildGlassContainer(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionTitle('Basic Information', Icons.info_outline),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _titleController,
                                          label: 'Offer Title',
                                          hint: 'e.g., Summer Fertilizer Sale',
                                          icon: Icons.title_rounded,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _descriptionController,
                                          label: 'Description',
                                          hint: 'Tell users about this amazing deal...',
                                          icon: Icons.description_outlined,
                                          maxLines: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                _buildGlassContainer(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Product & Pricing', Icons.sell_outlined),
                                      const SizedBox(height: 16),
                                      _buildProductSelection(),
                                      if (!_isBundleMode) ...[
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _discountController,
                                          label: 'Discount % for all selected',
                                          hint: 'e.g. 40',
                                          icon: Icons.percent_rounded,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          suffix: '%',
                                          inputFormatters: FormValidators.percentInputFormatters,
                                          validator: FormValidators.discountPercent,
                                          onChanged: _onBulkDiscountChanged,
                                        ),
                                        if (_selectedProductIds.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            '${_selectedProductIds.length} product(s) selected — discount applies automatically when you launch.',
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                        const SizedBox(height: 24),
                                        _buildOfferAvailabilitySelector(),
                                      ],
                                      if (_isBundleMode) ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _originalPriceController,
                                                label: 'Total Original Price',
                                                hint: '0.00',
                                                icon: Icons.money_off_rounded,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                prefix: r'Rs. ',
                                                readOnly: true,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _discountedPriceController,
                                                label: 'New Price',
                                                hint: '0.00',
                                                icon: Icons.attach_money_rounded,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                prefix: r'Rs. ',
                                                onChanged: _onDiscountedPriceChanged,
                                                validator: (v) {
                                                  if (v == null || v.isEmpty) return 'Required';
                                                  final parsed = double.tryParse(v);
                                                  if (parsed == null) return 'Invalid number';
                                                  if (parsed <= 0) return 'Must be > 0';
                                                  if (_originalPriceController.text.isNotEmpty) {
                                                    final orig = double.tryParse(_originalPriceController.text);
                                                    if (orig != null && parsed >= orig) {
                                                      return 'Must be < Original';
                                                    }
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildTextField(
                                          controller: _discountController,
                                          label: 'Discount Percentage (%)',
                                          hint: '0',
                                          icon: Icons.percent_rounded,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          suffix: '%',
                                          inputFormatters: FormValidators.percentInputFormatters,
                                          validator: FormValidators.discountPercent,
                                          onChanged: _onDiscountPercentageChanged,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildGlassContainer(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle('Visibility & Duration', Icons.event_available_outlined),
                                      const SizedBox(height: 16),
                                      if (_isBundleMode) ...[
                                        _buildTextField(
                                          controller: _imageUrlController,
                                          label: 'Banner Image',
                                          hint: 'Choose file or enter URL...',
                                          icon: Icons.image_outlined,
                                          readOnly: true,
                                          onTap: _pickAndUploadImage,
                                          suffixIcon: _isUploadingImage
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(12.0),
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                )
                                              : IconButton(
                                                  icon: Icon(Icons.folder_open_rounded, color: accentColor),
                                                  onPressed: _pickAndUploadImage,
                                                ),
                                        ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: _selectedProductIds.isEmpty ? null : _insertOriginalImages,
                                            icon: const Icon(Icons.dashboard_customize_rounded),
                                            label: const Text('Insert Original Product Images (Max 3)'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: accentColor,
                                              side: BorderSide(color: accentColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        if (_imageUrlController.text.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: BundleOfferImageStrip(
                                              imageUrl: _imageUrlController.text,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              backgroundColor: Colors.grey[100],
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 16),
                                      ],
                                      if (_isBundleMode) ...[
                                        _buildOfferAvailabilitySelector(),
                                        const SizedBox(height: 16),
                                      ],
                                      _buildDatePicker(),
                                    ],
                                  ),
                                ),
                                ],
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

  Widget _buildModeToggle() {
    if (_isEditing) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBundleMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isBundleMode ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Bulk Individual Discount',
                    style: GoogleFonts.poppins(
                      color: !_isBundleMode ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isBundleMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isBundleMode ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Make a Bundle',
                    style: GoogleFonts.poppins(
                      color: _isBundleMode ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lightColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: accentColor,
          ),
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
    String? prefix,
    String? suffix,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixText: prefix,
            suffixText: suffix,
            prefixIcon: Icon(icon, color: accentColor, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: bgColor.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: lightColor.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: accentColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferAvailabilitySelector() {
    final isInStock = _offerAvailabilityId == OfferAvailability.available;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Status',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _offerAvailabilityId = OfferAvailability.available),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isInStock ? accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: isInStock ? Colors.white : accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'In Stock',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isInStock ? Colors.white : accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _offerAvailabilityId = OfferAvailability.outOfStock),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isInStock ? Colors.orange.shade700 : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_shopping_cart_outlined,
                          size: 18,
                          color: !isInStock ? Colors.white : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Out of Stock',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !isInStock ? Colors.white : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleProductEditView() {
    final offer = widget.offer!;
    final imageUrl = resolveProductImageUrl(offer.imageUrl);
    final origPrice = offer.originalPrice ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Product', Icons.inventory_2_outlined),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductThumbnail(imageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.productName ?? 'Product',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        if (offer.productCode != null && offer.productCode!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            offer.productCode!,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Original price: Rs. ${origPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _discountController,
                label: 'Discount Percentage (%)',
                hint: 'e.g. 40',
                icon: Icons.percent_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                suffix: '%',
                inputFormatters: FormValidators.percentInputFormatters,
                onChanged: _onSingleEditDiscountChanged,
                validator: FormValidators.discountPercent,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _discountedPriceController,
                label: 'Sale Price',
                hint: 'e.g. 1000',
                icon: Icons.sell_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefix: r'Rs. ',
                inputFormatters: FormValidators.percentInputFormatters,
                onChanged: _onSingleEditSalePriceChanged,
                validator: (v) => _validateSingleEditSalePrice(v, origPrice),
              ),
              const SizedBox(height: 8),
              Text(
                'Edit either the discount % or sale price — the other updates automatically.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildOfferAvailabilitySelector(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildGlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Visibility & Duration', Icons.event_available_outlined),
              const SizedBox(height: 16),
              _buildDatePicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isBundleMode ? 'Select Products for Bundle' : 'Select Products & Set Individual Discounts',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingProducts)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 10),
                Text('Loading products...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else if (_products.isEmpty)
          Text('No products available.', style: GoogleFonts.poppins(color: Colors.grey[600]))
        else
          _buildProductTable(),
      ],
    );
  }

  Widget _buildProductTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(bgColor.withOpacity(0.35)),
        dataRowMinHeight: 64,
        dataRowMaxHeight: 72,
        columnSpacing: 16,
        columns: [
          const DataColumn(label: Text('Image')),
          const DataColumn(label: Text('Product')),
          const DataColumn(label: Text('Code')),
          const DataColumn(label: Text('Price')),
          if (!_isBundleMode) const DataColumn(label: Text('Discount %')),
          if (!_isBundleMode) const DataColumn(label: Text('Sale Price')),
        ],
        rows: _products.where((p) => p.id != null).map((p) {
          final id = p.id!;
          final isSelected = _selectedProductIds.contains(id);
          final origPrice = p.price ?? 0.0;
          final discountPct = _effectiveDiscountForProduct(id) ?? 0.0;
          final salePrice = origPrice - (origPrice * (discountPct / 100));
          final imageUrl = resolveProductImages(p.images).isNotEmpty
              ? resolveProductImages(p.images).first
              : resolveProductImageUrl(p.images.isNotEmpty ? p.images.first : null);

          return DataRow(
            selected: isSelected,
            onSelectChanged: (selected) => _toggleProductSelection(p, selected ?? false),
            cells: [
              DataCell(_buildProductThumbnail(imageUrl)),
              DataCell(
                SizedBox(
                  width: 140,
                  child: Text(
                    p.productName ?? 'Unknown',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(p.productCode, style: GoogleFonts.poppins(fontSize: 12))),
              DataCell(Text('Rs. ${origPrice.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12))),
              if (!_isBundleMode)
                DataCell(
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _discountControllerFor(id),
                      enabled: isSelected,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: FormValidators.percentInputFormatters,
                      decoration: InputDecoration(
                        hintText: '%',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              if (!_isBundleMode)
                DataCell(
                  Text(
                    isSelected ? 'Rs. ${salePrice.toStringAsFixed(0)}' : '—',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? accentColor : Colors.grey,
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductThumbnail(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        color: Colors.grey[100],
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                headers: kProductImageHeaders,
                errorBuilder: (_, __, ___) => Icon(Icons.inventory_2_outlined, color: Colors.grey[400]),
              )
            : Icon(Icons.inventory_2_outlined, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _endDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: accentColor),
            const SizedBox(width: 12),
            Text(
              _endDate == null 
                  ? 'Select Last Day of Sale' 
                  : 'Last Day of Sale: ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
              style: GoogleFonts.poppins(
                color: _endDate == null ? Colors.grey[600] : Colors.black,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // ElevatedButton button
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          widget.offer == null
              ? (_isBundleMode ? 'Launch Bundle Offer' : 'Launch Individual Offers')
              : 'Save Changes',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ), // end ElevatedButton button
    );
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

      String mimeType;
      if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else {
        mimeType = 'image/jpeg';
      }

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
          _imageUrlController.text = jsonResponse['data']['url'];
          _isUploadingImage = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Banner image uploaded successfully!')),
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
}
