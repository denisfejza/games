import 'dart:math';

import 'package:flutter/material.dart';

/// Decorative background patterns. Static by design: no background motion
/// while a child is deciding (CLAUDE.md UI rules).
enum Pattern { dots, zigzag, stars, waves, diagonal, confetti }

class PatternBackground extends StatelessWidget {
  const PatternBackground({super.key, required this.color, required this.pattern, this.child, this.seed = 0});

  final Color color;
  final Pattern pattern;
  final Widget? child;

  /// Varies the confetti layout between panels.
  final int seed;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _PatternPainter(color, pattern, seed), child: child ?? const SizedBox.expand());
}

class _PatternPainter extends CustomPainter {
  _PatternPainter(this.color, this.pattern, this.seed);

  final Color color;
  final Pattern pattern;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final ink = Paint()..color = Colors.white.withValues(alpha: 0.22);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (pattern) {
      case Pattern.dots:
        for (var y = 0.0, row = 0; y < size.height + 30; y += 30, row++) {
          for (var x = row.isEven ? 0.0 : 15.0; x < size.width + 30; x += 30) {
            canvas.drawCircle(Offset(x, y), 5, ink);
          }
        }
      case Pattern.zigzag:
        for (var y = 20.0; y < size.height + 40; y += 44) {
          final path = Path()..moveTo(-12, y);
          for (var x = -12.0, up = true; x < size.width + 24; x += 14, up = !up) {
            path.lineTo(x + 14, y + (up ? -9 : 9));
          }
          canvas.drawPath(path, line);
        }
      case Pattern.waves:
        for (var y = 20.0; y < size.height + 40; y += 46) {
          final path = Path()..moveTo(0, y);
          for (var x = 0.0; x <= size.width + 8; x += 4) {
            path.lineTo(x, y + sin(x / 14) * 7);
          }
          canvas.drawPath(path, line);
        }
      case Pattern.stars:
        for (var y = 24.0, row = 0; y < size.height + 48; y += 48, row++) {
          for (var x = row.isEven ? 24.0 : 48.0; x < size.width + 48; x += 48) {
            canvas.drawPath(starPath(Offset(x, y), 11, 5), ink);
          }
        }
      case Pattern.diagonal:
        final stripe = Paint()
          ..color = Colors.white.withValues(alpha: 0.16)
          ..strokeWidth = 14;
        for (var x = -size.height; x < size.width; x += 38) {
          canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), stripe);
        }
      case Pattern.confetti:
        final r = Random(seed);
        final count = (size.width * size.height / 1400).clamp(10, 400).toInt();
        for (var i = 0; i < count; i++) {
          canvas.save();
          canvas.translate(r.nextDouble() * size.width, r.nextDouble() * size.height);
          canvas.rotate(r.nextDouble() * pi);
          canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -3, 12, 6), const Radius.circular(3)), ink);
          canvas.restore();
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.color != color || old.pattern != pattern || old.seed != seed;
}

/// A five-pointed star centred on [c].
Path starPath(Offset c, double outer, double inner) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? outer : inner;
    final a = -pi / 2 + i * pi / 5;
    final p = c + Offset(cos(a) * r, sin(a) * r);
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  return path..close();
}
