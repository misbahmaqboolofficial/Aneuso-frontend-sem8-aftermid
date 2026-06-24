import 'dart:convert';

import '../../data/models/special_offer_model.dart';

List<dynamic>? parseOfferProductsData(dynamic raw) {
  if (raw == null) return null;
  dynamic decoded = raw;
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    try {
      decoded = jsonDecode(trimmed);
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }
    } catch (_) {
      return null;
    }
  }
  if (decoded is List) return decoded;
  return null;
}

bool isBundleOffer(SpecialOfferModel offer) {
  final products = parseOfferProductsData(offer.productsData);
  if (products != null && products.length >= 2) return true;

  final image = offer.imageUrl?.trim() ?? '';
  if (image.startsWith('[')) {
    try {
      final decoded = jsonDecode(image);
      if (decoded is List && decoded.length >= 2) return true;
    } catch (_) {}
  }

  return false;
}

int bundleItemCount(SpecialOfferModel offer) {
  final products = parseOfferProductsData(offer.productsData);
  if (products != null && products.isNotEmpty) return products.length;

  final image = offer.imageUrl?.trim() ?? '';
  if (image.startsWith('[')) {
    try {
      final decoded = jsonDecode(image);
      if (decoded is List) return decoded.length;
    } catch (_) {}
  }

  return offer.productId != null ? 1 : 0;
}
