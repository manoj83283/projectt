import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.icon,
    this.width,
    this.height =
        AppDimensions.buttonHeight,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        _getButtonColor();

    final textColor =
        _getTextColor();

    final radius =
        borderRadius ??
            BorderRadius.circular(
              AppDimensions.buttonRadius,
            );

    Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize:
                MainAxisSize.min,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: textColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          );

    switch (type) {
      case ButtonType.outline:
        return SizedBox(
          width: width,
          height: height,
          child: OutlinedButton(
            onPressed:
                isEnabled &&
                        !isLoading
                    ? onPressed
                    : null,
            style:
                OutlinedButton.styleFrom(
              padding:
                  padding ??
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
              side: BorderSide(
                color: buttonColor,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius: radius,
              ),
            ),
            child: child,
          ),
        );

      case ButtonType.text:
        return SizedBox(
          width: width,
          height: height,
          child: TextButton(
            onPressed:
                isEnabled &&
                        !isLoading
                    ? onPressed
                    : null,
            style:
                TextButton.styleFrom(
              shape:
                  RoundedRectangleBorder(
                borderRadius: radius,
              ),
            ),
            child: child,
          ),
        );

      default:
        return SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed:
                isEnabled &&
                        !isLoading
                    ? onPressed
                    : null,
            style:
                ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  buttonColor,
              disabledBackgroundColor:
                  Colors.grey.shade400,
              padding:
                  padding ??
                      const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
              shape:
                  RoundedRectangleBorder(
                borderRadius: radius,
              ),
            ),
            child: child,
          ),
        );
    }
  }

  Color _getButtonColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;

      case ButtonType.secondary:
        return AppColors.secondary;

      case ButtonType.success:
        return AppColors.success;

      case ButtonType.danger:
        return AppColors.error;

      case ButtonType.warning:
        return AppColors.warning;

      case ButtonType.outline:
        return AppColors.primary;

      case ButtonType.text:
        return AppColors.primary;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.outline:
      case ButtonType.text:
        return AppColors.primary;

      default:
        return Colors.white;
    }
  }
}