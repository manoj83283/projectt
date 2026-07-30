import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91 9876543210';

  static const String websiteUrl =
      'https://www.eventease.com';

  Future<void> _launchUrl(
    String url,
  ) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query:
          'subject=EventEase Support Request',
    );

    await launchUrl(uri);
  }

  Future<void> _callSupport() async {
    final uri = Uri(
      scheme: 'tel',
      path: supportPhone,
    );

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ========================
            // HEADER
            // ========================

            Card(
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          Theme.of(context)
                              .primaryColor,
                      child: const Icon(
                        Icons.support_agent,
                        size: 40,
                        color:
                            Colors.white,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Get support, find answers, and contact the EventEase support team.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ========================
            // QUICK CONTACT
            // ========================

            const Text(
              'Quick Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                    title:
                        const Text(
                      'Call Support',
                    ),
                    subtitle: Text(
                      supportPhone,
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: _callSupport,
                  ),

                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.email,
                      color: Colors.red,
                    ),
                    title:
                        const Text(
                      'Email Support',
                    ),
                    subtitle: Text(
                      supportEmail,
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: _sendEmail,
                  ),

                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Colors.blue,
                    ),
                    title:
                        const Text(
                      'Visit Website',
                    ),
                    subtitle: Text(
                      websiteUrl,
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () =>
                        _launchUrl(
                      websiteUrl,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ========================
            // FAQs
            // ========================

            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _faqTile(
              'How do I receive bookings?',
              'Customers can discover your services and book directly through the EventEase platform.',
            ),

            _faqTile(
              'When will I receive payments?',
              'Payments are credited based on the payout cycle configured for your provider account.',
            ),

            _faqTile(
              'How do I edit my services?',
              'Navigate to My Services → Select Service → Edit Service.',
            ),

            _faqTile(
              'How can I update availability?',
              'Go to Availability Screen and update your working days and timings.',
            ),

            _faqTile(
              'How do I contact customers?',
              'You can use the built-in chat module or phone contact options available in bookings.',
            ),

            const SizedBox(height: 20),

            // ========================
            // SUPPORT OPTIONS
            // ========================

            const Text(
              'Support Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.menu_book,
                    ),
                    title:
                        const Text(
                      'Provider Guide',
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.video_library,
                    ),
                    title:
                        const Text(
                      'Video Tutorials',
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.feedback,
                    ),
                    title:
                        const Text(
                      'Send Feedback',
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {},
                  ),
                  const Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.bug_report,
                    ),
                    title:
                        const Text(
                      'Report Issue',
                    ),
                    trailing: const Icon(
                      Icons
                          .arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'EventEase Provider v1.0.0',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(
    String question,
    String answer,
  ) {
    return Card(
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}