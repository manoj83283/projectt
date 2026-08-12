import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends State<TransactionsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  Future<void> _loadTransactions() async {
    await context
        .read<PaymentProvider>()
        .getPayments();
  }

  List<PaymentModel> _filterTransactions(
    List<PaymentModel> payments,
  ) {
    if (_selectedFilter == 'all') {
      return payments;
    }

    return payments.where((payment) {
      return (payment.status ?? '')
              .toLowerCase() ==
          _selectedFilter;
    }).toList();
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'failed':
        return Colors.red;

      case 'refunded':
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'completed':
        return Icons.check_circle;

      case 'pending':
        return Icons.schedule;

      case 'failed':
        return Icons.cancel;

      case 'refunded':
        return Icons.replay;

      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final transactions =
              _filterTransactions(
            provider.payments,
          );

          return Column(
            children: [
              // =========================
              // FILTER BAR
              // =========================

              Padding(
                padding:
                    const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('all'),
                      _filterChip('completed'),
                      _filterChip('pending'),
                      _filterChip('failed'),
                      _filterChip('refunded'),
                    ],
                  ),
                ),
              ),

              // =========================
              // TRANSACTIONS
              // =========================

              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : transactions.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons
                                      .receipt_long_outlined,
                                  size: 80,
                                  color:
                                      Colors.grey,
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'No Transactions Found',
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh:
                                _loadTransactions,
                            child:
                                ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .all(
                                16,
                              ),
                              itemCount:
                                  transactions
                                      .length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final payment =
                                    transactions[
                                        index];

                                return Card(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom:
                                        12,
                                  ),
                                  child:
                                      Padding(
                                    padding:
                                        const EdgeInsets.all(
                                      16,
                                    ),
                                    child:
                                        Column(
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  _statusColor(payment.status).withValues(
                                                alpha: 0.12,
                                              ),
                                              child:
                                                  Icon(
                                                _statusIcon(
                                                  payment.status,
                                                ),
                                                color:
                                                    _statusColor(
                                                  payment.status,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              width:
                                                  12,
                                            ),

                                            Expanded(
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    payment.orderId ??
                                                        'Order Payment',
                                                    style:
                                                        const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        4,
                                                  ),
                                                  Text(
                                                    payment.transactionId ??
                                                        'N/A',
                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Text(
                                              '₹${payment.amount}',
                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.green,
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize:
                                                    18,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                          height:
                                              12,
                                        ),

                                        const Divider(),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .calendar_today,
                                              size:
                                                  18,
                                            ),
                                            const SizedBox(
                                              width:
                                                  8,
                                            ),
                                            Expanded(
                                              child:
                                                  Text(
                                                payment.createdAt ??
                                                    '',
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                          height:
                                              10,
                                        ),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .payment,
                                              size:
                                                  18,
                                            ),
                                            const SizedBox(
                                              width:
                                                  8,
                                            ),
                                            Expanded(
                                              child:
                                                  Text(
                                                payment.paymentMethod ??
                                                    'Online',
                                              ),
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    12,
                                                vertical:
                                                    6,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    _statusColor(
                                                  payment.status,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  30,
                                                ),
                                              ),
                                              child:
                                                  Text(
                                                (payment.status ??
                                                        'Pending')
                                                    .toUpperCase(),
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Colors.white,
                                                  fontSize:
                                                      11,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(
    String filter,
  ) {
    final selected =
        _selectedFilter == filter;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        selected: selected,
        label: Text(
          filter.toUpperCase(),
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }
}