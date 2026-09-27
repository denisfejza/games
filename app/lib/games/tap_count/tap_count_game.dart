import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import '../common/pools.dart';
import 'tap_count_config.dart';

class TapCountEngine implements GameEngine {
  const TapCountEngine();

  @override
  String get type => 'tap_count';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => TapCountConfig.validate(def, content);

  @override
  Widget build(GameContext context) => GameScreen(context: context, create: TapCountGame.new);
}

/// Tap each object once; each tap shows and says the next number.
class TapCountGame extends PipGame {
  TapCountGame(super.host) : _rounds = CountRounds(host.random);

  final CountRounds _rounds;
  CountRound? round;
  final List<GameCard> objects = [];
  int counted = 0;

  @override
  Future<void> startRound() async {
    final r = round = _rounds.next(TapCountConfig.parse(host.rounds.params, host.context.content));
    counted = 0;
    objects
      ..clear()
      ..addAll([
        for (var i = 0; i < r.count; i++)
          GameCard(face: PictureFace(r.item.picture), size: Vector2.all(100), onTap: _tapped),
      ]);
    await addAll(objects);
    layout(size);
    await host.prompt(const ['gameCountTap']);
  }

  @override
  void layout(Vector2 size) {
    if (objects.isEmpty) return;
    final g = gridLayout(objects.length, size, maxCard: 170, gap: 0.3);
    // A little jitter so they look scattered, fixed per object so resizes don't jump.
    final jitter = Random(objects.length);
    for (var i = 0; i < objects.length; i++) {
      objects[i]
        ..size = g.card
        ..position = g.centres[i] + Vector2(jitter.nextDouble() - 0.5, jitter.nextDouble() - 0.5) * g.card.x * 0.12;
    }
  }

  void _tapped(GameCard card) {
    final r = round;
    if (r == null || locked) return;
    if (card.done) {
      // Counted twice: that's the one-to-one mistake. Pip is curious; hint the rest.
      card.wiggle();
      if (host.tryAgain()) {
        for (final o in objects.where((o) => !o.done)) {
          o.hint();
        }
        host.hintShown();
      }
      return;
    }
    counted++;
    card
      ..done = true
      ..face = _Numbered(card.face, counted)
      ..pop();
    for (final o in objects) {
      o.clearHint();
    }
    host.audio.say(numberKey(counted), interrupt: true);
    if (counted == r.count) {
      host.correct();
      solved(praiseKey: 'praiseCountedAll', pause: const Duration(milliseconds: 900));
    }
  }
}

/// The object with its count number on a badge.
class _Numbered extends CardFace {
  const _Numbered(this.inner, this.n);
  final CardFace inner;
  final int n;

  @override
  void paint(Canvas canvas, Rect rect) {
    inner.paint(canvas, rect.deflate(rect.width * 0.12));
    final c = Offset(rect.left + rect.width * 0.18, rect.top + rect.width * 0.18);
    canvas.drawCircle(c, rect.width * 0.16, Paint()..color = const Color(0xFF8E5CF7));
    TextFace('$n', color: const Color(0xFFFFFFFF)).paint(canvas, Rect.fromCircle(center: c, radius: rect.width * 0.2));
  }
}
