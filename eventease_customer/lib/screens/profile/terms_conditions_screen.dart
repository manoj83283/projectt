import 'package:flutter/material.dart';

class TermsConditionsScreen
    extends StatelessWidget {
  const TermsConditionsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Center(
                  child: Icon(
                    Icons.gavel,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Last Updated: July 2026',
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _sectionTitle(
                  '1. Acceptance of Terms',
                ),
                const Text(
                  'By accessing and using EventEase, you agree to comply with and be bound by these Terms & Conditions. If you do not agree, please discontinue use of the platform.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '2. User Eligibility',
                ),
                const Text(
                  'Users must provide accurate information during registration and maintain the confidentiality of account credentials.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '3. Service Bookings',
                ),
                const Text(
                  'Users may browse, book, and purchase services from verified providers. Booking confirmation is subject to provider availability and successful payment processing.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '4. Payments',
                ),
                const Text(
                  'Payments must be completed through approved payment methods. EventEase may use secure third-party payment gateways for transaction processing.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '5. Cancellation & Refunds',
                ),
                const Text(
                  'Cancellation and refund policies may vary depending on service providers, booking type, timing, and applicable platform policies.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '6. Provider Responsibilities',
                ),
                const Text(
                  'Service providers are responsible for delivering booked services accurately, professionally, and within the agreed schedule.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '7. User Responsibilities',
                ),
                const Text(
                  'Users must provide accurate booking details, respect providers, avoid misuse of platform services, and comply with applicable laws.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '8. Reviews & Ratings',
                ),
                const Text(
                  'Users may submit reviews and ratings based on genuine experiences. EventEase reserves the right to remove misleading, abusive, or inappropriate content.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '9. Prohibited Activities',
                ),
                const Text(
                  'Users must not engage in fraudulent transactions, unauthorized access, abuse of platform functionality, spam, or activities that harm the platform or its users.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '10. Intellectual Property',
                ),
                const Text(
                  'All platform content including logos, images, software, branding, and design elements remain the property of EventEase or respective licensors.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '11. Limitation of Liability',
                ),
                const Text(
                  'EventEase acts as a marketplace platform connecting customers and providers. Liability is limited to the extent permitted by applicable law.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '12. Account Suspension',
                ),
                const Text(
                  'EventEase reserves the right to suspend or terminate accounts that violate platform policies, legal requirements, or community standards.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '13. Privacy Policy',
                ),
                const Text(
                  'Your use of the platform is also governed by our Privacy Policy, which explains how information is collected, stored, and processed.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '14. Changes to Terms',
                ),
                const Text(
                  'EventEase may update these Terms & Conditions from time to time. Continued use of the platform constitutes acceptance of updated terms.',
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  '15. Contact Information',
                ),
                const Text(
                  'Email: support@eventease.com\n'
                  'Website: www.eventease.com\n'
                  'Customer Support: 24/7',
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.blue
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    'By continuing to use EventEase, you acknowledge that you have read, understood, and agreed to these Terms & Conditions.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }
}