import 'dart:convert';
import 'package:aneuso_app/core/constants/app_constants.dart';
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
          double.tryParse(json['price_at_time']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
      currentPrice:
          double.tryParse(json['current_price']?.toString() ?? '0') ?? 0,
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrls: images,
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

  double get subtotal => totals['subtotal'] ?? 0;
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

  static Future<CartItem?> addToCart(int productId, int quantity) async {
    try {
      final token = await _getToken();
      final cart = await getCart();

      if (token == null || cart == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/cart/${cart.id}/items'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return CartItem.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding to cart: $e');
      return null;
    }
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

      return response.statusCode == 200;
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
}
