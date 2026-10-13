import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Shared app backdrop: a glass hourglass with gold sand that slowly runs
/// out, flips and starts again, plus a few drifting gold specks. Light theme
/// is white/grey like a studio photo; dark theme keeps the deep green. The
/// hourglass is kept faint so content on top stays readable, and it stands
/// still when the system "remove animations" setting is on.
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
    duration: _HourglassPainter.cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.35;
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
              painter: _HourglassPainter(
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

class _HourglassPainter extends CustomPainter {
  static const _runSeconds = 60.0;
  static const _flipSeconds = 1.8;
  static final cycle = Duration(
    milliseconds: ((_runSeconds + _flipSeconds) * 1000).round(),
  );

  static const _gold = [
    Color(0xFFF6D277),
    Color(0xFFE2AE45),
    Color(0xFFB98426),
  ];

  final bool isDark;
  final Animation<double> animation;

  _HourglassPainter({required this.isDark, required this.animation})
    : super(repaint: animation);

  // Glass half-width at |y| = u (0 = neck, 1 = rim), as a fraction of max.
  static double _profile(double u) {
    const neck = 0.07;
    return neck +
        (1 - neck) *
            math.pow(math.sin(u.clamp(0.0, 1.0) * math.pi * 0.70), 0.75);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final seconds = animation.value * (_runSeconds + _flipSeconds);
    final running = seconds < _runSeconds;
    final progress = running ? seconds / _runSeconds : 1.0;
    final flip = running
        ? 0.0
        : Curves.easeInOutCubic.transform(
            (seconds - _runSeconds) / _flipSeconds,
          );

    _paintBackdrop(canvas, rect);

    final h = math.min(size.height * 0.58, size.width * 1.15);
    final w = h * 0.58;
    final center = Offset(size.width / 2, size.height * 0.53);

    _paintDust(canvas, size, animation.value);

    // Table shadow (light theme), squashes while the glass is flipping.
    if (!isDark) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(w * 0.25, h / 2 + 6),
          width: w * 1.25 * (1 - 0.4 * math.sin(flip * math.pi)),
          height: h * 0.05,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.07)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(flip * math.pi);
    _paintHourglass(canvas, w, h, progress, seconds);
    canvas.restore();
  }

  void _paintBackdrop(Canvas canvas, Rect rect) {
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
              : const [Color(0xFFF7F8F9), Color(0xFFEEF0F2), Color(0xFFE3E6EA)],
        ).createShader(rect),
    );
    // Warm glow behind the hourglass
    final glowCenter = Offset(rect.width / 2, rect.height * 0.5);
    final glowRadius = rect.width * 0.9;
    final glow = (isDark ? const Color(0xFFE2AE45) : Colors.white).withValues(
      alpha: isDark ? 0.07 : 0.8,
    );
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [glow, glow.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );
  }

  void _paintDust(Canvas canvas, Size size, double t) {
    final rnd = math.Random(11);
    final paint = Paint();
    for (var i = 0; i < 18; i++) {
      final x0 = rnd.nextDouble();
      final y0 = rnd.nextDouble();
      final r = 0.8 + rnd.nextDouble() * 1.8;
      final speed = 1 + rnd.nextInt(2); // whole passes per cycle: seamless loop
      final phase = rnd.nextDouble();
      final y = ((y0 - t * speed) % 1.0 + 1.0) % 1.0;
      final x = x0 + 0.015 * math.sin(2 * math.pi * (t * speed * 3 + phase));
      final twinkle = 0.5 + 0.5 * math.sin(2 * math.pi * (t * 20 + phase));
      paint.color = _gold[1].withValues(
        alpha: (isDark ? 0.22 : 0.30) * (0.4 + 0.6 * twinkle),
      );
      canvas.drawCircle(Offset(x * size.width, y * size.height), r, paint);
    }
  }

  void _paintHourglass(
    Canvas canvas,
    double w,
    double h,
    double progress,
    double seconds,
  ) {
    final half = h / 2;
    final maxHw = w / 2;

    // Glass outline: right side top -> bottom, then left side bottom -> top.
    final glass = Path();
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final y = -1 + 2 * i / steps;
      final p = Offset(maxHw * _profile(y.abs()), y * half);
      i == 0 ? glass.moveTo(p.dx, p.dy) : glass.lineTo(p.dx, p.dy);
    }
    for (var i = steps; i >= 0; i--) {
      final y = -1 + 2 * i / steps;
      glass.lineTo(-maxHw * _profile(y.abs()), y * half);
    }
    glass.close();

    // Glass body tint
    canvas.drawPath(
      glass,
      Paint()..color = Colors.white.withValues(alpha: isDark ? 0.03 : 0.35),
    );

    // Sand, clipped to the glass interior
    final topLevel =
        0.62 * (1 - progress); // fraction of the half height above the neck
    final bottomLevel = 0.62 * progress; // fraction filled from the base
    final sandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _gold
            .map((c) => c.withValues(alpha: isDark ? 0.30 : 0.55))
            .toList(),
      ).createShader(Rect.fromLTRB(-maxHw, -half, maxHw, half));

    canvas.save();
    canvas.clipPath(glass);
    if (topLevel > 0.005) {
      final y = -topLevel * half;
      final dip = h * 0.03 * math.min(1, topLevel * 4);
      final top = Path()
        ..moveTo(-maxHw, y)
        ..quadraticBezierTo(0, y + dip * 2, maxHw, y)
        ..lineTo(maxHw, 0)
        ..lineTo(-maxHw, 0)
        ..close();
      canvas.drawPath(top, sandPaint);
    }
    if (bottomLevel > 0.005) {
      final y = half - bottomLevel * half;
      final mound = h * 0.045 * math.min(1, progress * 4);
      final bottom = Path()
        ..moveTo(-maxHw, y + mound * 0.4)
        ..quadraticBezierTo(0, y - mound * 1.6, maxHw, y + mound * 0.4)
        ..lineTo(maxHw, half)
        ..lineTo(-maxHw, half)
        ..close();
      canvas.drawPath(bottom, sandPaint);

      // Falling stream with grains sliding down it
      if (progress < 0.995) {
        final streamEnd = y - mound * 0.6;
        canvas.drawLine(
          Offset.zero,
          Offset(0, streamEnd),
          Paint()
            ..color = _gold[1].withValues(alpha: isDark ? 0.35 : 0.6)
            ..strokeWidth = 1.6,
        );
        final grain = Paint()
          ..color = _gold[0].withValues(alpha: isDark ? 0.5 : 0.8);
        for (var i = 0; i < 4; i++) {
          final f = ((seconds * 1.6 + i / 4) % 1.0);
          canvas.drawCircle(Offset(0, f * streamEnd), 1.4, grain);
        }
      }
    }
    canvas.restore();

    // Outline, rims and highlights
    final lineColor = isDark
        ? const Color(0xFFCFE9D8)
        : const Color(0xFFA8B1BC);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = lineColor.withValues(alpha: isDark ? 0.18 : 0.55);
    canvas.drawPath(glass, outline);
    final rimHw = maxHw * _profile(1);
    for (final y in [-half, half]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, y),
          width: rimHw * 2,
          height: h * 0.022,
        ),
        outline,
      );
    }

    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: isDark ? 0.10 : 0.75);
    for (final sign in [-1.0, 1.0]) {
      final path = Path();
      for (var i = 0; i <= 12; i++) {
        final u = 0.35 + 0.45 * i / 12;
        final p = Offset(-maxHw * _profile(u) * 0.78, sign * u * half);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, highlight);
    }
  }

  @override
  bool shouldRepaint(covariant _HourglassPainter old) => old.isDark != isDark;
}
