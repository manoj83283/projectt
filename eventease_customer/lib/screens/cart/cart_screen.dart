import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
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
      cartItems[index]['quantity']++;
    });
  }

  void decreaseQuantity(int index) {
    if (cartItems[index]['quantity'] > 1) {
      setState(() {
        cartItems[index]['quantity']--;
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

    for (var item in cartItems) {
      total +=
          (item['price'] as int) *
          (item['quantity'] as int);
    }

    return total;
  }

  double get platformFee => 500;

  double get totalAmount =>
      subtotal + platformFee;

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text('My Cart'),
      ),

      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : RefreshIndicator(
              onRefresh: refreshCart,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      children: [
                        // =====================
                        // CART ITEMS
                        // =====================

                        ...List.generate(
                          cartItems.length,
                          (index) {
                            final item =
                                cartItems[
                                    index];

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration:
                                          BoxDecoration(
                                        color: ThemeConfig
                                            .primaryColor
                                            .withOpacity(
                                          0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      child:
                                          const Icon(
                                        Icons
                                            .business_center,
                                        color: ThemeConfig
                                            .primaryColor,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item[
                                                'name'],
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
                                                5,
                                          ),

                                          Text(
                                            item[
                                                'provider'],
                                          ),

                                          const SizedBox(
                                            height:
                                                8,
                                          ),

                                          Text(
                                            '₹${item['price']}',
                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.green,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () =>
                                                  removeItem(
                                            index,
                                          ),
                                          icon:
                                              const Icon(
                                            Icons
                                                .delete,
                                            color:
                                                Colors.red,
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            IconButton(
                                              icon:
                                                  const Icon(
                                                Icons
                                                    .remove_circle_outline,
                                              ),
                                              onPressed:
                                                  () {
                                                decreaseQuantity(
                                                  index,
                                                );
                                              },
                                            ),
                                            Text(
                                              cartItems[index]
                                                      [
                                                      'quantity']
                                                  .toString(),
                                            ),
                                            IconButton(
                                              icon:
                                                  const Icon(
                                                Icons
                                                    .add_circle_outline,
                                              ),
                                              onPressed:
                                                  () {
                                                increaseQuantity(
                                                  index,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
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
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  TextField(
                                controller:
                                    couponController,
                                decoration:
                                    const InputDecoration(
                                  hintText:
                                      'Enter Coupon Code',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text(
                                      'Coupon Applied',
                                    ),
                                  ),
                                );
                              },
                              child:
                                  const Text(
                                'Apply',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // =====================
                        // SUMMARY
                        // =====================

                        Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(
                              16,
                            ),
                            child:
                                Column(
                              children: [
                                _summaryRow(
                                  'Subtotal',
                                  '₹${subtotal.toStringAsFixed(0)}',
                                ),
                                _summaryRow(
                                  'Platform Fee',
                                  '₹500',
                                ),
                                const Divider(),
                                _summaryRow(
                                  'Total Amount',
                                  '₹${totalAmount.toStringAsFixed(0)}',
                                  isTotal:
                                      true,
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
          cartItems.isEmpty
              ? null
              : Container(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  color: Colors.white,
                  child: SizedBox(
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteConfig
                              .booking,
                        );
                      },
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
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: isTotal
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Browse services and add them to your cart.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteConfig.home,
                  (route) => false,
                );
              },
              child: const Text(
                'Explore Services',
              ),
            ),
          ],
        ),
      ),
    );
  }
}