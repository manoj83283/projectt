import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../common/custom_button.dart';

enum ConfirmationDialogType {
  info,
  success,
  warning,
  danger,
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;

  final String confirmText;
  final String cancelText;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final ConfirmationDialogType type;

  final IconData? icon;

  final bool isLoading;
  final bool barrierDismissible;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.type = ConfirmationDialogType.info,
    this.icon,
    this.isLoading = false,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _getColor();
    final IconData dialogIcon =
        icon ?? _getDefaultIcon();

    return Dialog(
      insetPadding: const EdgeInsets.all(
        AppDimensions.padding24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius20,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.padding24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // =====================================================
              // ICON
              // =====================================================

              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  dialogIcon,
                  color: color,
                  size: 38,
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding20,
              ),

              // =====================================================
              // TITLE
              // =====================================================

              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),

              const SizedBox(
                height: AppDimensions.padding12,
              ),

              // =====================================================
              // MESSAGE
              // =====================================================

              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              // =====================================================
              // ACTIONS
              // =====================================================

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: cancelText,
                      type: ButtonType.outline,
                      isEnabled: !isLoading,
                      onPressed: () {
                        if (onCancel != null) {
                          onCancel!();
                        } else {
                          Navigator.of(context).pop(
                            false,
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(
                    width: AppDimensions.padding12,
                  ),

                  Expanded(
                    child: CustomButton(
                      text: confirmText,
                      type: _getButtonType(),
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () {
                              if (onConfirm != null) {
                                onConfirm!();
                              } else {
                                Navigator.of(context).pop(
                                  true,
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // COLOR
  // =====================================================

  Color _getColor() {
    switch (type) {
      case ConfirmationDialogType.success:
        return AppColors.success;

      case ConfirmationDialogType.warning:
        return AppColors.warning;

      case ConfirmationDialogType.danger:
        return AppColors.error;

      case ConfirmationDialogType.info:
        return AppColors.primary;
    }
  }

  // =====================================================
  // ICON
  // =====================================================

  IconData _getDefaultIcon() {
    switch (type) {
      case ConfirmationDialogType.success:
        return Icons.check_circle_outline_rounded;

      case ConfirmationDialogType.warning:
        return Icons.warning_amber_rounded;

      case ConfirmationDialogType.danger:
        return Icons.delete_outline_rounded;

      case ConfirmationDialogType.info:
        return Icons.info_outline_rounded;
    }
  }

  // =====================================================
  // BUTTON TYPE
  // =====================================================

  ButtonType _getButtonType() {
    switch (type) {
      case ConfirmationDialogType.success:
        return ButtonType.success;

      case ConfirmationDialogType.warning:
        return ButtonType.warning;

      case ConfirmationDialogType.danger:
        return ButtonType.danger;

      case ConfirmationDialogType.info:
        return ButtonType.primary;
    }
  }

  // =====================================================
  // STATIC SHOW METHOD
  // =====================================================

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    ConfirmationDialogType type =
        ConfirmationDialogType.info,
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          type: type,
          icon: icon,
          barrierDismissible: barrierDismissible,
        );
      },
    );
  }
}

// =====================================================
// DELETE CONFIRMATION DIALOG
// =====================================================

class DeleteConfirmationDialog {
  DeleteConfirmationDialog._();

  static Future<bool?> show({
    required BuildContext context,
    String title = 'Delete Confirmation',
    String message =
        'Are you sure you want to delete this item? This action cannot be undone.',
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: ConfirmationDialogType.danger,
      icon: Icons.delete_outline_rounded,
    );
  }
}

// =====================================================
// LOGOUT CONFIRMATION DIALOG
// =====================================================

class LogoutConfirmationDialog {
  LogoutConfirmationDialog._();

  static Future<bool?> show({
    required BuildContext context,
    String title = 'Logout',
    String message = 'Are you sure you want to logout?',
    String confirmText = 'Logout',
    String cancelText = 'Cancel',
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: ConfirmationDialogType.warning,
      icon: Icons.logout_rounded,
    );
  }
}

// =====================================================
// APPROVE CONFIRMATION DIALOG
// =====================================================

class ApproveConfirmationDialog {
  ApproveConfirmationDialog._();

  static Future<bool?> show({
    required BuildContext context,
    String title = 'Approve Confirmation',
    String message =
        'Are you sure you want to approve this request?',
    String confirmText = 'Approve',
    String cancelText = 'Cancel',
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: ConfirmationDialogType.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }
}

// =====================================================
// REJECT CONFIRMATION DIALOG
// =====================================================

class RejectConfirmationDialog {
  RejectConfirmationDialog._();

  static Future<bool?> show({
    required BuildContext context,
    String title = 'Reject Confirmation',
    String message =
        'Are you sure you want to reject this request?',
    String confirmText = 'Reject',
    String cancelText = 'Cancel',
  }) {
    return ConfirmationDialog.show(
      context: context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      type: ConfirmationDialogType.danger,
      icon: Icons.cancel_outlined,
    );
  }
}