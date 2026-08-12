import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      emailController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // TODO:
      // Call backend API here
      // POST /api/auth/forgot-password

      await Future.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Password reset link sent to ${emailController.text}',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Forgot Password',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: ThemeConfig
                        .primaryColor
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 60,
                    color:
                        ThemeConfig.primaryColor,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Enter your registered email address. We will send a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                TextFormField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                    hintText:
                        'Enter your email',
                    prefixIcon:
                        Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Email is required';
                    }

                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value)) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : _sendResetLink,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Reset Link',
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                  label: const Text(
                    'Back to Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}