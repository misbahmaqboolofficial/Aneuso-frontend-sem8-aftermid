// import 'package:aneuso_app/presentation/screens/citizen/order_success_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:aneuso_app/services/order_service.dart';
// import 'package:aneuso_app/services/cart_service.dart';

// class CheckoutScreen extends StatefulWidget {
//   final Cart cart;

//   const CheckoutScreen({Key? key, required this.cart}) : super(key: key);

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late CheckoutSummary? _checkoutSummary;
//   bool _isLoading = true;
//   bool _isProcessing = false;
//   String? _error;

//   // Form Controllers
//   final TextEditingController _shippingAddressController = TextEditingController();
//   final TextEditingController _billingAddressController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _promoCodeController = TextEditingController();

//   // Form Values
//   String _shippingAddress = '';
//   String _billingAddress = '';
//   int _paymentMethodId = 153; // Default payment method (cash)
//   int? _promotionId;
//   String? _notes;
//   bool _sameAsShipping = true;
//   Promotion? _appliedPromotion;
//   List<Map<String, dynamic>> _paymentMethods = [];
//   bool _showPromoField = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Load payment methods
//       final paymentMethods = await OrderService.getPaymentMethods();

//       setState(() {
//         _paymentMethods = paymentMethods;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _calculateCheckout() async {
//     if (!_validateForm()) return;

//     setState(() {
//       _isProcessing = true;
//       _error = null;
//     });

//     try {
//       final summary = await OrderService.checkout(
//         shippingAddress: _shippingAddress,
//         billingAddress: _sameAsShipping ? _shippingAddress : _billingAddress,
//         paymentMethodId: _paymentMethodId,
//         promotionId: _promotionId,
//         notes: _notes,
//       );

//       if (summary != null) {
//         setState(() {
//           _checkoutSummary = summary;
//         });
//       } else {
//         throw Exception('Failed to calculate checkout');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }

//   Future<void> _applyPromoCode() async {
//     final code = _promoCodeController.text.trim();
//     if (code.isEmpty) return;

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final promotion = await OrderService.validatePromotion(code);
//       if (promotion != null) {
//         setState(() {
//           _appliedPromotion = promotion;
//           _promotionId = promotion.id;
//         });

//         // Recalculate checkout with promotion
//         await _calculateCheckout();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Promotion code applied successfully!',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Invalid or expired promotion code',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to validate promotion code',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }

//   Future<void> _removePromoCode() async {
//     setState(() {
//       _appliedPromotion = null;
//       _promotionId = null;
//       _promoCodeController.clear();
//     });

//     await _calculateCheckout();
//   }

//   Future<void> _placeOrder() async {
//     if (_checkoutSummary == null) {
//       await _calculateCheckout();
//       if (_checkoutSummary == null) return;
//     }

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final order = await OrderService.createOrder(
//         companyId: 1, // Default company ID
//         shippingAddress: _shippingAddress,
//         billingAddress: _sameAsShipping ? _shippingAddress : _billingAddress,
//         orderStatusId: 134, // Default order status
//         paymentStatusId: 144, // Default payment status
//         paymentMethodId: _paymentMethodId,
//         notes: _notes,
//         promotionId: _promotionId,
//       );

//       if (order != null) {
//         // Clear cart after successful order
//         await CartService.clearCart();

//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OrderSuccessScreen(order: order),
//           ),
//           (route) => route.isFirst,
//         );
//       } else {
//         throw Exception('Failed to place order');
//       }
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to place order: ${e.toString()}',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isProcessing = false;
//       });
//     }
//   }

//   bool _validateForm() {
//     if (_shippingAddress.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please enter shipping address',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//       return false;
//     }

//     if (!_sameAsShipping && _billingAddress.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please enter billing address',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       );
//       return false;
//     }

//     return true;
//   }

//   Widget _buildAddressSection() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 20),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on_rounded,
//                 color: Color(0xFF6F38C5),
//                 size: 24,
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'Delivery Address',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF6F38C5),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),

//           // Shipping Address
//           TextFormField(
//             controller: _shippingAddressController,
//             decoration: InputDecoration(
//               labelText: 'Shipping Address',
//               labelStyle: TextStyle(color: Color(0xFF9B5DE0)),
//               prefixIcon: Icon(Icons.home_rounded, color: Color(0xFF9B5DE0)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: Color(0xFF6F38C5), width: 2),
//               ),
//             ),
//             maxLines: 3,
//             onChanged: (value) {
//               setState(() {
//                 _shippingAddress = value;
//               });
//               if (_sameAsShipping) {
//                 _billingAddressController.text = value;
//                 _billingAddress = value;
//               }
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Shipping address is required';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 15),

