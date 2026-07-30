import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final bool isLoading;
  final bool enabled;

  final IconData? icon;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  final double height;
  final double borderRadius;
  final double fontSize;
  final double elevation;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height = 52,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.elevation = 0,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled =
        !enabled || isLoading;

    return Container(
      margin: margin,
      width: double.infinity,
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: isDisabled
              ? null
              : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: elevation,
            backgroundColor:
                backgroundColor ??
                    Theme.of(context)
                        .primaryColor,
            foregroundColor:
                textColor ?? Colors.white,
            disabledBackgroundColor:
                Colors.grey.shade400,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                borderRadius,
              ),
              side: borderColor != null
                  ? BorderSide(
                      color:
                          borderColor!,
                    )
                  : BorderSide.none,
            ),
            padding:
                padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: TextStyle(
                          fontSize:
                              fontSize,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}