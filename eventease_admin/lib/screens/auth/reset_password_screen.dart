import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_validator.dart';
import '../../generated/assets.gen.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _newPasswordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _errorMessage;
  String? _email;
  String? _otp;
  String? _source;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _email = args['email']?.toString();
      _otp = args['otp']?.toString();
      _source = args['source']?.toString();
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_email == null ||
        _email!.isEmpty ||
        _otp == null ||
        _otp!.isEmpty) {
      NavigationService.showError(
        'Invalid reset session. Please try again.',
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.forgotPassword,
        (_) => false,
      );

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPassword(
        email: _email!,
        otp: _otp!,
        newPassword:
            _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      NavigationService.showSuccess(
        'Password reset successfully. Please login again.',
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });

      NavigationService.showError(
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // =====================================================
  // BACK TO LOGIN
  // =====================================================

  void _goBackToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  // =====================================================
  // BACK TO OTP
  // =====================================================

  void _goBackToOtp() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.otpVerification,
      arguments: {
        'email': _email,
        'source': _source ?? 'forgot_password',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final bool isDesktop =
              constraints.maxWidth >= 900;

          return SafeArea(
            child: Row(
              children: [
                if (isDesktop)
                  Expanded(
                    flex: 6,
                    child: _buildLeftPanel(),
                  ),

                Expanded(
                  flex: 5,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(
                        AppDimensions.padding24,
                      ),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 460,
                        ),
                        child:
                            _buildResetPasswordCard(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // LEFT PANEL
  // =====================================================

  Widget _buildLeftPanel() {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: _DecorativeCircle(
              size: 260,
              opacity: 0.12,
            ),
          ),

          Positioned(
            bottom: -100,
            left: -90,
            child: _DecorativeCircle(
              size: 320,
              opacity: 0.10,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(
              56,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      padding:
                          const EdgeInsets.all(
                        10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          AppDimensions.radius16,
                        ),
                      ),
                      child: Image.asset(
                        Assets.images.logo,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons
                                .admin_panel_settings_rounded,
                            color:
                                AppColors.primary,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                const Text(
                  'Create a strong new password for your admin account.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight:
                        FontWeight.w800,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Choose a secure password to protect your EventEase Admin access. Use a unique password and avoid reusing old credentials.',
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.88),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 36),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    _FeatureBadge(
                      icon: Icons.lock_reset_outlined,
                      label: 'Reset Password',
                    ),
                    _FeatureBadge(
                      icon: Icons.security_outlined,
                      label: 'Secure Access',
                    ),
                    _FeatureBadge(
                      icon: Icons.verified_user_outlined,
                      label: 'Verified Session',
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  'Version ${AppConfig.appVersion} • ${AppConfig.environmentName}',
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.70),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // RESET PASSWORD CARD
  // =====================================================

  Widget _buildResetPasswordCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius24,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              Text(
                AppStrings.resetPassword,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                _email != null && _email!.isNotEmpty
                    ? 'Set a new password for $_email.'
                    : 'Set a new password for your admin account.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),

              const SizedBox(
                height: AppDimensions.padding32,
              ),

              if (_errorMessage != null) ...[
                InlineErrorWidget(
                  message: _errorMessage!,
                ),
                const SizedBox(
                  height: AppDimensions.padding20,
                ),
              ],

              CustomTextField(
                controller:
                    _newPasswordController,
                labelText: 'New Password',
                hintText:
                    'Enter new password',
                obscureText:
                    _obscureNewPassword,
                textInputAction:
                    TextInputAction.next,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword =
                          !_obscureNewPassword;
                    });
                  },
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons
                            .visibility_off_outlined
                        : Icons
                            .visibility_outlined,
                  ),
                ),
                validator:
                    AppValidator.password,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              const SizedBox(
                height: AppDimensions.padding20,
              ),

              CustomTextField(
                controller:
                    _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText:
                    'Re-enter new password',
                obscureText:
                    _obscureConfirmPassword,
                textInputAction:
                    TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons
                            .visibility_off_outlined
                        : Icons
                            .visibility_outlined,
                  ),
                ),
                validator: (value) {
                  return AppValidator
                      .confirmPassword(
                    password:
                        _newPasswordController.text,
                    confirmPassword: value,
                  );
                },
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              const SizedBox(
                height: AppDimensions.padding16,
              ),

              _buildPasswordGuidelines(),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              CustomButton(
                text: 'Reset Password',
                icon: Icons.lock_reset_rounded,
                isLoading: _isLoading,
                onPressed:
                    _isLoading
                        ? null
                        : _resetPassword,
              ),

              const SizedBox(
                height: AppDimensions.padding16,
              ),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Back to OTP',
                  type: ButtonType.outline,
                  icon:
                      Icons.arrow_back_rounded,
                  isEnabled: !_isLoading,
                  onPressed:
                      _isLoading
                          ? null
                          : _goBackToOtp,
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding12,
              ),

              Center(
                child: TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _goBackToLogin,
                  child: const Text(
                    'Back to Login',
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding20,
              ),

              _buildSecurityNote(),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // LOGO
  // =====================================================

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Container(
            height: 72,
            width: 72,
            padding:
                const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.08),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius20,
              ),
            ),
            child: Image.asset(
              Assets.images.logo,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 38,
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PASSWORD GUIDELINES
  // =====================================================

  Widget _buildPasswordGuidelines() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius12,
        ),
        border: Border.all(
          color: AppColors.warning
              .withOpacity(0.18),
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Password Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            '• Minimum 8 characters\n'
            '• Use uppercase and lowercase letters\n'
            '• Include numbers or special characters\n'
            '• Avoid using old or common passwords',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECURITY NOTE
  // =====================================================

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: AppColors.info
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius12,
        ),
        border: Border.all(
          color: AppColors.info
              .withOpacity(0.18),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.security_outlined,
            color: AppColors.info,
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'After password reset, all previous login sessions may be invalidated for security.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DECORATIVE CIRCLE
// =====================================================

class _DecorativeCircle
    extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(
          opacity,
        ),
      ),
    );
  }
}

// =====================================================
// FEATURE BADGE
// =====================================================

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.12,
        ),
        borderRadius: BorderRadius.circular(
          30,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}