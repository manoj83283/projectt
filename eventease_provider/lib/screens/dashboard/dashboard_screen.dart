import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/route_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/provider_provider.dart';
import '../../providers/review_provider.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      await Future.wait([
        context.read<ProviderProvider>().refreshData(),
        context.read<BookingProvider>().refreshData(),
        context.read<OrderProvider>().refreshData(),
        context.read<PaymentProvider>().refreshData(),
        context.read<ReviewProvider>().refreshData(),
      ]);
    } catch (_) {
      // Keep dashboard usable even if one section fails.
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _navigateTo(String routeName) {
    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );

    Navigator.pushNamed(
      context,
      routeName,
    );
  }

  void _navigateFromDrawer(String routeName) {
    Navigator.pop(context);

    Future.delayed(
      const Duration(milliseconds: 120),
      () {
        if (!mounted) return;

        Navigator.pushNamed(
          context,
          routeName,
        );
      },
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
            tooltip: 'Notifications',
            icon: const Icon(
              Icons.notifications,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                RouteConfig.notifications,
              );
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                RouteConfig.settings,
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: _loadDashboardData,
          ),
        ],
      ),

      // =====================================================
      // DRAWER
      // =====================================================
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
                    provider.provider?.fullName ??
                        provider.provider?.name ??
                        'Provider',
                  ),
                  accountEmail: Text(
                    provider.provider?.email ?? '',
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      _getInitial(
                        provider.provider?.fullName ??
                            provider.provider?.name ??
                            'P',
                      ),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.dashboard,
              ),
              title: const Text(
                'Dashboard',
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.business_center,
              ),
              title: const Text(
                'Services',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.myServices,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.calendar_month,
              ),
              title: const Text(
                'Bookings',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.bookings,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.shopping_bag,
              ),
              title: const Text(
                'Orders',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.orders,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
              ),
              title: const Text(
                'Earnings',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.earnings,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.reviews,
              ),
              title: const Text(
                'Reviews',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.reviews,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.notifications,
              ),
              title: const Text(
                'Notifications',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.notifications,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.schedule,
              ),
              title: const Text(
                'Availability',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.availability,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.person,
              ),
              title: const Text(
                'Profile',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.profile,
                );
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text(
                'Settings',
              ),
              onTap: () {
                _navigateFromDrawer(
                  RouteConfig.settings,
                );
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<ProviderProvider>(
                builder: (
                  context,
                  providerData,
                  child,
                ) {
                  return Text(
                    'Welcome, ${providerData.provider?.fullName ?? providerData.provider?.name ?? 'Provider'} 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 20,
              ),

              // =====================================================
              // EARNINGS CARDS
              // =====================================================
              Consumer<PaymentProvider>(
                builder: (
                  context,
                  payment,
                  child,
                ) {
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    children: [
                      _dashboardCard(
                        title: 'Total Earnings',
                        value:
                            '₹${payment.totalEarnings.toStringAsFixed(0)}',
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConfig.earnings,
                          );
                        },
                      ),
                      _dashboardCard(
                        title: 'Available Balance',
                        value:
                            '₹${payment.availableBalance.toStringAsFixed(0)}',
                        icon: Icons.wallet,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConfig.earnings,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 16,
              ),

              // =====================================================
              // BOOKING CARDS
              // =====================================================
              Consumer<BookingProvider>(
                builder: (
                  context,
                  booking,
                  child,
                ) {
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    children: [
                      _dashboardCard(
                        title: 'Bookings',
                        value: booking.bookings.length.toString(),
                        icon: Icons.event_note,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConfig.bookings,
                          );
                        },
                      ),
                      _dashboardCard(
                        title: 'Today Bookings',
                        value: booking.todayBookings.length.toString(),
                        icon: Icons.today,
                        color: Colors.deepPurple,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConfig.bookings,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 16,
              ),

              // =====================================================
              // RATING CARD
              // =====================================================
              Consumer<ReviewProvider>(
                builder: (
                  context,
                  review,
                  child,
                ) {
                  return _dashboardCard(
                    title: 'Average Rating',
                    value: review.averageRating.toStringAsFixed(1),
                    icon: Icons.star,
                    color: Colors.amber,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.reviews,
                      );
                    },
                  );
                },
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _actionButton(
                    icon: Icons.business_center,
                    title: 'Services',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.myServices,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.add_business,
                    title: 'Add Service',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.addService,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.calendar_month,
                    title: 'Bookings',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.bookings,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.shopping_bag,
                    title: 'Orders',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.orders,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.account_balance_wallet,
                    title: 'Earnings',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.earnings,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.reviews,
                    title: 'Reviews',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.reviews,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.chat,
                    title: 'Chats',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.chatList,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.notifications,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.schedule,
                    title: 'Availability',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.availability,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.profile,
                      );
                    },
                  ),
                  _actionButton(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig.settings,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitial(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return 'P';
    }

    return value.substring(0, 1).toUpperCase();
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 35,
                color: color,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 105,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}