import '../../domain/entities/product_entity.dart';

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
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      categoryId: json['category_id'] ?? 0,
      description: json['description'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      stockQuantity: json['stock_quantity'] ?? 0,
      statusId: json['status_id'] ?? 0,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
    };
  }
}
