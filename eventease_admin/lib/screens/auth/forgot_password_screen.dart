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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // =====================================================
  // SEND OTP
  // =====================================================

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email =
          _emailController.text.trim();

      await _authService.forgotPassword(
        email: email,
      );

      if (!mounted) return;

      NavigationService.showSuccess(
        'OTP sent successfully to your email.',
      );

      Navigator.pushNamed(
        context,
        AppRoutes.otpVerification,
        arguments: {
          'email': email,
          'source': 'forgot_password',
        },
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
                            _buildForgotPasswordCard(),
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
                  'Recover access to your admin account securely.',
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
                  'Enter your registered admin email address. We will send an OTP verification code to help reset your password safely.',
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
                      icon: Icons.email_outlined,
                      label: 'Email OTP',
                    ),
                    _FeatureBadge(
                      icon: Icons.security_outlined,
                      label: 'Secure Reset',
                    ),
                    _FeatureBadge(
                      icon: Icons.lock_reset_outlined,
                      label: 'Password Recovery',
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
  // FORGOT PASSWORD CARD
  // =====================================================

  Widget _buildForgotPasswordCard() {
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
                AppStrings.forgotPassword,
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
                'Enter your registered admin email. We will send an OTP to verify your identity.',
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
                controller: _emailController,
                labelText: AppStrings.email,
                hintText:
                    'Enter registered admin email',
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                validator:
                    AppValidator.email,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              CustomButton(
                text: 'Send OTP',
                icon: Icons.send_rounded,
                isLoading: _isLoading,
                onPressed:
                    _isLoading ? null : _sendOtp,
              ),

              const SizedBox(
                height: AppDimensions.padding16,
              ),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Back to Login',
                  type: ButtonType.outline,
                  icon: Icons.arrow_back_rounded,
                  isEnabled: !_isLoading,
                  onPressed:
                      _isLoading
                          ? null
                          : _goBackToLogin,
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding24,
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
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
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
              'For security, OTP will be sent only to the registered admin email address.',
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}