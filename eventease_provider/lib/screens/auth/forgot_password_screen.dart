import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.sendOtp(
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phone:
                _phoneController.text.trim(),
            email:
                _emailController.text.trim(),
            isForgotPassword: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Failed to send OTP',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
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
                      height: 110,
                      width: 110,
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
                        Icons.lock_reset,
                        color:
                            Colors.white,
                        size: 55,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Forgot Password?',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Enter your registered email and mobile number to receive OTP.',
                      textAlign:
                          TextAlign.center,
                      style: theme
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // EMAIL

                    TextFormField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Email Address',
                        prefixIcon:
                            Icon(Icons.email),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Email is required';
                        }

                        if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+',
                        ).hasMatch(
                          value,
                        )) {
                          return 'Enter valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // PHONE

                    TextFormField(
                      controller:
                          _phoneController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Mobile Number',
                        prefixIcon:
                            Icon(Icons.phone),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Mobile number is required';
                        }

                        if (value.length <
                            10) {
                          return 'Enter valid mobile number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 32,
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
                                : _sendOtp,
                        child:
                            authProvider
                                    .isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'SEND OTP',
                                  ),
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