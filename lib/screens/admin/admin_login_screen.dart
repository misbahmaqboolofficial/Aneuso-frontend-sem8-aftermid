// import 'package:flutter/material.dart';
// import '../auth/user_type_selection_screen.dart';
// import 'admin_dashboard.dart';

// class AdminLoginScreen extends StatefulWidget {
//   const AdminLoginScreen({super.key});

//   @override
//   State<AdminLoginScreen> createState() => _AdminLoginScreenState();
// }

// class _AdminLoginScreenState extends State<AdminLoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Login'),
//         backgroundColor: const Color(0xFF2E8B57), // Primary Green
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pushReplacement(
//             context, 
//             MaterialPageRoute(builder: (context) => const UserTypeSelectionScreen())
//           ),
//         ),
//       ),
//       backgroundColor: const Color(0xFFF9FDFB), // Light Background
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
//                     Icons.admin_panel_settings,
//                     size: 80,
//                     color: const Color(0xFF2E8B57), // Primary Green
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Admin Portal',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2E8B57), // Primary Green
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Gulbahao Management System',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF2C3E50), // Dark Text
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 40),

//                   // Email Field
//                   TextFormField(
//                     controller: _emailController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Admin email is required';
//                       }
//                       final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
//                       if (!emailRegex.hasMatch(value)) {
//                         return 'Enter a valid email address';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: InputDecoration(
//                       labelText: 'Admin Email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       prefixIcon: const Icon(Icons.email),
//                       filled: true,
//                       fillColor: Colors.white,
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
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       prefixIcon: const Icon(Icons.lock),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                           color: const Color(0xFF2C3E50), // Dark Text
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Login Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _loginAdmin,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2E8B57), // Primary Green
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
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
//                               'ADMIN LOGIN',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),

//                   // Admin Access Info
//                   const SizedBox(height: 40),
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF2E8B57).withOpacity(0.1), // Primary Green with opacity
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFF2E8B57).withOpacity(0.3)),
//                     ),
//                     child: Column(
//                       children: [
//                         const Row(
//                           children: [
//                             Icon(Icons.security, color: Color(0xFF2E8B57), size: 20), // Primary Green
//                             SizedBox(width: 10),
//                             Text(
//                               'Admin Privileges:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF2E8B57), // Primary Green
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 15),
//                         Text(
//                           '🔧 Manage all user accounts\n'
//                           '✅ Approve/Reject driver applications\n'
//                           '🚫 Block/Unblock any user account\n'
//                           '📊 View system analytics\n'
//                           '⚙️ Configure system settings\n'
//                           '👥 Manage drivers and citizens',
//                           style: TextStyle(
//                             color: const Color(0xFF2E8B57).withOpacity(0.8), // Primary Green
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           '🔒 Restricted access - Authorized personnel only',
//                           style: TextStyle(
//                             color: const Color(0xFF2E8B57), // Primary Green
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
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

//   void _loginAdmin() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));

//       final email = _emailController.text.trim();
//       final password = _passwordController.text;

//       // Check credentials securely
//       if ((email == 'admin@gulbahao.com' && password == 'Admin123') ||
//           (email == 'management@gulbahao.com' && password == 'Admin123')) {
        
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AdminDashboard(),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid admin credentials'),
//             backgroundColor: Color(0xFFE67C22), // Warning Orange
//           ),
//         );
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }