import 'package:flutter/material.dart';


class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    required this.title, super.key,
    this.showBackButton = true,
    this.centerTitle = false,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.elevation = 0,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor:
          backgroundColor ?? Colors.white,
      foregroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,

      automaticallyImplyLeading: false,

      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
              ),
              onPressed: onBackPressed ??
                  () {
                    Navigator.pop(context);
                  },
            )
          : null,

      actions: actions,

      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(
        kToolbarHeight +
            (bottom?.preferredSize.height ??
                0),
      );
}