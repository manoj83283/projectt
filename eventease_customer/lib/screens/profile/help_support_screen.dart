import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class HelpSupportScreen
    extends StatelessWidget {
  const HelpSupportScreen({
    super.key,
  });

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
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contact our support team or browse FAQs',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            _buildTile(
              context,
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle:
                  'Talk with support team',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteConfig.chat,
                );
              },
            ),

            _buildTile(
              context,
              icon: Icons.phone,
              title: 'Call Support',
              subtitle:
                  '+91 98765 43210',
              onTap: () {},
            ),

            _buildTile(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle:
                  'support@eventease.com',
              onTap: () {},
            ),

            _buildTile(
              context,
              icon: Icons.question_answer,
              title: 'FAQs',
              subtitle:
                  'Frequently asked questions',
              onTap: () {},
            ),

            _buildTile(
              context,
              icon: Icons.policy,
              title: 'Privacy Policy',
              subtitle:
                  'Read our privacy policy',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteConfig
                      .privacyPolicy,
                );
              },
            ),

            _buildTile(
              context,
              icon: Icons.description,
              title:
                  'Terms & Conditions',
              subtitle:
                  'View terms of use',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteConfig
                      .termsConditions,
                );
              },
            ),

            const SizedBox(
              height: 24,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'EventEase Support',
                    style: TextStyle(
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Available Monday - Sunday',
                  ),
                  SizedBox(height: 4),
                  Text(
                    '9:00 AM - 9:00 PM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Colors.blue.withValues(
            alpha: 0.1,
          ),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
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
}