import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                const Center(
                  child: Icon(
                    Icons.privacy_tip,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    "Privacy Policy",
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
                    "Last Updated: July 2026",
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _sectionTitle(
                  "1. Introduction",
                ),

                const Text(
                  "EventEase respects your privacy and is committed to protecting your personal information. This Privacy Policy describes how we collect, use, store, and protect your information when using the EventEase platform.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "2. Information We Collect",
                ),

                const Text(
                  "• Name\n"
                  "• Email Address\n"
                  "• Mobile Number\n"
                  "• Profile Information\n"
                  "• Address Information\n"
                  "• Booking & Order History\n"
                  "• Payment Information\n"
                  "• Device & Usage Information",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "3. How We Use Your Information",
                ),

                const Text(
                  "We use your information to provide services, manage bookings, process payments, improve user experience, send important notifications, and provide customer support.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "4. Payment Security",
                ),

                const Text(
                  "All payments are processed through secure payment gateways. EventEase does not store sensitive card details on its servers.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "5. Data Protection",
                ),

                const Text(
                  "We implement industry-standard security measures including encryption, secure authentication, access controls, and monitoring systems to protect your data.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "6. Location Permissions",
                ),

                const Text(
                  "Location data may be used to provide nearby services, provider tracking, event location assistance, and improved user experiences.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "7. Notifications",
                ),

                const Text(
                  "EventEase may send booking updates, payment alerts, promotional offers, system notifications, and customer support communications.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "8. Third-Party Services",
                ),

                const Text(
                  "Our platform may integrate with third-party providers such as payment gateways, maps, analytics providers, cloud storage systems, and notification services.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "9. User Rights",
                ),

                const Text(
                  "Users may review, update, modify, or request deletion of personal information in accordance with applicable laws and company policies.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "10. Account Deletion",
                ),

                const Text(
                  "Users can request account deletion through profile settings or customer support. Certain information may be retained where required by law.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "11. Children Privacy",
                ),

                const Text(
                  "EventEase services are not intended for use by children without parental or legal guardian supervision.",
                ),

                const SizedBox(height: 20),

                _sectionTitle(
                  "12. Contact Us",
                ),

                const Text(
                  "Email: support@eventease.com\n"
                  "Website: www.eventease.com\n"
                  "Customer Support: 24/7",
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.blue
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    "By using EventEase, you agree to the terms outlined in this Privacy Policy.",
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