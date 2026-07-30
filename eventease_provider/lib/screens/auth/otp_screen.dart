import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String? email;
  final bool isForgotPassword;

  const OtpScreen({
    super.key,
    required this.phone,
    this.email,
    this.isForgotPassword = false,
  });

  @override
  State<OtpScreen> createState() =>
      _OtpScreenState();
}

class _OtpScreenState
    extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _otpController =
      TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.verifyOtp(
      phone: widget.phone,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      if (widget.isForgotPassword &&
          widget.email != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ResetPasswordScreen(
              email: widget.email!,
              otp: _otpController.text
                  .trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('OTP Verified Successfully'),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Invalid OTP',
          ),
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.sendOtp(
      phone: widget.phone,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'OTP sent successfully'
              : 'Failed to send OTP',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OTP Verification',
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (
            context,
            authProvider,
            child,
          ) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),

                    Container(
                      height: 100,
                      width: 100,
                      decoration:
                          BoxDecoration(
                        color:
                            theme.primaryColor,
                        borderRadius:
                            BorderRadius
                                .circular(
                          24,
                        ),
                      ),
                      child: const Icon(
                        Icons.sms_rounded,
                        size: 50,
                        color:
                            Colors.white,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Verify OTP',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Enter the OTP sent to\n${widget.phone}',
                      textAlign:
                          TextAlign.center,
                      style: theme
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(
                      height: 35,
                    ),

                    TextFormField(
                      controller:
                          _otpController,
                      keyboardType:
                          TextInputType
                              .number,
                      maxLength: 6,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight:
                            FontWeight.bold,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Enter OTP',
                        prefixIcon:
                            Icon(
                          Icons.lock_clock,
                        ),
                        counterText: '',
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'OTP is required';
                        }

                        if (value.length !=
                            6) {
                          return 'Enter valid OTP';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,
                      child:
                          ElevatedButton(
                        onPressed:
                            authProvider
                                    .isLoading
                                ? null
                                : _verifyOtp,
                        child:
                            authProvider
                                    .isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors
                                        .white,
                                  )
                                : const Text(
                                    'VERIFY OTP',
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    TextButton.icon(
                      onPressed:
                          authProvider
                                  .isLoading
                              ? null
                              : _resendOtp,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Resend OTP',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}