import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'UPI';

  final TextEditingController addressController =
      TextEditingController(
    text:
        'Hitech City, Hyderabad, Telangana',
  );

  final TextEditingController notesController =
      TextEditingController();

  double subtotal = 25000;
  double platformFee = 500;
  double discount = 1000;

  double get total =>
      subtotal + platformFee - discount;

  @override
  void dispose() {
    addressController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void placeOrder() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConfig.orderSuccess,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Checkout',
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            //=================================
            // ADDRESS
            //=================================

            const Text(
              'Event Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller:
                          addressController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        prefixIcon:
                            Icon(
                          Icons.location_on,
                        ),
                        hintText:
                            'Enter event address',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //=================================
            // ITEMS
            //=================================

            const Text(
              'Booked Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration:
                          BoxDecoration(
                        color: ThemeConfig
                            .primaryColor
                            .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: ThemeConfig
                            .primaryColor,
                      ),
                    ),
                    title: const Text(
                      'Wedding Photography',
                    ),
                    subtitle:
                        const Text(
                      'Qty: 1',
                    ),
                    trailing:
                        const Text(
                      '₹15,000',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration:
                          BoxDecoration(
                        color: ThemeConfig
                            .primaryColor
                            .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: ThemeConfig
                            .primaryColor,
                      ),
                    ),
                    title: const Text(
                      'Event Decoration',
                    ),
                    subtitle:
                        const Text(
                      'Qty: 1',
                    ),
                    trailing:
                        const Text(
                      '₹10,000',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //=================================
            // PAYMENT METHOD
            //=================================

            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Column(
                children: [
                  RadioListTile(
                    value: 'UPI',
                    groupValue:
                        selectedPaymentMethod,
                    title:
                        const Text(
                      'UPI Payment',
                    ),
                    secondary:
                        const Icon(
                      Icons.qr_code,
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod =
                            value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: 'Card',
                    groupValue:
                        selectedPaymentMethod,
                    title:
                        const Text(
                      'Credit / Debit Card',
                    ),
                    secondary:
                        const Icon(
                      Icons.credit_card,
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod =
                            value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: 'NetBanking',
                    groupValue:
                        selectedPaymentMethod,
                    title:
                        const Text(
                      'Net Banking',
                    ),
                    secondary:
                        const Icon(
                      Icons.account_balance,
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod =
                            value!;
                      });
                    },
                  ),
                  RadioListTile(
                    value: 'Cash',
                    groupValue:
                        selectedPaymentMethod,
                    title:
                        const Text(
                      'Pay Later',
                    ),
                    secondary:
                        const Icon(
                      Icons.payments,
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod =
                            value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //=================================
            // NOTES
            //=================================

            const Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                hintText:
                    'Special requirements...',
              ),
            ),

            const SizedBox(height: 20),

            //=================================
            // BILL SUMMARY
            //=================================

            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    _summaryRow(
                      'Subtotal',
                      '₹${subtotal.toStringAsFixed(0)}',
                    ),
                    _summaryRow(
                      'Platform Fee',
                      '₹${platformFee.toStringAsFixed(0)}',
                    ),
                    _summaryRow(
                      'Discount',
                      '-₹${discount.toStringAsFixed(0)}',
                      color:
                          Colors.green,
                    ),
                    const Divider(),
                    _summaryRow(
                      'Total Amount',
                      '₹${total.toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            icon:
                const Icon(Icons.payment),
            onPressed: placeOrder,
            label: Text(
              'Pay ₹${total.toStringAsFixed(0)}',
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color:
                  color ?? Colors.black,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize:
                  isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}