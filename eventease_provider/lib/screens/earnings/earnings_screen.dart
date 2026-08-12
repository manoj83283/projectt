import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/payment_provider.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() =>
      _EarningsScreenState();
}

class _EarningsScreenState
    extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context
        .read<PaymentProvider>()
        .refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Earnings',
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading &&
              provider.payments.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =========================
                  // SUMMARY CARDS
                  // =========================

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title:
                              'Total Earnings',
                          value:
                              '₹${provider.totalEarnings.toStringAsFixed(0)}',
                          color:
                              Colors.green,
                          icon: Icons
                              .currency_rupee,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _summaryCard(
                          title:
                              'Available',
                          value:
                              '₹${provider.availableBalance.toStringAsFixed(0)}',
                          color: Colors
                              .blue,
                          icon: Icons
                              .account_balance_wallet,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title:
                              'Pending',
                          value:
                              '₹${provider.pendingSettlement.toStringAsFixed(0)}',
                          color: Colors
                              .orange,
                          icon: Icons
                              .hourglass_top,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _summaryCard(
                          title: 'Payments',
                          value: provider
                              .payments.length
                              .toString(),
                          color:
                              Colors.purple,
                          icon: Icons
                              .payments,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =========================
                  // PAYOUT
                  // =========================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton.icon(
                      onPressed: () {
                        _showPayoutDialog(
                          context,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .account_balance,
                      ),
                      label: const Text(
                        'REQUEST PAYOUT',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'Recent Payments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (provider
                      .payments.isEmpty)
                    const Card(
                      child: Padding(
                        padding:
                            EdgeInsets.all(
                          20,
                        ),
                        child: Center(
                          child: Text(
                            'No payments found',
                          ),
                        ),
                      ),
                    ),

                  ...provider.payments
                      .take(20)
                      .map(
                        (payment) =>
                            Card(
                          margin:
                              const EdgeInsets.only(
                            bottom:
                                10,
                          ),
                          child:
                              ListTile(
                            leading:
                                CircleAvatar(
                              backgroundColor:
                                  Colors
                                      .green
                                      .withValues(
                                alpha: 0.1,
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .currency_rupee,
                                color:
                                    Colors.green,
                              ),
                            ),
                            title: Text(
                              payment
                                      .orderId ??
                                  'Payment',
                            ),
                            subtitle:
                                Text(
                              payment
                                      .createdAt ??
                                  '',
                            ),
                            trailing:
                                Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  '₹${payment.amount}',
                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.green,
                                  ),
                                ),
                                Text(
                                  payment
                                          .status ??
                                      '',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
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
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
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

  void _showPayoutDialog(
    BuildContext context,
  ) {
    final controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text('Request Payout'),
          content: TextField(
            controller: controller,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount =
                    double.tryParse(
                          controller.text,
                        ) ??
                        0;

                if (amount <= 0) {
                  return;
                }

                final success =
                    await context
                        .read<
                            PaymentProvider>()
                        .requestPayout(
                  amount: amount,
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Payout request sent'
                          : 'Failed to request payout',
                    ),
                  ),
                );
              },
              child:
                  const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}