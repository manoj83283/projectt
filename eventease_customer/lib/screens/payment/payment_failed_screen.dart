import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String bookingId;
  final String? errorMessage;
  final String? errorCode;

  const PaymentFailedScreen({
    required this.bookingId, super.key,
    this.errorMessage,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // =========================================
              // FAILURE ICON
              // =========================================

              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel,
                  color: AppColors.error,
                  size: 85,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Payment Failed',
                style: AppStyles.heading2,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                errorMessage ??
                    'Your transaction could not be completed. Please try again.',
                textAlign: TextAlign.center,
                style: AppStyles.subtitle,
              ),

              const SizedBox(height: 30),

              // =========================================
              // DETAILS CARD
              // =========================================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  children: [
                    _detailRow(
                      'Booking ID',
                      bookingId,
                    ),

                    if (errorCode != null) ...[
                      const Divider(),
                      _detailRow(
                        'Error Code',
                        errorCode!,
                      ),
                    ],

                    const Divider(),

                    _detailRow(
                      'Status',
                      'Failed',
                      valueColor: AppColors.error,
                    ),

                    const Divider(),

                    _detailRow(
                      'Date',
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "If money was deducted, it will usually be refunded automatically according to your payment provider's policies.",
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // =========================================
              // RETRY BUTTON
              // =========================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      AppStyles.primaryButton,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Retry Payment',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =========================================
              // HOME BUTTON
              // =========================================

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: AppStyles
                      .secondaryButton,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Back To Home',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppStyles.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}