import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
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

    Navigator.pushReplacementNamed(
      context,
      RouteConfig.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
                const SizedBox(height: 50),

                // ==================================
                // LOGO
                // ==================================

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
                    Icons.event_available,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Login to continue using EventEase',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // ==================================
                // EMAIL
                // ==================================

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

                // ==================================
                // PASSWORD
                // ==================================

                TextFormField(
                  controller:
                      passwordController,
                  obscureText:
                      obscurePassword,
                  decoration:
                      InputDecoration(
                    labelText: 'Password',
                    hintText:
                        'Enter password',
                    prefixIcon:
                        const Icon(
                      Icons.lock,
                    ),
                    suffixIcon: IconButton(
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

                const SizedBox(height: 10),

                // ==================================
                // FORGOT PASSWORD
                // ==================================

                Align(
                  alignment:
                      Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig
                            .forgotPassword,
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================
                // LOGIN BUTTON
                // ==================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : _login,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================
                // DIVIDER
                // ==================================

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors
                            .grey.shade300,
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text('OR'),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors
                            .grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================
                // GOOGLE LOGIN
                // ==================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.g_mobiledata,
                    ),
                    label: const Text(
                      'Continue with Google',
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================
                // SIGNUP
                // ==================================

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
                        Navigator.pushNamed(
                          context,
                          RouteConfig
                              .signup,
                        );
                      },
                      child: const Text(
                        'Sign Up',
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