import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class WishlistAction
    extends StatelessWidget {
  const WishlistAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.favorite_border,
      ),
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.wishlist,
        );
      },
    );
  }
}