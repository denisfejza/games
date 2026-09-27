import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import '../common/pools.dart';
import 'board_common.dart';

/// `dominoes` — Animal Dominoes (PLAN 4.2): match pictures or dot counts
/// end-to-end. Params: `mode` `picture` (default) · `dots` · `numeral_dots`
/// (numeral on one half, dots on the other), `items` (pictures), `values`
/// (how many different values, default 4 → 10 tiles), `hand` (default 3), `players`.
class DominoesEngine implements GameEngine {
  const DominoesEngine();

  @override
  String get type => 'dominoes';

  @override
  List<String> validate(GameDef def, ContentLibrary content) {
    final values = (def.params['values'] as int?) ?? 4;
    final items = resolveItems(content, def.params['items'] ?? 'tags:animal+farm');
    return [
      ...unknownItems(content, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
      if ((def.params['mode'] ?? 'picture') == 'picture' && items.length < values) '${def.id}: need $values pictures',
    ];
  }

  @override
  Widget build(GameContext context) => BoardGameScreen(context: context, create: DominoesGame.new);
}

/// Two values. [flipped] swaps the halves for display.
class Domino {
  Domino(this.a, this.b);
  final int a;
  final int b;
  bool matches(int v) => a == v || b == v;
}

/// Full set of tiles for [values] (all pairs a ≤ b), shuffled.
List<Domino> dominoSet(int values, Random r) => [
  for (var a = 0; a < values; a++)
    for (var b = a; b < values; b++) Domino(a, b),
]..shuffle(r);

class DominoesGame extends BoardGame {
  DominoesGame(super.host, super.mode);

  late final String faces = host.rounds.params['mode'] as String? ?? 'picture';
  late final int values = ((host.rounds.params['values'] as int?) ?? 4).clamp(3, 6);
  late final List<VocabItem> pictures = pick(
    host.random,
    resolveItems(host.context.content, host.rounds.params['items'] ?? 'tags:animal+farm'),
    values,
  );
  late final List<Domino> pile = dominoSet(values, host.random);
  final List<List<Domino>> hands = [];

  /// The chain, left to right, each tile oriented so neighbours touch.
  final List<(int, int)> chain = [];
  final List<DominoTile> handTiles = [];
  final List<DominoTile> chainTiles = [];
  late final PileComponent pileButton;
  int errors = 0;

  int get leftEnd => chain.first.$1;
  int get rightEnd => chain.last.$2;

  CardFace half(int v, {bool second = false}) => switch (faces) {
    'dots' => DotsFace(v + 1),
    'numeral_dots' => second ? DotsFace(v + 1) : TextFace('${v + 1}'),
    _ => PictureFace(pictures[v].picture),
  };

  @override
  Future<void> startRound() async {
    final hand = ((host.rounds.params['hand'] as int?) ?? 3).clamp(2, 5);
    for (var p = 0; p < turns.players.length; p++) {
      hands.add([for (var i = 0; i < hand; i++) pile.removeLast()]);
    }
    final first = pile.removeLast();
    chain.add((first.a, first.b));
    pileButton = PileComponent(onTap: _draw);
    await add(pileButton);
    await _rebuild();
    await host.prompt(const ['dominoPlay']);
    await announceTurn();
  }

  Future<void> _rebuild() async {
    removeAll([...handTiles, ...chainTiles]);
    handTiles.clear();
    chainTiles.clear();
    for (final (a, b) in chain.length > 5 ? chain.sublist(chain.length - 5) : chain) {
      chainTiles.add(DominoTile(half(a), half(b, second: true)));
    }
    final hand = hands[turns.index];
    for (final d in hand) {
      handTiles.add(DominoTile(half(d.a), half(d.b, second: true), domino: d, onTap: turns.pipsTurn ? null : _play));
    }
    await addAll([...chainTiles, ...handTiles]);
    layout(size);
  }

