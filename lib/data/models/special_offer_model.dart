import 'dart:convert';

import '../../core/utils/offer_bundle_util.dart';

class SpecialOfferModel {
  final int? id;
  final int? productId;
  final List<dynamic>? productsData;
  final String title;
  final String? description;
  final double? discountPercentage;
  final double? originalPrice;
  final double? discountedPrice;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? statusId;
  final String? productName;
  final String? productCode;

  SpecialOfferModel({
    this.id,
    this.productId,
    this.productsData,
    required this.title,
    this.description,
    this.discountPercentage,
    this.originalPrice,
    this.discountedPrice,
    this.imageUrl,
    this.startDate,
    this.endDate,
    this.statusId,
    this.productName,
    this.productCode,
  });

  factory SpecialOfferModel.fromJson(Map<String, dynamic> json) {
    return SpecialOfferModel(
      id: json['id'],
      productId: json['product_id'],
      productsData: parseOfferProductsData(json['products_data']),
      title: json['title'] ?? '',
      description: json['description'],
      discountPercentage: json['discount_percentage'] != null ? double.parse(json['discount_percentage'].toString()) : null,
      originalPrice: json['original_price'] != null ? double.parse(json['original_price'].toString()) : null,
      discountedPrice: json['discounted_price'] != null ? double.parse(json['discounted_price'].toString()) : null,
      imageUrl: json['image_url'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      statusId: json['status_id'],
      productName: json['product_name'],
      productCode: json['product_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'products_data': productsData,
      'title': title,
      'description': description,
      'discount_percentage': discountPercentage,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'image_url': imageUrl,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status_id': statusId,
    };
  }
}
