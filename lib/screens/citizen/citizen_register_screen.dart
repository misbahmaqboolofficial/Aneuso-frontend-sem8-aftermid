// import 'package:flutter/material.dart';
// import 'citizen_login_screen.dart';
// import '../../services/api_service.dart';

// class CitizenRegisterScreen extends StatefulWidget {
//   const CitizenRegisterScreen({super.key});

//   @override
//   State<CitizenRegisterScreen> createState() => _CitizenRegisterScreenState();
// }

// class _CitizenRegisterScreenState extends State<CitizenRegisterScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _cnicController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
  
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Citizen Registration'),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pushReplacement(
//             context, 
//             MaterialPageRoute(builder: (context) => const CitizenLoginScreen())
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
//                     Icons.person_add,
//                     size: 80,
//                     color: Colors.orange,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Citizen Registration',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Create your citizen account to report waste issues',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 40),

//                   // Full Name Field
//                   TextFormField(
//                     controller: _nameController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Full name is required';
//                       }
//                       if (value.length < 3) {
//                         return 'Name must be at least 3 characters';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Full Name',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.person),
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
//                         return 'Home address is required';
//                       }
//                       if (value.length < 10) {
//                         return 'Please enter complete address';
//                       }
//                       return null;
//                     },
//                     maxLines: 2,
//                     decoration: InputDecoration(
//                       labelText: 'Home Address',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.home),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // CNIC Field
//                   TextFormField(
//                     controller: _cnicController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'CNIC is required';
//                       }
//                       final cnicRegex = RegExp(r'^[0-9]{5}-[0-9]{7}-[0-9]{1}$');
//                       if (!cnicRegex.hasMatch(value)) {
//                         return 'Enter valid CNIC (12345-1234567-1)';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.text,
//                     decoration: InputDecoration(
//                       labelText: 'CNIC (12345-1234567-1)',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.badge),
//                       filled: true,
//                       fillColor: Colors.grey[50],
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
//                       onPressed: _isLoading ? null : _registerCitizen,
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
//                               'REGISTER AS CITIZEN',
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
//                               builder: (context) => const CitizenLoginScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Login Here',
//                           style: TextStyle(
//                             color: Colors.orange,
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
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.orange[200]!),
//                     ),
//                     child: const Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.info, color: Colors.orange, size: 20),
//                             SizedBox(width: 10),
//                             Text(
//                               'Citizen Features:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           '• Report waste collection issues\n'
//                           '• Track waste pickup schedules\n'
//                           '• Receive notifications\n'
//                           '• View recycling tips\n'
//                           '• Contact local authorities\n'
//                           '• Admin can block accounts if misused',
//                           style: TextStyle(
//                             color: Colors.orange,
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

//   void _registerCitizen() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         print('🔄 Attempting citizen registration...');
        
//         // Call REAL backend API for registration
//         final response = await ApiService.post('/api/citizens/register', {
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'address': _addressController.text.trim(),
//           'cnic': _cnicController.text.trim(),
//           'password': _passwordController.text,
//         });

//         setState(() {
//           _isLoading = false;
//         });

//         print('✅ Citizen registration response: $response');

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
//                     MaterialPageRoute(builder: (context) => const CitizenLoginScreen()),
//                   );
//                 },
//               ),
//             ),
//           );

//           // Auto navigate to login after 3 seconds
//           Future.delayed(const Duration(seconds: 3), () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const CitizenLoginScreen()),
//             );
//           });

//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response['message'] ?? 'Registration failed'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           print('❌ Citizen registration failed: ${response['message']}');
//         }
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//         });
        
//         print('❌ Citizen registration network error: $e');
        
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