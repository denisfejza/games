import 'dart:math';

import 'package:flutter/material.dart';

import 'pip_controller.dart';

/// Pip the fox drawn with simple shapes, full body, one pose per mood.
/// TODO(asset): replaced by the Rive character (docs/PIP_RIVE_SPEC.md).
///
/// Coordinates are fractions of the width; the canvas is 1 wide × 1.2 tall.
class PipPainter extends CustomPainter {
  PipPainter({required this.mood, this.mouthOpen = 0, this.bounce = 0});

  static const aspect = 1.2;
  static const orange = Color(0xFFFF7A1A);
  static const darkOrange = Color(0xFFE0600A);
  static const ink = Color(0xFF3B2C4A);
  static const cream = Color(0xFFFFF4E6);

  final PipMood mood;

  /// 0–1, how far the mouth is open while talking.
  final double mouthOpen;

  /// 0–1 progress of the current one-shot reaction (bounce/jump/tilt).
  final double bounce;

  /// Generous tap areas (fractions of width), checked in this order.
  static const _parts = <PipPart, List<Rect>>{
    PipPart.nose: [Rect.fromLTRB(0.38, 0.36, 0.62, 0.5)],
    PipPart.mouth: [Rect.fromLTRB(0.34, 0.5, 0.66, 0.62)],
    PipPart.ear: [Rect.fromLTRB(0.02, -0.02, 0.36, 0.24), Rect.fromLTRB(0.64, -0.02, 0.98, 0.24)],
    PipPart.belly: [Rect.fromLTRB(0.3, 0.66, 0.7, 1.04)],
    PipPart.hand: [Rect.fromLTRB(0.06, 0.68, 0.3, 1.0), Rect.fromLTRB(0.7, 0.68, 0.94, 1.0)],
    PipPart.feet: [Rect.fromLTRB(0.2, 1.04, 0.8, 1.2)],
  };

