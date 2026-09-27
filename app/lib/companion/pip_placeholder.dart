import 'package:flutter/material.dart';

/// Pip the fox, drawn with simple shapes.
/// TODO(asset): replaced by the Rive character in PLAN 1.1.
class PipPlaceholder extends StatelessWidget {
  const PipPlaceholder({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _FoxPainter()),
  );
}

class _FoxPainter extends CustomPainter {
  static const orange = Color(0xFFFF7A1A);
  static const dark = Color(0xFF3B2C4A);
  static const cream = Color(0xFFFFF4E6);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Offset p(double x, double y) => Offset(x * w, y * w);
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeJoin = StrokeJoin.round;

    Path ear(double side) => Path()
      ..moveTo(p(0.5 + side * 0.08, 0.3).dx, p(0.5 + side * 0.08, 0.3).dy)
      ..lineTo(p(0.5 + side * 0.4, 0.04).dx, p(0.5 + side * 0.4, 0.04).dy)
      ..lineTo(p(0.5 + side * 0.4, 0.44).dx, p(0.5 + side * 0.4, 0.44).dy)
      ..close();
    final head = Path()..addOval(Rect.fromCenter(center: p(0.5, 0.56), width: w * 0.8, height: w * 0.68));

    // White sticker outline behind everything.
    for (final path in [ear(-1), ear(1), head]) {
      canvas.drawPath(path, outline);
    }
    for (final side in [-1.0, 1.0]) {
      canvas.drawPath(ear(side), Paint()..color = orange);
      canvas.drawPath(
        Path()
          ..moveTo(p(0.5 + side * 0.2, 0.28).dx, p(0.5 + side * 0.2, 0.28).dy)
          ..lineTo(p(0.5 + side * 0.36, 0.12).dx, p(0.5 + side * 0.36, 0.12).dy)
          ..lineTo(p(0.5 + side * 0.36, 0.34).dx, p(0.5 + side * 0.36, 0.34).dy)
          ..close(),
        Paint()..color = dark,
      );
    }
    canvas.drawPath(head, Paint()..color = orange);
    // Cream muzzle and cheeks.
    canvas.drawOval(Rect.fromCenter(center: p(0.34, 0.72), width: w * 0.36, height: w * 0.3), Paint()..color = cream);
    canvas.drawOval(Rect.fromCenter(center: p(0.66, 0.72), width: w * 0.36, height: w * 0.3), Paint()..color = cream);
    // Eyes with a highlight.
    for (final x in [0.36, 0.64]) {
      canvas.drawCircle(p(x, 0.52), w * 0.055, Paint()..color = dark);
      canvas.drawCircle(p(x + 0.018, 0.505), w * 0.018, Paint()..color = Colors.white);
    }
    // Nose and smile.
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.66), width: w * 0.11, height: w * 0.08), Paint()..color = dark);
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.72), width: w * 0.2, height: w * 0.12),
      0.2,
      2.7,
      false,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025
        ..strokeCap = StrokeCap.round,
    );
    // Rosy cheeks.
    for (final x in [0.22, 0.78]) {
      canvas.drawCircle(p(x, 0.64), w * 0.05, Paint()..color = const Color(0x55FF4F6D));
    }
  }

  @override
  bool shouldRepaint(_FoxPainter old) => false;
}
