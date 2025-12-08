import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_overlay.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  // Password visibility
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.text = StorageUtil.getStringData("email") ?? "";
    _passwordController.text = StorageUtil.getStringData("password") ?? "";
    // print('DEBUG: Controllers initialized');
  }

  @override
  void dispose() {
    // print('DEBUG: Disposing - Email: ${_emailController.text}');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.login(
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );
    await StorageUtil.setStringData(
      "email",
      _emailController.text.trim().toLowerCase(),
    );
    await StorageUtil.setStringData("password", _passwordController.text);
    if (success && mounted) {
      _navigateToDashboard(authProvider.currentUser!);
    }
  }

  // Future<void> _testLogin(AuthProvider authProvider, String email) async {
  //   final success = await authProvider.testLogin(email: email);

  //   if (success && mounted) {
  //     _navigateToDashboard(authProvider.currentUser!);
  //   }
  // }

  // void _navigateToDashboard(UserEntity user) {
  //   String routeName = '/dashboard';

  //   // Navigate to different dashboards based on user type
  //   switch (user.userTypeId) {
  //     case AppConstants.userTypeAdmin:
  //       routeName = '/admin-dashboard';
  //       break;
  //     case AppConstants.userTypeIndustry:
  //       routeName = '/industry-dashboard';
  //       break;
  //     case AppConstants.userTypeDriver:
  //       routeName = '/driver-dashboard';
  //       break;
  //     case AppConstants.userTypeCitizen:
  //       routeName = '/citizen-dashboard';
  //       break;
  //   }

  //   Navigator.pushReplacementNamed(context, routeName);
  // }
  void _navigateToDashboard(UserEntity user) {
    String routeName = '/dashboard';

    // Navigate to different dashboards based on user type
    switch (user.userTypeId) {
      case AppConstants.userTypeAdmin:
        routeName = '/admin-dashboard';
        break;
      case AppConstants.userTypeIndustry:
        routeName = '/industry-dashboard';
        break;
      case AppConstants.userTypeDriver:
        routeName = '/driver-dashboard';
        break;
      case AppConstants.userTypeCitizen:
        routeName = '/citizen-dashboard';
        break;
    }

    // Use pushReplacementNamed to replace the login screen
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    // final authProvider = Provider.of<AuthProvider>(context);
    // if (authProvider.isLoggedIn && authProvider.currentUser != null) {
    //   // return const Scaffold(
    //   //   body: Center(
    //   //     child: Text('No user logged in. Please log in again.'),
    //   //   ),
    //   // );
    //   _navigateToDashboard(authProvider.currentUser!);
    // }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo/Header
                        _buildHeader(),
                        const SizedBox(height: 40),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Error Message
                        if (authProvider.error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Text(
                              authProvider.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _login(authProvider),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Test Users Section (Optional - uncomment if needed)
                        // _buildTestUsersSection(authProvider),
                        // const SizedBox(height: 20),
                        const Divider(height: 30),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),

                        // Add some extra space at the bottom for better scrolling
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.recycling, size: 80, color: Colors.green[700]),
        const SizedBox(height: 16),
        const Text(
          'ANEUSO - Waste Management',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login to your account',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget _buildTestUsersSection(AuthProvider authProvider) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Test Users:',
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       Wrap(
  //         spacing: 8,
  //         runSpacing: 8,
  //         children: _testUsers.map((user) {
  //           return ElevatedButton(
  //             onPressed: () => _testLogin(authProvider, user['email']!),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.blue[50],
  //               foregroundColor: Colors.blue,
  //             ),
  //             child: Text(user['label']!),
  //           );
  //         }).toList(),
  //       ),
  //     ],
  //   );
  // }
}
