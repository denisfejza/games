import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../core/audio/audio_service.dart';
import '../../content/models.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import 'glyph_strokes.dart';
import 'trace_path_config.dart';
import 'trace_progress.dart';

class TracePathEngine implements GameEngine {
  const TracePathEngine();

  @override
  String get type => 'trace_path';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => TracePathConfig.validate(def, content);

  @override
  Widget build(GameContext context) {
    final glyphs = TracePathConfig(context.def.params).glyphs.length;
    // One glyph per round unless the level says otherwise.
    final def = context.def.params.containsKey('rounds')
        ? context.def
        : GameDef.fromJsonWithParams(context.def, {...context.def.params, 'rounds': glyphs});
    return GameScreen(
      context: GameContext(
        def: def,
        content: context.content,
        band: context.band,
        locale: context.locale,
        random: context.random,
        text: context.text,
        onFinished: context.onFinished,
      ),
      create: TracePathGame.new,
    );
  }
}

class TracePathGame extends PipGame {
  TracePathGame(super.host);

  TraceBoard? board;
  String? glyphId;

  @override
  Future<void> startRound() async {
    final glyphs = TracePathConfig(host.rounds.params).glyphs;
    final id = glyphId = glyphs[host.rounds.round % glyphs.length];
    board = TraceBoard(
      TraceProgress(glyphFor(id)!),
      color: const Color(0xFF7B6CF6),
      onStroke: _onStroke,
      onMiss: _onMiss,
    );
    await add(board!);
    layout(size);
    await host.prompt(['gameTrace', TracePathConfig.promptKey(id, host.context.locale)]);
  }

  @override
  void layout(Vector2 size) {
    final b = board;
    if (b == null) return;
    final g = b.progress.glyph;
    final scale = min(size.x * 0.8 / g.width, size.y * 0.9 / g.height);
    b
      ..unit = scale
      ..size = Vector2(g.width * scale, g.height * scale)
      ..position = Vector2((size.x - g.width * scale) / 2, (size.y - g.height * scale) / 2);
  }

  void _onStroke() {
    host.audio.effect(Effect.pop);
    if (board!.progress.done) {
      host.correct();
      solved(praiseKey: 'praiseTraced');
    }
  }

  void _onMiss() {
    if (host.tryAgain()) {
      board!.showGuide();
      host.hintShown();
    }
  }
}

/// The tracing surface: faint track, the child's progress in colour, a
/// "start here" dot, and a guide dot that runs along the stroke as a hint.
class TraceBoard extends PositionComponent with DragCallbacks, HasGameReference<PipGame> {
  TraceBoard(this.progress, {required this.color, required this.onStroke, required this.onMiss});

  final TraceProgress progress;
  final Color color;
  final VoidCallback onStroke;
  final VoidCallback onMiss;
  double unit = 100;
  bool _movedThisDrag = false;
  double _guide = -1;

  Offset _toGlyph(Vector2 local) => Offset(local.x / unit, local.y / unit);
  Offset _toLocal(Offset g) => Offset(g.dx * unit, g.dy * unit);

  void showGuide() => _guide = 0;

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _movedThisDrag = false;
    _feed(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) => _feed(event.localEndPosition);

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_movedThisDrag && !progress.done) onMiss();
  }

  void _feed(Vector2 local) {
    if (progress.done || game.locked) return;
    final before = progress.stroke;
    if (progress.update(_toGlyph(local))) {
      _movedThisDrag = true;
      _guide = -1;
      if (progress.stroke != before) onStroke();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_guide >= 0) {
      _guide += dt / 1.6;
      if (_guide > 1) _guide = -1;
    }
  }

  Path _path(List<Offset> pts) {
    final p = Path()..moveTo(_toLocal(pts.first).dx, _toLocal(pts.first).dy);
    for (final o in pts.skip(1)) {
      final l = _toLocal(o);
      p.lineTo(l.dx, l.dy);
    }
    return p;
  }

  @override
  void render(Canvas canvas) {
    final w = unit * 0.13;
    Paint pen(Color c, double width) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var s = 0; s < progress.checkpoints.length; s++) {
      final pts = progress.checkpoints[s];
      canvas.drawPath(_path(pts), pen(Colors.white.withValues(alpha: 0.85), w * 1.5));
      canvas.drawPath(_path(pts), pen(const Color(0x223B2C4A), w * 0.25));
      if (s < progress.stroke) canvas.drawPath(_path(pts), pen(color, w));
      if (s == progress.stroke && progress.reached >= 0) {
        canvas.drawPath(_path(pts.sublist(0, progress.reached + 1)), pen(color, w));
      }
    }
    final next = progress.next;
    if (next != null) {
      final c = _toLocal(next);
      canvas.drawCircle(c, w * 0.9, Paint()..color = const Color(0xFF3FAF5C));
      canvas.drawCircle(c, w * 0.9, pen(Colors.white, 4));
      // Arrow towards where the stroke goes.
      final pts = progress.checkpoints[progress.stroke];
      final ahead = pts[min(progress.reached + 4, pts.length - 1)];
      final dir = _toLocal(ahead) - c;
      if (dir.distance > 1) {
        final u = dir / dir.distance;
        final tip = c + u * w * 2.2;
        final side = Offset(-u.dy, u.dx) * w * 0.6;
        canvas.drawPath(
          Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo((c + u * w * 1.3 + side).dx, (c + u * w * 1.3 + side).dy)
            ..lineTo((c + u * w * 1.3 - side).dx, (c + u * w * 1.3 - side).dy)
            ..close(),
          Paint()..color = const Color(0xFF3FAF5C),
        );
      }
    }
    if (_guide >= 0 && !progress.done) {
      final pts = progress.checkpoints[progress.stroke];
      final p = _toLocal(pts[(_guide * (pts.length - 1)).round()]);
      canvas.drawCircle(p, w * 0.7, Paint()..color = const Color(0xFFFFC928));
    }
  }
}
