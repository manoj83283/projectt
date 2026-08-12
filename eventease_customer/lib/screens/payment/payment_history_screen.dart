import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_helper.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({
    super.key,
  });

  @override
  State<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState
    extends State<PaymentHistoryScreen> {
  Future<void> _refresh() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  final List<Map<String, dynamic>> payments = [
    {
      'paymentId': 'PAY123456',
      'bookingId': 'BOOK1001',
      'amount': 15000,
      'status': 'success',
      'date': DateTime.now(),
    },
    {
      'paymentId': 'PAY123457',
      'bookingId': 'BOOK1002',
      'amount': 8500,
      'status': 'failed',
      'date': DateTime.now().subtract(
        const Duration(days: 1),
      ),
    },
    {
      'paymentId': 'PAY123458',
      'bookingId': 'BOOK1003',
      'amount': 22000,
      'status': 'pending',
      'date': DateTime.now().subtract(
        const Duration(days: 2),
      ),
    },
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return AppColors.success;

      case 'failed':
        return AppColors.error;

      case 'pending':
        return AppColors.warning;

      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Icons.check_circle;

      case 'failed':
        return Icons.cancel;

      case 'pending':
        return Icons.schedule;

      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Payment History',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: payments.isEmpty
            ? const Center(
                child: Text(
                  'No payment history found',
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                itemCount:
                    payments.length,
                itemBuilder:
                    (context, index) {
                  final payment =
                      payments[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    decoration:
                        AppStyles
                            .cardDecoration,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(
                        16,
                      ),

                      leading: CircleAvatar(
                        backgroundColor:
                            _statusColor(
                          payment['status'],
                        ).withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          _statusIcon(
                            payment[
                                'status'],
                          ),
                          color:
                              _statusColor(
                            payment[
                                'status'],
                          ),
                        ),
                      ),

                      title: Text(
                        CurrencyFormatter
                            .format(
                          payment[
                              'amount'],
                        ),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            "Booking: ${payment["bookingId"]}",
                          ),

                          Text(
                            "Payment: ${payment["paymentId"]}",
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),

                          Text(
                            DateHelper
                                .formatDateTime(
                              payment[
                                  'date'],
                            ),
                          ),
                        ],
                      ),

                      trailing: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              _statusColor(
                            payment[
                                'status'],
                          ).withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          payment['status']
                              .toString()
                              .toUpperCase(),
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color:
                                _statusColor(
                              payment[
                                  'status'],
                            ),
                          ),
                        ),
                      ),

                      onTap: () {
                        _showPaymentDetails(
                          payment,
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showPaymentDetails(
    Map<String, dynamic> payment,
  ) {
    showModalBottomSheet(
      context: context,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return Padding(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Text(
                'Payment Details',
                style:
                    AppStyles.heading3,
              ),

              const SizedBox(
                height: 20,
              ),

              _detailRow(
                'Payment ID',
                payment['paymentId'],
              ),

              _detailRow(
                'Booking ID',
                payment['bookingId'],
              ),

              _detailRow(
                'Amount',
                CurrencyFormatter
                    .format(
                  payment['amount'],
                ),
              ),

              _detailRow(
                'Status',
                payment['status']
                    .toString()
                    .toUpperCase(),
              ),

              _detailRow(
                'Date',
                DateHelper
                    .formatDateTime(
                  payment['date'],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title),
          ),
          Expanded(
            child: Text(
              value,
              textAlign:
                  TextAlign.end,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}