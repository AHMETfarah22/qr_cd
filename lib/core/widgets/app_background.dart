import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shared app backdrop with a study theme: green gradient, faint notebook
/// ruling with a margin line, and line-art books, pages, a pencil and
/// sparkles drifting slowly upward. Drawn in code (sharp on every screen)
/// and kept low-contrast so content stays readable. Motion stops when the
/// system "remove animations" setting is on.
class AppBackground extends StatefulWidget {
  final Widget child;

  /// Forces light or dark styling for screens designed for only one of them.
  final Brightness? brightness;

  const AppBackground({super.key, required this.child, this.brightness});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 48),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        (widget.brightness ?? Theme.of(context).brightness) == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _BackgroundPainter(
                isDark: isDark,
                animation: _controller,
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

enum _Doodle { closedBook, openBook, page, pencil, sparkle, cap }

class _Floater {
  final _Doodle kind;
  final double x; // 0..1 of width
  final double y; // 0..1 of height at t = 0
  final double size;
  final int speed; // screen passes per loop (integer keeps the loop seamless)
  final double phase;

  const _Floater(this.kind, this.x, this.y, this.size, this.speed, this.phase);
}

const _floaters = [
  _Floater(_Doodle.openBook, 0.78, 0.18, 46, 1, 0.0),
  _Floater(_Doodle.closedBook, 0.16, 0.42, 38, 1, 0.3),
  _Floater(_Doodle.pencil, 0.86, 0.62, 40, 1, 0.55),
  _Floater(_Doodle.page, 0.30, 0.86, 34, 1, 0.8),
  _Floater(_Doodle.sparkle, 0.55, 0.30, 14, 2, 0.15),
  _Floater(_Doodle.cap, 0.62, 0.74, 34, 1, 0.45),
  _Floater(_Doodle.sparkle, 0.10, 0.08, 10, 2, 0.65),
  _Floater(_Doodle.closedBook, 0.92, 0.95, 30, 1, 0.9),
];

class _BackgroundPainter extends CustomPainter {
  final bool isDark;
  final Animation<double> animation;

  _BackgroundPainter({required this.isDark, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = animation.value;

    // Base green gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF0F2E1B),
                  AppColors.background,
                  Color(0xFF031009),
                ]
              : const [Color(0xFFF1FAF4), Color(0xFFE6F5EC), Color(0xFFD9EFE1)],
        ).createShader(rect),
    );

    _glow(
      canvas,
      Offset(size.width * 0.95, size.height * 0.04),
      size.width * 0.85,
      AppColors.accent.withValues(alpha: isDark ? 0.16 : 0.22),
    );
    _glow(
      canvas,
      Offset(0, size.height * 0.78),
      size.width * 0.9,
      const Color(0xFF1FB5A0).withValues(alpha: isDark ? 0.10 : 0.12),
    );

    // Notebook ruling and margin line
    final rule = Paint()
      ..color = (isDark ? Colors.white : AppColors.accentDeep).withValues(
        alpha: isDark ? 0.035 : 0.07,
      )
      ..strokeWidth = 1;
    for (double y = 96; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
    canvas.drawLine(
      const Offset(34, 0),
      Offset(34, size.height),
      Paint()
        ..color = const Color(
          0xFFFF7A7A,
        ).withValues(alpha: isDark ? 0.10 : 0.18)
        ..strokeWidth = 1.2,
    );

    // Drifting doodles
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = (isDark ? const Color(0xFFB8F5CB) : AppColors.accentDeep)
          .withValues(alpha: isDark ? 0.11 : 0.16);
    final fill = Paint()
      ..color = (isDark ? AppColors.accent : AppColors.accentDeep).withValues(
        alpha: isDark ? 0.14 : 0.16,
      );

    for (final f in _floaters) {
      final travel = 1.2 * f.speed * t;
      final yFrac = ((f.y - travel) % 1.2 + 1.2) % 1.2 - 0.1;
      final wave = math.sin(2 * math.pi * (t * f.speed + f.phase));
      final center = Offset(f.x * size.width + wave * 12, yFrac * size.height);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(wave * 0.18);
      _drawDoodle(canvas, f.kind, f.size, stroke, fill);
      canvas.restore();
    }
  }

  void _glow(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _drawDoodle(
    Canvas canvas,
    _Doodle kind,
    double s,
    Paint stroke,
    Paint fill,
  ) {
    switch (kind) {
      case _Doodle.closedBook:
        final r = Rect.fromCenter(
          center: Offset.zero,
          width: s * 0.75,
          height: s,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, Radius.circular(s * 0.08)),
          stroke,
        );
        canvas.drawLine(
          Offset(r.left + s * 0.14, r.top),
          Offset(r.left + s * 0.14, r.bottom),
          stroke,
        );
        canvas.drawLine(
          Offset(r.left + s * 0.26, r.top + s * 0.3),
          Offset(r.right - s * 0.12, r.top + s * 0.3),
          stroke,
        );
      case _Doodle.openBook:
        final h = s * 0.32;
        final left = Path()
          ..moveTo(0, -h * 0.6)
          ..quadraticBezierTo(-s * 0.25, -h, -s * 0.5, -h * 0.75)
          ..lineTo(-s * 0.5, h)
          ..quadraticBezierTo(-s * 0.25, h * 0.75, 0, h * 1.2)
          ..close();
        canvas.drawPath(left, stroke);
        canvas.save();
        canvas.scale(-1, 1);
        canvas.drawPath(left, stroke);
        canvas.restore();
        for (var i = 0; i < 2; i++) {
          final y = -h * 0.2 + i * h * 0.5;
          canvas.drawLine(Offset(-s * 0.38, y), Offset(-s * 0.12, y), stroke);
          canvas.drawLine(Offset(s * 0.12, y), Offset(s * 0.38, y), stroke);
        }
      case _Doodle.page:
        final w = s * 0.72, h = s;
        final fold = s * 0.2;
        final path = Path()
          ..moveTo(-w / 2, -h / 2)
          ..lineTo(w / 2 - fold, -h / 2)
          ..lineTo(w / 2, -h / 2 + fold)
          ..lineTo(w / 2, h / 2)
          ..lineTo(-w / 2, h / 2)
          ..close()
          ..moveTo(w / 2 - fold, -h / 2)
          ..lineTo(w / 2 - fold, -h / 2 + fold)
          ..lineTo(w / 2, -h / 2 + fold);
        canvas.drawPath(path, stroke);
        for (var i = 0; i < 3; i++) {
          final y = -h * 0.1 + i * h * 0.18;
          canvas.drawLine(Offset(-w * 0.32, y), Offset(w * 0.3, y), stroke);
        }
      case _Doodle.pencil:
        canvas.rotate(-math.pi / 4);
        final w = s * 0.2, len = s;
        canvas.drawRect(Rect.fromLTWH(-len / 2, -w / 2, len * 0.75, w), stroke);
        final tip = Path()
          ..moveTo(len * 0.25, -w / 2)
          ..lineTo(len / 2, 0)
          ..lineTo(len * 0.25, w / 2);
        canvas.drawPath(tip, stroke);
        canvas.drawLine(
          Offset(-len * 0.32, -w / 2),
          Offset(-len * 0.32, w / 2),
          stroke,
        );
      case _Doodle.sparkle:
        final path = Path();
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4 - math.pi / 2;
          final r = i.isEven ? s : s * 0.32;
          final p = Offset(math.cos(a) * r, math.sin(a) * r);
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path..close(), fill);
      case _Doodle.cap:
        final top = Path()
          ..moveTo(0, -s * 0.3)
          ..lineTo(s * 0.5, -s * 0.08)
          ..lineTo(0, s * 0.14)
          ..lineTo(-s * 0.5, -s * 0.08)
          ..close();
        canvas.drawPath(top, stroke);
        final base = Path()
          ..moveTo(-s * 0.3, 0)
          ..lineTo(-s * 0.3, s * 0.26)
          ..quadraticBezierTo(0, s * 0.42, s * 0.3, s * 0.26)
          ..lineTo(s * 0.3, 0);
        canvas.drawPath(base, stroke);
        canvas.drawLine(
          Offset(s * 0.5, -s * 0.08),
          Offset(s * 0.5, s * 0.26),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => old.isDark != isDark;
}
