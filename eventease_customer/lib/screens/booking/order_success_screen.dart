import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bookingId =
        'BK${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      backgroundColor: Colors.white,
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
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.green
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================
              // TITLE
              // ==================================

              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Your booking has been successfully placed and payment has been received.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================
              // BOOKING CARD
              // ==================================

              Card(
                elevation: 2,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        'Booking ID',
                        bookingId,
                      ),

                      const Divider(),

                      _infoRow(
                        'Status',
                        'Confirmed',
                        valueColor:
                            Colors.green,
                      ),

                      _infoRow(
                        'Payment',
                        'Success',
                        valueColor:
                            Colors.green,
                      ),

                      _infoRow(
                        'Amount',
                        '₹15,500',
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ==================================
              // TRACK BUTTON
              // ==================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.location_on,
                  ),
                  label: const Text(
                    'Track Booking',
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig
                          .trackBooking,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================
              // MY BOOKINGS
              // ==================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.list_alt,
                  ),
                  label: const Text(
                    'My Bookings',
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig
                          .myBookings,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ==================================
              // HOME BUTTON
              // ==================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      RouteConfig.home,
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

  Widget _infoRow(
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
          Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
              color:
                  valueColor ??
                  Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}