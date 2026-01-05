import 'package:aneuso_app/presentation/screens/citizen/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:aneuso_app/services/order_service.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;

  const OrderSuccessScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4E56C0).withOpacity(0.05),
                    Color(0xFF9B5DE0).withOpacity(0.05),
                    Color(0xFFD78FEE).withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),

                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4E56C0),
                        Color(0xFF9B5DE0),
                        Color(0xFFD78FEE),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4E56C0).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Success Message
                Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4E56C0),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 15),

                Text(
                  'Thank you for your purchase. Your order has been confirmed.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),

                // Order Details Card
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Order Number
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFFFDCFFA).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Order Number',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9B5DE0),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              order.orderNumber,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4E56C0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 25),

                      // Order Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            order.items.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4E56C0),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Rs ${order.finalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4E56C0),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order Status',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF4E56C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.orderStatusName,
                              style: TextStyle(
                                color: Color(0xFF4E56C0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment Status',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF9B5DE0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.paymentStatusName,
                              style: TextStyle(
                                color: Color(0xFF9B5DE0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 25),

                      Divider(color: Colors.grey[300], height: 1),

                      SizedBox(height: 25),

                      // Order Items
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Items:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4E56C0),
                            ),
                          ),
                          SizedBox(height: 15),
                          ...order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFDCFFA).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        size: 20,
                                        color: Color(0xFF9B5DE0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4E56C0),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Qty: ${item.quantity} × Rs ${item.unitPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rs ${item.totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4E56C0),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrdersScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Color(0xFF4E56C0),
                                width: 2,
                              ),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                'View All Orders',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4E56C0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 15),

                    Expanded(
                      child: Container(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4E56C0),
                                  Color(0xFF9B5DE0),
                                  Color(0xFFD78FEE),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4E56C0).withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Continue Shopping',
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
                    ),
                  ],
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
