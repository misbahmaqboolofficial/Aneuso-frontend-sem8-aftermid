// import 'package:flutter/material.dart';
// import '../auth/user_type_selection_screen.dart';
// import 'driver_dashboard.dart';
// import 'driver_register_screen.dart';

// class DriverLoginScreen extends StatefulWidget {
//   const DriverLoginScreen({super.key});

//   @override
//   State<DriverLoginScreen> createState() => _DriverLoginScreenState();
// }

// class _DriverLoginScreenState extends State<DriverLoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Login'),
//         backgroundColor: Colors.blue,
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
//                     Icons.drive_eta,
//                     size: 80,
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Driver Login',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Login to access your driving tasks and routes',
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
//                       onPressed: _isLoading ? null : _loginDriver,
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
//                               builder: (context) => const DriverRegisterScreen(),
//                             ),
//                           );
//                         },
//                         child: const Text(
//                           'Apply Here',
//                           style: TextStyle(
//                             color: Colors.blue,
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
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.blue[200]!),
//                     ),
//                     child: const Column(
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.info, color: Colors.blue, size: 20),
//                             SizedBox(width: 10),
//                             Text(
//                               'Driver Login Information:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           '• Only approved drivers can login\n'
//                           '• Admin approval required for new applications\n'
//                           '• Contact admin for login issues\n'
//                           '• Keep your credentials secure',
//                           style: TextStyle(
//                             color: Colors.blue,
//                             fontSize: 12,
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Text(
//                           '⚠️ You can only login if admin approves your application',
//                           style: TextStyle(
//                             color: Colors.orange,
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

//   void _loginDriver() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       // Simulate API call
//       await Future.delayed(const Duration(seconds: 2));

//       final email = _emailController.text.trim();
//       final password = _passwordController.text;

//       // Check credentials securely
//       if ((email == 'muhammad.ahsan@driver.com' && password == 'Driver123') ||
//           (email == 'abdullah.hassan@driver.com' && password == 'Driver123')) {
        
//         String name = email == 'muhammad.ahsan@driver.com' ? 'Muhammad Ahsan' : 'Abdullah Hassan';
//         String vehicle = email == 'muhammad.ahsan@driver.com' ? 'Toyota Hilux Truck' : 'Suzuki Bolan Van';
        
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DriverDashboard(
//               driverName: name,
//               email: email,
//               vehicle: vehicle,
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid credentials or driver not approved'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }