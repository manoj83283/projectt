import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String message;

  final String? image;

  final IconData? icon;

  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyWidget({
    super.key,
    required this.title,
    required this.message,
    this.image,
    this.icon,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // ==========================
            // IMAGE / ICON
            // ==========================

            if (image != null)
              Image.asset(
                image!,
                height: 180,
                fit: BoxFit.contain,
              )
            else
              Icon(
                icon ??
                    Icons
                        .inbox_outlined,
                size: 90,
                color: Colors.grey,
              ),

            const SizedBox(height: 24),

            // ==========================
            // TITLE
            // ==========================

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 10),

            // ==========================
            // MESSAGE
            // ==========================

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        Colors.grey,
                  ),
            ),

            if (buttonText != null &&
                onButtonPressed != null) ...[
              const SizedBox(
                height: 24,
              ),

              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      onButtonPressed,
                  child: Text(
                    buttonText!,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ======================================================
// EMPTY BOOKINGS
// ======================================================

class EmptyBookingsWidget
    extends StatelessWidget {
  const EmptyBookingsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.event_busy,
      title: 'No Bookings Found',
      message:
          'You have not received any bookings yet.',
    );
  }
}

// ======================================================
// EMPTY ORDERS
// ======================================================

class EmptyOrdersWidget
    extends StatelessWidget {
  const EmptyOrdersWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.shopping_bag_outlined,
      title: 'No Orders Found',
      message:
          'No orders are currently available.',
    );
  }
}

// ======================================================
// EMPTY SERVICES
// ======================================================

class EmptyServicesWidget
    extends StatelessWidget {
  final VoidCallback? onAddService;

  const EmptyServicesWidget({
    super.key,
    this.onAddService,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.miscellaneous_services,
      title: 'No Services Available',
      message:
          'Start by adding your first service.',
      buttonText: 'Add Service',
      onButtonPressed:
          onAddService,
    );
  }
}

// ======================================================
// EMPTY REVIEWS
// ======================================================

class EmptyReviewsWidget
    extends StatelessWidget {
  const EmptyReviewsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.star_border,
      title: 'No Reviews Yet',
      message:
          'Customer reviews will appear here.',
    );
  }
}

// ======================================================
// EMPTY CHAT
// ======================================================

class EmptyChatWidget
    extends StatelessWidget {
  const EmptyChatWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.chat_bubble_outline,
      title: 'No Conversations',
      message:
          'Customer chats will appear here.',
    );
  }
}

// ======================================================
// EMPTY NOTIFICATIONS
// ======================================================

class EmptyNotificationsWidget
    extends StatelessWidget {
  const EmptyNotificationsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon:
          Icons.notifications_off_outlined,
      title: 'No Notifications',
      message:
          'You are all caught up.',
    );
  }
}

// ======================================================
// EMPTY SEARCH
// ======================================================

class EmptySearchWidget
    extends StatelessWidget {
  const EmptySearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message:
          'Try changing your search criteria.',
    );
  }
}

// ======================================================
// NO INTERNET
// ======================================================

class NoInternetWidget
    extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message:
          'Please check your internet connection and try again.',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
    );
  }
}