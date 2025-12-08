// import 'package:flutter/material.dart';
// import 'driver_login_screen.dart';

// class DriverRegisterScreen extends StatefulWidget {
//   const DriverRegisterScreen({super.key});

//   @override
//   State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
// }

// class _DriverRegisterScreenState extends State<DriverRegisterScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _cnicController = TextEditingController();
//   final TextEditingController _vehicleController = TextEditingController();
//   final TextEditingController _experienceController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
  
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Registration'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pushReplacement(
//             context, 
//             MaterialPageRoute(builder: (context) => const DriverLoginScreen())
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
//                     Icons.drive_eta,
//                     size: 60,
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(height: 15),
//                   const Text(
//                     'Driver Registration',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Apply to become a driver. Admin approval required.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 30),

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

//                   // Phone Number Field
//                   TextFormField(
//                     controller: _phoneController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Phone number is required';
//                       }
//                       final phoneRegex = RegExp(r'^03[0-9]{2}-[0-9]{7}$');
//                       if (!phoneRegex.hasMatch(value)) {
//                         return 'Enter valid phone (0300-1234567)';
//                       }
//                       return null;
//                     },
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(
//                       labelText: 'Phone Number (0300-1234567)',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.phone),
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

//                   // Vehicle Type Field
//                   TextFormField(
//                     controller: _vehicleController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Vehicle type is required';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Vehicle Type (e.g., Toyota Hilux)',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.directions_car),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                     ),
//                   ),
//                   const SizedBox(height: 15),

//                   // Experience Field
//                   TextFormField(
//                     controller: _experienceController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Experience is required';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Driving Experience (e.g., 3 years)',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       prefixIcon: const Icon(Icons.work),
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
//                       onPressed: _isLoading ? null : _registerDriver,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
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
//                               'SUBMIT APPLICATION',
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
//                               builder: (context) => const DriverLoginScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Login Here',
//                           style: TextStyle(
//                             color: Colors.blue,
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
//                     child: Column(
//                       children: [
//                         const Row(
//                           children: [
//                             Icon(Icons.warning, color: Colors.orange, size: 20),
//                             SizedBox(width: 10),
//                             Text(
//                               'Important Information:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           '• Your application will be reviewed by admin\n'
//                           '• You can only login after admin approval\n'
//                           '• CNIC is required for identity verification\n'
//                           '• Fake accounts will be permanently banned\n'
//                           '• Admin can remove drivers at any time',
//                           style: TextStyle(
//                             color: Colors.orange,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           '📞 Contact Admin: admin@gulbahao.com',
//                           style: TextStyle(
//                             color: Colors.blue[700],
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
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

//   void _registerDriver() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate API call for registration
//       Future.delayed(const Duration(seconds: 2), () {
//         setState(() {
//           _isLoading = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Application submitted successfully! Admin will review your request.'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 5),
//             action: SnackBarAction(
//               label: 'OK',
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const DriverLoginScreen()),
//                 );
//               },
//             ),
//           ),
//         );

//         // TODO: Save driver application to database
//         // TODO: Notify admin about new application
//       });
//     }
//   }
// }