//           // Same as shipping checkbox
//           Row(
//             children: [
//               Checkbox(
//                 value: _sameAsShipping,
//                 onChanged: (value) {
//                   setState(() {
//                     _sameAsShipping = value ?? true;
//                     if (_sameAsShipping) {
//                       _billingAddressController.text = _shippingAddress;
//                       _billingAddress = _shippingAddress;
//                     }
//                   });
//                 },
//                 activeColor: Color(0xFF6F38C5),
//               ),
//               Text(
//                 'Billing address same as shipping',
//                 style: TextStyle(
//                   color: Color(0xFF6F38C5),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),

//           // Billing Address (if different)
//           if (!_sameAsShipping)
//             TextFormField(
//               controller: _billingAddressController,
//               decoration: InputDecoration(
//                 labelText: 'Billing Address',
//                 labelStyle: TextStyle(color: Color(0xFF9B5DE0)),
//                 prefixIcon: Icon(Icons.business_rounded, color: Color(0xFF9B5DE0)),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide(color: Color(0xFF6F38C5), width: 2),
//                 ),
//               ),
//               maxLines: 3,
//               onChanged: (value) {
//                 setState(() {
//                   _billingAddress = value;
//                 });
//               },
//               validator: (value) {
//                 if (!_sameAsShipping && (value == null || value.isEmpty)) {
//                   return 'Billing address is required';
//                 }
//                 return null;
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentSection() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 20),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.payment_rounded,
//                 color: Color(0xFF6F38C5),
//                 size: 24,
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'Payment Method',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF6F38C5),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),

//           // Payment Methods
//           if (_paymentMethods.isNotEmpty)
//             ..._paymentMethods.map((method) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: InkWell(
//                   onTap: () {
//                     setState(() {
//                       _paymentMethodId = method['id'];
//                     });
//                   },
//                   borderRadius: BorderRadius.circular(15),
//                   child: Container(
//                     padding: EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: _paymentMethodId == method['id']
//                           ? Color(0xFF6F38C5).withOpacity(0.1)
//                           : Colors.grey[50],
//                       borderRadius: BorderRadius.circular(15),
//                       border: Border.all(
//                         color: _paymentMethodId == method['id']
//                             ? Color(0xFF6F38C5)
//                             : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF6F38C5).withOpacity(0.1),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             _getPaymentMethodIcon(method['name']),
//                             color: Color(0xFF6F38C5),
//                             size: 20,
//                           ),
//                         ),
//                         SizedBox(width: 15),
//                         Expanded(
//                           child: Text(
//                             method['name'] ?? 'Unknown Method',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF6F38C5),
//                             ),
//                           ),
//                         ),
//                         if (_paymentMethodId == method['id'])
//                           Icon(
//                             Icons.check_circle_rounded,
//                             color: Color(0xFF6F38C5),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           SizedBox(height: 15),

//           // Promo Code Section
//           Row(
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     setState(() {
//                       _showPromoField = !_showPromoField;
//                     });
//                   },
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.local_offer_rounded,
//                         color: Color(0xFF9B5DE0),
//                         size: 18,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Apply Promo Code',
//                         style: TextStyle(
//                           color: Color(0xFF9B5DE0),
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               if (_appliedPromotion != null)
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Color(0xFF6F38C5),
//                         Color(0xFF9B5DE0),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       Text(
//                         _appliedPromotion!.code,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 12,
//                         ),
//                       ),
//                       SizedBox(width: 5),
//                       GestureDetector(
//                         onTap: _removePromoCode,
//                         child: Icon(
//                           Icons.close_rounded,
//                           color: Colors.white,
//                           size: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//             ],
//           ),

//           if (_showPromoField)
//             Padding(
//               padding: const EdgeInsets.only(top: 15),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _promoCodeController,
//                       decoration: InputDecoration(
//                         labelText: 'Enter Promo Code',
//                         labelStyle: TextStyle(color: Color(0xFF9B5DE0)),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide(color: Color(0xFF6F38C5), width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Container(
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _isProcessing ? null : _applyPromoCode,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF6F38C5),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                         child: _isProcessing
//                             ? SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Text(
//                                 'Apply',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderSummary() {
//     if (_checkoutSummary == null) {
//       return Container(
//         margin: EdgeInsets.only(bottom: 20),
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 10,
//               offset: Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Order Summary',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF6F38C5),
//                   ),
//                 ),
//                 Container(
//                   height: 40,
//                   child: ElevatedButton(
//                     onPressed: _isProcessing ? null : _calculateCheckout,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: EdgeInsets.zero,
//                     ),
//                     child: Ink(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Color(0xFF6F38C5),
//                             Color(0xFF9B5DE0),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                         child: _isProcessing
//                             ? SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Text(
//                                 'Calculate Total',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Please fill in your address and payment details to calculate the total.',
//               style: TextStyle(
//                 color: Colors.grey[600],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       margin: EdgeInsets.only(bottom: 20),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF6F38C5).withOpacity(0.9),
//             Color(0xFF9B5DE0).withOpacity(0.9),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xFF6F38C5).withOpacity(0.3),
//             blurRadius: 15,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.receipt_long_rounded,
//                 color: Colors.white,
//                 size: 24,
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'Order Summary',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),

