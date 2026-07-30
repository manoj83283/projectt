import 'package:flutter/material.dart';

import '../../models/customer_model.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  Color _statusColor(bool isActive) {
    return isActive
        ? Colors.green
        : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Details',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =========================
            // PROFILE HEADER
            // =========================

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
                      radius: 45,
                      backgroundColor:
                          Theme.of(context)
                              .primaryColor,
                      backgroundImage:
                          customer.profileImage !=
                                  null &&
                              customer
                                  .profileImage!
                                  .isNotEmpty
                          ? NetworkImage(
                              customer
                                  .profileImage!,
                            )
                          : null,
                      child: customer.profileImage ==
                                  null ||
                              customer
                                  .profileImage!
                                  .isEmpty
                          ? Text(
                              customer.fullName
                                  .substring(
                                    0,
                                    1,
                                  )
                                  .toUpperCase(),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(
                        height: 16),

                    Text(
                      customer.fullName,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: _statusColor(
                                customer
                                        .isActive ??
                                    true)
                            .withOpacity(
                                0.15),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        (customer.isActive ??
                                true)
                            ? 'ACTIVE'
                            : 'INACTIVE',
                        style: TextStyle(
                          color:
                              _statusColor(
                            customer.isActive ??
                                true,
                          ),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // CONTACT INFO
            // =========================

            _sectionTitle(
              'Contact Information',
            ),

            Card(
              child: Column(
                children: [
                  _infoTile(
                    Icons.email,
                    'Email',
                    customer.email,
                  ),
                  _infoTile(
                    Icons.phone,
                    'Phone',
                    customer.phone,
                  ),
                  _infoTile(
                    Icons.location_on,
                    'Address',
                    customer.address ??
                        'Not Available',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // ACCOUNT INFO
            // =========================

            _sectionTitle(
              'Account Information',
            ),

            Card(
              child: Column(
                children: [
                  _infoTile(
                    Icons.badge,
                    'Customer ID',
                    customer.id,
                  ),
                  _infoTile(
                    Icons.calendar_month,
                    'Joined Date',
                    customer.createdAt ??
                        'N/A',
                  ),
                  _infoTile(
                    Icons.verified_user,
                    'Verification',
                    customer.isVerified ==
                            true
                        ? 'Verified'
                        : 'Pending',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // STATS
            // =========================

            _sectionTitle(
              'Statistics',
            ),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.event,
                    title: 'Bookings',
                    value:
                        '${customer.totalBookings ?? 0}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.star,
                    title: 'Reviews',
                    value:
                        '${customer.totalReviews ?? 0}',
                    color:
                        Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons
                        .currency_rupee,
                    title: 'Spent',
                    value:
                        '₹${customer.totalSpent ?? 0}',
                    color:
                        Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    value:
                        '${customer.favoriteCount ?? 0}',
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =========================
            // NOTES
            // =========================

            _sectionTitle('Notes'),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  customer.notes ??
                      'No notes available',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // ACTIONS
            // =========================

            SizedBox(
              width: double.infinity,
              child:
                  ElevatedButton.icon(
                onPressed: () {
                  // Open Chat Screen
                },
                icon: const Icon(
                  Icons.chat,
                ),
                label:
                    const Text('CHAT'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed: () {
                  // Call Customer
                },
                icon: const Icon(
                  Icons.call,
                ),
                label:
                    const Text('CALL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}