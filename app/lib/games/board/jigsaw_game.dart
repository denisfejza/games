import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../../worlds/world_style.dart';
import '../common/card_face.dart';
import '../common/drag_card.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import '../common/pools.dart';

/// `jigsaw` (PLAN 4.6): 4→12 piece puzzles with generous snap-to-place.
/// Played alone or together (no turns). Params: `pieces` (4, 6, 9 or 12),
/// `items` (pictures to use, one per round), `rounds`.
class JigsawEngine implements GameEngine {
  const JigsawEngine();

  @override
  String get type => 'jigsaw';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => [
    ...unknownItems(content, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
    if (!{4, 6, 9, 12}.contains(def.params['pieces'] ?? 4)) '${def.id}: pieces must be 4, 6, 9 or 12',
  ];

  @override
  Widget build(GameContext context) => GameScreen(context: context, create: JigsawGame.new);
}

/// Grid for a piece count: (columns, rows).
(int, int) jigsawGrid(int pieces) => switch (pieces) {
  6 => (3, 2),
  9 => (3, 3),
  12 => (4, 3),
  _ => (2, 2),
};

class JigsawGame extends PipGame {
  JigsawGame(super.host);

  VocabItem? picture;
  final List<PuzzlePiece> pieces = [];
  JigsawFrame? frame;
  final Set<int> placed = {};
  String? _last;

  @override
  Future<void> startRound() async {
    final pool = resolveItems(host.context.content, host.rounds.params['items'] ?? 'tag:animal');
    final options = [
      for (final p in pool)
        if (p.id != _last) p,
    ];
    final item = picture = options[host.random.nextInt(options.length)];
    _last = item.id;
    final (cols, rows) = jigsawGrid((host.rounds.params['pieces'] as int?) ?? 4);
    placed.clear();
    pieces
      ..clear()
      ..addAll([
        for (var i = 0; i < cols * rows; i++)
          PuzzlePiece(_PieceFace(item.picture, i % cols, i ~/ cols, cols, rows), i, onDrop: _dropped),
      ]);
    frame = JigsawFrame(cols, rows);
    await addAll([frame!, ...pieces]);
    layout(size);
    await host.prompt(const ['jigsawPlace']);
  }

  Vector2 slot(int i) {
    final f = frame!;
    final (cols, _) = (f.cols, f.rows);
    final cell = f.size.x / cols;
    return f.position - f.size / 2 + Vector2((i % cols + 0.5) * cell, (i ~/ cols + 0.5) * cell);
  }

  @override
  void layout(Vector2 size) {
    final f = frame;
    if (f == null) return;
    final cell = min(size.x * 0.55 / f.cols, size.y * 0.58 / f.rows);
    f
      ..size = Vector2(cell * f.cols, cell * f.rows)
      ..position = Vector2(size.x / 2, size.y * 0.32);
    // Tray: scattered in a fixed shuffled order along the bottom.
    final order = [for (var i = 0; i < pieces.length; i++) i]..shuffle(Random(pieces.length));
    final trayCell = min(size.x / (pieces.length + 1), cell * 0.9);
    for (var k = 0; k < pieces.length; k++) {
      final p = pieces[order[k]];
      p.size = Vector2.all(placed.contains(p.index) ? cell : trayCell);
      p.home = placed.contains(p.index)
          ? slot(p.index)
          : Vector2(size.x / 2 + (k - (pieces.length - 1) / 2) * trayCell * 1.05, size.y * 0.8);
      if (!p.dragging) p.position = p.home.clone();
    }
  }

  bool _dropped(DragCard card, Vector2 at) {
    if (locked) return false;
    final p = card as PuzzlePiece;
    final target = slot(p.index);
    final cell = frame!.size.x / frame!.cols;
    // Generous: anywhere within most of a piece's width of its place.
    if (at.distanceTo(target) < cell * 0.6) {
      placed.add(p.index);
      p
        ..size = Vector2.all(cell)
        ..done = true
        ..snapTo(target);
      host.correct();
      if (placed.length == pieces.length) _complete();
      return true;
    }
    // Dropped on another piece's place: that's a try-again (not just a dropped piece).
    final onFrame =
        at.x > frame!.position.x - frame!.size.x / 2 &&
        at.x < frame!.position.x + frame!.size.x / 2 &&
        at.y > frame!.position.y - frame!.size.y / 2 &&
        at.y < frame!.position.y + frame!.size.y / 2;
    if (onFrame && host.tryAgain()) {
      frame!.hintSlot = p.index;
      host.hintShown();
    }
    return false;
  }

  Future<void> _complete() async {
    frame!.hintSlot = null;
    await host.audio.say(picture!.nameKey, interrupt: true);
    await solved();
  }
}

class PuzzlePiece extends DragCard {
  PuzzlePiece(CardFace face, this.index, {required super.onDrop}) : super(face: face, size: Vector2.all(80));

  final int index;
}

/// One section of the picture: the whole picture drawn big, clipped to this cell.
class _PieceFace extends CardFace {
  const _PieceFace(this.picture, this.col, this.row, this.cols, this.rows);

  final Picture picture;
  final int col;
  final int row;
  final int cols;
  final int rows;

  @override
  void paint(Canvas canvas, Rect rect) {
    final r = rect.inflate(rect.width * 0.06 / 0.88);
    final full = Rect.fromLTWH(r.left - col * r.width, r.top - row * r.height, r.width * cols, r.height * rows);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.1)));
    canvas.drawRect(full, Paint()..color = WorldStyle.of('board_games').color.withValues(alpha: 0.35));
    paintPicture(
      canvas,
      picture,
      Rect.fromCenter(center: full.center, width: full.shortestSide * 1.35, height: full.shortestSide * 1.35),
    );
    canvas.restore();
  }
}

class JigsawFrame extends PositionComponent {
  JigsawFrame(this.cols, this.rows) : super(anchor: Anchor.center);

  final int cols;
  final int rows;
  int? hintSlot;

  @override
  void render(Canvas canvas) {
    final cell = size.x / cols;
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(16)),
      Paint()..color = const Color(0x66FFFFFF),
    );
    for (var i = 0; i < cols * rows; i++) {
      final r = Rect.fromLTWH((i % cols) * cell, (i ~/ cols) * cell, cell, cell).deflate(3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(10)),
        Paint()
          ..color = hintSlot == i ? const Color(0xFFFFC928) : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = hintSlot == i ? 6 : 2,
      );
    }
  }
}
