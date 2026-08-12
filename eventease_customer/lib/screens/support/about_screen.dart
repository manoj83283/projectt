import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'About EventEase',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.event_available,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'EventEase',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'All-in-One Event Services Marketplace',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'EventEase connects customers with trusted service providers for weddings, parties, corporate events, catering, photography, decoration, venues, and other event-related services through a single platform.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why EventEase?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        'Verified Service Providers',
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        'Secure Online Payments',
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        'Real-Time Booking Tracking',
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: Text(
                        'Ratings & Reviews',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.web),
                    title: Text('Website'),
                    subtitle:
                        Text('www.eventease.com'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(
                      'support@eventease.com',
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text(
                      'Customer Support',
                    ),
                    subtitle:
                        Text('+91 1800-000-0000'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                      ),
                      title:
                          Text('Version'),
                      trailing:
                          Text('1.0.0'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.update,
                      ),
                      title: Text(
                        'Build Number',
                      ),
                      trailing: Text(
                        '100',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '© 2026 EventEase. All Rights Reserved.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}