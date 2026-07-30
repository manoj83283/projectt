import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;

  final String confirmText;
  final String cancelText;

  final IconData icon;

  final Color confirmButtonColor;
  final Color iconColor;

  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.icon = Icons.help_outline,
    this.confirmButtonColor = Colors.blue,
    this.iconColor = Colors.blue,
    this.isDestructive = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.help_outline,
    Color confirmButtonColor = Colors.blue,
    Color iconColor = Colors.blue,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        confirmButtonColor:
            confirmButtonColor,
        iconColor: iconColor,
        isDestructive: isDestructive,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      contentPadding:
          const EdgeInsets.all(24),
      content: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          // ==========================
          // ICON
          // ==========================

          CircleAvatar(
            radius: 32,
            backgroundColor:
                iconColor.withOpacity(0.1),
            child: Icon(
              icon,
              size: 34,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 20),

          // ==========================
          // TITLE
          // ==========================

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // ==========================
          // MESSAGE
          // ==========================

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // ==========================
          // ACTIONS
          // ==========================

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  child: Text(
                    cancelText,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        isDestructive
                            ? Colors.red
                            : confirmButtonColor,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      true,
                    );
                  },
                  child: Text(
                    confirmText,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==============================================
// DELETE CONFIRMATION
// ==============================================

class DeleteConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    String title =
        'Delete Item',
    String message =
        'Are you sure you want to delete this item? This action cannot be undone.',
  }) {
    return ConfirmationDialog.show(
      context,
      title: title,
      message: message,
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      confirmButtonColor:
          Colors.red,
      confirmText: 'Delete',
      isDestructive: true,
    );
  }
}

// ==============================================
// LOGOUT CONFIRMATION
// ==============================================

class LogoutConfirmationDialog {
  static Future<bool> show(
    BuildContext context,
  ) {
    return ConfirmationDialog.show(
      context,
      title: 'Logout',
      message:
          'Are you sure you want to logout from your account?',
      icon: Icons.logout,
      iconColor: Colors.orange,
      confirmButtonColor:
          Colors.orange,
      confirmText: 'Logout',
    );
  }
}

// ==============================================
// CANCEL BOOKING
// ==============================================

class CancelBookingDialog {
  static Future<bool> show(
    BuildContext context,
  ) {
    return ConfirmationDialog.show(
      context,
      title: 'Cancel Booking',
      message:
          'Do you really want to cancel this booking?',
      icon: Icons.event_busy,
      iconColor: Colors.red,
      confirmButtonColor:
          Colors.red,
      confirmText: 'Cancel Booking',
      isDestructive: true,
    );
  }
}

// ==============================================
// DELETE SERVICE
// ==============================================

class DeleteServiceDialog {
  static Future<bool> show(
    BuildContext context,
  ) {
    return ConfirmationDialog.show(
      context,
      title: 'Delete Service',
      message:
          'Deleting this service will permanently remove it from your account.',
      icon:
          Icons.miscellaneous_services,
      iconColor: Colors.red,
      confirmButtonColor:
          Colors.red,
      confirmText: 'Delete',
      isDestructive: true,
    );
  }
}