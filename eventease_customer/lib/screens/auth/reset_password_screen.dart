import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? token;

  const ResetPasswordScreen({
    super.key,
    this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  String? _routeToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is String) {
      _routeToken = arguments;
    }

    if (arguments is Map<String, dynamic>) {
      _routeToken = arguments['token']?.toString();
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String get _resetToken {
    return widget.token ?? _routeToken ?? '';
  }

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_resetToken.trim().isEmpty) {
      _showSnackBar(
        message: 'Reset token is missing. Please request password reset again.',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final bool success = await AuthService.instance.resetPassword(
        token: _resetToken.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (!success) {
        _showSnackBar(
          message: 'Failed to reset password. Please try again.',
          backgroundColor: Colors.red,
        );
        return;
      }

      _showSnackBar(
        message: 'Password reset successful',
        backgroundColor: Colors.green,
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteConfig.login,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
      );
    }
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
        ),
      ),
    );
  }

  String? _passwordValidator(String? value) {
    final String password = value?.trim() ?? '';

    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Password must contain at least one letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final String confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm password';
    }

    if (confirmPassword != passwordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  Widget _buildHeaderIcon() {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          24,
        ),
      ),
      child: const Icon(
        Icons.lock_reset,
        size: 60,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'New Password',
        hintText: 'Enter new password',
        prefixIcon: const Icon(
          Icons.lock,
        ),
        suffixIcon: IconButton(
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: _passwordValidator,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        if (!isLoading) {
          resetPassword();
        }
      },
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter password',
        prefixIcon: const Icon(
          Icons.lock_outline,
        ),
        suffixIcon: IconButton(
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    obscureConfirmPassword = !obscureConfirmPassword;
                  });
                },
          icon: Icon(
            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: _confirmPasswordValidator,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : resetPassword,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Reset Password',
              ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return TextButton.icon(
      onPressed: isLoading
          ? null
          : () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteConfig.login,
                (route) => false,
              );
            },
      icon: const Icon(
        Icons.arrow_back,
      ),
      label: const Text(
        'Back to Login',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reset Password',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeaderIcon(),
                const SizedBox(height: 30),
                const Text(
                  'Create New Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your new password must be different from previously used passwords.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 35),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 35),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}