//           // Order Items
//           Column(
//             children: _checkoutSummary!.items.map((item) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         '${item.productName} x${item.quantity}',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.9),
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Text(
//                       'Rs ${item.totalPrice.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),

//           SizedBox(height: 15),
//           Divider(color: Colors.white.withOpacity(0.3), height: 1),
//           SizedBox(height: 15),

//           // Summary Details
//           _buildSummaryRow('Subtotal', 'Rs ${_checkoutSummary!.summary.subtotal.toStringAsFixed(2)}'),
//           SizedBox(height: 8),

//           if (_checkoutSummary!.summary.discountAmount > 0)
//             Column(
//               children: [
//                 _buildSummaryRow('Discount', '-Rs ${_checkoutSummary!.summary.discountAmount.toStringAsFixed(2)}'),
//                 SizedBox(height: 8),
//               ],
//             ),

//           _buildSummaryRow('Tax (10%)', 'Rs ${_checkoutSummary!.summary.taxAmount.toStringAsFixed(2)}'),
//           SizedBox(height: 15),
//           Divider(color: Colors.white.withOpacity(0.3), height: 1),
//           SizedBox(height: 15),

//           // Final Amount
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Total Amount',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 'Rs ${_checkoutSummary!.summary.finalAmount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: 20),
//           Container(
//             height: 50,
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isProcessing ? null : _placeOrder,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: EdgeInsets.zero,
//               ),
//               child: Ink(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.white.withOpacity(0.4),
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: _isProcessing
//                       ? SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Color(0xFF6F38C5),
//                           ),
//                         )
//                       : Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.lock_rounded,
//                               color: Color(0xFF6F38C5),
//                               size: 20,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               'Place Order & Pay',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFF6F38C5),
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.9),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   IconData _getPaymentMethodIcon(String methodName) {
//     final lowerName = methodName.toLowerCase();
//     if (lowerName.contains('cash')) return Icons.money_rounded;
//     if (lowerName.contains('card')) return Icons.credit_card_rounded;
//     if (lowerName.contains('bank')) return Icons.account_balance_rounded;
//     if (lowerName.contains('digital')) return Icons.payment_rounded;
//     return Icons.payment_rounded;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         title: ShaderMask(
//           shaderCallback: (bounds) {
//             return LinearGradient(
//               colors: [
//                 Color(0xFF6F38C5),
//                 Color(0xFF9B5DE0),
//               ],
//             ).createShader(bounds);
//           },
//           child: Text(
//             'Checkout',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//         leading: IconButton(
//           icon: Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Color(0xFF6F38C5).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new_rounded,
//               color: Color(0xFF6F38C5),
//               size: 20,
//             ),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Color(0xFF6F38C5),
//                           Color(0xFF9B5DE0),
//                         ],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.shopping_cart_checkout_rounded,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Loading Checkout...',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Color(0xFF6F38C5),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   CircularProgressIndicator(
//                     color: Color(0xFF6F38C5),
//                   ),
//                 ],
//               ),
//             )
//           : _error != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           color: Colors.red.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.error_outline_rounded,
//                           color: Colors.red,
//                           size: 50,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 40),
//                         child: Text(
//                           _error!,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.red[800],
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Container(
//                         height: 48,
//                         child: ElevatedButton(
//                           onPressed: _loadInitialData,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.transparent,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding: EdgeInsets.zero,
//                           ),
//                           child: Ink(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   Color(0xFF6F38C5),
//                                   Color(0xFF9B5DE0),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Color(0xFF6F38C5).withOpacity(0.4),
//                                   blurRadius: 10,
//                                   offset: Offset(0, 5),
//                                 ),
//                               ],
//                             ),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.refresh_rounded,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Text(
//                                     'Try Again',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   padding: EdgeInsets.all(20),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         // Cart Summary
//                         Container(
//                           padding: EdgeInsets.all(15),
//                           margin: EdgeInsets.only(bottom: 20),
//                           decoration: BoxDecoration(
//                             color: Color(0xFFFDCFFA).withOpacity(0.3),
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(
//                               color: Color(0xFFD78FEE).withOpacity(0.3),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.shopping_cart_rounded,
//                                 color: Color(0xFF9B5DE0),
//                                 size: 24,
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${widget.cart.totalItems} Items in Cart',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                         color: Color(0xFF6F38C5),
//                                       ),
//                                     ),
//                                     Text(
//                                       'Rs ${widget.cart.subtotal.toStringAsFixed(2)}',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Color(0xFF9B5DE0),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Address Section
//                         _buildAddressSection(),

//                         // Payment Section
//                         _buildPaymentSection(),

//                         // Additional Notes
//                         Container(
//                           margin: EdgeInsets.only(bottom: 20),
//                           padding: EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 blurRadius: 10,
//                                 offset: Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.note_alt_rounded,
//                                     color: Color(0xFF6F38C5),
//                                     size: 24,
//                                   ),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     'Additional Notes',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w700,
//                                       color: Color(0xFF6F38C5),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 15),
//                               TextFormField(
//                                 controller: _notesController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Special instructions for delivery',
//                                   labelStyle: TextStyle(color: Color(0xFF9B5DE0)),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                     borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                     borderSide: BorderSide(color: Color(0xFF6F38C5), width: 2),
//                                   ),
//                                 ),
//                                 maxLines: 3,
//                                 onChanged: (value) {
//                                   setState(() {
//                                     _notes = value;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Order Summary
//                         _buildOrderSummary(),

//                         SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:aneuso_app/services/cart_service.dart';
import 'package:aneuso_app/core/utils/local_notification_service.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('checkout_screen.dart');

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Cart? _cart;
  List<PaymentMethod> _paymentMethods = [];
  int _selectedPaymentMethodId = 0;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Remove late keyword and initialize properly
  CheckoutSummary? _checkoutSummary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cart = await CartService.getCart();
      final paymentMethods = await CartService.getPaymentMethods();

      if (cart == null) {
        throw Exception('Cart not found');
      }

      // Initialize checkout summary
      _checkoutSummary = CheckoutSummary(
        subtotal: cart.subtotal,
        totalItems: cart.totalItems,
        tax: 0.0, // You can calculate tax based on your business logic
        shipping: 0.0, // Add shipping calculation if needed
        total: cart.subtotal,
      );

      setState(() {
        _cart = cart;
        _paymentMethods = paymentMethods;
        if (paymentMethods.isNotEmpty) {
          _selectedPaymentMethodId = paymentMethods.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processCheckout() async {
    if (_selectedPaymentMethodId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await CartService.checkout(
        paymentMethodId: _selectedPaymentMethodId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        deliveryAddress: _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
      );

      setState(() {
        _isProcessing = false;
      });

      if (result != null && result['success'] == true) {
        // Show success dialog
        await _showSuccessDialog(result);
      } else {
        // throw Exception(
        //   'Checkout failed: ${result?['message'] ?? 'Unknown error'}',
        // );
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result?['message'] ?? 'Unknown error'}'),
          backgroundColor: Colors.red,
        ),
      );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> result) async {
    // Fire a native Android notification for the successful order
    final orderNumber = result['data']?['order_number']?.toString() ?? 'N/A';
    await LocalNotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '✅ Order Placed Successfully!',
      body: 'Your order #$orderNumber has been confirmed. Thank you for your purchase!',
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6F38C5),
                ),
              ),
              SizedBox(height: 15),
              if (result['data']?['order_number'] != null)
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFFDCFFA).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xFFD78FEE)),
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
                        result['data']['order_number'].toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6F38C5),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
              Text(
                'Thank you for your order!',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 5),
              Text(
                'You will receive a confirmation email shortly.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              Container(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
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
                        colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    bool isSelected = _selectedPaymentMethodId == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodId = method.id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6F38C5).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Color(0xFF6F38C5)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFF6F38C5).withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0xFF6F38C5)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getPaymentMethodIcon(method.typeName),
                color: isSelected ? Colors.white : Color(0xFF6F38C5),
                size: 20,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6F38C5),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getPaymentMethodDescription(method.typeName),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF6F38C5),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(String typeName) {
    switch (typeName) {
      case 'method_bank_transfer':
        return Icons.account_balance_rounded;
      case 'method_cash':
        return Icons.money_rounded;
      case 'method_cheque':
        return Icons.description_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _getPaymentMethodDescription(String typeName) {
    switch (typeName) {
      case 'method_bank_transfer':
        return 'Pay via bank transfer';
      case 'method_cash':
        return 'Pay with cash on delivery';
      case 'method_cheque':
        return 'Pay with cheque';
      default:
        return 'Payment method';
    }
  }

  Widget _buildOrderSummary() {
    if (_checkoutSummary == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6F38C5).withOpacity(0.9),
            Color(0xFF9B5DE0).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6F38C5).withOpacity(0.3),
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
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          _buildSummaryRow(
            'Subtotal',
            'Rs ${_checkoutSummary!.subtotal.toStringAsFixed(2)}',
          ),
          _buildSummaryRow('Items', _checkoutSummary!.totalItems.toString()),
          if (_checkoutSummary!.tax! > 0)
            _buildSummaryRow(
              'Tax',
              'Rs ${_checkoutSummary!.tax!.toStringAsFixed(2)}',
            ),
          if (_checkoutSummary!.shipping! > 0)
            _buildSummaryRow(
              'Shipping',
              'Rs ${_checkoutSummary!.shipping!.toStringAsFixed(2)}',
            ),
          Divider(color: Colors.white.withOpacity(0.3), height: 20),
          _buildSummaryRow(
            'Total',
            'Rs ${_checkoutSummary!.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              color: Colors.white.withOpacity(isTotal ? 1 : 0.9),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 16,
              color: Colors.white,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
            ).createShader(bounds);
          },
          child: Text(
            _kScreenTitle,
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
              color: Color(0xFF6F38C5).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF6F38C5),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
                        colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.shopping_cart_checkout_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Preparing Checkout...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6F38C5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  CircularProgressIndicator(color: Color(0xFF6F38C5)),
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
                      onPressed: _loadData,
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
                            colors: [Color(0xFF6F38C5), Color(0xFF9B5DE0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6F38C5).withOpacity(0.4),
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
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Items Summary
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
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
                          'Order Items (${_cart?.totalItems ?? 0})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6F38C5),
                          ),
                        ),
                        SizedBox(height: 10),
                        ...(_cart?.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.productName} x${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Rs ${item.totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6F38C5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ) ??
                            []),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Delivery Address (Optional)
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
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
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6F38C5),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter your delivery address...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF6F38C5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Additional Notes (Optional)
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
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
                          'Additional Notes (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6F38C5),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Any special instructions or notes...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF6F38C5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Payment Methods
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
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
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6F38C5),
                          ),
                        ),
                        SizedBox(height: 15),
                        if (_paymentMethods.isEmpty)
                          Text(
                            'No payment methods available',
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        else
                          Column(
                            children: _paymentMethods
                                .map(
                                  (method) => _buildPaymentMethodCard(method),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Order Summary
                  _buildOrderSummary(),
                  SizedBox(height: 20),

                  // Terms and Conditions
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Color(0xFFFDCFFA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(0xFFD78FEE).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: Color(0xFF9B5DE0),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your payment is secure. By completing your purchase, you agree to our Terms of Service and Privacy Policy.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6F38C5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Place Order Button
                  Container(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.zero,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _isProcessing
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey[400]!,
                                    Colors.grey[500]!,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Color(0xFF6F38C5),
                                    Color(0xFF9B5DE0),
                                    Color(0xFFD78FEE),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: _isProcessing
                              ? null
                              : [
                                  BoxShadow(
                                    color: Color(0xFF6F38C5).withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _isProcessing
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Place Order - Rs ${_checkoutSummary?.total.toStringAsFixed(2) ?? "0.00"}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
