import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String? labelText;
  final String? hintText;
  final String Function(T item)? itemLabelBuilder;
  final Widget Function(T item)? itemBuilder;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isExpanded;
  final bool isRequired;
  final Widget? prefixIcon;
  final Color? fillColor;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.labelText,
    this.hintText,
    this.itemLabelBuilder,
    this.itemBuilder,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.isExpanded = true,
    this.isRequired = false,
    this.prefixIcon,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: isExpanded,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
      decoration: InputDecoration(
        labelText: isRequired
            ? '${labelText ?? ''} *'
            : labelText,
        hintText: hintText,
        filled: true,
        fillColor:
            fillColor ?? AppColors.surface,
        prefixIcon: prefixIcon,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: itemBuilder != null
              ? itemBuilder!(item)
              : Text(
                  itemLabelBuilder != null
                      ? itemLabelBuilder!(item)
                      : item.toString(),
                  overflow:
                      TextOverflow.ellipsis,
                ),
        );
      }).toList(),
    );
  }
}