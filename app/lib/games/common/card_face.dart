import 'dart:math';

import 'package:flutter/material.dart';

import '../../companion/pip_view.dart' show ShapePainter;
import '../../content/vocab.dart';

/// What a card shows. Shared by every engine (Flame and Flutter).
sealed class CardFace {
  const CardFace();

  /// Paints the face centred in [rect].
  void paint(Canvas canvas, Rect rect);
}

class PictureFace extends CardFace {
  const PictureFace(this.picture);
  final Picture picture;

  @override
  void paint(Canvas canvas, Rect rect) => paintPicture(canvas, picture, rect);
}

/// A numeral, letter or short word.
class TextFace extends CardFace {
  const TextFace(this.text, {this.color = const Color(0xFF3B2C4A)});
  final String text;
  final Color color;

  @override
  void paint(Canvas canvas, Rect rect) {
    final size = rect.shortestSide * (text.length > 2 ? 0.34 : 0.56);
    _drawText(
      canvas,
      text,
      rect.center,
      TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: size, color: color),
    );
  }
}

/// [count] dots: dice layouts up to 6, ten-frame rows above that.
class DotsFace extends CardFace {
  const DotsFace(this.count, {this.color = const Color(0xFF8E5CF7)});
  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Rect rect) {
    final paint = Paint()..color = color;
    final r = rect.deflate(rect.shortestSide * 0.16);
    for (final p in dotLayout(count)) {
      canvas.drawCircle(
        Offset(r.left + p.dx * r.width, r.top + p.dy * r.height),
        rect.shortestSide * (count > 6 ? 0.06 : 0.08),
        paint,
      );
    }
  }
}

/// [count] copies of a picture (counting, more/less).
class GroupFace extends CardFace {
  const GroupFace(this.picture, this.count);
  final Picture picture;
  final int count;

  @override
  void paint(Canvas canvas, Rect rect) {
    final cols = count <= 1 ? 1 : (count <= 4 ? 2 : (count <= 9 ? 3 : 4));
    final rows = (count / cols).ceil();
    final cell = min(rect.width / cols, rect.height / rows) * 0.92;
    final w = cell * cols;
    final h = cell * rows;
    for (var i = 0; i < count; i++) {
      final c = Offset(
        rect.center.dx - w / 2 + cell * (i % cols + 0.5),
        rect.center.dy - h / 2 + cell * (i ~/ cols + 0.5),
      );
      paintPicture(canvas, picture, Rect.fromCenter(center: c, width: cell, height: cell));
    }
  }
}

/// A speaker: the card plays a sound when tapped (picture/sound memory pairs).
class SoundFace extends CardFace {
  const SoundFace();

  @override
  void paint(Canvas canvas, Rect rect) => _drawText(
    canvas,
    String.fromCharCode(Icons.volume_up_rounded.codePoint),
    rect.center,
    TextStyle(
      fontFamily: Icons.volume_up_rounded.fontFamily,
      fontSize: rect.shortestSide * 0.56,
      color: const Color(0xFF1E88E5),
    ),
  );
}

/// A five- or ten-frame with [filled] of [total] boxes dotted ("make 5").
class FrameFace extends CardFace {
  const FrameFace(this.total, this.filled, {this.color = const Color(0xFF8E5CF7)});
  final int total;
  final int filled;
  final Color color;

  @override
  void paint(Canvas canvas, Rect rect) {
    final rows = total > 5 ? 2 : 1;
    final cell = min(rect.width / 5, rect.height / rows) * 0.94;
    final left = rect.center.dx - cell * 2.5;
    final top = rect.center.dy - cell * rows / 2;
    final line = Paint()
      ..color = const Color(0xFF3B2C4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (var i = 0; i < total; i++) {
      final box = Rect.fromLTWH(left + (i % 5) * cell, top + (i ~/ 5) * cell, cell, cell);
      canvas.drawRect(box, line);
      if (i < filled) canvas.drawCircle(box.center, cell * 0.32, Paint()..color = color);
    }
  }
}

/// [count] pictures with the last [crossed] of them crossed out ("take away").
class CrossedGroupFace extends CardFace {
  const CrossedGroupFace(this.picture, this.count, this.crossed);
  final Picture picture;
  final int count;
  final int crossed;

