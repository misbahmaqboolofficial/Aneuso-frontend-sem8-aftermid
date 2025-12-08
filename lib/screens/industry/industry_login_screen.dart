// import 'package:flutter/material.dart';
// import '../auth/user_type_selection_screen.dart';
// import 'industry_register_screen.dart';
// import '../../services/api_service.dart';
// import 'industry_dashboard.dart'; // ADD THIS IMPORT

// class IndustryLoginScreen extends StatefulWidget {
//   const IndustryLoginScreen({super.key});

//   @override
//   State<IndustryLoginScreen> createState() => _IndustryLoginScreenState();
// }

// class _IndustryLoginScreenState extends State<IndustryLoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Industry Login'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pushReplacement(
//             context, 
//             MaterialPageRoute(builder: (context) => const UserTypeSelectionScreen())
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
//                   const SizedBox(height: 40),
                  
//                   Icon(
//                     Icons.business,
//                     size: 80,
//                     color: Colors.green,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Industry Login',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Login to manage your industrial waste disposal',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 40),

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
//                   const SizedBox(height: 20),

//                   // Password Field
//                   TextFormField(
//                     controller: _passwordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Password is required';
//                       }
//                       return null;
//                     },
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.lock),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                           color: Colors.grey,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Login Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _loginIndustry,
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
//                               'LOGIN',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),
                  
//                   // Sign Up Link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Don't have an account? "),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const IndustryRegisterScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Register Here',
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // // Test Credentials Info
//                   // const SizedBox(height: 40),
//                   // Container(
//                   //   padding: const EdgeInsets.all(20),
//                   //   decoration: BoxDecoration(
//                   //     color: Colors.green[50],
//                   //     borderRadius: BorderRadius.circular(10),
//                   //     border: Border.all(color: Colors.green[200]!),
//                   //   ),
//                   //   child: Column(
//                   //     children: [
//                   //       const Row(
//                   //         children: [
//                   //           Icon(Icons.business, color: Colors.green, size: 20),
//                   //           SizedBox(width: 10),
//                   //           Text(
//                   //             'Test Credentials:',
//                   //             style: TextStyle(
//                   //               fontWeight: FontWeight.bold,
//                   //               color: Colors.green,
//                   //             ),
//                   //           ),
//                   //         ],
//                   //       ),
//                   //       const SizedBox(height: 15),
//                   //       _buildTestCredential('Textile Mill Ltd', 'textile@industry.com', 'Industry123'),
//                   //       const SizedBox(height: 10),
//                   //       _buildTestCredential('Plastic Solutions Inc', 'plastic@industry.com', 'Industry123'),
//                   //       const SizedBox(height: 10),
//                   //       const Text(
//                   //         '⚠️ Make sure backend server is running on localhost:5000',
//                   //         style: TextStyle(
//                   //           color: Colors.orange,
//                   //           fontSize: 12,
//                   //         ),
//                   //         textAlign: TextAlign.center,
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
                  
//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTestCredential(String company, String email, String password) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green[100]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             company,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text('📧 $email'),
//           Text('🔑 $password'),
//         ],
//       ),
//     );
//   }

//   void _loginIndustry() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         print('🔄 Attempting login with: ${_emailController.text}');
        
//         // Call REAL backend API
//         final response = await ApiService.industryLogin(
//           _emailController.text.trim(),
//           _passwordController.text,
//         );

//         setState(() {
//           _isLoading = false;
//         });

//         print('✅ Login response: $response');

//         if (response['success'] == true) {
//           final industry = response['industry'];
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Welcome back, ${industry['companyName']}!'),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 3),
//             ),
//           );
          
//           // Print success details
//           print('🎉 Login Successful!');
//           print('🏭 Company: ${industry['companyName']}');
//           print('📧 Email: ${industry['email']}');
//           print('📞 Phone: ${industry['phone']}');
          
//           // NAVIGATE TO INDUSTRY DASHBOARD - ADDED THIS
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => IndustryDashboard(
//                 companyName: industry['companyName'],
//                 email: industry['email'],
//               ),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response['message'] ?? 'Login failed'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           print('❌ Login failed: ${response['message']}');
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
        
//         print('❌ Network error: $e');
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Network error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }