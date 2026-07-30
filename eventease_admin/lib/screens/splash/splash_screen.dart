import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/storage/storage_helper.dart';
import '../../generated/assets.gen.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController
      _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();

    _startAppFlow();
  }

  // =====================================================
  // INITIALIZE ANIMATIONS
  // =====================================================

  void _initializeAnimations() {
    _animationController =
        AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _fadeAnimation =
        CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation =
        Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  // =====================================================
  // START APP FLOW
  // =====================================================

  Future<void> _startAppFlow() async {
    _navigationTimer = Timer(
      const Duration(seconds: 2),
      () async {
        await _navigateNext();
      },
    );
  }

  // =====================================================
  // NAVIGATE NEXT
  // =====================================================

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final bool isLoggedIn =
        StorageHelper.getBool(
      StorageKeys.isLoggedIn,
    );

    final String? accessToken =
        StorageHelper.getString(
      StorageKeys.accessToken,
    );

    final bool hasValidSession =
        isLoggedIn &&
        accessToken != null &&
        accessToken.isNotEmpty;

    if (hasValidSession) {
      NavigationService.pushAndRemoveUntil(
        AppRoutes.dashboard,
      );
    } else {
      NavigationService.pushAndRemoveUntil(
        AppRoutes.login,
      );
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();

    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundPattern(),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSplashContent(
                    context,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // BACKGROUND PATTERN
  // =====================================================

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _CircleDecoration(
              size: 220,
              opacity: 0.10,
            ),
          ),

          Positioned(
            bottom: 100,
            left: -90,
            child: _CircleDecoration(
              size: 260,
              opacity: 0.08,
            ),
          ),

          Positioned(
            top: 180,
            left: 40,
            child: _CircleDecoration(
              size: 90,
              opacity: 0.08,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SPLASH CONTENT
  // =====================================================

  Widget _buildSplashContent(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(
        AppDimensions.padding24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),

          const SizedBox(
            height: AppDimensions.padding24,
          ),

          Text(
            AppStrings.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
          ),

          const SizedBox(
            height: AppDimensions.padding8,
          ),

          Text(
            AppConfig.appTagLine,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      Colors.white.withOpacity(
                    0.85,
                  ),
                  fontWeight: FontWeight.w400,
                ),
          ),

          const SizedBox(
            height: AppDimensions.padding32,
          ),

          const SizedBox(
            width: 34,
            height: 34,
            child:
                CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LOGO
  // =====================================================

  Widget _buildLogo() {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(
        AppDimensions.padding20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AppDimensions.radius24,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.18,
            ),
            blurRadius: 30,
            offset: const Offset(
              0,
              14,
            ),
          ),
        ],
      ),
      child: Image.asset(
        Assets.images.splashLogo,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Icon(
            Icons.admin_panel_settings_rounded,
            color: AppColors.primary,
            size: 56,
          );
        },
      ),
    );
  }

  // =====================================================
  // FOOTER
  // =====================================================

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Version ${AppConfig.appVersion}',
          style: TextStyle(
            color: Colors.white.withOpacity(
              0.85,
            ),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          AppConfig.environmentName,
          style: TextStyle(
            color: Colors.white.withOpacity(
              0.65,
            ),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// CIRCLE DECORATION
// =====================================================

class _CircleDecoration
    extends StatelessWidget {
  final double size;
  final double opacity;

  const _CircleDecoration({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(
          opacity,
        ),
      ),
    );
  }
}