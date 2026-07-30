import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _fullNameController =
      TextEditingController();

  final TextEditingController
      _businessNameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

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
    _fullNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.register(
      fullName:
          _fullNameController.text.trim(),
      email:
          _emailController.text.trim(),
      phone:
          _phoneController.text.trim(),
      password:
          _passwordController.text.trim(),
      businessName:
          _businessNameController.text
              .trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful. Please login.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Registration failed',
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
          'Provider Registration',
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
                  const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      height: 90,
                      width: 90,
                      decoration:
                          BoxDecoration(
                        color:
                            theme.primaryColor,
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .storefront_rounded,
                        color:
                            Colors.white,
                        size: 45,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(
                      'Create Provider Account',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // FULL NAME

                    TextFormField(
                      controller:
                          _fullNameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Full Name',
                        prefixIcon:
                            Icon(Icons.person),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Full name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // BUSINESS NAME

                    TextFormField(
                      controller:
                          _businessNameController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Business Name',
                        prefixIcon: Icon(
                          Icons.business,
                        ),
                      ),
                      validator:
                          (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Business name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
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
                      height: 16,
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
                            'Password',
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
                                .isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length <
                            6) {
                          return 'Minimum 6 characters required';
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
                                : _register,
                        child:
                            authProvider
                                    .isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors
                                        .white,
                                  )
                                : const Text(
                                    'REGISTER',
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

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