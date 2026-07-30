import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

extension ThemeExtensionX on BuildContext {
  ThemeData get theme =>
      Theme.of(this);

  ColorScheme get colors =>
      Theme.of(this).colorScheme;

  TextTheme get textTheme =>
      Theme.of(this).textTheme;

  bool get isDarkMode =>
      Theme.of(this).brightness ==
      Brightness.dark;

  Color get primaryColor =>
      AppColors.primary;

  Color get successColor =>
      AppColors.success;

  Color get warningColor =>
      AppColors.warning;

  Color get errorColor =>
      AppColors.error;

  Color get backgroundColor =>
      isDarkMode
          ? AppColors.darkBackground
          : AppColors.background;
}