  /// Which part of Pip is at [local] in a widget of [size], if any.
  static PipPart? partAt(Offset local, Size size) {
    final p = Offset(local.dx / size.width, local.dy / size.width);
    for (final e in _parts.entries) {
      if (e.value.any((r) => r.contains(p))) return e.key;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    Offset p(double x, double y) => Offset(x * w, y * w);
    Paint fill(Color c) => Paint()..color = c;
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;

    // One-shot motion: happy hops, celebrate jumps higher, thinking tilts.
    final hop = sin(bounce * pi);
    final lift = switch (mood) {
      PipMood.happy => hop * 0.05,
      PipMood.celebrate => hop * 0.1,
      _ => 0.0,
    };
    canvas.save();
    canvas.translate(0, -lift * w);

    // Tail.
    final tail = Path()
      ..moveTo(p(0.66, 0.95).dx, p(0.66, 0.95).dy)
      ..quadraticBezierTo(p(1.02, 0.95).dx, p(1.02, 0.95).dy, p(0.94, 0.62).dx, p(0.94, 0.62).dy)
      ..quadraticBezierTo(p(0.86, 0.82).dx, p(0.86, 0.82).dy, p(0.66, 0.84).dx, p(0.66, 0.84).dy)
      ..close();
    canvas.drawPath(tail, fill(orange));
    canvas.drawCircle(p(0.93, 0.64), w * 0.05, fill(cream));

    // Feet and body.
    for (final x in [0.39, 0.61]) {
      canvas.drawOval(Rect.fromCenter(center: p(x, 1.1), width: w * 0.18, height: w * 0.1), fill(darkOrange));
    }
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.86), width: w * 0.5, height: w * 0.46), fill(orange));
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.9), width: w * 0.3, height: w * 0.3), fill(cream));

    // Arms: up when celebrating, otherwise at the sides.
    final armsUp = mood == PipMood.celebrate;
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(p(0.5 + side * 0.24, 0.78).dx, p(0.5 + side * 0.24, 0.78).dy);
      canvas.rotate(side * (armsUp ? -2.4 : 0.5));
      canvas.drawOval(Rect.fromLTWH(-w * 0.05, 0, w * 0.1, w * 0.22), fill(darkOrange));
      canvas.restore();
    }

    // Head (tilted when thinking).
    canvas.save();
    final tilt = mood == PipMood.thinking ? 0.12 : 0.0;
    canvas.translate(p(0.5, 0.42).dx, p(0.5, 0.42).dy);
    canvas.rotate(tilt);
    canvas.translate(-p(0.5, 0.42).dx, -p(0.5, 0.42).dy);

    final earLift = mood == PipMood.listening ? 0.06 : 0.0;
    for (final side in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(p(0.5 + side * 0.1, 0.24).dx, p(0.5 + side * 0.1, 0.24).dy)
        ..lineTo(p(0.5 + side * 0.4, 0.02 - earLift).dx, p(0.5 + side * 0.4, 0.02 - earLift).dy)
        ..lineTo(p(0.5 + side * 0.4, 0.36).dx, p(0.5 + side * 0.4, 0.36).dy)
        ..close();
      canvas.drawPath(ear, fill(orange));
      final inner = Path()
        ..moveTo(p(0.5 + side * 0.2, 0.22).dx, p(0.5 + side * 0.2, 0.22).dy)
        ..lineTo(p(0.5 + side * 0.36, 0.1 - earLift).dx, p(0.5 + side * 0.36, 0.1 - earLift).dy)
        ..lineTo(p(0.5 + side * 0.36, 0.28).dx, p(0.5 + side * 0.36, 0.28).dy)
        ..close();
      canvas.drawPath(inner, fill(ink));
    }
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.42), width: w * 0.8, height: w * 0.6), fill(orange));
    canvas.drawOval(Rect.fromCenter(center: p(0.34, 0.52), width: w * 0.34, height: w * 0.26), fill(cream));
    canvas.drawOval(Rect.fromCenter(center: p(0.66, 0.52), width: w * 0.34, height: w * 0.26), fill(cream));

    // Eyes.
    for (final x in [0.35, 0.65]) {
      final c = p(x, 0.38);
      switch (mood) {
        case PipMood.happy || PipMood.celebrate:
          canvas.drawArc(Rect.fromCenter(center: c, width: w * 0.12, height: w * 0.1), pi, pi, false, line);
        case PipMood.sleepy:
          canvas.drawArc(Rect.fromCenter(center: c, width: w * 0.12, height: w * 0.08), 0, pi, false, line);
        default:
          final r = mood == PipMood.listening ? 0.062 : 0.052;
          canvas.drawCircle(c, w * r, fill(ink));
          final look = mood == PipMood.thinking ? const Offset(0.015, -0.02) : Offset.zero;
          canvas.drawCircle(c + Offset((0.016 + look.dx) * w, (-0.016 + look.dy) * w), w * 0.017, fill(Colors.white));
      }
    }
    // Nose.
    canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.47), width: w * 0.11, height: w * 0.08), fill(ink));

    // Mouth: open while talking, big smile when happy, small smile otherwise.
    if (mood == PipMood.talking || mouthOpen > 0.05) {
      final h = w * (0.03 + 0.07 * mouthOpen);
      canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.56), width: w * 0.12, height: h), fill(ink));
    } else if (mood == PipMood.sleepy) {
      canvas.drawOval(Rect.fromCenter(center: p(0.5, 0.56), width: w * 0.05, height: w * 0.05), fill(ink));
    } else {
      final big = mood == PipMood.happy || mood == PipMood.celebrate;
      canvas.drawArc(
        Rect.fromCenter(center: p(0.5, 0.53), width: w * (big ? 0.22 : 0.16), height: w * (big ? 0.14 : 0.09)),
        0.25,
        pi - 0.5,
        false,
        line,
      );
    }
    // Rosy cheeks.
    for (final x in [0.2, 0.8]) {
      canvas.drawCircle(p(x, 0.5), w * 0.05, fill(const Color(0x55FF4F6D)));
    }
    canvas.restore();

    if (mood == PipMood.sleepy) {
      final tp = TextPainter(
        text: TextSpan(
          text: 'z z',
          style: TextStyle(fontSize: w * 0.14, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p(0.72, -0.05));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PipPainter old) => old.mood != mood || old.mouthOpen != mouthOpen || old.bounce != bounce;
}
