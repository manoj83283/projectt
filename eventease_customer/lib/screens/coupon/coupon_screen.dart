import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() =>
      _CouponScreenState();
}

class _CouponScreenState
    extends State<CouponScreen> {
  final TextEditingController _couponController =
      TextEditingController();

  String? selectedCoupon;

  final List<Map<String, dynamic>> coupons = [
    {
      "code": "EVENT10",
      "title": "Flat 10% OFF",
      "description":
          "Get 10% discount on all bookings.",
      "discount": "10%",
      "expiry": "31 Dec 2026",
    },
    {
      "code": "WELCOME500",
      "title": "₹500 OFF",
      "description":
          "Flat ₹500 off for new customers.",
      "discount": "₹500",
      "expiry": "30 Nov 2026",
    },
    {
      "code": "FESTIVE20",
      "title": "Festival Offer",
      "description":
          "Get up to 20% off on event services.",
      "discount": "20%",
      "expiry": "15 Jan 2027",
    },
  ];

  void _applyCoupon(String code) {
    Navigator.pop(
      context,
      {
        "couponCode": code,
      },
    );
  }

  void _copyCoupon(String code) {
    Clipboard.setData(
      ClipboardData(text: code),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            "$code copied",
          ),
        ),
      );
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Coupons & Offers",
        ),
      ),

      body: Column(
        children: [
          // =====================================
          // ENTER COUPON
          // =====================================

          Container(
            padding:
                const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        _couponController,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Enter Coupon Code",
                      border:
                          OutlineInputBorder(),
                    ),
                    textCapitalization:
                        TextCapitalization
                            .characters,
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    final code =
                        _couponController.text
                            .trim();

                    if (code.isNotEmpty) {
                      _applyCoupon(code);
                    }
                  },
                  child: const Text(
                    "Apply",
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // =====================================
          // AVAILABLE COUPONS
          // =====================================

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount: coupons.length,
              itemBuilder:
                  (context, index) {
                final coupon =
                    coupons[index];

                final isSelected =
                    selectedCoupon ==
                        coupon["code"];

                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 16,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppColors
                              .primary
                          : Colors.grey
                              .shade300,
                      width:
                          isSelected
                              ? 2
                              : 1,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    12,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: AppColors
                                    .primary
                                    .withOpacity(
                                  0.1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
                              ),
                              child: Text(
                                coupon[
                                    "discount"],
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .primary,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            const Spacer(),

                            IconButton(
                              onPressed: () {
                                _copyCoupon(
                                  coupon[
                                      "code"],
                                );
                              },
                              icon:
                                  const Icon(
                                Icons.copy,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          coupon["title"],
                          style:
                              AppStyles.title,
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          coupon[
                              "description"],
                          style:
                              AppStyles.bodyMedium,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .confirmation_number,
                              size: 18,
                            ),

                            const SizedBox(
                                width: 6),

                            Text(
                              coupon["code"],
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .calendar_today,
                              size: 16,
                              color:
                                  Colors.red,
                            ),

                            const SizedBox(
                                width: 6),

                            Text(
                              "Expires: ${coupon["expiry"]}",
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              ElevatedButton(
                            style: AppStyles
                                .primaryButton,
                            onPressed: () {
                              setState(() {
                                selectedCoupon =
                                    coupon[
                                        "code"];
                              });

                              _applyCoupon(
                                coupon[
                                    "code"],
                              );
                            },
                            child:
                                const Text(
                              "Apply Coupon",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}