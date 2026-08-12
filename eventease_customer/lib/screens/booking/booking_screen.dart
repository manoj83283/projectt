import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {
  DateTime? selectedDate;

  String selectedTime = '10:00 AM';

  final TextEditingController guestsController =
      TextEditingController(text: '100');

  final TextEditingController notesController =
      TextEditingController();

  final List<String> timeSlots = [
    '08:00 AM',
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
    '08:00 PM',
  ];

  double servicePrice = 15000;

  @override
  void dispose() {
    guestsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final DateTime? picked =
        await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(
        DateTime.now().year + 2,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void proceedToPayment() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Please select date'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      RouteConfig.orderSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)
        ?.settings
        .arguments as Map<String, dynamic>?;

    final String serviceName =
        service?['name'] ??
            'Event Service';

    final double totalAmount =
        servicePrice;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title:
            const Text('Book Service'),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // SERVICE INFO

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration:
                          BoxDecoration(
                        color:
                            ThemeConfig
                                .primaryColor
                                .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .business_center,
                        size: 35,
                        color: ThemeConfig
                            .primaryColor,
                      ),
                    ),
                    const SizedBox(
                        width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            serviceName,
                            style:
                                const TextStyle(
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                          const SizedBox(
                              height:
                                  6),
                          const Text(
                            'Starting from ₹15,000',
                            style:
                                TextStyle(
                              color: Colors
                                  .green,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DATE

            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: selectDate,
              child: Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(
                    color: Colors.grey
                        .shade300,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                    ),
                    const SizedBox(
                        width: 10),
                    Text(
                      selectedDate ==
                              null
                          ? 'Choose Date'
                          : DateFormat(
                              'dd MMM yyyy',
                            ).format(
                              selectedDate!,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TIME

            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  timeSlots.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected:
                      selectedTime ==
                          time,
                  onSelected: (_) {
                    setState(() {
                      selectedTime =
                          time;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // GUESTS

            const Text(
              'Guest Count',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  guestsController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                hintText:
                    'Number Of Guests',
                prefixIcon:
                    Icon(Icons.group),
              ),
            ),

            const SizedBox(height: 20),

            // ADDRESS

            const Text(
              'Event Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(
                  color: Colors.grey
                      .shade300,
                ),
                borderRadius:
                    BorderRadius
                        .circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hyderabad, Telangana',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NOTES

            const Text(
              'Special Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  notesController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                hintText:
                    'Write additional requirements...',
              ),
            ),

            const SizedBox(height: 25),

            // SUMMARY

            const Text(
              'Booking Summary',
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
                      'Service Fee',
                      '₹15,000',
                    ),
                    _summaryRow(
                      'Platform Fee',
                      '₹500',
                    ),
                    const Divider(),
                    _summaryRow(
                      'Total Amount',
                      '₹${totalAmount + 500}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed:
                proceedToPayment,
            child: Text(
              'Proceed To Pay ₹${totalAmount + 500}',
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
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isTotal
                  ? Colors.green
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}