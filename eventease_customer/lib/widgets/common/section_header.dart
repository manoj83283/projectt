import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    required this.title, super.key,
    this.actionText,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          if (actionText != null)
            InkWell(
              onTap: onTap,
              borderRadius:
                  BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      actionText!,
                      style: const TextStyle(
                        color:
                            AppColors.primary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color:
                          AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}