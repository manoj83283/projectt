import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../common/custom_button.dart';

class ApproveDialog extends StatelessWidget {
  final String title;
  final String message;

  final String confirmText;
  final String cancelText;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final bool isLoading;

  final IconData icon;

  const ApproveDialog({
    super.key,
    this.title = 'Approve Request',
    this.message =
        'Are you sure you want to approve this request?',
    this.confirmText = 'Approve',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
    this.icon =
        Icons.check_circle_outline_rounded,
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
              // ==========================================
              // ICON
              // ==========================================

              Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  color:
                      AppColors.success
                          .withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding20,
              ),

              // ==========================================
              // TITLE
              // ==========================================

              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),

              const SizedBox(
                height: AppDimensions.padding12,
              ),

              // ==========================================
              // MESSAGE
              // ==========================================

              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),

              const SizedBox(
                height: AppDimensions.padding20,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppDimensions.padding12,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.success
                          .withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radius12,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color:
                          AppColors.success,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This action will approve and activate the selected record.',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(
                height: AppDimensions.padding24,
              ),

              // ==========================================
              // ACTIONS
              // ==========================================

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: cancelText,
                      type: ButtonType.outline,
                      isEnabled:
                          !isLoading,
                      onPressed: () {
                        if (onCancel !=
                            null) {
                          onCancel!();
                          return;
                        }

                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width:
                        AppDimensions.padding12,
                  ),

                  Expanded(
                    child: CustomButton(
                      text: confirmText,
                      type: ButtonType.success,
                      icon: Icons.check,
                      isLoading:
                          isLoading,
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                  if (onConfirm !=
                                      null) {
                                    onConfirm!();
                                    return;
                                  }

                                  Navigator.pop(
                                    context,
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

  // ==========================================
  // STATIC SHOW
  // ==========================================

  static Future<bool?> show({
    required BuildContext context,
    String title =
        'Approve Request',
    String message =
        'Are you sure you want to approve this request?',
    String confirmText = 'Approve',
    String cancelText = 'Cancel',
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible:
          barrierDismissible,
      builder: (_) {
        return ApproveDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
        );
      },
    );
  }
}

// ==========================================
// PROVIDER APPROVAL
// ==========================================

class ApproveProviderDialog {
  ApproveProviderDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return ApproveDialog.show(
      context: context,
      title: 'Approve Provider',
      message:
          'Are you sure you want to approve this provider account?',
    );
  }
}

// ==========================================
// KYC APPROVAL
// ==========================================

class ApproveKycDialog {
  ApproveKycDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return ApproveDialog.show(
      context: context,
      title: 'Approve KYC',
      message:
          'Are you sure you want to approve this KYC verification request?',
    );
  }
}

// ==========================================
// SERVICE APPROVAL
// ==========================================

class ApproveServiceDialog {
  ApproveServiceDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return ApproveDialog.show(
      context: context,
      title: 'Approve Service',
      message:
          'Are you sure you want to approve this service listing?',
    );
  }
}

// ==========================================
// SETTLEMENT APPROVAL
// ==========================================

class ApproveSettlementDialog {
  ApproveSettlementDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return ApproveDialog.show(
      context: context,
      title: 'Approve Settlement',
      message:
          'Are you sure you want to approve this provider settlement request?',
    );
  }
}

// ==========================================
// REVIEW APPROVAL
// ==========================================

class ApproveReviewDialog {
  ApproveReviewDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return ApproveDialog.show(
      context: context,
      title: 'Approve Review',
      message:
          'Are you sure you want to approve this customer review?',
    );
  }
}

// ==========================================
// ADMIN APPROVAL
// ==========================================

class ApproveAdminDialog {
  ApproveAdminDialog._();

  static Future<bool?> show({
    required BuildContext context,
  }) {
    return ApproveDialog.show(
      context: context,
      title: 'Approve Admin',
      message:
          'Are you sure you want to activate and approve this admin account?',
    );
  }
}