  @override
  void layout(Vector2 size) {
    if (chain.isEmpty) return;
    final tileW = min(size.x / 6.5, 190.0);
    final w = Vector2(tileW, tileW / 2);
    for (var i = 0; i < chainTiles.length; i++) {
      chainTiles[i]
        ..size = w
        ..position = Vector2(size.x / 2 + (i - (chainTiles.length - 1) / 2) * (tileW + 4), size.y * 0.3);
    }
    for (var i = 0; i < handTiles.length; i++) {
      handTiles[i]
        ..size = w * 1.1
        ..position = Vector2(size.x / 2 + (i - (handTiles.length - 1) / 2) * (tileW * 1.2), size.y * 0.72);
    }
    pileButton
      ..size = Vector2(tileW * 0.7, tileW * 0.9)
      ..position = Vector2(size.x * 0.9, size.y * 0.72);
  }

  bool _canPlay(Domino d) => d.matches(leftEnd) || d.matches(rightEnd);

  Future<bool> _place(Domino d) async {
    if (d.matches(rightEnd)) {
      chain.add(d.a == rightEnd ? (d.a, d.b) : (d.b, d.a));
    } else if (d.matches(leftEnd)) {
      chain.insert(0, d.b == leftEnd ? (d.a, d.b) : (d.b, d.a));
    } else {
      return false;
    }
    hands[turns.index].remove(d);
    host.correct();
    return true;
  }

  Future<void> _play(DominoTile t) async {
    if (ended || turns.pipsTurn || locked) return;
    final d = t.domino!;
    if (!await _place(d)) {
      t.wiggle();
      errors++;
      if (host.tryAgain()) _hint();
      return;
    }
    await _afterMove();
  }

  void _hint() {
    final playable = handTiles.where((t) => _canPlay(t.domino!)).toList();
    if (playable.isNotEmpty) {
      playable.first.hint();
    } else {
      pileButton.hint = true;
    }
    host.hintShown();
  }

  Future<void> _draw() async {
    if (ended || turns.pipsTurn || locked) return;
    if (hands[turns.index].any(_canPlay)) {
      // A tile already fits: point to it instead of drawing.
      _hint();
      return;
    }
    await _drawAndPass();
  }

  Future<void> _drawAndPass() async {
    pileButton.hint = false;
    if (pile.isNotEmpty) {
      await host.audio.say('dominoDraw', interrupt: true);
      hands[turns.index].add(pile.removeLast());
    }
    await _afterMove();
  }

  Future<void> _afterMove() async {
    locked = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final stuck = pile.isEmpty && hands.every((h) => !h.any(_canPlay));
    if (hands[turns.index].isEmpty || stuck) {
      await endGame(errors: errors);
      return;
    }
    turns.next();
    await _rebuild();
    locked = false;
    await announceTurn();
  }

  @override
  Future<void> playPipTurn() async {
    final playable = hands[turns.index].where(_canPlay).toList();
    // Gentle Pip: plays the first tile that fits, not the cleverest one.
    if (playable.isEmpty) {
      await _drawAndPass();
      return;
    }
    await _place(playable.first);
    await _afterMove();
  }
}

class DominoTile extends GameCard {
  DominoTile(this.left, this.right, {this.domino, void Function(DominoTile)? onTap})
    : super(
        face: const EmptyFace(),
        size: Vector2(160, 80),
        onTap: onTap == null ? null : (c) => onTap(c as DominoTile),
      );

  final CardFace left;
  final CardFace right;
  final Domino? domino;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final r = size.toRect().deflate(size.y * 0.1);
    left.paint(canvas, Rect.fromLTWH(r.left, r.top, r.width / 2, r.height));
    right.paint(canvas, Rect.fromLTWH(r.center.dx, r.top, r.width / 2, r.height));
    canvas.drawLine(
      Offset(r.center.dx, r.top),
      Offset(r.center.dx, r.bottom),
      Paint()
        ..color = const Color(0x553B2C4A)
        ..strokeWidth = 3,
    );
  }
}

/// The face-down pile to draw from.
class PileComponent extends PositionComponent with TapCallbacks, HasGameReference<PipGame> {
  PileComponent({required this.onTap}) : super(anchor: Anchor.center);

  final VoidCallback onTap;
  bool hint = false;

  @override
  void render(Canvas canvas) {
    for (var i = 2; i >= 0; i--) {
      final r = size.toRect().shift(Offset(i * 5.0, -i * 5.0));
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(12)), Paint()..color = const Color(0xFF7B6CF6));
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(12)),
        Paint()
          ..color = hint && i == 0 ? const Color(0xFFFFC928) : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = hint && i == 0 ? 6 : 3,
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.acceptTap()) onTap();
  }
}
