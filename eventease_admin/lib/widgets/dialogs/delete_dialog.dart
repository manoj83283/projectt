import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../common/custom_button.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;

  final String confirmText;
  final String cancelText;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final bool isLoading;
  final bool showWarningText;

  final IconData icon;

  const DeleteDialog({
    super.key,
    this.title = AppStrings.deleteConfirmationTitle,
    this.message = AppStrings.deleteConfirmationMessage,
    this.confirmText = AppStrings.delete,
    this.cancelText = AppStrings.cancel,
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
    this.showWarningText = true,
    this.icon = Icons.delete_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
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
          maxWidth: 430,
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
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: 0.10,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.error,
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

              if (showWarningText) ...[
                const SizedBox(
                  height: AppDimensions.padding16,
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(
                    AppDimensions.padding12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radius12,
                    ),
                    border: Border.all(
                      color: AppColors.error.withValues(
                        alpha: 0.18,
                      ),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              // =====================================================
              // ACTION BUTTONS
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
                          return;
                        }

                        Navigator.of(context).pop(
                          false,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: AppDimensions.padding12,
                  ),

                  Expanded(
                    child: CustomButton(
                      text: confirmText,
                      type: ButtonType.danger,
                      icon: Icons.delete_outline_rounded,
                      isLoading: isLoading,
                      onPressed: isLoading
                          ? null
                          : () {
                              if (onConfirm != null) {
                                onConfirm!();
                                return;
                              }

                              Navigator.of(context).pop(
                                true,
                              );
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
  // STATIC SHOW
  // =====================================================

  static Future<bool?> show({
    required BuildContext context,
    String title = AppStrings.deleteConfirmationTitle,
    String message = AppStrings.deleteConfirmationMessage,
    String confirmText = AppStrings.delete,
    String cancelText = AppStrings.cancel,
    bool barrierDismissible = true,
    bool showWarningText = true,
    IconData icon = Icons.delete_outline_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return DeleteDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          showWarningText: showWarningText,
          icon: icon,
        );
      },
    );
  }
}

// =====================================================
// MODULE SPECIFIC DELETE DIALOGS
// =====================================================

class DeleteCustomerDialog {
  DeleteCustomerDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Customer',
      message:
          'Are you sure you want to delete this customer? All related customer activity may also be affected.',
      confirmText: 'Delete',
    );
  }
}

class DeleteProviderDialog {
  DeleteProviderDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Provider',
      message:
          'Are you sure you want to delete this provider? Provider services, bookings, and settlement records may be affected.',
      confirmText: 'Delete',
    );
  }
}

class DeleteCategoryDialog {
  DeleteCategoryDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Category',
      message:
          'Are you sure you want to delete this category? Services under this category may be impacted.',
      confirmText: 'Delete',
    );
  }
}

class DeleteServiceDialog {
  DeleteServiceDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Service',
      message:
          'Are you sure you want to delete this service? This may impact active or historical booking data.',
      confirmText: 'Delete',
    );
  }
}

class DeleteBookingDialog {
  DeleteBookingDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Booking',
      message:
          'Are you sure you want to delete this booking record?',
      confirmText: 'Delete',
    );
  }
}

class DeleteOrderDialog {
  DeleteOrderDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Order',
      message:
          'Are you sure you want to delete this order record?',
      confirmText: 'Delete',
    );
  }
}

class DeleteCouponDialog {
  DeleteCouponDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Coupon',
      message:
          'Are you sure you want to delete this coupon? Customers will no longer be able to use this offer.',
      confirmText: 'Delete',
    );
  }
}

class DeleteBannerDialog {
  DeleteBannerDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Banner',
      message:
          'Are you sure you want to delete this banner from the platform?',
      confirmText: 'Delete',
    );
  }
}

class DeleteReviewDialog {
  DeleteReviewDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Review',
      message:
          'Are you sure you want to permanently delete this review?',
      confirmText: 'Delete',
    );
  }
}

class DeleteNotificationDialog {
  DeleteNotificationDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Notification',
      message:
          'Are you sure you want to delete this notification record?',
      confirmText: 'Delete',
    );
  }
}

class DeleteTicketDialog {
  DeleteTicketDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Support Ticket',
      message:
          'Are you sure you want to delete this support ticket?',
      confirmText: 'Delete',
    );
  }
}

class DeleteAdminDialog {
  DeleteAdminDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Admin',
      message:
          'Are you sure you want to delete this admin account? This may affect role and permission management.',
      confirmText: 'Delete',
    );
  }
}

class DeleteReportDialog {
  DeleteReportDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return DeleteDialog.show(
      context: context,
      title: 'Delete Report',
      message:
          'Are you sure you want to delete this generated report?',
      confirmText: 'Delete',
    );
  }
}