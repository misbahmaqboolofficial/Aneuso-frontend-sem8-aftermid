class ProductEntity {
  final int id;
  final String productName;
  final String productCode;
  final int categoryId;
  final String? description;
  final double? price;
  final int stockQuantity;
  final int statusId;
  final List<String> images;

  ProductEntity({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.categoryId,
    this.description,
    this.price,
    required this.stockQuantity,
    required this.statusId,
    required this.images,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
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
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
