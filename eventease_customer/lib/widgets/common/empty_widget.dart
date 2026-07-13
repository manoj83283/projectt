import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onPressed;

  const EmptyWidget({
    super.key,
    this.title = 'No Data Found',
    this.message =
        'Nothing available at the moment.',
    this.icon = Icons.inbox_outlined,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            if (buttonText != null &&
                onPressed != null) ...[
              const SizedBox(height: 24),

              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label: Text(buttonText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty Orders Widget
class EmptyOrdersWidget
    extends StatelessWidget {
  final VoidCallback? onBrowse;

  const EmptyOrdersWidget({
    super.key,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.shopping_bag_outlined,
      title: "No Orders Yet",
      message:
          "Your orders will appear here after placing an order.",
      buttonText: "Browse Services",
      onPressed: onBrowse,
    );
  }
}

/// Empty Cart Widget
class EmptyCartWidget
    extends StatelessWidget {
  final VoidCallback? onShopNow;

  const EmptyCartWidget({
    super.key,
    this.onShopNow,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.shopping_cart_outlined,
      title: "Your Cart Is Empty",
      message:
          "Looks like you haven't added any services yet.",
      buttonText: "Shop Now",
      onPressed: onShopNow,
    );
  }
}

/// Empty Chat Widget
class EmptyChatWidget
    extends StatelessWidget {
  const EmptyChatWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.chat_bubble_outline,
      title: "No Conversations",
      message:
          "Start chatting with providers to see messages here.",
    );
  }
}

/// Empty Reviews Widget
class EmptyReviewsWidget
    extends StatelessWidget {
  const EmptyReviewsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const EmptyWidget(
      icon: Icons.rate_review_outlined,
      title: "No Reviews",
      message:
          "Reviews and ratings will appear here.",
    );
  }
}

/// Empty Address Widget
class EmptyAddressWidget
    extends StatelessWidget {
  final VoidCallback? onAddAddress;

  const EmptyAddressWidget({
    super.key,
    this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.location_off_outlined,
      title: "No Saved Addresses",
      message:
          "Add an address for faster bookings and deliveries.",
      buttonText: "Add Address",
      onPressed: onAddAddress,
    );
  }
}