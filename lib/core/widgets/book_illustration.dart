import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Open-book illustration with a highlighted line, a bookmark ribbon and
/// twinkling sparkles. Drawn with a CustomPainter so it scales cleanly and
/// follows the light/dark theme. Set [animate] to float the book gently.
class BookIllustration extends StatefulWidget {
  final double width;
  final bool animate;

  const BookIllustration({super.key, this.width = 180, this.animate = true});

  @override
  State<BookIllustration> createState() => _BookIllustrationState();
}

class _BookIllustrationState extends State<BookIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: widget.width,
      height: widget.width * 0.75,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _BookPainter(
            t: Curves.easeInOut.transform(_controller.value),
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _BookPainter extends CustomPainter {
  final double t;
  final bool isDark;

  _BookPainter({required this.t, required this.isDark});

  // Design space is 240 x 180, scaled to the widget size.
  static const double _w = 240;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / _w;
    canvas.save();
    canvas.scale(s);

    final bob = -3.0 * t; // gentle float

    // Ground shadow (shrinks slightly as the book floats up)
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(120, 168),
        width: 180 - 14 * t,
        height: 14,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.save();
    canvas.translate(0, bob);

    // Cover
    final cover = Path()
      ..moveTo(10, 58)
      ..quadraticBezierTo(66, 42, 120, 70)
      ..quadraticBezierTo(174, 42, 230, 58)
      ..lineTo(230, 152)
      ..quadraticBezierTo(174, 140, 120, 164)
      ..quadraticBezierTo(66, 140, 10, 152)
      ..close();
    canvas.drawPath(
      cover,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E8A4C), Color(0xFF0F5A30)],
        ).createShader(const Rect.fromLTWH(10, 42, 220, 122)),
    );

    // Page block thickness (under-pages)
    final underPaint = Paint()..color = const Color(0xFFE4DECB);
    canvas.drawPath(_leftPage(dy: 6, spread: 3), underPaint);
    canvas.drawPath(_rightPage(dy: 6, spread: 3), underPaint);

    // Pages
    canvas.drawPath(
      _leftPage(),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFFEF8), Color(0xFFF1ECDC)],
        ).createShader(const Rect.fromLTWH(20, 40, 98, 112)),
    );
    canvas.drawPath(
      _rightPage(),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF1ECDC), Color(0xFFFFFEF8)],
        ).createShader(const Rect.fromLTWH(122, 40, 98, 112)),
    );

    // Spine shadow
    canvas.drawRect(
      const Rect.fromLTWH(108, 56, 24, 98),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: 0.14),
            Colors.black.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTWH(108, 56, 24, 98)),
    );

    // Text lines
    final line = Paint()
      ..color = const Color(0xFFC9DDD0)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    const leftLengths = [64.0, 52.0, 60.0, 44.0, 58.0, 36.0];
    const rightLengths = [58.0, 62.0, 40.0, 60.0, 50.0, 30.0];
    for (var i = 0; i < 6; i++) {
      final y = 74.0 + i * 11;
      canvas.drawLine(Offset(34, y), Offset(34 + leftLengths[i], y), line);
      canvas.drawLine(Offset(136, y), Offset(136 + rightLengths[i], y), line);
    }

    // Highlighter stroke over one line on the right page
    canvas.drawLine(
      const Offset(134, 96),
      const Offset(198, 96),
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.45)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    // Bookmark ribbon
    final ribbon = Path()
      ..moveTo(192, 38)
      ..lineTo(204, 38)
      ..lineTo(204, 86)
      ..lineTo(198, 80)
      ..lineTo(192, 86)
      ..close();
    canvas.drawPath(ribbon, Paint()..color = const Color(0xFFF59E0B));

    canvas.restore();

    // Sparkles (twinkle out of phase)
    _sparkle(
      canvas,
      const Offset(36, 24),
      8 + 3 * t,
      AppColors.accent,
      0.55 + 0.45 * t,
    );
    _sparkle(
      canvas,
      const Offset(120, 14),
      11 - 3 * t,
      AppColors.accent,
      1 - 0.4 * t,
    );
    _sparkle(
      canvas,
      const Offset(210, 20),
      6 + 3 * (1 - t),
      const Color(0xFFF59E0B),
      0.6 + 0.4 * (1 - t),
    );

    canvas.restore();
  }

  Path _leftPage({double dy = 0, double spread = 0}) => Path()
    ..moveTo(20 - spread, 50 + dy)
    ..quadraticBezierTo(68, 34 + dy, 118, 62 + dy)
    ..lineTo(118, 152 + dy)
    ..quadraticBezierTo(68, 128 + dy, 20 - spread, 142 + dy)
    ..close();

  Path _rightPage({double dy = 0, double spread = 0}) => Path()
    ..moveTo(122, 62 + dy)
    ..quadraticBezierTo(172, 34 + dy, 220 + spread, 50 + dy)
    ..lineTo(220 + spread, 142 + dy)
    ..quadraticBezierTo(172, 128 + dy, 122, 152 + dy)
    ..close();

  void _sparkle(
    Canvas canvas,
    Offset c,
    double r,
    Color color,
    double opacity,
  ) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final radius = i.isEven ? r : r * 0.32;
      final p = c + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: opacity.clamp(0.0, 1.0)),
    );
  }

  @override
  bool shouldRepaint(covariant _BookPainter old) =>
      old.t != t || old.isDark != isDark;
}