  @override
  void paint(Canvas canvas, Rect rect) {
    GroupFace(picture, count).paint(canvas, rect);
    final cols = count <= 1 ? 1 : (count <= 4 ? 2 : (count <= 9 ? 3 : 4));
    final rows = (count / cols).ceil();
    final cell = min(rect.width / cols, rect.height / rows) * 0.92;
    final x0 = rect.center.dx - cell * cols / 2;
    final y0 = rect.center.dy - cell * rows / 2;
    final pen = Paint()
      ..color = const Color(0xFFE53935)
      ..strokeWidth = cell * 0.1
      ..strokeCap = StrokeCap.round;
    for (var i = count - crossed; i < count; i++) {
      final c = Offset(x0 + cell * (i % cols + 0.5), y0 + cell * (i ~/ cols + 0.5));
      final d = cell * 0.32;
      canvas.drawLine(c - Offset(d, d), c + Offset(d, d), pen);
      canvas.drawLine(c + Offset(-d, d), c + Offset(d, -d), pen);
    }
  }
}

/// Question mark for an empty slot (patterns).
class BlankFace extends CardFace {
  const BlankFace();

  @override
  void paint(Canvas canvas, Rect rect) => _drawText(
    canvas,
    '?',
    rect.center,
    TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w800,
      fontSize: rect.shortestSide * 0.5,
      color: const Color(0x663B2C4A),
    ),
  );
}

/// Positions (0–1) for [n] dots.
List<Offset> dotLayout(int n) {
  const dice = <int, List<Offset>>{
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.25, 0.25), Offset(0.75, 0.75)],
    3: [Offset(0.2, 0.2), Offset(0.5, 0.5), Offset(0.8, 0.8)],
    4: [Offset(0.25, 0.25), Offset(0.75, 0.25), Offset(0.25, 0.75), Offset(0.75, 0.75)],
    5: [Offset(0.2, 0.2), Offset(0.8, 0.2), Offset(0.5, 0.5), Offset(0.2, 0.8), Offset(0.8, 0.8)],
    6: [
      Offset(0.25, 0.18),
      Offset(0.75, 0.18),
      Offset(0.25, 0.5),
      Offset(0.75, 0.5),
      Offset(0.25, 0.82),
      Offset(0.75, 0.82),
    ],
  };
  if (n <= 0) return const [];
  if (n <= 6) return dice[n]!;
  // Ten-frame: two rows of five.
  return [for (var i = 0; i < n; i++) Offset(0.1 + (i % 5) * 0.2, i < 5 ? 0.3 : 0.7)];
}

void paintPicture(Canvas canvas, Picture picture, Rect rect) {
  final s = rect.shortestSide;
  switch (picture) {
    case EmojiPicture(:final emoji):
      _drawText(canvas, emoji, rect.center, TextStyle(fontFamily: 'PipEmoji', fontSize: s * 0.66));
    case ColourPicture(:final colour):
      canvas.drawCircle(rect.center, s * 0.36, Paint()..color = colour);
      canvas.drawCircle(
        rect.center,
        s * 0.36,
        Paint()
          ..color = const Color(0x33000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.03,
      );
    case ShapePicture(:final shape):
      canvas.save();
      canvas.translate(rect.center.dx - s * 0.36, rect.center.dy - s * 0.36);
      ShapePainter(shape).paint(canvas, Size.square(s * 0.72));
      canvas.restore();
    case ImagePicture():
      // TODO(asset): illustrated pictures (needs Flame sprite loading).
      _drawText(canvas, '?', rect.center, TextStyle(fontSize: s * 0.5));
  }
}

void _drawText(Canvas canvas, String text, Offset centre, TextStyle style) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2));
}
