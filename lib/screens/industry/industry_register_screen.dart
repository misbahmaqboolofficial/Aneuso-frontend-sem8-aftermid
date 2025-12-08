// import 'package:flutter/material.dart';
// import 'industry_login_screen.dart';
// import '../../services/api_service.dart';

// class IndustryRegisterScreen extends StatefulWidget {
//   const IndustryRegisterScreen({super.key});

//   @override
//   State<IndustryRegisterScreen> createState() => _IndustryRegisterScreenState();
// }

// class _IndustryRegisterScreenState extends State<IndustryRegisterScreen> {
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _businessTypeController = TextEditingController();
//   final TextEditingController _branchCodeController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
  
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Industry Registration'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pushReplacement(
//             context, 
//             MaterialPageRoute(builder: (context) => const IndustryLoginScreen())
//           ),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
                  
//                   Icon(
//                     Icons.business,
//                     size: 60,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(height: 15),
//                   const Text(
//                     'Industry Registration',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Register your industrial business for waste management',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 30),

//                   // Company Name Field
//                   TextFormField(
//                     controller: _companyNameController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Company name is required';
//                       }
//                       if (value.length < 3) {
//                         return 'Company name must be at least 3 characters';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Company Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.business),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Email Field
//                   TextFormField(
//                     controller: _emailController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Email is required';
//                       }
//                       final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//                       if (!emailRegex.hasMatch(value)) {
//                         return 'Enter a valid email address';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: 'Email Address',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.email),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Phone Number Field - FIXED FOR ALL PAKISTAN NUMBERS
//                   TextFormField(
//                     controller: _phoneController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Phone number is required';
//                       }
//                       // Accept all Pakistan numbers: +92 XXX XXXXXXX or 0XXX XXXXXXX
//                       final phoneRegex = RegExp(r'^(\+92[ -]?|0)[1-9][0-9]{1,2}[ -]?[0-9]{7}$');
//                       if (!phoneRegex.hasMatch(value)) {
//                         return 'Enter valid Pakistan phone (+92 42 3456789 or 042-3456789)';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(
//                       labelText: 'Phone Number (+92 42 3456789 or 042-3456789)',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.phone),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Address Field
//                   TextFormField(
//                     controller: _addressController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Business address is required';
//                       }
//                       if (value.length < 10) {
//                         return 'Please enter complete address';
//                       }
//                       return null;
//                     },
//                     maxLines: 2,
//                     decoration: InputDecoration(
//                       labelText: 'Business Address',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.location_on),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Business Type Field
//                   TextFormField(
//                     controller: _businessTypeController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Business type is required';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Business Type (e.g., Textile, Plastic, Food)',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.work),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Branch Code Field
//                   TextFormField(
//                     controller: _branchCodeController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Branch code is required';
//                       }
//                       if (value.length < 3) {
//                         return 'Branch code must be at least 3 characters';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Unique Branch Code',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.code),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       hintText: 'e.g., TXT001, PLA001, FOD001',
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Password Field
//                   TextFormField(
//                     controller: _passwordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Password is required';
//                       }
//                       if (value.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.lock),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Confirm Password Field
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please confirm your password';
//                       }
//                       if (value != _passwordController.text) {
//                         return 'Passwords do not match';
//                       }
//                       return null;
//                     },
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       labelText: 'Confirm Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Register Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _registerIndustry,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: _isLoading 
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : const Text(
//                               'REGISTER INDUSTRY',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),
                  
//                   // Login Link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Already have an account? "),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const IndustryLoginScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Login Here',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Important Notice
//                   const SizedBox(height: 30),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.green[200]!),
//                     ),
//                     child: const Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.info, color: Colors.green, size: 20),
//                             SizedBox(width: 10),
//                             Text(
//                               'Registration Information:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           '✅ Each branch needs unique branch code\n'
//                           '✅ Immediate login after registration\n'
//                           '✅ Multiple branches can register separately\n'
//                           '⚠️ Admin can block accounts for violations\n'
//                           '📞 Contact admin for assistance',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _registerIndustry() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         print('🔄 Attempting industry registration...');
        
//         // Call REAL backend API for registration
//         final response = await ApiService.post('/api/industries/register', {
//           'companyName': _companyNameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'address': _addressController.text.trim(),
//           'businessType': _businessTypeController.text.trim(),
//           'branchCode': _branchCodeController.text.trim(),
//           'password': _passwordController.text,
//         });

//         setState(() {
//           _isLoading = false;
//         });

//         print('✅ Industry registration response: $response');

//         if (response['success'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response['message'] ?? 'Registration successful!'),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 5),
//               action: SnackBarAction(
//                 label: 'LOGIN',
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => const IndustryLoginScreen()),
//                   );
//                 },
//               ),
//             ),
//           );

//           // Auto navigate to login after 3 seconds
//           Future.delayed(const Duration(seconds: 3), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const IndustryLoginScreen()),
//             );
//           });

//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response['message'] ?? 'Registration failed'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           print('❌ Industry registration failed: ${response['message']}');
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
        
//         print('❌ Industry registration network error: $e');
        
//         // Show user-friendly error message
//         String errorMessage = 'Registration failed. Please try again.';
        
//         if (e.toString().contains('Network error')) {
//           errorMessage = 'Network connection failed. Please check your internet.';
//         }
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }