import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../providers/auth_provider.dart';
import '../widgets/loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String _completePhoneNumber = '';
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _completePhoneNumber = user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final success = await authProvider.updateProfileWithPassword(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _completePhoneNumber,
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _showPasswordFields
          ? _newPasswordController.text.trim()
          : '',
    );

    if (mounted) {
      final message =
          authProvider.error ??
          (success
              ? 'Profile updated successfully'
              : 'Failed to update profile');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (success) {
        setState(() {
          _showPasswordFields = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'No user data',
                style: TextStyle(fontSize: 18, color: Color(0xFF4E56C0)),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Color(0xFFFDCFFA).withOpacity(0.05),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [Color(0xFF4E56C0), Color(0xFF9B5DE0)],
                ).createShader(bounds);
              },
              child: Text(
                'My Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF4E56C0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF4E56C0),
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4E56C0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.save_rounded,
                    color: Color(0xFF4E56C0),
                    size: 22,
                  ),
                ),
                onPressed: () => _saveProfile(authProvider),
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4E56C0).withOpacity(0.9),
                          Color(0xFF9B5DE0).withOpacity(0.9),
                          Color(0xFFD78FEE).withOpacity(0.9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4E56C0).withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFFDCFFA)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4E56C0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_rounded,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      user.phoneNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User Info Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Color(0xFF4E56C0).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          'User Type',
                          user.userType,
                          Icons.person_rounded,
                          Color(0xFF4E56C0),
                        ),
                        _buildInfoItem(
                          'Status',
                          user.isActive ? 'Active' : 'Inactive',
                          Icons.circle_rounded,
                          user.isActive ? Color(0xFF4E56C0) : Color(0xFF9B5DE0),
                        ),
                        _buildInfoItem(
                          'Email Verified',
                          user.isEmailVerified ? 'Verified' : 'Pending',
                          Icons.verified_rounded,
                          user.isEmailVerified
                              ? Color(0xFF4E56C0)
                              : Color(0xFF9B5DE0),
                        ),
                      ],
                    ),
                  ),

                  // Profile Form Card
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Section Title
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4E56C0).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: Color(0xFF4E56C0),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Edit Profile Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4E56C0),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),

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
                                  color: Color(0xFF4E56C0).withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: IntlPhoneField(
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(
                                  color: Color(0xFF9B5DE0).withOpacity(0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(18),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Color(0xFF4E56C0).withOpacity(0.5),
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
                              initialValue: _completePhoneNumber,
                              onChanged: (phone) {
                                setState(() {
                                  _completePhoneNumber = phone.completeNumber;
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
                          ),
                          SizedBox(height: 30),

                          // Change Password Section
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPasswordFields = !_showPasswordFields;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _showPasswordFields
                                    ? Color(0xFF4E56C0).withOpacity(0.05)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _showPasswordFields
                                      ? Color(0xFF4E56C0).withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _showPasswordFields
                                              ? Color(0xFF4E56C0)
                                              : Colors.grey.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock_rounded,
                                          color: _showPasswordFields
                                              ? Colors.white
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        _showPasswordFields
                                            ? 'Hide Change Password'
                                            : 'Change Password',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _showPasswordFields
                                              ? Color(0xFF4E56C0)
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    _showPasswordFields
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: Color(0xFF4E56C0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: _showPasswordFields ? 20 : 0),

                          if (_showPasswordFields) ...[
                            // Current Password Field
                            _buildStyledTextField(
                              controller: _currentPasswordController,
                              label: 'Current Password',
                              icon: Icons.lock_rounded,
                              isPassword: true,
                              isVisible: _isPasswordVisible,
                              onVisibilityChanged: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (_showPasswordFields &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter your current password';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),

                            // New Password Field
                            _buildStyledTextField(
                              controller: _newPasswordController,
                              label: 'New Password',
                              icon: Icons.lock_reset_rounded,
                              isPassword: true,
                              isVisible: _isNewPasswordVisible,
                              onVisibilityChanged: () {
                                setState(() {
                                  _isNewPasswordVisible =
                                      !_isNewPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (_showPasswordFields &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter a new password';
                                }
                                if (_showPasswordFields &&
                                    value != null &&
                                    value.length < 6) {
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
                                if (_showPasswordFields &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please confirm your password';
                                }
                                if (_showPasswordFields &&
                                    value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30),
                          ],

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _saveProfile(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4E56C0),
                                      Color(0xFF9B5DE0),
                                      Color(0xFFD78FEE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF4E56C0).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'SAVE CHANGES',
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Security Note
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFFDCFFA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(0xFFD78FEE).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security_rounded,
                          color: Color(0xFF4E56C0),
                          size: 24,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            'Your personal information is protected with advanced security measures.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4E56C0).withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Center(child: Icon(icon, color: color, size: 24)),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
