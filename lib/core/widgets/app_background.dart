import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shared app backdrop: soft vertical gradient, two blurred accent glows and
/// a faint dot grid. Theme-aware, drawn in code so it stays sharp on every
/// screen size.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _BackgroundPainter(isDark: isDark)),
          ),
        ),
        child,
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final bool isDark;

  _BackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF0B2414),
                  AppColors.background,
                  Color(0xFF030D07),
                ]
              : const [
                  Color(0xFFF7FCF9),
                  AppColors.lightBackground,
                  Color(0xFFE6F3EB),
                ],
        ).createShader(rect),
    );

    // Accent glow, top right
    _glow(
      canvas,
      center: Offset(size.width * 0.95, size.height * 0.04),
      radius: size.width * 0.85,
      color: AppColors.accent.withValues(alpha: isDark ? 0.16 : 0.22),
    );
    // Teal glow, lower left
    _glow(
      canvas,
      center: Offset(size.width * 0.0, size.height * 0.78),
      radius: size.width * 0.9,
      color: const Color(0xFF1FB5A0).withValues(alpha: isDark ? 0.10 : 0.12),
    );

    // Faint dot grid for texture
    final dot = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF0B5D36)).withValues(
        alpha: isDark ? 0.035 : 0.05,
      );
    const spacing = 26.0;
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, dot);
      }
    }
  }

  void _glow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
