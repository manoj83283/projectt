import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/currency_formatter.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final double gst;
  final double discount;
  final double serviceFee;
  final String bookingId;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.bookingId,
    this.gst = 0,
    this.discount = 0,
    this.serviceFee = 0,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
  String _selectedMethod = "razorpay";

  double get totalAmount =>
      widget.amount +
      widget.gst +
      widget.serviceFee -
      widget.discount;

  Future<void> _makePayment() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Processing payment via $_selectedMethod",
        ),
      ),
    );

    // TODO:
    // Integrate Razorpay Here
    // Navigate to Success Screen
  }

  Widget _paymentTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedMethod,
      activeColor: AppColors.primary,
      onChanged: (value) {
        setState(() {
          _selectedMethod = value!;
        });
      },
      secondary: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Payment",
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: AppStyles.primaryButton,
            onPressed: _makePayment,
            child: Text(
              "Pay ${CurrencyFormatter.format(totalAmount)}",
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ===================
            // BOOKING INFO
            // ===================

            Container(
              decoration:
                  AppStyles.cardDecoration,
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    "Booking Details",
                    style: AppStyles.title,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Booking ID : ${widget.bookingId}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===================
            // PAYMENT METHODS
            // ===================

            const Text(
              "Select Payment Method",
              style: AppStyles.heading3,
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  _paymentTile(
                    title: "Razorpay",
                    value: "razorpay",
                    icon:
                        Icons.account_balance_wallet,
                  ),
                  _paymentTile(
                    title: "UPI",
                    value: "upi",
                    icon: Icons.qr_code,
                  ),
                  _paymentTile(
                    title:
                        "Google Pay",
                    value: "gpay",
                    icon:
                        Icons.payment,
                  ),
                  _paymentTile(
                    title: "PhonePe",
                    value: "phonepe",
                    icon:
                        Icons.phone_android,
                  ),
                  _paymentTile(
                    title: "Paytm",
                    value: "paytm",
                    icon:
                        Icons.wallet,
                  ),
                  _paymentTile(
                    title:
                        "Cash On Service",
                    value: "cash",
                    icon:
                        Icons.money,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===================
            // PRICE SUMMARY
            // ===================

            Container(
              decoration:
                  AppStyles.cardDecoration,
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                children: [
                  const Align(
                    alignment:
                        Alignment
                            .centerLeft,
                    child: Text(
                      "Price Summary",
                      style:
                          AppStyles.title,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),

                  _priceRow(
                    "Service Amount",
                    CurrencyFormatter
                        .format(
                      widget.amount,
                    ),
                  ),

                  _priceRow(
                    "GST",
                    CurrencyFormatter
                        .format(
                      widget.gst,
                    ),
                  ),

                  _priceRow(
                    "Service Fee",
                    CurrencyFormatter
                        .format(
                      widget.serviceFee,
                    ),
                  ),

                  _priceRow(
                    "Discount",
                    "-${CurrencyFormatter.format(widget.discount)}",
                    color:
                        Colors.green,
                  ),

                  const Divider(),

                  _priceRow(
                    "Total Amount",
                    CurrencyFormatter
                        .format(
                      totalAmount,
                    ),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration: BoxDecoration(
                color: Colors.blue
                    .withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "100% Secure Payments. All transactions are encrypted.",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    String title,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isBold
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}