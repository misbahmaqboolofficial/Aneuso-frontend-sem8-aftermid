import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/special_offer_model.dart';
import '../../../services/special_offer_service.dart';
import '../../widgets/bundle_offer_image_strip.dart';
import 'offer_details_screen.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';
import 'package:aneuso_app/core/utils/offer_bundle_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('special_offers_screen.dart');

class SpecialOffersScreen extends StatefulWidget {
  const SpecialOffersScreen({super.key});

  @override
  State<SpecialOffersScreen> createState() => _SpecialOffersScreenState();
}

class _SpecialOffersScreenState extends State<SpecialOffersScreen> {
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
    try {
      final offers = await _offerService.getOffers(isActive: true);
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
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF450693),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF450693),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF450693) : const Color(0xFFD78FEE).withOpacity(0.5),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _currentFilter = filter);
                  }
                },
              ),
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
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _kScreenTitle,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
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

  Widget _buildOfferCard(SpecialOfferModel offer) {
    final isBundle = isBundleOffer(offer);
    final itemCount = bundleItemCount(offer);
    final bundleTitle = isBundle 
        ? '${offer.discountPercentage?.toInt() ?? 0}% discount on these products'
        : offer.title;
    final productNameDisplay = isBundle 
        ? 'Bundle Offer: $itemCount Items' 
        : (offer.productName ?? 'Special Offer');

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetailsScreen(offerId: offer.id!),
          ),
        );
        _loadOffers();
      },
      child: Container(
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
            // Image with gradient overlay and discount badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Hero(
                    tag: 'offer_${offer.id}',
                    child: offer.imageUrl != null && offer.imageUrl!.isNotEmpty
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
                  ),
                  if (offer.discountPercentage != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                    style: const TextStyle(
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  'Rs. ${offer.discountedPrice?.toStringAsFixed(0) ?? '0'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6F38C5),
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
            
            // Card Content Info
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
                              bundleTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6F38C5),
                              ),
                            ),
                            Text(
                              productNameDisplay,
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
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9B5DE0),
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
                      const SizedBox(width: 4),
                      Text(
                        offer.endDate != null
                            ? 'Last Day of Sale: ${DateFormat('dd MMM yyyy').format(offer.endDate!)}'
                            : 'Limited Time Offer',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Color(0xFF9B5DE0)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
            'No active offers at the moment',
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
