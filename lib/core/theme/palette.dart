import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Theme-aware colors for screens that are shown in both light and dark mode.
class Palette {
  final bool isDark;
  const Palette._(this.isDark);

  factory Palette.of(BuildContext context) =>
      Palette._(Theme.of(context).brightness == Brightness.dark);

  Color get background =>
      isDark ? AppColors.background : AppColors.lightBackground;
  Color get card => isDark ? AppColors.process : Colors.white;
  Color get cardMuted => isDark
      ? AppColors.process.withValues(alpha: 0.5)
      : AppColors.lightProcess;
  Color get textPrimary => isDark ? Colors.white : AppColors.lightTextPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get border => isDark
      ? AppColors.accent.withValues(alpha: 0.12)
      : Colors.black.withValues(alpha: 0.06);

  /// Accent for text and small icons: the neon accent is too light to read
  /// on the light background, so a deeper green is used there.
  Color get accentText => isDark ? AppColors.accent : const Color(0xFF15803D);

  List<BoxShadow> get softShadow => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.25)
          : const Color(0x140B5D36),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: softShadow,
  );
}
