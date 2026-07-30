import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/provider_provider.dart';
import '../../providers/review_provider.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      await context
          .read<ProviderProvider>()
          .refreshData();

      await context
          .read<BookingProvider>()
          .refreshData();

      await context
          .read<OrderProvider>()
          .refreshData();

      await context
          .read<PaymentProvider>()
          .refreshData();

      await context
          .read<ReviewProvider>()
          .refreshData();
    } catch (_) {}
  }

  Future<void> _logout() async {
    await context
        .read<AuthProvider>()
        .logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Provider Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed:
                _loadDashboardData,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Consumer<ProviderProvider>(
              builder: (
                context,
                provider,
                child,
              ) {
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    provider.provider
                            ?.fullName ??
                        'Provider',
                  ),
                  accountEmail: Text(
                    provider.provider
                            ?.email ??
                        '',
                  ),
                  currentAccountPicture:
                      const CircleAvatar(
                    child: Icon(
                      Icons.person,
                      size: 40,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text(
                'Dashboard',
              ),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.business_center,
              ),
              title: const Text(
                'Services',
              ),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title: const Text(
                'Bookings',
              ),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.shopping_bag,
              ),
              title:
                  const Text('Orders'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
              ),
              title:
                  const Text('Payments'),
              onTap: () {},
            ),

            const Spacer(),

            ListTile(
              leading:
                  const Icon(Icons.logout),
              title:
                  const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Consumer<ProviderProvider>(
                builder: (
                  context,
                  providerData,
                  child,
                ) {
                  return Text(
                    'Welcome, ${providerData.provider?.fullName ?? 'Provider'} 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Consumer<PaymentProvider>(
                builder: (
                  context,
                  payment,
                  child,
                ) {
                  return GridView(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    children: [
                      _dashboardCard(
                        title:
                            'Total Earnings',
                        value:
                            '₹${payment.totalEarnings.toStringAsFixed(0)}',
                        icon:
                            Icons.currency_rupee,
                        color: Colors.green,
                      ),
                      _dashboardCard(
                        title:
                            'Available Balance',
                        value:
                            '₹${payment.availableBalance.toStringAsFixed(0)}',
                        icon:
                            Icons.wallet,
                        color: Colors.blue,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              Consumer<BookingProvider>(
                builder: (
                  context,
                  booking,
                  child,
                ) {
                  return GridView(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    children: [
                      _dashboardCard(
                        title:
                            'Bookings',
                        value: booking
                            .bookings.length
                            .toString(),
                        icon:
                            Icons.event_note,
                        color:
                            Colors.orange,
                      ),
                      _dashboardCard(
                        title:
                            'Today Bookings',
                        value: booking
                            .todayBookings
                            .length
                            .toString(),
                        icon:
                            Icons.today,
                        color:
                            Colors.deepPurple,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              Consumer<ReviewProvider>(
                builder: (
                  context,
                  review,
                  child,
                ) {
                  return _dashboardCard(
                    title:
                        'Average Rating',
                    value: review
                        .averageRating
                        .toStringAsFixed(1),
                    icon: Icons.star,
                    color: Colors.amber,
                  );
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _actionButton(
                    icon:
                        Icons.business_center,
                    title: 'Services',
                  ),
                  _actionButton(
                    icon:
                        Icons.calendar_month,
                    title: 'Bookings',
                  ),
                  _actionButton(
                    icon:
                        Icons.chat,
                    title: 'Chats',
                  ),
                  _actionButton(
                    icon:
                        Icons.person,
                    title: 'Profile',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: color,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
  }) {
    return SizedBox(
      width: 100,
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.all(12),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign:
                    TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}