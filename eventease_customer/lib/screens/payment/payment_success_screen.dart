import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/currency_formatter.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String bookingId;
  final String paymentId;
  final double amount;

  const PaymentSuccessScreen({
    required this.bookingId, required this.paymentId, required this.amount, super.key,
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

              // ==================================
              // SUCCESS ICON
              // ==================================

              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.success
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Payment Successful',
                style: AppStyles.heading2,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Your booking has been confirmed successfully.',
                textAlign: TextAlign.center,
                style: AppStyles.subtitle,
              ),

              const SizedBox(height: 30),

              // ==================================
              // PAYMENT DETAILS
              // ==================================

              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppStyles.cardDecoration,
                child: Column(
                  children: [
                    _detailRow(
                      'Booking ID',
                      bookingId,
                    ),

                    const Divider(),

                    _detailRow(
                      'Payment ID',
                      paymentId,
                    ),

                    const Divider(),

                    _detailRow(
                      'Amount Paid',
                      CurrencyFormatter.format(
                        amount,
                      ),
                      valueColor:
                          AppColors.success,
                    ),

                    const Divider(),

                    _detailRow(
                      'Date',
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ==================================
              // VIEW BOOKING
              // ==================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      AppStyles.primaryButton,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.bookingDetails,
                    );
                  },
                  child: const Text(
                    'View Booking',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================
              // HOME BUTTON
              // ==================================

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
      padding: const EdgeInsets.symmetric(
        vertical: 10,
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