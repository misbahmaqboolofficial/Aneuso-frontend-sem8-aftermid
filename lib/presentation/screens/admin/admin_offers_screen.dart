//  — search // <name> button|card|drawer item|dashboard card
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/special_offer_model.dart';
import '../../../services/special_offer_service.dart';
import '../../widgets/bundle_offer_image_strip.dart';
import 'offer_form_screen.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/constants/stock_availability.dart';
import 'package:aneuso_app/core/utils/offer_bundle_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('admin_offers_screen.dart');

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen> {
  final SpecialOfferService _offerService = SpecialOfferService();
  List<SpecialOfferModel> _offers = [];
  bool _isLoading = true;
  String _currentFilter = 'All'; // 'All', 'Single Items', 'Bundles'


  @override
  void initState() {
    super.initState();
    _loadOffers();
  }


  List<SpecialOfferModel> get _filteredOffers {
    if (_currentFilter == 'All') return _offers;
    return _offers.where((offer) {
      final isBundle = isBundleOffer(offer);
      if (_currentFilter == 'Single Items') return !isBundle;
      if (_currentFilter == 'Bundles') return isBundle;
      return true;
    }).toList();
  }

  Future<void> _loadOffers() async {
    setState(() => _isLoading = true);
    try {
      final offers = await _offerService.getOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
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

  Future<void> _deleteOffer(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this special offer?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ), // end Cancel button
          // Delete button
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ), // end Delete button
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _offerService.deleteOffer(id);
        _loadOffers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offer deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _toggleOfferAvailability(SpecialOfferModel offer, bool outOfStock) async {
    try {
      await _offerService.updateOffer(offer.id!, {
        'status_id': outOfStock ? OfferAvailability.outOfStock : OfferAvailability.available,
      });
      await _loadOffers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(outOfStock ? 'Offer marked out of stock' : 'Offer marked in stock')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadOffers,
        color: const Color(0xFF9B5DE0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFDCFFA),
              ],
            ),
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(),
              _buildFilterToggle(),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B5DE0)),
                    ),
                  ),
                )
              else if (_filteredOffers.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final offer = _filteredOffers[index];
                        return _buildOfferCard(offer);
                      },
                      childCount: _filteredOffers.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6F38C5).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OfferFormScreen()),
            );
            if (result == true) _loadOffers();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Create Offer',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildFilterToggle() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['All', 'Single Items', 'Bundles'].map((filter) {
            final isSelected = _currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              // ChoiceChip button
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF6F38C5),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF6F38C5),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF6F38C5) : const Color(0xFF9B5DE0).withOpacity(0.5),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _currentFilter = filter);
                  }
                },
              ), // end ChoiceChip button
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _kScreenTitle,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6F38C5),
                Color(0xFF9B5DE0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SpecialOfferModel offer) {
    final label = OfferAvailability.label(offer.statusId, offer.endDate).toUpperCase();
    final color = OfferAvailability.color(offer.statusId, offer.endDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            OfferAvailability.isOutOfStock(offer.statusId)
                ? Icons.remove_shopping_cart_outlined
                : (offer.endDate != null && offer.endDate!.isBefore(DateTime.now())
                    ? Icons.error_outline
                    : Icons.check_circle_outline),
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(SpecialOfferModel offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6F38C5).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with status badge, discount badge and price tag
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                offer.imageUrl != null && offer.imageUrl!.isNotEmpty
                    ? BundleOfferImageStrip(
                        imageUrl: offer.imageUrl,
                        height: 200,
                        backgroundColor: const Color(0xFFFDCFFA).withOpacity(0.2),
                        placeholder: const Center(
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: const Color(0xFFFDCFFA),
                        child: const Center(
                          child: Icon(Icons.local_offer, size: 50, color: Colors.grey),
                        ),
                      ),
                // Status Badge (Active/Expired)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildStatusBadge(offer),
                ),
                // Discount Percentage Badge
                if (offer.discountPercentage != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.discountPercentage?.toInt()}% OFF',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Price Tags Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (offer.originalPrice != null) ...[
                                Text(
                                  'Rs. ${offer.originalPrice!.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                'Rs. ${offer.discountedPrice?.toStringAsFixed(0) ?? '0'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6F38C5),
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
          
          // Card Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6F38C5),
                            ),
                          ),
                          Text(
                            offer.productName ?? 'General Deal',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (offer.productCode != null && offer.productCode!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDCFFA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          offer.productCode!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9B5DE0),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  offer.description ?? 'No description available',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.endDate != null
                            ? 'Last Day of Sale: ${DateFormat('dd MMM yyyy').format(offer.endDate!)}'
                            : 'Limited Time Offer',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: [
                if (OfferAvailability.isAvailable(offer.statusId))
                  TextButton.icon(
                    onPressed: () => _toggleOfferAvailability(offer, true),
                    icon: const Icon(Icons.remove_shopping_cart_outlined, size: 18, color: Colors.orange),
                    label: Text(
                      'Out of Stock',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.orange),
                    ),
                  )
                else if (OfferAvailability.isOutOfStock(offer.statusId))
                  TextButton.icon(
                    onPressed: () => _toggleOfferAvailability(offer, false),
                    icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                    label: Text(
                      'Mark In Stock',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.green),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfferFormScreen(offer: offer),
                      ),
                    );
                    if (result == true) _loadOffers();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6F38C5)),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6F38C5),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _deleteOffer(offer.id!),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: const Color(0xFF6F38C5).withOpacity(0.6),
          ),
          const SizedBox(height: 20),
          Text(
            'No special offers created yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
