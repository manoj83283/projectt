import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() =>
      _HelpSupportScreenState();
}

class _HelpSupportScreenState
    extends State<HelpSupportScreen> {
  final TextEditingController issueController =
      TextEditingController();

  final List<Map<String, String>> faqs = [
    {
      "question":
          "How do I book a service?",
      "answer":
          "Search a service, open details, choose date & time, and complete payment."
    },
    {
      "question":
          "How can I cancel my booking?",
      "answer":
          "Open My Bookings, select booking details and click Cancel Booking."
    },
    {
      "question":
          "How do I track my order?",
      "answer":
          "Go to My Orders and tap Track Order."
    },
    {
      "question":
          "How do I change my password?",
      "answer":
          "Navigate to Profile → Settings → Change Password."
    },
    {
      "question":
          "How can I contact support?",
      "answer":
          "Use Call, Email, Live Chat or Support Ticket options below."
    },
  ];

  @override
  void dispose() {
    issueController.dispose();
    super.dispose();
  }

  void submitTicket() {
    if (issueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your issue',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Support ticket submitted successfully',
        ),
      ),
    );

    issueController.clear();
  }

  Widget buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

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
            // ==================
            // HEADER
            // ==================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.support_agent,
                      size: 80,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================
            // SUPPORT OPTIONS
            // ==================

            const Text(
              'Support Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            buildSupportCard(
              icon: Icons.chat,
              title: "Live Chat",
              subtitle:
                  "Chat with support team",
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteConfig.chat,
                );
              },
            ),

            buildSupportCard(
              icon: Icons.phone,
              title: "Call Support",
              subtitle:
                  "+91 1800-000-0000",
              onTap: () {},
            ),

            buildSupportCard(
              icon: Icons.email,
              title: "Email Support",
              subtitle:
                  "support@eventease.com",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ==================
            // FAQ
            // ==================

            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...faqs.map(
              (faq) => Card(
                child: ExpansionTile(
                  title: Text(
                    faq['question']!,
                  ),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets
                              .all(16),
                      child: Text(
                        faq['answer']!,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================
            // CREATE TICKET
            // ==================

            const Text(
              'Report an Issue',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller:
                          issueController,
                      maxLines: 5,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Describe your issue...',
                        alignLabelWithHint:
                            true,
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            submitTicket,
                        icon: const Icon(
                          Icons.send,
                        ),
                        label: const Text(
                          'Submit Ticket',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================
            // APP INFO
            // ==================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: const [
                    ListTile(
                      leading:
                          Icon(Icons.info),
                      title: Text(
                          'App Version'),
                      trailing:
                          Text('1.0.0'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.verified,
                      ),
                      title: Text(
                        'Customer Support',
                      ),
                      trailing:
                          Text('24/7'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}