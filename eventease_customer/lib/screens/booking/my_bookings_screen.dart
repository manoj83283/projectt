import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({
    super.key,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK1001',
      'service': 'Wedding Photography',
      'provider': 'RK Photography',
      'date': '20 Jul 2026',
      'amount': '₹15,500',
      'status': 'Confirmed',
      'location': 'Hyderabad',
    },
    {
      'id': 'BK1002',
      'service': 'Catering',
      'provider': 'Tasty Catering',
      'date': '05 Jul 2026',
      'amount': '₹25,500',
      'status': 'Completed',
      'location': 'Secunderabad',
    },
    {
      'id': 'BK1003',
      'service': 'DJ Service',
      'provider': 'DJ Beats',
      'date': '12 Jun 2026',
      'amount': '₹10,000',
      'status': 'Cancelled',
      'location': 'Madhapur',
    },
  ];

  List<Map<String, dynamic>> filteredBookings = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    filteredBookings = _filterByStatus(
      'Confirmed',
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshBookings() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    _filterBookings();
  }

  void _filterBookings() {
    String status = 'Confirmed';

    switch (_tabController.index) {
      case 0:
        status = 'Confirmed';
        break;
      case 1:
        status = 'Completed';
        break;
      case 2:
        status = 'Cancelled';
        break;
    }

    setState(() {
      filteredBookings = _filterByStatus(
        status,
      );
    });
  }

  List<Map<String, dynamic>> _filterByStatus(
    String status,
  ) {
    return bookings.where((booking) {
      return booking['status'] == status;
    }).toList();
  }

  Color _getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Rescheduled':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(
    String status,
  ) {
    switch (status) {
      case 'Confirmed':
        return Icons.event_available_outlined;
      case 'Completed':
        return Icons.task_alt_outlined;
      case 'Cancelled':
        return Icons.cancel_outlined;
      case 'Pending':
        return Icons.pending_actions_outlined;
      case 'Rescheduled':
        return Icons.update_outlined;
      default:
        return Icons.event_note_outlined;
    }
  }

  void _openBookingDetails(
    Map<String, dynamic> booking,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.bookingDetails,
      arguments: booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'My Bookings',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Confirmed',
            ),
            Tab(
              text: 'Completed',
            ),
            Tab(
              text: 'Cancelled',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookings,
        child: filteredBookings.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> booking =
                      filteredBookings[index];

                  return _BookingCard(
                    booking: booking,
                    statusColor: _getStatusColor(
                      booking['status']?.toString() ?? '',
                    ),
                    statusIcon: _getStatusIcon(
                      booking['status']?.toString() ?? '',
                    ),
                    onTap: () => _openBookingDetails(
                      booking,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 150),
        Icon(
          Icons.event_busy_outlined,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'No Bookings Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Your bookings will appear here.',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String service = booking['service']?.toString() ?? 'Service';
    final String provider =
        booking['provider']?.toString() ?? 'Provider';
    final String status =
        booking['status']?.toString() ?? 'Unknown';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(
                        0.12,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          service,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          provider,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              const Divider(),
              const SizedBox(
                height: 5,
              ),
              _InfoRow(
                title: 'Booking ID',
                value: booking['id']?.toString() ?? '',
              ),
              _InfoRow(
                title: 'Date',
                value: booking['date']?.toString() ?? '',
              ),
              _InfoRow(
                title: 'Amount',
                value: booking['amount']?.toString() ?? '',
              ),
              _InfoRow(
                title: 'Location',
                value: booking['location']?.toString() ?? 'N/A',
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(
                        0.12,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}