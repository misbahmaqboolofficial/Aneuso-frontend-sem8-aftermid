// import 'package:flutter/material.dart';
// import '../auth/user_type_selection_screen.dart';
// import 'citizen_register_screen.dart';
// import '../../services/api_service.dart';
// import 'citizen_dashboard.dart';

// class CitizenLoginScreen extends StatefulWidget {
//   const CitizenLoginScreen({super.key});

//   @override
//   State<CitizenLoginScreen> createState() => _CitizenLoginScreenState();
// }

// class _CitizenLoginScreenState extends State<CitizenLoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Citizen Login'),
//         backgroundColor: Colors.orange,
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
//                     Icons.person,
//                     size: 80,
//                     color: Colors.orange,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Citizen Login',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Login to access citizen features and report issues',
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
//                       onPressed: _isLoading ? null : _loginCitizen,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
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
                  
//                   // Register Link - Below Login Button
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Don't have an account? "),
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const CitizenRegisterScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Register Here',
//                           style: TextStyle(
//                             color: Colors.orange,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Information Notice
//                   const SizedBox(height: 40),
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.orange[200]!),
//                     ),
//                     child: const Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.people, color: Colors.orange, size: 20),
//                             SizedBox(width: 10),
//                             Text(
//                               'Citizen Login Information:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           '• Registered citizens can login immediately\n'
//                           '• Report waste collection issues\n'
//                           '• Track waste pickup schedules\n'
//                           '• Receive important notifications\n'
//                           '• Contact local authorities',
//                           style: TextStyle(
//                             color: Colors.orange,
//                             fontSize: 12,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           '⚠️ Admin can block accounts for misuse',
//                           style: TextStyle(
//                             color: Colors.red,
//                             fontSize: 12,
//                           ),
//                           textAlign: TextAlign.center,
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

//   void _loginCitizen() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         print('🔄 Attempting citizen login with: ${_emailController.text}');
        
//         // Call REAL backend API
//         final response = await ApiService.citizenLogin(
//           _emailController.text.trim(),
//           _passwordController.text,
//         );

//         setState(() {
//           _isLoading = false;
//         });

//         print('✅ Citizen login response: $response');

//         if (response['success'] == true) {
//           final citizen = response['citizen'];
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Welcome back, ${citizen['name']}!'),
//               backgroundColor: Colors.green,
//             ),
//           );
          
//           // Print success details
//           print('🎉 Citizen Login Successful!');
//           print('👤 Citizen: ${citizen['name']}');
//           print('📧 Email: ${citizen['email']}');
//           print('📞 Phone: ${citizen['phone']}');
          
//           // NAVIGATE TO CITIZEN DASHBOARD
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CitizenDashboard(
//                 citizenName: citizen['name'],
//                 email: citizen['email'],
//                 address: citizen['address'],
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
//           print('❌ Citizen login failed: ${response['message']}');
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
        
//         print('❌ Citizen network error: $e');
        
//         // Show user-friendly error message
//         String errorMessage = 'Login failed. Please check your credentials.';
        
//         if (e.toString().contains('401')) {
//           errorMessage = 'Invalid email or password, or account is blocked.';
//         } else if (e.toString().contains('Network error')) {
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