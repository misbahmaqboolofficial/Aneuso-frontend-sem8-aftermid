import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/special_offer_model.dart';
import '../../../services/special_offer_service.dart';
import '../../../services/cart_service.dart';
import '../../widgets/bundle_offer_image_strip.dart';
import 'cart_screen.dart';
import 'package:aneuso_app/core/utils/offer_bundle_util.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/constants/stock_availability.dart';

final String _kScreenTitle = ScreenTitle.fromFile('offer_details_screen.dart');

class OfferDetailsScreen extends StatefulWidget {
  final int offerId;
  const OfferDetailsScreen({super.key, required this.offerId});

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  final SpecialOfferService _offerService = SpecialOfferService();
  SpecialOfferModel? _offer;
  bool _isLoading = true;
  Duration _timeLeft = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadOffer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadOffer() async {
    try {
      final offer = await _offerService.getOfferById(widget.offerId);
      setState(() {
        _offer = offer;
        _isLoading = false;
        if (offer.endDate != null) {
          _startTimer();
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_offer?.endDate == null) return;
      final now = DateTime.now();
      final diff = _offer!.endDate!.difference(now);
      if (diff.isNegative) {
        timer.cancel();
        setState(() => _timeLeft = Duration.zero);
      } else {
        setState(() => _timeLeft = diff);
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Future<void> _addToCart({bool goToCart = true}) async {
    if (OfferAvailability.isOutOfStock(_offer?.statusId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This offer is currently out of stock.')),
      );
      return;
    }
    final products = parseOfferProductsData(_offer?.productsData);
    final isBundle = products != null && products.length >= 2;
    if (_offer?.productId == null && !isBundle) return;
    if (_offer?.id == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      bool success;
      if (isBundle && products != null) {
        success = await CartService.addBundleOfferToCart(
          specialOfferId: _offer!.id!,
          products: products.cast<Map<String, dynamic>>(),
        );
      } else {
        final added = await CartService.addToCart(
          _offer!.productId!,
          1,
          specialOfferId: _offer!.id,
        );
        success = added != null;
      }

      if (!mounted) return;
      Navigator.pop(context);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not add offer to cart. Check stock and try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (goToCart) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
        return;
      }

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isBundle
                  ? 'Bundle added to cart with special offer prices!'
                  : 'Added to cart with special offer price!',
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_offer == null) {
      return const Scaffold(body: Center(child: Text('Offer not found')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_kScreenTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),
                  const SizedBox(height: 24),
                  _buildCountdownTimer(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildPriceSection(),
                  _buildBundleProducts(),
                  const SizedBox(height: 100), // space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: 'offer_${_offer!.id}',
      child: _offer!.imageUrl != null && _offer!.imageUrl!.trim().isNotEmpty
          ? BundleOfferImageStrip(
              imageUrl: _offer!.imageUrl,
              height: 350,
              fit: BoxFit.contain,
              backgroundColor: Colors.grey[200],
              placeholder: const Center(
                child: Icon(Icons.shopping_bag_outlined, size: 100, color: Color(0xFF9B5DE0)),
              ),
            )
          : Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Icon(Icons.shopping_bag_outlined, size: 100, color: Color(0xFF9B5DE0)),
            ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _offer!.title,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_offer!.discountPercentage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_offer!.discountPercentage?.toInt()}% OFF',
                  style: GoogleFonts.poppins(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        if (_offer!.productName != null || isBundleOffer(_offer!)) ...[
          const SizedBox(height: 8),
          Text(
            isBundleOffer(_offer!)
                ? 'Bundle Offer: ${bundleItemCount(_offer!)} Items'
                : 'For: ${_offer!.productName ?? ""}',
            style: GoogleFonts.poppins(
              color: const Color(0xFF6F38C5),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBundleProducts() {
    final products = parseOfferProductsData(_offer?.productsData);
    if (products == null || products.length < 2) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Products in this bundle',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...products.map((p) {
          final orig = double.tryParse(p['original_price'].toString()) ?? 0;
          final disc = double.tryParse(p['discounted_price'].toString()) ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p['product_name'] ?? '',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${orig.toStringAsFixed(0)}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Rs. ${disc.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6F38C5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    if (_timeLeft.isNegative || _timeLeft == Duration.zero) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: Colors.amber[900]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OFFER ENDS IN',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[900],
                ),
              ),
              Text(
                _formatDuration(_timeLeft),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this offer',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _offer!.description ?? 'No detailed description provided for this special promotion.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_offer!.originalPrice != null)
              Text(
                'Rs. ${_offer!.originalPrice?.toStringAsFixed(2)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
            Text(
              'Rs. ${_offer!.discountedPrice?.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6F38C5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    final outOfStock = OfferAvailability.isOutOfStock(_offer?.statusId);
    final isBundle = isBundleOffer(_offer!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBundle && !outOfStock)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'All ${bundleItemCount(_offer!)} items will be added with bundle discount pricing.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: outOfStock ? null : () => _addToCart(goToCart: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: outOfStock ? Colors.grey : const Color(0xFF6F38C5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    outOfStock
                        ? Icons.remove_shopping_cart_outlined
                        : Icons.shopping_cart_checkout_outlined,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    outOfStock
                        ? 'Out of Stock'
                        : isBundle
                            ? 'Add Bundle & Go to Cart'
                            : 'Add to Cart & Checkout',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
