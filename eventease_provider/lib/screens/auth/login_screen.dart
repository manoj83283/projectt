import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success =
        await authProvider.login(
      email: _emailController.text
          .trim(),
      password:
          _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DashboardScreen(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Login failed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),

                    // LOGO

                    Center(
                      child: Container(
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
                          Icons
                              .event_available,
                          color:
                              Colors.white,
                          size: 55,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Welcome Back',
                      textAlign:
                          TextAlign.center,
                      style: theme
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Login to manage your EventEase business',
                      textAlign:
                          TextAlign.center,
                      style: theme
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(
                      height: 36,
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
                      validator: (
                        value,
                      ) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Email is required';
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
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility
                                : Icons
                                    .visibility_off,
                          ),
                        ),
                      ),
                      validator: (
                        value,
                      ) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Password is required';
                        }

                        if (value.length < 6) {
                          return 'Minimum 6 characters required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Align(
                      alignment:
                          Alignment
                              .centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // LOGIN BUTTON

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            authProvider
                                    .isLoading
                                ? null
                                : _login,
                        child:
                            authProvider
                                    .isLoading
                                ? const SizedBox(
                                    height:
                                        22,
                                    width:
                                        22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'LOGIN',
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
                          "Don't have an account?",
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Register',
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