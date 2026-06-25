import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_util.dart';
import '../../../core/utils/form_validators.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/loading_overlay.dart';
import 'package:aneuso_app/core/utils/screen_title_util.dart';

final String _kScreenTitle = ScreenTitle.fromFile('otp_verification_screen.dart');

class OtpVerificationScreen extends StatefulWidget {
  final UserEntity? user;
  final String email;
  final String purpose;

  const OtpVerificationScreen({
    Key? key,
    this.user,
    required this.email,
    required this.purpose,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String get _verificationEmail {
    if (widget.email.trim().isNotEmpty) {
      return widget.email.trim().toLowerCase();
    }
    return StorageUtil.getStringData('pending_otp_email')?.trim().toLowerCase() ?? '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapOtpSession());

    // Setup OTP field focus management
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {
        if (!_otpFocusNodes[i].hasFocus) {
          _updateOtpController();
        }
      });
    }
  }

  void _updateOtpController() {
    _otpController.text = _otpFromBoxes();
  }

  String _otpFromBoxes() {
    return _otpControllers.map((c) => c.text.trim()).join();
  }

  void _fillOtpBoxes(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].text = i < clean.length ? clean[i] : '';
    }
    _updateOtpController();
    if (clean.length >= 6) {
      FocusScope.of(context).unfocus();
    } else if (clean.isNotEmpty) {
      final next = clean.length.clamp(0, 5);
      FocusScope.of(context).requestFocus(_otpFocusNodes[next]);
    }
  }

  void _handleOtpInput(int index, String value) {
    if (value.length > 1) {
      _fillOtpBoxes(value);
      return;
    }
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
      }
    }
    _updateOtpController();
  }

  Future<void> _bootstrapOtpSession() async {
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    var email = _verificationEmail;
    if (email.isEmpty) {
      email = auth.otpVerificationEmail?.trim().toLowerCase() ?? '';
    }
    if (email.isNotEmpty) {
      await StorageUtil.setStringData('pending_otp_email', email);
      auth.startOtpVerification(email: email, purpose: widget.purpose);
    } else {
      auth.ensureOtpCountdownRunning();
      auth.ensureOtpSession(email: '', purpose: widget.purpose);
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).ensureOtpCountdownRunning();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOtp(AuthProvider authProvider) async {
    _updateOtpController();
    final otp = _otpFromBoxes();

    final otpError = FormValidators.otpCode(otp);
    if (otpError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(otpError), backgroundColor: Colors.red.shade400),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    if (_verificationEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email missing — go back and sign up again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    authProvider.ensureOtpSession(
      email: _verificationEmail,
      purpose: widget.purpose,
    );

    final success = await authProvider.verifyOtp(
      otp: otp,
      user: widget.user,
    );

    if (success && mounted) {
      await StorageUtil.removeStringData('pending_otp_email');
      _navigateToDashboard(authProvider.currentUser!);
    }
  }

  void _navigateToDashboard(UserEntity user) {
    String routeName = '/dashboard';
    switch (user.userTypeId) {
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
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_kScreenTitle),
        backgroundColor: const Color(0xFF6F38C5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6F38C5),
              Color(0xFF9B5DE0),
              Color(0xFFD78FEE),
              Color(0xFFFDCFFA),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return LoadingOverlay(
                isLoading: authProvider.isVerifyingOtp,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () {
                            final auth = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            auth.cancelOtpVerification();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
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
                        ),
                      ),
                      SizedBox(height: 20),

                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Animated Verification Icon
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.white, Color(0xFFFDCFFA)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.verified_user_rounded,
                                size: 50,
                                color: Color(0xFF6F38C5),
                              ),
                            ),
                            SizedBox(height: 20),

                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [Colors.white, Color(0xFFFDCFFA)],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'Verify Your Email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),

                            Text(
                              'Enter the 6-digit code sent to your email',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),

                      // Email Display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF6F38C5),
                              ),
                              child: Icon(
                                Icons.email_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verification code sent to:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.email,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),

                      // OTP Input Fields
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              'Enter 6-digit Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),

                            // OTP Boxes
                            Row(
                              children: List.generate(6, (index) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompactPhone(context) ? 3 : 4,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 0.85,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                0xFF6F38C5,
                                              ).withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: TextFormField(
                                          controller: _otpControllers[index],
                                          focusNode: _otpFocusNodes[index],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          textAlign: TextAlign.center,
                                          maxLength: 1,
                                          style: TextStyle(
                                            fontSize: isCompactPhone(context) ? 22 : 28,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF6F38C5),
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Color(0xFF9B5DE0),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            _handleOtpInput(index, value);
                                          },
                                          validator: FormValidators.otpDigit,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 10),

                            // Validation message
                            if (_otpController.text.isNotEmpty &&
                                _otpController.text.length != 6)
                              Text(
                                'Please enter all 6 digits',
                                style: TextStyle(
                                  color: Colors.red[100],
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),

                      // Timer and Resend Section
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Code expires in: ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 4),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: authProvider.otpTimeoutSeconds <= 30
                                        ? Colors.red.withOpacity(0.3)
                                        : Color(0xFF6F38C5).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _formatTime(authProvider.otpTimeoutSeconds),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // Resend Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    authProvider.otpTimeoutSeconds <= 0 &&
                                        !authProvider.isResendingOtp
                                    ? () async {
                                        bool isSent = await authProvider
                                            .resendOtp();
                                        if (mounted && isSent) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'OTP resent successfully!',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                authProvider.error ??
                                                    'Failed to resend OTP',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.zero,
                                  disabledBackgroundColor: Colors.grey
                                      .withOpacity(0.3),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient:
                                        authProvider.otpTimeoutSeconds <= 0 &&
                                            !authProvider.isResendingOtp
                                        ? LinearGradient(
                                            colors: [
                                              Color(0xFFD78FEE),
                                              Color(0xFF9B5DE0),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow:
                                        authProvider.otpTimeoutSeconds <= 0 &&
                                            !authProvider.isResendingOtp
                                        ? [
                                            BoxShadow(
                                              color: Color(
                                                0xFF9B5DE0,
                                              ).withOpacity(0.4),
                                              blurRadius: 15,
                                              offset: Offset(0, 8),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: authProvider.isResendingOtp
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.refresh_rounded,
                                                color:
                                                    authProvider
                                                            .otpTimeoutSeconds <=
                                                        0
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(
                                                        0.5,
                                                      ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'RESEND CODE',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      authProvider
                                                              .otpTimeoutSeconds <=
                                                          0
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withOpacity(0.5),
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
                      SizedBox(height: 30),

                      // Error Message
                      if (authProvider.error != null) ...[
                        Container(
                          width: double.infinity,
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
                        SizedBox(height: 20),
                      ],

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _verifyOtp(authProvider),
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
                                  Color(0xFF6F38C5),
                                  Color(0xFF9B5DE0),
                                  Color(0xFFD78FEE),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6F38C5).withOpacity(0.4),
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
                                    Icons.verified_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'VERIFY & CONTINUE',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
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
                      SizedBox(height: 20),

                      // Help Text
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Didn\'t receive a code? Check your email and spam folder.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
