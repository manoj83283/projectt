import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;
  final int debounceMilliseconds;
  final EdgeInsetsGeometry? margin;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
    this.debounceMilliseconds = 500,
    this.margin,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomSearchBar> createState() =>
      _CustomSearchBarState();
}

class _CustomSearchBarState
    extends State<CustomSearchBar> {
  late TextEditingController
      _controller;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ??
            TextEditingController();

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _onSearchChanged(
    String value,
  ) {
    if (widget.onChanged == null) {
      return;
    }

    _debounce?.cancel();

    _debounce = Timer(
      Duration(
        milliseconds:
            widget
                .debounceMilliseconds,
      ),
      () {
        widget.onChanged?.call(
          value.trim(),
        );
      },
    );
  }

  void _clearSearch() {
    _controller.clear();

    widget.onChanged?.call('');
    widget.onClear?.call();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: 50,
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        textInputAction:
            TextInputAction.search,
        onChanged: _onSearchChanged,
        onSubmitted:
            widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,

          filled: true,
          fillColor:
              AppColors.surface,

          prefixIcon:
              widget.prefixIcon ??
              const Icon(
                Icons.search,
                color:
                    AppColors.primary,
              ),

          suffixIcon:
              widget.suffixIcon ??
              (_controller
                      .text
                      .isNotEmpty
                  ? IconButton(
                      onPressed:
                          _clearSearch,
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
                  : null),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radius12,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radius12,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radius12,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.primary,
              width: 2,
            ),
          ),

          disabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radius12,
            ),
            borderSide:
                BorderSide(
              color:
                  Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TABLE SEARCH BAR
// =====================================================

class TableSearchBar
    extends StatelessWidget {
  final TextEditingController
      controller;

  final ValueChanged<String>?
      onChanged;

  const TableSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: CustomSearchBar(
        controller: controller,
        hintText:
            'Search records...',
        onChanged: onChanged,
      ),
    );
  }
}

// =====================================================
// SEARCH APP BAR
// =====================================================

class SearchAppBar
    extends StatelessWidget {
  final TextEditingController
      controller;

  final ValueChanged<String>?
      onChanged;

  final String hintText;

  const SearchAppBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText =
        'Search anything...',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: CustomSearchBar(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
      ),
    );
  }
}