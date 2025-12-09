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

  String getCompletePhoneNumber() {
    return _completePhoneNumber;
  }

  String getPhoneNumberOnly() {
    return _phoneNumberOnly;
  }

  String getCountryCode() {
    return _countryCode;
  }

  Future<void> _register(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

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
      phoneNumber: getCompletePhoneNumber(),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4E56C0),
              Color(0xFF9B5DE0),
              Color(0xFFD78FEE),
              Color(0xFFFDCFFA),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [Colors.white, Color(0xFFFDCFFA)],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4E56C0).withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return LoadingOverlay(
                    isLoading: authProvider.isLoading,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Welcome Card
                          Container(
                            padding: const EdgeInsets.all(25),
                            margin: const EdgeInsets.only(bottom: 30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF4E56C0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF4E56C0,
                                        ).withOpacity(0.5),
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.recycling_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Join ANEUSO',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Create your account to manage waste efficiently',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Registration Form Card
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Full Name Field
                                  _buildStyledTextField(
                                    controller: _fullNameController,
                                    label: 'Full Name',
                                    icon: Icons.person_rounded,
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
                                  SizedBox(height: 20),

                                  // Email Field
                                  _buildStyledTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email_rounded,
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
                                  SizedBox(height: 20),

                                  // Phone Number Field
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF4E56C0,
                                          ).withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IntlPhoneField(
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        labelStyle: TextStyle(
                                          color: Color(
                                            0xFF9B5DE0,
                                          ).withOpacity(0.7),
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(18),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          borderSide: BorderSide(
                                            color: Color(
                                              0xFF4E56C0,
                                            ).withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Color(0xFF4E56C0),
                                        fontSize: 16,
                                      ),
                                      dropdownTextStyle: TextStyle(
                                        color: Color(0xFF4E56C0),
                                      ),
                                      initialCountryCode: 'PK',
                                      onChanged: (phone) {
                                        setState(() {
                                          _completePhoneNumber =
                                              phone.completeNumber;
                                          _countryCode = phone.countryCode;
                                          _phoneNumberOnly = phone.number;
                                        });
                                      },
                                      onCountryChanged: (country) {
                                        setState(() {
                                          _countryCode = country.code;
                                        });
                                      },
                                      validator: (phone) {
                                        if (phone == null ||
                                            phone.number.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        if (phone.number.length < 7) {
                                          return 'Please enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // User Type Dropdown
                                  Builder(
                                    builder: (ctx) {
                                      final auth = Provider.of<AuthProvider>(
                                        ctx,
                                      );
                                      if (auth.isLoadingUserTypes) {
                                        return Container(
                                          padding: EdgeInsets.all(18),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF9B5DE0),
                                            ),
                                          ),
                                        );
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                0xFF4E56C0,
                                              ).withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonFormField<int>(
                                          value: _selectedUserType,
                                          decoration: InputDecoration(
                                            labelText: 'User Type',
                                            labelStyle: TextStyle(
                                              color: Color(
                                                0xFF9B5DE0,
                                              ).withOpacity(0.7),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.group_rounded,
                                              color: Color(0xFF9B5DE0),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(18),
                                            filled: true,
                                            fillColor: Colors.white,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: Color(
                                                  0xFF4E56C0,
                                                ).withOpacity(0.5),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Color(0xFF4E56C0),
                                            fontSize: 16,
                                          ),
                                          dropdownColor: Colors.white,
                                          items: auth.userTypes
                                              .map(
                                                (type) => DropdownMenuItem<int>(
                                                  value: type.id,
                                                  child: Text(
                                                    type.typeName.toString(),
                                                    style: TextStyle(
                                                      color: Color(0xFF4E56C0),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (value) async {
                                            setState(() {
                                              _selectedUserType = value;
                                              _selectedDesignationId = null;
                                            });

                                            if (value ==
                                                AppConstants.userTypeIndustry) {
                                              await auth
                                                  .fetchIndustryDesignations();
                                            }
                                          },
                                          validator: (value) {
                                            if (value == null) {
                                              return 'Please select a user type';
                                            }
                                            return null;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),

                                  // Designation Dropdown
                                  if (_selectedUserType ==
                                      AppConstants.userTypeIndustry)
                                    Builder(
                                      builder: (ctx) {
                                        final auth = Provider.of<AuthProvider>(
                                          ctx,
                                        );
                                        if (auth.isLoadingDesignations) {
                                          return Container(
                                            padding: EdgeInsets.all(18),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF9B5DE0),
                                              ),
                                            ),
                                          );
                                        }

                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(
                                                  0xFF4E56C0,
                                                ).withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: DropdownButtonFormField<int>(
                                            value: _selectedDesignationId,
                                            decoration: InputDecoration(
                                              labelText: 'Designation',
                                              labelStyle: TextStyle(
                                                color: Color(
                                                  0xFF9B5DE0,
                                                ).withOpacity(0.7),
                                              ),
                                              prefixIcon: Icon(
                                                Icons.work_rounded,
                                                color: Color(0xFF9B5DE0),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.all(
                                                18,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide(
                                                  color: Color(
                                                    0xFF4E56C0,
                                                  ).withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            style: TextStyle(
                                              color: Color(0xFF4E56C0),
                                              fontSize: 16,
                                            ),
                                            dropdownColor: Colors.white,
                                            items: auth.designations
                                                .map(
                                                  (d) => DropdownMenuItem<int>(
                                                    value: d.id,
                                                    child: Text(
                                                      d.designationName
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF4E56C0,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedDesignationId = value;
                                              });
                                            },
                                            validator: (value) {
                                              if (_selectedUserType ==
                                                      AppConstants
                                                          .userTypeIndustry &&
                                                  value == null) {
                                                return 'Please select a designation';
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      },
                                    ),

                                  if (_selectedUserType ==
                                      AppConstants.userTypeIndustry)
                                    SizedBox(height: 20),

                                  // Password Field
                                  _buildStyledTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    icon: Icons.lock_rounded,
                                    isPassword: true,
                                    isVisible: _isPasswordVisible,
                                    onVisibilityChanged: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
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
                                  SizedBox(height: 20),

                                  // Confirm Password Field
                                  _buildStyledTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password',
                                    icon: Icons.lock_outline_rounded,
                                    isPassword: true,
                                    isVisible: _isConfirmPasswordVisible,
                                    onVisibilityChanged: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
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

                                  // Error Message
                                  if (authProvider.error != null) ...[
                                    SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              authProvider.error!,
                                              style: TextStyle(
                                                color: Colors.red[800],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  SizedBox(height: 30),

                                  // Register Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () => _register(authProvider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFF4E56C0),
                                              Color(0xFF9B5DE0),
                                              Color(0xFFD78FEE),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                0xFF4E56C0,
                                              ).withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_add_alt_1_rounded,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'CREATE ACCOUNT',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 25),

                                  // Login Link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account?',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 15,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                        ),
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Colors.white,
                                            decorationThickness: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Terms and Privacy
                          Text(
                            'By creating an account, you agree to our Terms and Privacy Policy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4E56C0).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Color(0xFF4E56C0), fontSize: 16),
        keyboardType: keyboardType,
        obscureText: isPassword && !isVisible,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF9B5DE0).withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Color(0xFF9B5DE0)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Color(0xFFD78FEE),
                  ),
                  onPressed: onVisibilityChanged,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Color(0xFF4E56C0).withOpacity(0.5),
              width: 2,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
