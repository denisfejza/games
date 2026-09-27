import '../../core/audio/audio_service.dart' as audio show Effect;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'card_face.dart';
import 'pip_game.dart';

/// A big white card that shows a [CardFace]. Tap feedback happens on tap-down
/// (well under 100 ms); [onTap] fires on release.
class GameCard extends PositionComponent with TapCallbacks, HasGameReference<PipGame> {
  GameCard({
    required this.face,
    required Vector2 size,
    this.onTap,
    this.faceUp = true,
    this.backColor = const Color(0xFF7B6CF6),
    this.value,
  }) : super(size: size, anchor: Anchor.center);

  CardFace face;
  bool faceUp;
  final Color backColor;
  void Function(GameCard card)? onTap;

  /// Whatever the engine wants to remember about this card.
  final Object? value;

  bool _hinting = false;
  bool _pressed = false;

  /// Green ring and tick: solved. Uses a shape as well as colour.
  bool done = false;

  /// Greyed out (not tappable).
  bool dimmed = false;

  static const _ink = Color(0xFF3B2C4A);
  static const _gold = Color(0xFFFFC928);
  static const _green = Color(0xFF3FAF5C);

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final r = Radius.circular(size.x * 0.16);
    final lift = _pressed ? 2.0 : 6.0;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.shift(Offset(0, lift)), r), Paint()..color = const Color(0x33000000));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, r), Paint()..color = faceUp ? Colors.white : backColor);
    if (faceUp) {
      canvas.save();
      if (dimmed) canvas.saveLayer(rect, Paint()..color = const Color(0x66FFFFFF));
      face.paint(canvas, rect.deflate(size.x * 0.06));
      if (dimmed) canvas.restore();
      canvas.restore();
    } else {
      canvas.drawCircle(rect.center, size.x * 0.2, Paint()..color = Colors.white.withValues(alpha: 0.3));
    }
    final ring = done ? _green : (_hinting ? _gold : Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), r),
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = done || _hinting ? size.x * 0.06 : 4,
    );
    if (done) {
      final c = Offset(rect.right - size.x * 0.12, rect.top + size.x * 0.12);
      canvas.drawCircle(c, size.x * 0.11, Paint()..color = _green);
      final tick = Path()
        ..moveTo(c.dx - size.x * 0.05, c.dy)
        ..lineTo(c.dx - size.x * 0.01, c.dy + size.x * 0.04)
        ..lineTo(c.dx + size.x * 0.06, c.dy - size.x * 0.04);
      canvas.drawPath(
        tick,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }
    if (_hinting) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(6), r),
        Paint()
          ..color = _ink.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (onTap == null || dimmed || !game.acceptTap()) return;
    _pressed = true;
    game.host.audio.effect(game.tapEffect);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!_pressed) return;
    _pressed = false;
    onTap?.call(this);
  }

  @override
  void onTapCancel(TapCancelEvent event) => _pressed = false;

  /// Turns over with a squash (skipped with reduced motion).
  Future<void> flip(bool up) async {
    if (up) game.host.audio.effect(audio.Effect.flip);
    if (game.host.reducedMotion) {
      faceUp = up;
      return;
    }
    await _run(ScaleEffect.to(Vector2(0, 1), EffectController(duration: 0.12)));
    faceUp = up;
    await _run(ScaleEffect.to(Vector2(1, 1), EffectController(duration: 0.12)));
  }

  /// Curious wobble for a wrong answer (never a shake of "no").
  void wiggle() {
    if (game.host.reducedMotion) return;
    add(
      SequenceEffect([
        RotateEffect.to(0.08, EffectController(duration: 0.08)),
        RotateEffect.to(-0.08, EffectController(duration: 0.12)),
        RotateEffect.to(0, EffectController(duration: 0.08)),
      ]),
    );
  }

  /// Quick grow-and-back for a right answer.
  void pop() {
    if (game.host.reducedMotion) return;
    add(ScaleEffect.to(Vector2.all(1.15), EffectController(duration: 0.12, reverseDuration: 0.16)));
  }

  /// Gold ring that pulses three times, then stays gold until the round ends.
  void hint() {
    _hinting = true;
    if (game.host.reducedMotion) return;
    add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.25, reverseDuration: 0.25, repeatCount: 3)));
  }

  void clearHint() => _hinting = false;

  bool get hinting => _hinting;

  Future<void> _run(Effect e) {
    add(e);
    return e.removed;
  }
}

/// Lays out [n] cards in a grid inside [area]; returns centres and card size.
({List<Vector2> centres, Vector2 card}) gridLayout(
  int n,
  Vector2 area, {
  int? cols,
  double maxCard = 220,
  double gap = 0.12,
}) {
  if (n == 0) return (centres: const [], card: Vector2.zero());
  var bestCols = cols ?? 1;
  var best = 0.0;
  for (var c = cols ?? 1; c <= (cols ?? n); c++) {
    final rows = (n / c).ceil();
    final s = min(area.x / (c + (c + 1) * gap), area.y / (rows + (rows + 1) * gap));
    if (s > best) {
      best = s;
      bestCols = c;
    }
  }
  final s = min(best, maxCard);
  final rows = (n / bestCols).ceil();
  final g = s * gap;
  final w = bestCols * s + (bestCols - 1) * g;
  final h = rows * s + (rows - 1) * g;
  final centres = <Vector2>[];
  for (var i = 0; i < n; i++) {
    final row = i ~/ bestCols;
    final inRow = row == rows - 1 ? n - row * bestCols : bestCols;
    final rowW = inRow * s + (inRow - 1) * g;
    final x0 = (area.x - w) / 2 + (w - rowW) / 2;
    centres.add(Vector2(x0 + (i % bestCols) * (s + g) + s / 2, (area.y - h) / 2 + row * (s + g) + s / 2));
  }
  return (centres: centres, card: Vector2.all(s));
}
