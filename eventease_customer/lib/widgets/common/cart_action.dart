import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class CartAction extends StatelessWidget {
  final int count;

  const CartAction({
    super.key,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
          ),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.cart,
            );
          },
        ),

        if (count > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.all(4),
              decoration:
                  const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}