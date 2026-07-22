import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class NotificationAction
    extends StatelessWidget {
  const NotificationAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.notifications_outlined,
      ),
      onPressed: () {
        Navigator.pushNamed(
          context,
          AppRoutes.notifications,
        );
      },
    );
  }
}