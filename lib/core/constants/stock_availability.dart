import 'package:flutter/material.dart';

/// Product availability uses `products.status_id`.
class ProductAvailability {
  static const int inStock = 1;
  static const int inactive = 2;
  static const int outOfStock = 3;

  static bool isOutOfStock({required int statusId, required int stockQuantity}) {
    if (statusId == outOfStock) return true;
    if (statusId == inactive) return false;
    return stockQuantity <= 0;
  }

  static bool isAvailable({required int statusId, required int stockQuantity}) {
    return statusId == inStock && stockQuantity > 0;
  }

  static String label({required int statusId, required int stockQuantity}) {
    if (statusId == inactive) return 'Inactive';
    if (isOutOfStock(statusId: statusId, stockQuantity: stockQuantity)) {
      return 'Out of Stock';
    }
    return 'In Stock';
  }

  static Color color({required int statusId, required int stockQuantity}) {
    if (statusId == inactive) return Colors.grey;
    if (isOutOfStock(statusId: statusId, stockQuantity: stockQuantity)) {
      return Colors.red;
    }
    return Colors.green;
  }
}

/// Offer availability uses `special_offers.status_id`.
class OfferAvailability {
  static const int available = 1;
  static const int outOfStock = 2;

  static bool isOutOfStock(int? statusId) => statusId == outOfStock;

  static bool isAvailable(int? statusId) =>
      statusId == null || statusId == available;

  static String label(int? statusId, DateTime? endDate) {
    if (isOutOfStock(statusId)) return 'Out of Stock';
    if (endDate != null && endDate.isBefore(DateTime.now())) return 'Expired';
    return 'Active';
  }

  static Color color(int? statusId, DateTime? endDate) {
    if (isOutOfStock(statusId)) return Colors.orange;
    if (endDate != null && endDate.isBefore(DateTime.now())) return Colors.red;
    return Colors.green;
  }
}
