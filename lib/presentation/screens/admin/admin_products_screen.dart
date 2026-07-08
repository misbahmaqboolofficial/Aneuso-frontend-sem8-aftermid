//  — search // <name> button|card|drawer item|dashboard card
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aneuso_app/presentation/providers/admin_product_provider.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/constants/stock_availability.dart';
import 'package:aneuso_app/data/models/product_model.dart';

final String _kScreenTitle = ScreenTitle.fromFile('admin_products_screen.dart');

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  late AdminProductProvider provider;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  String _searchQuery = '';

  Widget _buildStockBadge({required int statusId, required int stockQuantity, double fontSize = 14}) {
    final label = ProductAvailability.label(statusId: statusId, stockQuantity: stockQuantity);
    final color = ProductAvailability.color(statusId: statusId, stockQuantity: stockQuantity);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: fontSize <= 12 ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _setProductAvailability(ProductModel prod, bool outOfStock) async {
    final updated = await provider.updateProduct(prod.id, {
      'status_id': outOfStock ? ProductAvailability.outOfStock : ProductAvailability.inStock,
      'stock_quantity': outOfStock ? 0 : (prod.stockQuantity > 0 ? prod.stockQuantity : 1),
    });
    if (!mounted) return;
    if (updated != null) {
      _performSearch(_searchQuery);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(outOfStock ? 'Product marked out of stock' : 'Product marked in stock')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<AdminProductProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider.loadProducts();
      }
    });

    // Listen to search controller changes
    _searchController.addListener(() {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim();

      if (_searchQuery.isEmpty) {
        _filteredProducts = provider.products;
      } else {
        final searchLower = _searchQuery.toLowerCase();
        _filteredProducts = provider.products.where((product) {
          final name = product.productName.toLowerCase();
          final code = product.productCode?.toLowerCase() ?? '';
          final desc = product.description?.toLowerCase() ?? '';

          return name.contains(searchLower) ||
              code.contains(searchLower) ||
              desc.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _filteredProducts = provider.products;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    dynamic prod,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              Text(
                'Are you sure you want to delete "${prod.productName}"?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 10),
              Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    // Cancel button
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
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
                    ), // end Cancel button
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 48,
                      // Delete button
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
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
                              colors: [Colors.red, Colors.redAccent],
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
                      ), // end Delete button
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteProduct(prod.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Product deleted successfully!' : 'Delete failed',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Update filtered products after deletion
        _performSearch(_searchQuery);
      }
    }
  }

  void _showProductDetails(BuildContext context, dynamic prod) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        if (prod.images != null && prod.images.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Image.network(prod.images.first, fit: BoxFit.contain),
                                  ),
                                  Positioned(
                                    top: 40,
                                    right: 20,
                                    child: IconButton(
                                      icon: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.close, color: Colors.white, size: 24),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: (prod.images != null && prod.images.isNotEmpty)
                            ? ClipOval(
                                child: Image.network(
                                  prod.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.shopping_bag_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                      ),
                    ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      prod.productName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6F38C5),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              _buildDetailItem(
                Icons.description_rounded,
                'Description',
                prod.description ?? 'No description',
              ),
              SizedBox(height: 15),
              _buildDetailItem(
                Icons.attach_money_rounded,
                'Price',
                'Rs ${prod.price ?? 0}',
              ),
              SizedBox(height: 15),
              _buildDetailItem(
                Icons.inventory_2_rounded,
                'Stock Quantity',
                '${prod.stockQuantity ?? 0} units',
              ),
              SizedBox(height: 15),
              _buildStockBadge(statusId: prod.statusId, stockQuantity: prod.stockQuantity ?? 0),
              SizedBox(height: 25),
              Container(
                height: 48,
                width: double.infinity,
                // Close button
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
                        colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ), // end Close button
              ),
            ],
          ),
        ),
      ),
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
      body: Consumer<AdminProductProvider>(
        builder: (context, p, _) {
          // Initialize filtered products if not already done
          if (_filteredProducts.isEmpty && p.products.isNotEmpty) {
            _filteredProducts = p.products;
          }

          final displayProducts = _searchQuery.isEmpty
              ? p.products
              : _filteredProducts;
          final isSearching = _searchQuery.isNotEmpty;

          if (p.isLoading && p.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading Products...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6F38C5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  CircularProgressIndicator(color: Color(0xFF6F38C5)),
                ],
              ),
            );
          }

          if (p.error != null && p.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      p.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 48,
                    // Try Again button
                    child: ElevatedButton(
                      onPressed: () => provider.loadProducts(),
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
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Try Again',
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
                    ), // end Try Again button
                  ),
                ],
              ),
            );
          }

          if (displayProducts.isEmpty && !isSearching) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFFFDCFFA).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_rounded,
                      size: 60,
                      color: Color(0xFF9B5DE0),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Products Available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6F38C5),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Start managing your inventory by adding new products',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 48,
                    // Add First Product button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/admin/product/form');
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add First Product',
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
                    ), // end Add First Product button
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: Color(0xFF6F38C5),
            onRefresh: () async {
              await provider.loadProducts();
              _clearSearch();
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
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
                              hintText: 'Search products...',
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
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              color: Color(0xFF6F38C5),
                            ),
                            onPressed: _clearSearch,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Search Results Header
                  if (isSearching) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: Color(0xFF6F38C5),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Search Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6F38C5),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF6F38C5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${displayProducts.length} found',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6F38C5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                  ],

                  // Card card
                  // Stats Card (only show when not searching) // end Card card
                  if (!isSearching && displayProducts.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
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
                            'Total',
                            displayProducts.length.toString(),
                            Icons.inventory_2_rounded,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            'In Stock',
                            displayProducts
                                .where((prod) => ProductAvailability.isAvailable(
                                      statusId: prod.statusId,
                                      stockQuantity: prod.stockQuantity,
                                    ))
                                .length
                                .toString(),
                            Icons.check_circle_rounded,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            'Value',
                            'Rs ${displayProducts.fold(0, (sum, item) => (sum + (item.price ?? 0)).toInt())}',
                            Icons.attach_money_rounded,
                          ),
                        ],
                      ),
                    ),
                  if (!isSearching && displayProducts.isNotEmpty)
                    SizedBox(height: 20),

                  // Products List Title
                  if (!isSearching && displayProducts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 15),
                      child: Text(
                        'All Products (${displayProducts.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6F38C5),
                        ),
                      ),
                    ),

                  // No Search Results
                  if (isSearching && displayProducts.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Color(0xFFFDCFFA).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 50,
                                color: Color(0xFF9B5DE0),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'No Products Found',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6F38C5),
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                'No products found for "${_searchQuery}"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 48,
                              // Clear Search button
                              child: ElevatedButton(
                                onPressed: _clearSearch,
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xFF6F38C5).withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.clear_all_rounded,
                                          color: Color(0xFF6F38C5),
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Clear Search',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6F38C5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ), // end Clear Search button
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Products List
                  if (displayProducts.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayProducts.length,
                        itemBuilder: (context, idx) {
                          final prod = displayProducts[idx];
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
                              isThreeLine: true,
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
                                  child: (prod.images != null && prod.images.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            prod.images.first,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 12,
                                                  height: 12,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.shopping_bag_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                ),
                              title: Text(
                                prod.productName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6F38C5),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money_rounded,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          'Rs ${prod.price ?? 0}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.inventory_2_rounded,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          '${prod.stockQuantity} units',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  _buildStockBadge(
                                    statusId: prod.statusId,
                                    stockQuantity: prod.stockQuantity,
                                    fontSize: 12,
                                  ),
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  onSelected: (value) async {
                                    if (value == 'view') {
                                      _showProductDetails(context, prod);
                                    } else if (value == 'edit') {
                                      Navigator.pushNamed(
                                        context,
                                        '/admin/product/form',
                                        arguments: {'id': prod.id},
                                      );
                                    } else if (value == 'mark_oos') {
                                      await _setProductAvailability(prod, true);
                                    } else if (value == 'mark_in_stock') {
                                      await _setProductAvailability(prod, false);
                                    } else if (value == 'delete') {
                                      await _showDeleteConfirmation(
                                        context,
                                        prod,
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
                                              fontSize: 14,
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
                                              fontSize: 14,
                                              color: Color(0xFF6F38C5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (ProductAvailability.isAvailable(
                                      statusId: prod.statusId,
                                      stockQuantity: prod.stockQuantity,
                                    ))
                                      PopupMenuItem(
                                        value: 'mark_oos',
                                        child: Row(
                                          children: [
                                            Icon(Icons.remove_shopping_cart_outlined, color: Colors.orange[700], size: 20),
                                            SizedBox(width: 10),
                                            Text('Mark Out of Stock', style: TextStyle(fontSize: 14, color: Colors.orange[700])),
                                          ],
                                        ),
                                      )
                                    else
                                      PopupMenuItem(
                                        value: 'mark_in_stock',
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle_outline, color: Colors.green[700], size: 20),
                                            SizedBox(width: 10),
                                            Text('Mark In Stock', style: TextStyle(fontSize: 14, color: Colors.green[700])),
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
                                              fontSize: 14,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () => _showProductDetails(context, prod),
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
      ),
      // FloatingActionButton button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/admin/product/form');
        },
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
      ), // end FloatingActionButton button
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)),
        ),
      ],
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
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
