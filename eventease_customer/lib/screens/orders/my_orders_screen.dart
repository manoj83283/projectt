import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({
    super.key,
  });

  @override
  State<MyOrdersScreen> createState() =>
      _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD1001',
      'service': 'Wedding Photography',
      'provider': 'RK Photography',
      'date': '20 Jul 2026',
      'amount': '₹15,500',
      'status': 'Active',
    },
    {
      'id': 'ORD1002',
      'service': 'Premium Catering',
      'provider': 'Tasty Catering',
      'date': '10 Jul 2026',
      'amount': '₹25,000',
      'status': 'Completed',
    },
    {
      'id': 'ORD1003',
      'service': 'Event Decoration',
      'provider': 'Royal Decorators',
      'date': '05 Jul 2026',
      'amount': '₹12,000',
      'status': 'Cancelled',
    },
  ];

  List<Map<String, dynamic>> filteredOrders = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    filteredOrders = [];

    _filterOrders();

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filterOrders();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();

    super.dispose();
  }

  Future<void> refreshOrders() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    _filterOrders();
  }

  String _currentStatus() {
    switch (_tabController.index) {
      case 1:
        return 'Completed';

      case 2:
        return 'Cancelled';

      case 0:
      default:
        return 'Active';
    }
  }

  void _filterOrders() {
    final status = _currentStatus();
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredOrders = orders.where(
        (order) {
          final orderStatus =
              order['status']?.toString() ?? '';

          final service =
              order['service']?.toString().toLowerCase() ?? '';

          final id =
              order['id']?.toString().toLowerCase() ?? '';

          final provider =
              order['provider']?.toString().toLowerCase() ?? '';

          final matchesStatus = orderStatus == status;

          final matchesQuery = query.isEmpty ||
              service.contains(query) ||
              id.contains(query) ||
              provider.contains(query);

          return matchesStatus && matchesQuery;
        },
      ).toList();
    });
  }

  void searchOrders(String query) {
    _filterOrders();
  }

  void _clearSearch() {
    searchController.clear();
    _filterOrders();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;

      case 'Completed':
        return Colors.blue;

      case 'Cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  void _openOrderDetails(
    Map<String, dynamic> order,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.orderDetails,
      arguments: order,
    );
  }

  void _trackOrder(
    Map<String, dynamic> order,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.trackOrder,
      arguments: order,
    );
  }

  void _reorder(
    Map<String, dynamic> order,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.booking,
      arguments: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title: const Text(
          'My Orders',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Active',
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
        onRefresh: refreshOrders,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: TextField(
                controller: searchController,
                onChanged: searchOrders,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search orders...',
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(
                            Icons.close,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final order = filteredOrders[index];

                        return _orderCard(
                          order: order,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderCard({
    required Map<String, dynamic> order,
  }) {
    final status = order['status']?.toString() ?? '';
    final service = order['service']?.toString() ?? '';
    final provider = order['provider']?.toString() ?? '';
    final id = order['id']?.toString() ?? '';
    final date = order['date']?.toString() ?? '';
    final amount = order['amount']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: () {
          _openOrderDetails(
            order,
          );
        },
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
                      color: Colors.blue.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.blue,
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
                          maxLines: 2,
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              const Divider(),

              _orderRow(
                'Order ID',
                id,
              ),
              _orderRow(
                'Date',
                date,
              ),
              _orderRow(
                'Amount',
                amount,
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(status).withOpacity(
                        0.15,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getStatusColor(
                          status,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  if (status == 'Active')
                    SizedBox(
                      width: 86,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          _trackOrder(
                            order,
                          );
                        },
                        child: const Text(
                          'Track',
                        ),
                      ),
                    ),

                  if (status == 'Completed')
                    SizedBox(
                      width: 96,
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          _reorder(
                            order,
                          );
                        },
                        child: const Text(
                          'Reorder',
                        ),
                      ),
                    ),

                  if (status == 'Cancelled')
                    SizedBox(
                      width: 96,
                      height: 40,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          _openOrderDetails(
                            order,
                          );
                        },
                        child: const Text(
                          'Details',
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Text(
            title,
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

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 150,
        ),
        const Icon(
          Icons.shopping_bag_outlined,
          size: 100,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 20,
        ),
        const Center(
          child: Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Center(
          child: Text(
            'Try searching with another keyword.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}