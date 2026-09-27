import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../common/game_card.dart';
import '../common/game_host.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import 'sound_match_config.dart';

class SoundMatchEngine implements GameEngine {
  const SoundMatchEngine();

  @override
  String get type => 'sound_match';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => SoundMatchConfig.validate(def, content);

  @override
  Widget build(GameContext context) =>
      GameScreen(context: context, create: (host) => SoundMatchGame(host));
}

/// Hear a prompt, tap the matching card.
class SoundMatchGame extends PipGame {
  SoundMatchGame(super.host)
      : _rounds = ChoiceRounds(host.random, text: host.context.text, locale: host.context.locale);

  final ChoiceRounds _rounds;
  ChoiceRound? round;
  final List<GameCard> cards = [];
  final List<GameCard> _stage = [];
  TextComponent? _op;

  GameHost get _h => host;

  @override
  Future<void> startRound() async {
    final config = SoundMatchConfig.parse(_h.rounds.params, _h.context.content);
    final r = round = _rounds.next(config);
    cards.clear();
    _stage.clear();
    for (var i = 0; i < r.faces.length; i++) {
      cards.add(GameCard(face: r.faces[i], size: Vector2.all(100), value: i, onTap: _tapped));
    }
    for (final f in r.stage) {
      _stage.add(GameCard(face: f, size: Vector2.all(100)));
    }
    _op = r.op == null
        ? null
        : TextComponent(
            text: r.op,
            anchor: Anchor.center,
            textRenderer: TextPaint(
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 64, color: Colors.white),
            ),
          );
    await addAll([...cards, ..._stage, ?_op]);
    layout(size);
    await _h.prompt(r.prompt);
  }

  @override
  void layout(Vector2 size) {
    if (round == null) return;
    final hasStage = _stage.isNotEmpty;
    final stageH = hasStage ? size.y * 0.38 : 0.0;
    if (hasStage) {
      final wide = _stage.length == 1 ? 2.2 : 1.0;
      final g = gridLayout(_stage.length, Vector2(size.x * 0.8, stageH), maxCard: 180, gap: 0.5);
      for (var i = 0; i < _stage.length; i++) {
        _stage[i]
          ..size = Vector2(g.card.x * wide, g.card.y)
          ..position = g.centres[i] + Vector2(size.x * 0.1, 0);
      }
      _op?.position = Vector2(size.x / 2, stageH / 2);
    }
    final g = gridLayout(cards.length, Vector2(size.x, size.y - stageH));
    for (var i = 0; i < cards.length; i++) {
      cards[i]
        ..size = g.card
        ..position = g.centres[i] + Vector2(0, stageH);
    }
  }

  void _tapped(GameCard card) {
    final r = round;
    if (r == null || locked) return;
    if (card.value == r.answer) {
      card
        ..done = true
        ..pop();
      for (final c in cards) {
        c.clearHint();
      }
      _h.correct();
      solved();
    } else {
      card.wiggle();
      if (_h.tryAgain()) {
        cards[r.answer].hint();
        _h.hintShown();
      }
    }
  }
}
