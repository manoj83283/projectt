import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _passwordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword =
      true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.resetPassword(
      email: widget.email,
      otp: widget.otp,
      password:
          _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Password reset successful',
          ),
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
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Failed to reset password',
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
          'Reset Password',
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
                      'Create New Password',
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
                      widget.email,
                      style: theme
                          .textTheme
                          .bodyMedium,
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // PASSWORD

                    TextFormField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            'New Password',
                        prefixIcon:
                            const Icon(
                          Icons.lock,
                        ),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility
                                : Icons
                                    .visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length <
                            6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // CONFIRM PASSWORD

                    TextFormField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Confirm Password',
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                    .visibility
                                : Icons
                                    .visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Confirm password';
                        }

                        if (value !=
                            _passwordController
                                .text) {
                          return 'Passwords do not match';
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
                                : _resetPassword,
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
                                    'RESET PASSWORD',
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