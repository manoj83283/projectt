import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_validator.dart';
import '../../generated/assets.gen.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/error_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();

    _emailController.text = '';
    _passwordController.text = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        AppStrings.loginSuccess,
      );

      NavigationService.pushAndRemoveUntil(
        AppRoutes.dashboard,
      );
    } else {
      NavigationService.showError(
        authProvider.errorMessage ??
            AppStrings.somethingWentWrong,
      );
    }
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  void _goToForgotPassword() {
    Navigator.pushNamed(
      context,
      AppRoutes.forgotPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (
          context,
          authProvider,
          child,
        ) {
          return LayoutBuilder(
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
                        child:
                            _buildLeftPanel(),
                      ),

                    Expanded(
                      flex: 5,
                      child: Center(
                        child:
                            SingleChildScrollView(
                          padding:
                              const EdgeInsets.all(
                            AppDimensions
                                .padding24,
                          ),
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(
                              maxWidth: 460,
                            ),
                            child:
                                _buildLoginCard(
                              authProvider,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
                          AppDimensions
                              .radius16,
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
                  'Manage your complete EventEase ecosystem from one powerful admin console.',
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
                  'Track bookings, manage providers, monitor orders, handle payments, verify KYC, send notifications, and analyze platform growth in real time.',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.88),
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
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                    ),
                    _FeatureBadge(
                      icon: Icons.verified_user_outlined,
                      label: 'KYC',
                    ),
                    _FeatureBadge(
                      icon: Icons.payments_outlined,
                      label: 'Payments',
                    ),
                    _FeatureBadge(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  'Version ${AppConfig.appVersion} • ${AppConfig.environmentName}',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.70),
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
  // LOGIN CARD
  // =====================================================

  Widget _buildLoginCard(
    AuthProvider authProvider,
  ) {
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
              _buildMobileLogo(),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              Text(
                AppStrings.welcomeBack,
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
                'Login to continue managing EventEase Admin.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),

              const SizedBox(
                height: AppDimensions.padding32,
              ),

              if (authProvider.errorMessage !=
                  null) ...[
                InlineErrorWidget(
                  message:
                      authProvider.errorMessage!,
                ),
                const SizedBox(
                  height: AppDimensions.padding20,
                ),
              ],

              CustomTextField(
                controller: _emailController,
                labelText: AppStrings.email,
                hintText:
                    'Enter admin email',
                keyboardType:
                    TextInputType.emailAddress,
                textInputAction:
                    TextInputAction.next,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                validator:
                    AppValidator.email,
              ),

              const SizedBox(
                height: AppDimensions.padding20,
              ),

              CustomTextField(
                controller:
                    _passwordController,
                labelText: AppStrings.password,
                hintText:
                    'Enter password',
                obscureText:
                    _obscurePassword,
                textInputAction:
                    TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons
                            .visibility_off_outlined
                        : Icons
                            .visibility_outlined,
                  ),
                ),
                validator:
                    AppValidator.password,
                onChanged: (_) {
                  if (authProvider
                          .errorMessage !=
                      null) {
                    authProvider.clearError();
                  }
                },
              ),

              const SizedBox(
                height: AppDimensions.padding12,
              ),

              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe =
                            value ?? true;
                      });
                    },
                  ),

                  const Text(
                    AppStrings.rememberMe,
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed:
                        _goToForgotPassword,
                    child: const Text(
                      AppStrings.forgotPassword,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              CustomButton(
                text: AppStrings.signIn,
                icon: Icons.login_rounded,
                isLoading:
                    authProvider.isLoading,
                onPressed:
                    authProvider.isLoading
                        ? null
                        : _login,
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
  // MOBILE LOGO
  // =====================================================

  Widget _buildMobileLogo() {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
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
                      .withValues(alpha: 0.08),
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
                      Icons
                          .admin_panel_settings_rounded,
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
      },
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
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius12,
        ),
        border: Border.all(
          color: AppColors.info
              .withValues(alpha: 0.18),
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
              'Secure admin access. Unauthorized usage is strictly monitored.',
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
        color: Colors.white.withValues(
          alpha: opacity,
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
        color: Colors.white.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          30,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.18,
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