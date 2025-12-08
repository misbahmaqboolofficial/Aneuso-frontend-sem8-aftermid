import 'dart:convert';

import 'package:aneuso_app/core/utils/storage_util.dart';
import 'package:aneuso_app/data/models/user_model.dart';
import 'package:aneuso_app/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int? _selectedUserType;
  int? _selectedDesignationId;

  // Phone number variables
  String _completePhoneNumber = '';
  String _countryCode = '';
  String _phoneNumberOnly = '';

  // Password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // user types and designations are loaded from the API via AuthProvider

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.fetchUserTypes().then((_) {
        setState(() {
          // Set default user type if available (prefer citizen constant)
          final types = auth.userTypes;
          if (types.isNotEmpty) {
            final found = types.firstWhere(
              (t) => t.id == AppConstants.userTypeCitizen,
              orElse: () => types.first,
            );
            _selectedUserType = found.id;
          }
        });
      });
    });
  }

  // Method to get complete phone number with country code
  String getCompletePhoneNumber() {
    return _completePhoneNumber;
  }

  // Method to get phone number without country code
  String getPhoneNumberOnly() {
    return _phoneNumberOnly;
  }

  // Method to get country code
  String getCountryCode() {
    return _countryCode;
  }

  Future<void> _register(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate phone number
    if (_completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phoneNumber: getCompletePhoneNumber(), // Pass phone with country code
      userTypeId: _selectedUserType!,
      designationId: _selectedDesignationId,
    );

    if (success && mounted) {
      UserModel user = UserModel.fromJson(
        jsonDecode(StorageUtil.getStringData("temp_user")!),
      );
      if (user.emailVerifiedAt != null) {
        String routeName = '/login';
        Navigator.pushReplacementNamed(context, routeName);
      } else {
        // Navigate to OTP verification screen
        final email = _emailController.text.trim();
        Navigator.pushReplacementNamed(
          context,
          '/otp-verification',
          arguments: {
            'email': email,
            'purpose': 'registration',
            'user': UserEntity(
              id: user.id,
              fullName: user.fullName,
              email: user.email,
              phoneNumber: user.phoneNumber,
              userTypeId: user.userTypeId,
              designationId: user.designationId,
              activeStatus: user.activeStatus,
              emailVerifiedAt: user.emailVerifiedAt,
            ),
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Full Name Field
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // International Phone Number Field
                    IntlPhoneField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      initialCountryCode: 'PK', // Default to Pakistan
                      onChanged: (phone) {
                        // In version 3.2.0, the phone parameter is a PhoneNumber object
                        setState(() {
                          _completePhoneNumber = phone.completeNumber;
                          _countryCode = phone.countryCode;
                          _phoneNumberOnly = phone.number;
                        });
                      },
                      onCountryChanged: (country) {
                        print('Country changed to: ${country.name}');
                        setState(() {
                          _countryCode = country.code;
                        });
                      },
                      validator: (phone) {
                        if (phone == null || phone.number.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (phone.number.length < 7) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // User Type Dropdown (loaded from API)
                    Builder(
                      builder: (ctx) {
                        final auth = Provider.of<AuthProvider>(ctx);
                        if (auth.isLoadingUserTypes) {
                          return const SizedBox(
                            height: 56,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final items = auth.userTypes
                            .map(
                              (type) => DropdownMenuItem<int>(
                                value: type.id,
                                child: Text(type.typeName.toString()),
                              ),
                            )
                            .toList();

                        return DropdownButtonFormField<int>(
                          value: _selectedUserType,
                          decoration: const InputDecoration(
                            labelText: 'User Type',
                            prefixIcon: Icon(Icons.group),
                            border: OutlineInputBorder(),
                          ),
                          items: items,
                          onChanged: (value) async {
                            setState(() {
                              _selectedUserType = value;
                              _selectedDesignationId = null;
                            });

                            // If Industry selected, load designations
                            if (value == AppConstants.userTypeIndustry) {
                              await auth.fetchIndustryDesignations();
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a user type';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Designation Dropdown (only for Industry users)
                    if (_selectedUserType == AppConstants.userTypeIndustry)
                      Builder(
                        builder: (ctx) {
                          final auth = Provider.of<AuthProvider>(ctx);
                          if (auth.isLoadingDesignations) {
                            return const SizedBox(
                              height: 56,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final items = auth.designations
                              .map(
                                (d) => DropdownMenuItem<int>(
                                  value: d.id,
                                  child: Text(d.designationName.toString()),
                                ),
                              )
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<int>(
                                value: _selectedDesignationId,
                                decoration: const InputDecoration(
                                  labelText: 'Designation',
                                  prefixIcon: Icon(Icons.work),
                                  border: OutlineInputBorder(),
                                ),
                                items: items,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDesignationId = value;
                                  });
                                },
                                validator: (value) {
                                  if (_selectedUserType ==
                                          AppConstants.userTypeIndustry &&
                                      value == null) {
                                    return 'Please select a designation';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),

                    // Password Field with Show/Hide Icon
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
                    const SizedBox(height: 16),

                    // Confirm Password Field with Show/Hide Icon
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    // Debug info for phone number (optional - remove in production)
                    // if (_completePhoneNumber.isNotEmpty) ...[
                    //   const SizedBox(height: 8),
                    //   Text(
                    //     'Phone with country code: $_completePhoneNumber',
                    //     style: const TextStyle(
                    //       fontSize: 12,
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                    // ],

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

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _register(authProvider),
                        child: const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.recycling, size: 60, color: Colors.green[700]),
        const SizedBox(height: 16),
        const Text(
          'Join ANEUSO - Waste Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account to get started',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
