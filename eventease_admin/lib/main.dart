import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const EventEaseAdminApp(),
  );
}

class EventEaseAdminApp extends StatelessWidget {
  const EventEaseAdminApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EventEase Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EventEase Admin Dashboard',
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: const [
          _DashboardCard(
            title: 'Customers',
            icon: Icons.people,
          ),
          _DashboardCard(
            title: 'Providers',
            icon: Icons.business,
          ),
          _DashboardCard(
            title: 'Bookings',
            icon: Icons.event,
          ),
          _DashboardCard(
            title: 'Orders',
            icon: Icons.shopping_cart,
          ),
          _DashboardCard(
            title: 'Payments',
            icon: Icons.payments,
          ),
          _DashboardCard(
            title: 'Reviews',
            icon: Icons.star,
          ),
          _DashboardCard(
            title: 'Coupons',
            icon: Icons.discount,
          ),
          _DashboardCard(
            title: 'Support',
            icon: Icons.support_agent,
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}