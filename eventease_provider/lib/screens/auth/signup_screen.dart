import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  final TextEditingController _businessNameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      businessName: _businessNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sign up successful. Please login.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Sign up failed. Please try again.',
          ),
        ),
      );
    }
  }

  String? _requiredValidator(
    String? value,
    String message,
  ) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    final isValidEmail = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    ).hasMatch(email);

    if (!isValidEmail) {
      return 'Enter valid email';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    final phone = value.trim();

    if (phone.length < 10) {
      return 'Enter valid mobile number';
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Minimum 6 characters required';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Provider Sign Up',
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
              padding: const EdgeInsets.all(20),
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
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(
                      'Create Provider Account',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // =========================
                    // FIRST NAME
                    // =========================

                    TextFormField(
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                      ),
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          'First name is required',
                        );
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // LAST NAME
                    // =========================

                    TextFormField(
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          'Last name is required',
                        );
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // BUSINESS NAME
                    // =========================

                    TextFormField(
                      controller: _businessNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        prefixIcon: Icon(
                          Icons.business,
                        ),
                      ),
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          'Business name is required',
                        );
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // EMAIL
                    // =========================

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(
                          Icons.email,
                        ),
                      ),
                      validator: _emailValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // PHONE
                    // =========================

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                      ),
                      validator: _phoneValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // PASSWORD
                    // =========================

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: _passwordValidator,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // =========================
                    // CONFIRM PASSWORD
                    // =========================

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: _confirmPasswordValidator,
                      onFieldSubmitted: (_) {
                        if (!authProvider.isLoading) {
                          _signup();
                        }
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // =========================
                    // SIGN UP BUTTON
                    // =========================

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : _signup,
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'SIGN UP',
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================
                    // LOGIN LINK
                    // =========================

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
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