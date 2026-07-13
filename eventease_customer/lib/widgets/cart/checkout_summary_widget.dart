import 'package:flutter/material.dart';

class CheckoutSummaryWidget extends StatelessWidget {
  final double itemTotal;
  final double discount;
  final double couponDiscount;
  final double serviceFee;
  final double platformFee;
  final double deliveryFee;
  final double tax;

  final String? couponCode;
  final VoidCallback? onApplyCoupon;
  final VoidCallback? onCheckout;

  const CheckoutSummaryWidget({
    super.key,
    required this.itemTotal,
    this.discount = 0,
    this.couponDiscount = 0,
    this.serviceFee = 0,
    this.platformFee = 0,
    this.deliveryFee = 0,
    this.tax = 0,
    this.couponCode,
    this.onApplyCoupon,
    this.onCheckout,
  });

  double get totalAmount {
    return itemTotal -
        discount -
        couponDiscount +
        serviceFee +
        platformFee +
        deliveryFee +
        tax;
  }

  Widget _priceRow({
    required String title,
    required String value,
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
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
              color: color,
              fontWeight: isBold
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Price Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _priceRow(
              title: "Item Total",
              value:
                  "₹${itemTotal.toStringAsFixed(0)}",
            ),

            if (discount > 0)
              _priceRow(
                title: "Discount",
                value:
                    "-₹${discount.toStringAsFixed(0)}",
                color: Colors.green,
              ),

            if (couponDiscount > 0)
              _priceRow(
                title: "Coupon Discount",
                value:
                    "-₹${couponDiscount.toStringAsFixed(0)}",
                color: Colors.green,
              ),

            if (platformFee > 0)
              _priceRow(
                title: "Platform Fee",
                value:
                    "₹${platformFee.toStringAsFixed(0)}",
              ),

            if (serviceFee > 0)
              _priceRow(
                title: "Service Fee",
                value:
                    "₹${serviceFee.toStringAsFixed(0)}",
              ),

            if (deliveryFee > 0)
              _priceRow(
                title: "Delivery Fee",
                value:
                    "₹${deliveryFee.toStringAsFixed(0)}",
              ),

            if (tax > 0)
              _priceRow(
                title: "GST / Tax",
                value:
                    "₹${tax.toStringAsFixed(0)}",
              ),

            const Divider(height: 24),

            if (couponCode != null)
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Colors.green.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Coupon Applied: $couponCode",
                        style:
                            const TextStyle(
                          color:
                              Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            OutlinedButton.icon(
              onPressed: onApplyCoupon,
              icon: const Icon(
                Icons.discount,
              ),
              label: const Text(
                "Apply Coupon",
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    "Grand Total",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "₹${totalAmount.toStringAsFixed(0)}",
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onCheckout,
                icon: const Icon(
                  Icons.payment,
                ),
                label: Text(
                  "Proceed to Pay ₹${totalAmount.toStringAsFixed(0)}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}