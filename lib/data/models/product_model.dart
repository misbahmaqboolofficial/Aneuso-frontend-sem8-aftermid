import 'dart:convert';

import '../../domain/entities/product_entity.dart';
import '../../core/utils/product_image_util.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required int id,
    required String productName,
    required String productCode,
    required int categoryId,
    String? description,
    double? price,
    required int stockQuantity,
    required int statusId,
    required List<String> images,
    String? categoryName,
  }) : super(
         id: id,
         productName: productName,
         productCode: productCode,
         categoryId: categoryId,
         description: description,
         price: price,
         stockQuantity: stockQuantity,
         statusId: statusId,
         images: images,
         categoryName: categoryName,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parseImages(dynamic raw) {
      if (raw == null) return const [];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      if (raw is String && raw.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          return [raw];
        }
      }
      return const [];
    }

    final images = resolveProductImages(
      parseImages(json['image_urls'] ?? json['images']),
    );

    return ProductModel(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      categoryId: json['category_id'] ?? 0,
      description: json['description'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      stockQuantity: json['stock_quantity'] ?? 0,
      statusId: json['status_id'] ?? 0,
      images: images,
      categoryName: json['category_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'product_code': productCode,
      'category_id': categoryId,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'status_id': statusId,
      'images': images,
      if (categoryName != null) 'category_name': categoryName,
    };
  }
}
