import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      phoneController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account created successfully',
        ),
      ),
    );

    Navigator.pushReplacementNamed(
      context,
      RouteConfig.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Create Account',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color:
                        ThemeConfig.primaryColor,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Join EventEase and start booking services',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 30),

                // FULL NAME

                TextFormField(
                  controller:
                      nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Full Name',
                    hintText:
                        'Enter your full name',
                    prefixIcon:
                        Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // EMAIL

                TextFormField(
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
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
                        value.isEmpty) {
                      return 'Email is required';
                    }

                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+',
                    ).hasMatch(value)) {
                      return 'Enter valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PHONE

                TextFormField(
                  controller:
                      phoneController,
                  keyboardType:
                      TextInputType.phone,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Phone Number',
                    hintText:
                        'Enter phone number',
                    prefixIcon:
                        Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Phone number is required';
                    }

                    if (value.length < 10) {
                      return 'Enter valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // PASSWORD

                TextFormField(
                  controller:
                      passwordController,
                  obscureText:
                      obscurePassword,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Password',
                    hintText:
                        'Create password',
                    prefixIcon:
                        const Icon(
                      Icons.lock,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Password is required';
                    }

                    if (value.length < 6) {
                      return 'Minimum 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // CONFIRM PASSWORD

                TextFormField(
                  controller:
                      confirmPasswordController,
                  obscureText:
                      obscureConfirmPassword,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Confirm Password',
                    hintText:
                        'Re-enter password',
                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                              !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Confirm password';
                    }

                    if (value !=
                        passwordController
                            .text) {
                      return 'Passwords do not match';
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
                        : _signup,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Account',
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    const Text(
                      'Already have an account?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      child: const Text(
                        'Login',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}