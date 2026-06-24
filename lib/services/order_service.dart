import 'dart:convert';
import 'package:aneuso_app/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_service.dart';

class CheckoutSummary {
  final int cartId;
  final List<CheckoutItem> items;
  final CheckoutSummaryDetails summary;
  final ShippingDetails shipping;
  final PaymentDetails payment;

  CheckoutSummary({
    required this.cartId,
    required this.items,
    required this.summary,
    required this.shipping,
    required this.payment,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    List<CheckoutItem> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => CheckoutItem.fromJson(item))
          .toList();
    }

    return CheckoutSummary(
      cartId: json['cart_id'] ?? 0,
      items: items,
      summary: CheckoutSummaryDetails.fromJson(json['summary'] ?? {}),
      shipping: ShippingDetails.fromJson(json['shipping'] ?? {}),
      payment: PaymentDetails.fromJson(json['payment'] ?? {}),
    );
  }
}

class CheckoutItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  CheckoutItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class CheckoutSummaryDetails {
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final int itemsCount;
  final int totalQuantity;

  CheckoutSummaryDetails({
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.finalAmount,
    required this.itemsCount,
    required this.totalQuantity,
  });

  factory CheckoutSummaryDetails.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryDetails(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0.0,
      itemsCount: json['items_count'] ?? 0,
      totalQuantity: json['total_quantity'] ?? 0,
    );
  }
}

class ShippingDetails {
  final String shippingAddress;
  final String billingAddress;

  ShippingDetails({
    required this.shippingAddress,
    required this.billingAddress,
  });

  factory ShippingDetails.fromJson(Map<String, dynamic> json) {
    return ShippingDetails(
      shippingAddress: json['shipping_address'] ?? '',
      billingAddress: json['billing_address'] ?? '',
    );
  }
}

class PaymentDetails {
  final int paymentMethodId;

  PaymentDetails({
    required this.paymentMethodId,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      paymentMethodId: json['payment_method_id'] ?? 0,
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;
  final String productName;
  final String productCode;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.productName,
    required this.productCode,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      productName: json['product_name'] ?? '',
      productCode: json['product_code'] ?? '',
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final int companyId;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String shippingAddress;
  final String billingAddress;
  final int orderStatusId;
  final int paymentStatusId;
  final int paymentMethodId;
  final String? transactionId;
  final int? promotionId;
  final String? notes;
  final DateTime createdAt;
  final String orderStatusName;
  final String paymentStatusName;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.companyId,
    required this.totalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.finalAmount,
    required this.shippingAddress,
    required this.billingAddress,
    required this.orderStatusId,
    required this.paymentStatusId,
    required this.paymentMethodId,
    this.transactionId,
    this.promotionId,
    this.notes,
    required this.createdAt,
    required this.orderStatusName,
    required this.paymentStatusName,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      userId: json['user_id'] ?? 0,
      companyId: json['company_id'] ?? 1,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      discountAmount: double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(json['final_amount']?.toString() ?? '0') ?? 0.0,
      shippingAddress: json['shipping_address'] ?? '',
      billingAddress: json['billing_address'] ?? '',
      orderStatusId: json['order_status_id'] ?? 134,
      paymentStatusId: json['payment_status_id'] ?? 144,
      paymentMethodId: json['payment_method_id'] ?? 154,
      transactionId: json['transaction_id'],
      promotionId: json['promotion_id'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      orderStatusName: json['order_status_name'] ?? 'Pending',
      paymentStatusName: json['payment_status_name'] ?? 'Pending',
      items: items,
    );
  }
}

class Promotion {
  final int id;
  final String code;
  final String name;
  final String? description;
  final int discountTypeId;
  final double discountValue;
  final double? minOrderAmount;
  final int? maxUsage;
  final int usageCount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;

  Promotion({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.discountTypeId,
    required this.discountValue,
    this.minOrderAmount,
    this.maxUsage,
    required this.usageCount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      discountTypeId: json['discount_type_id'] ?? 1,
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      minOrderAmount: json['min_order_amount'] != null 
          ? double.tryParse(json['min_order_amount'].toString()) 
          : null,
      maxUsage: json['max_usage'],
      usageCount: json['usage_count'] ?? 0,
      validFrom: DateTime.parse(json['valid_from'] ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(json['valid_until'] ?? DateTime.now().add(Duration(days: 30)).toIso8601String()),
      isActive: json['is_active'] == true || json['status_id'] == 1,
    );
  }
}

class OrderService {
  static const String baseUrl = "${AppConstants.baseUrl}/orders";
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Checkout
  static Future<CheckoutSummary?> checkout({
    required String shippingAddress,
    required String billingAddress,
    required int paymentMethodId,
    int? promotionId,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'shipping_address': shippingAddress,
          'billing_address': billingAddress,
          'payment_method_id': paymentMethodId,
          'promotion_id': promotionId,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return CheckoutSummary.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error during checkout: $e');
      return null;
    }
  }

  // Create Order
  static Future<Order?> createOrder({
    required int companyId,
    required String shippingAddress,
    required String billingAddress,
    required int orderStatusId,
    required int paymentStatusId,
    required int paymentMethodId,
    String? notes,
    int? promotionId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/orders/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'company_id': companyId,
          'shipping_address': shippingAddress,
          'billing_address': billingAddress,
          'order_status_id': orderStatusId,
          'payment_status_id': paymentStatusId,
          'payment_method_id': paymentMethodId,
          'notes': notes,
          'promotion_id': promotionId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Order.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get User Orders
  static Future<List<Order>> getUserOrders({int limit = 200}) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/me?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          return (jsonResponse['data'] as List)
              .map((item) => Order.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Get Order by ID
  static Future<Order?> getOrderById(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Order.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Get Promotions
  static Future<List<Promotion>> getPromotions() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/promotions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          return (jsonResponse['data'] as List)
              .map((item) => Promotion.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting promotions: $e');
      return [];
    }
  }

  // Validate Promotion Code
  static Future<Promotion?> validatePromotion(String code) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/promotions/validate/$code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Promotion.fromJson(jsonResponse['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error validating promotion: $e');
      return null;
    }
  }

  // Get Order Statuses
  static Future<List<Map<String, dynamic>>> getOrderStatuses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/types/order-statuses'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error getting order statuses: $e');
      return [];
    }
  }

  // Get Payment Methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/types/payment-methods'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }
}