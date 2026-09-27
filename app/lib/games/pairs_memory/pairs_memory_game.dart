import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../common/game_card.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import 'pairs_memory_config.dart';

class PairsMemoryEngine implements GameEngine {
  const PairsMemoryEngine();

  @override
  String get type => 'pairs_memory';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => PairsMemoryConfig.validate(def, content);

  @override
  Widget build(GameContext context) {
    final c = PairsMemoryConfig.parse(context.def.params, context.content);
    final def = GameDef.fromJsonWithParams(context.def, {'hintAfter': 3, ...context.def.params, 'rounds': c.pairs});
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
      create: PairsMemoryGame.new,
    );
  }
}

/// Memory pairs. Each pair found is a round; the board stays until all are found.
class PairsMemoryGame extends PipGame {
  PairsMemoryGame(super.host);

  late final PairsMemoryConfig config = PairsMemoryConfig.parse(host.rounds.params, host.context.content);
  final List<GameCard> cards = [];
  final List<GameCard> _up = [];

  /// Two players take turns; a match keeps the turn. Everyone is celebrated at the end.
  int player = 0;
  final List<int> found = [0, 0];
  _TurnBadge? _badge;

  @override
  Future<void> startRound() async {
    final deal = dealMemory(config, host.random, text: host.context.text, locale: host.context.locale);
    for (final spec in deal) {
      cards.add(GameCard(face: spec.face, size: Vector2.all(100), faceUp: false, value: spec, onTap: _tapped));
    }
    await addAll(cards);
    if (config.players == 2) {
      _badge = _TurnBadge(this);
      await add(_badge!);
    }
    layout(size);
    await host.prompt(const ['gameFindPairs']);
  }

  @override
  void layout(Vector2 size) {
    if (cards.isEmpty) return;
    final top = config.players == 2 ? 70.0 : 0.0;
    final g = gridLayout(cards.length, Vector2(size.x, size.y - top), maxCard: 180, gap: 0.14);
    for (var i = 0; i < cards.length; i++) {
      cards[i]
        ..size = g.card
        ..position = g.centres[i] + Vector2(0, top);
    }
    _badge?.position = Vector2(size.x / 2, 34);
  }

  MemoryCardSpec _spec(GameCard c) => c.value! as MemoryCardSpec;

  Future<void> _tapped(GameCard card) async {
    if (locked || card.faceUp || card.done || _up.length >= 2) return;
    _up.add(card);
    // Decide now: only the second card of a turn checks for a match, even if
    // both flips finish at the same moment.
    final second = _up.length == 2;
    if (second) locked = true;
    await card.flip(true);
    final say = _spec(card).sayKey;
    if (say != null) host.audio.say(say, interrupt: true);
    if (!second) return;
    // Wait for the first card's flip too before judging.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final [a, b] = _up;
    if (_spec(a).pair == _spec(b).pair) {
      _up.clear();
      a
        ..done = true
        ..pop();
      b
        ..done = true
        ..pop();
      for (final c in cards) {
        c.clearHint();
      }
      host.correct();
      found[player]++;
      locked = false;
      final over = await host.roundSolved(praiseKey: 'praisePair');
      if (over) await host.finish();
      return;
    }
    final hint = host.tryAgain();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    await Future.wait([a.flip(false), b.flip(false)]);
    _up.clear();
    if (config.players == 2) player = 1 - player;
    locked = false;
    if (hint) await _showHint();
  }

  /// Peeks at one unfound pair for a moment.
  Future<void> _showHint() async {
    final left = cards.where((c) => !c.done).toList();
    if (left.isEmpty) return;
    final pair = _spec(left.first).pair;
    final both = left.where((c) => _spec(c).pair == pair).toList();
    host.hintShown();
    locked = true;
    for (final c in both) {
      c.hint();
      await c.flip(true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    for (final c in both) {
      c.clearHint();
      await c.flip(false);
    }
    locked = false;
  }
}

/// Whose turn it is, with each player's pairs as stars. Shape + colour, not colour alone.
class _TurnBadge extends PositionComponent {
  _TurnBadge(this.game) : super(size: Vector2(260, 56), anchor: Anchor.center);

  final PairsMemoryGame game;
  static const colors = [Color(0xFFFF8C1A), Color(0xFF1FB5E3)];
  static const icons = [Icons.pets, Icons.emoji_nature];

  @override
  void render(Canvas canvas) {
    for (var p = 0; p < 2; p++) {
      final active = game.player == p;
      final r = Rect.fromLTWH(p * 136.0, 0, 124, 56);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(28)),
        Paint()..color = active ? colors[p] : const Color(0x88FFFFFF),
      );
      if (active) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(r.inflate(3), const Radius.circular(30)),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: String.fromCharCode(icons[p].codePoint),
              style: TextStyle(fontFamily: icons[p].fontFamily, fontSize: 30, color: Colors.white),
            ),
            TextSpan(
              text: '  ${'★' * game.found[p]}',
              style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 110);
      tp.paint(canvas, Offset(r.left + 12, r.center.dy - tp.height / 2));
    }
  }
}
