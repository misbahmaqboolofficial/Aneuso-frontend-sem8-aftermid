import 'package:flutter/material.dart';
import 'package:aneuso_app/services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await OrderService.getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('pending')) return Colors.orange;
    if (lowerStatus.contains('processing')) return Colors.blue;
    if (lowerStatus.contains('shipped')) return Colors.purple;
    if (lowerStatus.contains('delivered')) return Colors.green;
    if (lowerStatus.contains('cancelled')) return Colors.red;
    return Colors.grey;
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          // Product Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFFDCFFA).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag_rounded,
                size: 24,
                color: Color(0xFF9B5DE0),
              ),
            ),
          ),

          SizedBox(width: 15),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E56C0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  item.productCode,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF4E56C0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Qty: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4E56C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF9B5DE0).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rs ${item.unitPrice.toStringAsFixed(2)} each',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9B5DE0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 15),

          // Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                'Rs ${item.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4E56C0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    if (_order == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Number and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${_order!.orderNumber}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4E56C0),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Placed on ${_order!.createdAt.toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Status Badges
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _order!.orderStatusName,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _getStatusColor(_order!.orderStatusName),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_rounded,
                            color: _getStatusColor(_order!.orderStatusName),
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _order!.orderStatusName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(_order!.orderStatusName),
                            ),
                          ),
                          Text(
                            'Order Status',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 15),

              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          _order!.paymentStatusName,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _getStatusColor(_order!.paymentStatusName),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            color: _getStatusColor(_order!.paymentStatusName),
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _order!.paymentStatusName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(_order!.paymentStatusName),
                            ),
                          ),
                          Text(
                            'Payment Status',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Address Information
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4E56C0),
                ),
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF9B5DE0),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4E56C0),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _order!.shippingAddress,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.business_rounded,
                    color: Color(0xFF9B5DE0),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billing Address',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4E56C0),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _order!.billingAddress,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4E56C0),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFDCFFA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Color(0xFFD78FEE).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _order!.notes!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    if (_order == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4E56C0).withOpacity(0.9),
            Color(0xFF9B5DE0).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4E56C0).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),

          // Summary Rows
          _buildSummaryRow(
            'Subtotal',
            'Rs ${_order!.totalAmount.toStringAsFixed(2)}',
          ),
          SizedBox(height: 10),

          if (_order!.discountAmount > 0)
            Column(
              children: [
                _buildSummaryRow(
                  'Discount',
                  '-Rs ${_order!.discountAmount.toStringAsFixed(2)}',
                ),
                SizedBox(height: 10),
              ],
            ),

          _buildSummaryRow('Tax', 'Rs ${_order!.taxAmount.toStringAsFixed(2)}'),
          SizedBox(height: 15),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          SizedBox(height: 15),

          // Final Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Rs ${_order!.finalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Items Count
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '${_order!.items.length} Items | ${_order!.items.fold(0, (sum, item) => sum + item.quantity)} Total Quantity',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9))),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
            ).createShader(bounds);
          },
          child: Text(
            'Order Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF4E56C0).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF4E56C0),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4E56C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Color(0xFF4E56C0),
                size: 22,
              ),
            ),
            onPressed: _isLoading ? null : _loadOrder,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading Order...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF4E56C0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  CircularProgressIndicator(color: Color(0xFF4E56C0)),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loadOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4E56C0).withOpacity(0.4),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _order == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFFFDCFFA).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Color(0xFF9B5DE0),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Order Not Found',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4E56C0),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'The order you\'re looking for doesn\'t exist or you don\'t have permission to view it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: Color(0xFF4E56C0),
              onRefresh: _loadOrder,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Order Info Card
                    _buildOrderInfoCard(),

                    // Order Items
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Items (${_order!.items.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4E56C0),
                            ),
                          ),
                          SizedBox(height: 15),
                          ..._order!.items
                              .map((item) => _buildOrderItem(item))
                              .toList(),
                        ],
                      ),
                    ),

                    // Order Summary
                    _buildOrderSummary(),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
