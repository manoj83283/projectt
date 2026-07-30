import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../generated/assets.gen.dart';
import 'custom_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool showRetryButton;

  const AppErrorWidget({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.actionText,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: AppColors.error
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.error,
                size: 56,
              ),
            ),

            const SizedBox(
              height: AppDimensions.padding24,
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),

            const SizedBox(
              height: AppDimensions.padding12,
            ),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            if (showRetryButton &&
                onRetry != null) ...[
              const SizedBox(
                height:
                    AppDimensions.padding24,
              ),

              SizedBox(
                width: 180,
                child: CustomButton(
                  text:
                      actionText ?? 'Retry',
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =====================================================
// NETWORK ERROR
// =====================================================

class NetworkErrorWidget
    extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'No Internet Connection',
      message:
          'Please check your internet connection and try again.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }
}

// =====================================================
// SERVER ERROR
// =====================================================

class ServerErrorWidget
    extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Server Error',
      message:
          'Our servers are currently unavailable. Please try again later.',
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }
}

// =====================================================
// UNAUTHORIZED
// =====================================================

class UnauthorizedWidget
    extends StatelessWidget {
  final VoidCallback? onLogin;

  const UnauthorizedWidget({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Access Denied',
      message:
          'You do not have sufficient permissions to access this page.',
      icon: Icons.lock_outline_rounded,
      actionText: 'Login',
      onRetry: onLogin,
    );
  }
}

// =====================================================
// PAGE NOT FOUND
// =====================================================

class PageNotFoundWidget
    extends StatelessWidget {
  final VoidCallback? onBack;

  const PageNotFoundWidget({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      title: 'Page Not Found',
      message:
          'The page you are looking for does not exist.',
      icon: Icons.search_off_rounded,
      actionText: 'Go Back',
      onRetry: onBack,
    );
  }
}

// =====================================================
// MAINTENANCE
// =====================================================

class MaintenanceWidget
    extends StatelessWidget {
  const MaintenanceWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Assets.images.emptyState,
              height: 180,
            ),

            const SizedBox(
              height:
                  AppDimensions.padding24,
            ),

            Text(
              'Under Maintenance',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(
              height:
                  AppDimensions.padding12,
            ),

            Text(
              'The system is currently undergoing maintenance. Please check back later.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SMALL ERROR CARD
// =====================================================

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorCard({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.error
          .withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radius12,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding16,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ),

            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child:
                    const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INLINE ERROR
// =====================================================

class InlineErrorWidget
    extends StatelessWidget {
  final String message;

  const InlineErrorWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.error.withOpacity(
          0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radius8,
        ),
        border: Border.all(
          color:
              AppColors.error.withOpacity(
            0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}