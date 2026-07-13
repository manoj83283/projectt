import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool isOutlined;
  final IconData? icon;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.isOutlined = false,
    this.icon,
    this.height = 55,
    this.borderRadius = 12,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        backgroundColor ??
            Theme.of(context).primaryColor;

    final Color textColor =
        foregroundColor ?? Colors.white;

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton.icon(
          onPressed: (isEnabled && !isLoading)
              ? onPressed
              : null,
          icon: icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
          label: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
          style: OutlinedButton.styleFrom(
            minimumSize:
                Size(double.infinity, height),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                borderRadius,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading)
            ? onPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              borderRadius,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}