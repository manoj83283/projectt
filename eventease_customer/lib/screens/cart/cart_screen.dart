import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController couponController =
      TextEditingController();

  List<Map<String, dynamic>> cartItems = [
    {
      'id': '1',
      'name': 'Wedding Photography',
      'provider': 'RK Photography',
      'price': 15000,
      'quantity': 1,
    },
    {
      'id': '2',
      'name': 'Event Decoration',
      'provider': 'Royal Decorations',
      'price': 10000,
      'quantity': 1,
    },
  ];

  Future<void> refreshCart() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity'] =
          (cartItems[index]['quantity'] as int) + 1;
    });
  }

  void decreaseQuantity(int index) {
    final quantity = cartItems[index]['quantity'] as int;

    if (quantity > 1) {
      setState(() {
        cartItems[index]['quantity'] = quantity - 1;
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  double get subtotal {
    double total = 0;

    for (final item in cartItems) {
      total +=
          (item['price'] as int) *
          (item['quantity'] as int);
    }

    return total;
  }

  double get platformFee {
    if (cartItems.isEmpty) {
      return 0;
    }

    return 500;
  }

  double get totalAmount => subtotal + platformFee;

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final couponCode = couponController.text.trim();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter coupon code',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Coupon Applied',
        ),
      ),
    );
  }

  void _goToCheckout() {
    Navigator.pushNamed(
      context,
      RouteConfig.booking,
      arguments: {
        'cartItems': cartItems,
        'subtotal': subtotal,
        'platformFee': platformFee,
        'totalAmount': totalAmount,
      },
    );
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConfig.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title: const Text(
          'My Cart',
        ),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : RefreshIndicator(
              onRefresh: refreshCart,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      children: [
                        // =====================
                        // CART ITEMS
                        // =====================

                        ...List.generate(
                          cartItems.length,
                          (index) {
                            final item = cartItems[index];

                            return _cartItemCard(
                              item: item,
                              index: index,
                            );
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // =====================
                        // COUPON
                        // =====================

                        const Text(
                          'Coupon Code',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        _couponSection(),

                        const SizedBox(
                          height: 25,
                        ),

                        // =====================
                        // SUMMARY
                        // =====================

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(
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
                                const Divider(),
                                _summaryRow(
                                  'Total Amount',
                                  '₹${totalAmount.toStringAsFixed(0)}',
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
                ],
              ),
            ),
      bottomNavigationBar:
          cartItems.isEmpty ? null : _checkoutBar(),
    );
  }

  Widget _cartItemCard({
    required Map<String, dynamic> item,
    required int index,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.business_center,
                color: ThemeConfig.primaryColor,
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
                    item['name']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    item['provider']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '₹${item['price']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () {
                    removeItem(index);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.remove_circle_outline,
                      ),
                      onPressed: () {
                        decreaseQuantity(index);
                      },
                    ),
                    Text(
                      cartItems[index]['quantity'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add_circle_outline,
                      ),
                      onPressed: () {
                        increaseQuantity(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _couponSection() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: couponController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Enter Coupon Code',
            ),
            onSubmitted: (_) {
              _applyCoupon();
            },
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        // Important:
        // Fixed width prevents global ElevatedButton theme with
        // double.infinity width from crashing inside this Row.
        SizedBox(
          width: 95,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(
                0,
                48,
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: _applyCoupon,
            child: const Text(
              'Apply',
            ),
          ),
        ),
      ],
    );
  }

  Widget _checkoutBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(
          16,
        ),
        color: Colors.white,
        child: SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(
                0,
                55,
              ),
            ),
            onPressed: _goToCheckout,
            child: Text(
              'Checkout ₹${totalAmount.toStringAsFixed(0)}',
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
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Colors.grey.shade400,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'Your Cart Is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              'Browse services and add them to your cart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    0,
                    48,
                  ),
                ),
                onPressed: _goToHome,
                child: const Text(
                  'Explore Services',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}