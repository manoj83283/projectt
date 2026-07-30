import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
  });

  @override
  State<OtpScreen> createState() =>
      _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _otpController =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isResending = false;

  String? _errorMessage;
  String? _email;
  String? _source;

  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _email = args['email']?.toString();
      _source = args['source']?.toString();
    }

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();

    super.dispose();
  }

  // =====================================================
  // START TIMER
  // =====================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_remainingSeconds <= 0) {
          timer.cancel();
          return;
        }

        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  // =====================================================
  // VERIFY OTP
  // =====================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_email == null || _email!.isEmpty) {
      NavigationService.showError(
        'Email not found. Please try again.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otp =
          _otpController.text.trim();

      await _authService.verifyOtp(
        email: _email!,
        otp: otp,
      );

      if (!mounted) return;

      NavigationService.showSuccess(
        'OTP verified successfully.',
      );

      Navigator.pushNamed(
        context,
        AppRoutes.resetPassword,
        arguments: {
          'email': _email,
          'otp': otp,
          'source': _source ??
              'forgot_password',
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
  // RESEND OTP
  // =====================================================

  Future<void> _resendOtp() async {
    if (_email == null || _email!.isEmpty) {
      NavigationService.showError(
        'Email not found. Please try again.',
      );
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await _authService.forgotPassword(
        email: _email!,
      );

      if (!mounted) return;

      _otpController.clear();

      _startTimer();

      NavigationService.showSuccess(
        'OTP resent successfully.',
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
          _isResending = false;
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
  // BACK TO FORGOT PASSWORD
  // =====================================================

  void _goBackToForgotPassword() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.forgotPassword,
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
                        child: _buildOtpCard(),
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
                  'Verify your admin identity securely.',
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
                  'Enter the one-time password sent to your registered admin email. This keeps EventEase Admin protected from unauthorized access.',
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
                      icon:
                          Icons.mark_email_read_outlined,
                      label: 'Email OTP',
                    ),
                    _FeatureBadge(
                      icon: Icons.lock_outline,
                      label: 'Secure',
                    ),
                    _FeatureBadge(
                      icon:
                          Icons.verified_user_outlined,
                      label: 'Verified Access',
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
  // OTP CARD
  // =====================================================

  Widget _buildOtpCard() {
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
                AppStrings.otpVerification,
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
                _email != null &&
                        _email!.isNotEmpty
                    ? 'Enter the 6-digit OTP sent to $_email.'
                    : 'Enter the 6-digit OTP sent to your registered email.',
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
                controller: _otpController,
                labelText: 'OTP Code',
                hintText: 'Enter 6-digit OTP',
                keyboardType:
                    TextInputType.number,
                textInputAction:
                    TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.password_rounded,
                ),
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                  LengthLimitingTextInputFormatter(
                    6,
                  ),
                ],
                validator:
                    AppValidator.otp,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              const SizedBox(
                height: AppDimensions.padding12,
              ),

              _buildResendSection(),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              CustomButton(
                text: 'Verify OTP',
                icon: Icons.verified_rounded,
                isLoading: _isLoading,
                onPressed:
                    _isLoading ? null : _verifyOtp,
              ),

              const SizedBox(
                height: AppDimensions.padding16,
              ),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Change Email',
                  type: ButtonType.outline,
                  icon:
                      Icons.arrow_back_rounded,
                  isEnabled:
                      !_isLoading && !_isResending,
                  onPressed:
                      _isLoading || _isResending
                          ? null
                          : _goBackToForgotPassword,
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding12,
              ),

              Center(
                child: TextButton(
                  onPressed:
                      _isLoading || _isResending
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
  // RESEND SECTION
  // =====================================================

  Widget _buildResendSection() {
    final bool canResend =
        _remainingSeconds <= 0 &&
        !_isResending &&
        !_isLoading;

    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: canResend
              ? AppColors.success
              : AppColors.textSecondary,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            canResend
                ? 'Did not receive OTP?'
                : 'Resend OTP in $_remainingSeconds seconds',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),

        TextButton(
          onPressed:
              canResend ? _resendOtp : null,
          child: _isResending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Resend'),
        ),
      ],
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
                  Icons.verified_user_rounded,
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
              'Never share OTP with anyone. EventEase Admin will never ask for OTP outside this secure flow.',
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
// ROUTE GENERATOR COMPATIBILITY ALIAS
// =====================================================

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const OtpScreen();
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