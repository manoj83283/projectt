import 'package:flutter/material.dart';

import '../../models/customer_model.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<CustomerModel> _customers = [];

  List<CustomerModel> _filteredCustomers = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      // TODO:
      // Connect Customer Repository/API

      await Future.delayed(
        const Duration(seconds: 1),
      );

      setState(() {
        _customers = [];
        _filteredCustomers = _customers;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchCustomer(String value) {
    setState(() {
      final query = value.toLowerCase().trim();

      _filteredCustomers = _customers.where((customer) {
        return customer.fullName.toLowerCase().contains(query) ||
            customer.email.toLowerCase().contains(query) ||
            customer.phone.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _refresh() async {
    await _loadCustomers();
  }

  String _getInitial(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return "?";
    }

    return trimmedName.substring(0, 1).toUpperCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchCustomer,
              decoration: InputDecoration(
                hintText: 'Search customer...',
                prefixIcon: const Icon(
                  Icons.search,
                ),

                /// ✅ FIXED ERROR HERE
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(
                            16,
                          ),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final customer = _filteredCustomers[index];

                            return _customerCard(
                              customer,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.people_outline,
            size: 90,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No Customers Found',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerCard(
    CustomerModel customer,
  ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    _getInitial(customer.fullName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        customer.email,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(
              height: 24,
            ),

            _infoRow(
              Icons.phone,
              customer.phone,
            ),

            const SizedBox(height: 8),

            _infoRow(
              Icons.location_on,
              customer.address ?? 'No Address',
            ),

            const SizedBox(height: 8),

            _infoRow(
              Icons.event,
              'Bookings: ${customer.totalBookings ?? 0}',
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate Chat
                    },
                    icon: const Icon(
                      Icons.chat,
                    ),
                    label: const Text(
                      'Chat',
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Customer Details
                    },
                    icon: const Icon(
                      Icons.visibility,
                    ),
                    label: const Text(
                      'View',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}