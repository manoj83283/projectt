import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool enabled;
  final bool readOnly;
  final bool showVoiceButton;
  final bool showFilterButton;

  final VoidCallback? onTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.hintText =
        "Search services, providers, venues...",
    this.enabled = true,
    this.readOnly = false,
    this.showVoiceButton = false,
    this.showFilterButton = false,
    this.onTap,
    this.onVoiceTap,
    this.onFilterTap,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<SearchBarWidget> createState() =>
      _SearchBarWidgetState();
}

class _SearchBarWidgetState
    extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ??
            TextEditingController();
  }

  void clearSearch() {
    _controller.clear();

    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: (value) {
          setState(() {});
          widget.onChanged?.call(value);
        },
        onSubmitted:
            widget.onSubmitted,
        textInputAction:
            TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,

          border: InputBorder.none,

          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),

          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),

          suffixIcon: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.close,
                  ),
                  onPressed:
                      clearSearch,
                ),

              if (widget.showVoiceButton)
                IconButton(
                  icon: const Icon(
                    Icons.mic,
                  ),
                  onPressed:
                      widget.onVoiceTap,
                ),

              if (widget.showFilterButton)
                IconButton(
                  icon: const Icon(
                    Icons.tune,
                  ),
                  onPressed:
                      widget.onFilterTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}