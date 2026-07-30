import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../generated/assets.gen.dart';
import 'custom_button.dart';

class EmptyWidget extends StatelessWidget {
  final String? title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double imageHeight;
  final String? imagePath;
  final IconData? icon;

  const EmptyWidget({
    super.key,
    this.title,
    this.description,
    this.buttonText,
    this.onButtonPressed,
    this.imageHeight = 180,
    this.imagePath,
    this.icon,
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
            _buildVisual(),

            const SizedBox(
              height: AppDimensions.padding24,
            ),

            Text(
              title ?? AppStrings.noDataFound,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                  ),
            ),

            const SizedBox(
              height: AppDimensions.padding8,
            ),

            Text(
              description ??
                  'No records are available at the moment.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            if (onButtonPressed != null) ...[
              const SizedBox(
                height:
                    AppDimensions.padding24,
              ),

              SizedBox(
                width: 180,
                child: CustomButton(
                  text: buttonText ??
                      AppStrings.refresh,
                  onPressed:
                      onButtonPressed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisual() {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        height: imageHeight,
        fit: BoxFit.contain,
      );
    }

    if (icon != null) {
      return Container(
        height: imageHeight,
        width: imageHeight,
        decoration: BoxDecoration(
          color: AppColors.primary
              .withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: imageHeight * 0.45,
          color: AppColors.primary,
        ),
      );
    }

    return Image.asset(
      Assets.images.noData,
      height: imageHeight,
      fit: BoxFit.contain,
    );
  }
}

// =====================================================
// SPECIALIZED EMPTY STATES
// =====================================================

class NoCustomersWidget
    extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoCustomersWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.people_outline,
      title: 'No Customers Found',
      description:
          'Customer records will appear here once users register.',
      onButtonPressed: onRefresh,
    );
  }
}

class NoProvidersWidget
    extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoProvidersWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.business_center_outlined,
      title: 'No Providers Found',
      description:
          'No providers are currently available.',
      onButtonPressed: onRefresh,
    );
  }
}

class NoBookingsWidget
    extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoBookingsWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.event_note_outlined,
      title: 'No Bookings Found',
      description:
          'Booking data will appear here when customers start booking services.',
      onButtonPressed: onRefresh,
    );
  }
}

class NoOrdersWidget
    extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoOrdersWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.shopping_bag_outlined,
      title: 'No Orders Found',
      description:
          'There are currently no orders available.',
      onButtonPressed: onRefresh,
    );
  }
}

class NoNotificationsWidget
    extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoNotificationsWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      description:
          'No notifications have been sent yet.',
      onButtonPressed: onRefresh,
    );
  }
}

class NoSearchResultsWidget
    extends StatelessWidget {
  final VoidCallback? onClearFilters;

  const NoSearchResultsWidget({
    super.key,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      description:
          'Try changing search keywords or filters.',
      buttonText: 'Clear Filters',
      onButtonPressed:
          onClearFilters,
    );
  }
}