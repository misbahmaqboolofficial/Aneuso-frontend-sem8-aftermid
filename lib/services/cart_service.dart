import 'dart:convert';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:aneuso_app/core/utils/product_image_util.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int id;
  final int cartId;
  final int productId;
  int quantity;
  final double priceAtTime;
  final DateTime createdAt;
  final String productName;
  final String productCode;
  final double currentPrice;
  final int stockQuantity;
  final List<String> imageUrls;
  final String categoryName;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.priceAtTime,
    required this.createdAt,
    required this.productName,
    required this.productCode,
    required this.currentPrice,
    required this.stockQuantity,
    required this.imageUrls,
    required this.categoryName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['image_urls'] != null) {
      try {
        if (json['image_urls'] is String) {
          final parsed = jsonDecode(json['image_urls']);
          if (parsed is List) {
            images = List<String>.from(parsed);
          }
        } else if (json['image_urls'] is List) {
          images = List<String>.from(json['image_urls']);
        }
      } catch (e) {
        images = [];
      }
    }

    return CartItem(
      id: json['id'] ?? 0,
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      priceAtTime:
          double.tryParse(json['price_at_time']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      currentPrice:
          double.tryParse(json['current_price']?.toString() ?? '0') ?? 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrls: resolveProductImages(images),
      categoryName: json['category_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }

  double get totalPrice => priceAtTime * quantity;
}

class Cart {
  final int id;
  final int userId;
  final int? sessionId;
  final int statusId;
  final DateTime createdAt;
  final List<CartItem> items;
  final Map<String, dynamic> totals;

  Cart({
    required this.id,
    required this.userId,
    this.sessionId,
    required this.statusId,
    required this.createdAt,
    required this.items,
    required this.totals,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    }

    return Cart(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sessionId: json['session_id'],
      statusId: json['status_id'] ?? 1,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      items: items,
      totals: json['totals'] ?? {'subtotal': 0, 'items': 0},
    );
  }

  double get subtotal => double.tryParse(totals['subtotal']?.toString() ?? '0') ?? 0.0;
  int get totalItems => totals['items'] ?? 0;
}

class CartService {
  static const String baseUrl = '${AppConstants.baseUrl}/cart';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Cart?> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Cart.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  static Future<bool> createCart() async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating cart: $e');
      return false;
    }
  }

  static Future<CartItem?> addToCart(
    int productId,
    int quantity, {
    int? specialOfferId,
  }) async {
    try {
      final token = await _getToken();
      var cart = await getCart();

      if (token == null) return null;
      if (cart == null) {
        await createCart();
        cart = await getCart();
      }
      if (cart == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/cart/${cart.id}/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
          if (specialOfferId != null) 'special_offer_id': specialOfferId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final data = jsonResponse['data'];
          if (data != null && data is Map<String, dynamic>) {
            return CartItem.fromJson(data);
          }
          return null;
        }
      }
      print('Add to cart failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
  }

  /// Adds every product in a bundle offer with offer pricing applied.
  static Future<bool> addBundleOfferToCart({
    required int specialOfferId,
    required List<Map<String, dynamic>> products,
    int quantityEach = 1,
  }) async {
    for (final product in products) {
      final rawId = product['id'] ?? product['product_id'];
      final productId = rawId is int ? rawId : int.tryParse('$rawId');
      if (productId == null || productId <= 0) return false;

      final added = await addToCart(
        productId,
        quantityEach,
        specialOfferId: specialOfferId,
      );
      if (added == null) return false;
    }
    return true;
  }

  static Future<bool> updateCartItem(int itemId, int quantity) async {
    try {
      final token = await _getToken();
      final cart = await getCart();

      if (token == null || cart == null) return false;

      final response = await http.put(
        Uri.parse('$baseUrl/cart/${cart.id}/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating cart item: $e');
      return false;
    }
  }

  static Future<bool> removeCartItem(int itemId) async {
    try {
      final token = await _getToken();
      final cart = await getCart();

      if (token == null || cart == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/${cart.id}/items/$itemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error removing cart item: $e');
      return false;
    }
  }

  static Future<bool> clearCart() async {
    try {
      final token = await _getToken();
      final cart = await getCart();

      if (token == null || cart == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/${cart.id}/clear'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      }
      print('Clear cart failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  static Future<bool> deleteCart(int cartId) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$cartId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting cart: $e');
      return false;
    }
  }

  // Add these methods to CartService class
  static Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders/types/payment-methods'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final List data = jsonResponse['data'] ?? [];
          return data.map((item) => PaymentMethod.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> checkout({
    required int paymentMethodId,
    String? notes,
    String? deliveryAddress,
  }) async {
    try {
      final token = await _getToken();
      final cart = await getCart();

      if (token == null || cart == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'cart_id': cart.id,
          'payment_method_id': paymentMethodId,
          'notes': notes,
          // 'delivery_address': deliveryAddress,
          'shipping_address': deliveryAddress,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return jsonDecode(response.body);
    } catch (e) {
      print('Error during checkout: $e');
      return null;
    }
  }
}

class PaymentMethod {
  final int id;
  final String name;
  final String typeName;
  final DateTime createdAt;
  final int? groupId;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.typeName,
    required this.createdAt,
    this.groupId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      typeName: json['type_name'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      groupId: json['group_id'],
    );
  }

  String get displayName {
    switch (typeName) {
      case 'method_bank_transfer':
        return 'Bank Transfer';
      case 'method_cash':
        return 'Cash';
      case 'method_cheque':
        return 'Cheque';
      default:
        return name.replaceAll('method_', '').replaceAll('_', ' ').titleCase;
    }
  }
}

class CheckoutSummary {
  final double subtotal;
  final int totalItems;
  final double? tax;
  final double? shipping;
  final double total;

  CheckoutSummary({
    required this.subtotal,
    required this.totalItems,
    this.tax = 0.0,
    this.shipping = 0.0,
    required this.total,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      totalItems: json['total_items'] ?? 0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      shipping: double.tryParse(json['shipping']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'total_items': totalItems,
      'tax': tax,
      'shipping': shipping,
      'total': total,
    };
  }
}

extension StringExtension on String {
  String get titleCase {
    if (length <= 1) return toUpperCase();
    return split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
