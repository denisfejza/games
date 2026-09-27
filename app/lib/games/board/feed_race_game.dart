import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/mini_game.dart';
import '../common/pools.dart';
import 'board_common.dart';

/// `feed_race` — Feed the Animals (PLAN 4.8): roll, then tap one berry per
/// dot to feed your animal, counting aloud. Everyone keeps going until every
/// tummy is full. Params: `goal` berries (default 10), `dice` sides (3/6), `food`, `players`.
class FeedRaceEngine implements GameEngine {
  const FeedRaceEngine();

  @override
  String get type => 'feed_race';

  @override
  List<String> validate(GameDef def, ContentLibrary content) =>
      unknownItems(content, def.params['food']).map((i) => '${def.id}: unknown food "$i"').toList();

  @override
  Widget build(GameContext context) => BoardGameScreen(context: context, create: FeedRaceGame.new);
}

class FeedRaceGame extends BoardGame {
  FeedRaceGame(super.host, super.mode);

  late final int goal = ((host.rounds.params['goal'] as int?) ?? 10).clamp(3, 20);
  late final VocabItem food = host.context.content.item(host.rounds.params['food'] as String? ?? 'cherry');
  final List<GameCard> animals = [];
  final List<GameCard> berries = [];
  late final DieComponent die;
  final List<int> fed = [];
  int toFeed = 0;
  int counted = 0;

  @override
  Future<void> startRound() async {
    for (var p = 0; p < turns.players.length; p++) {
      fed.add(0);
      animals.add(GameCard(face: _Belly(turns.players[p].token, 0, goal), size: Vector2.all(100)));
    }
    for (var i = 0; i < 6; i++) {
      berries.add(GameCard(face: PictureFace(food.picture), size: Vector2.all(60), value: i, onTap: _berry));
    }
    die = DieComponent(
      sides: ((host.rounds.params['dice'] as int?) ?? 3).clamp(3, 6),
      onRolled: _rolled,
      random: host.random,
    );
    await addAll([...animals, ...berries, die]);
    layout(size);
    await host.prompt(const ['feedRaceRoll']);
    await announceTurn();
  }

  @override
  void layout(Vector2 size) {
    if (animals.isEmpty) return;
    final a = min(size.y * 0.42, 220.0);
    for (var p = 0; p < animals.length; p++) {
      animals[p]
        ..size = Vector2.all(a)
        ..position = Vector2(size.x * (p == 0 ? 0.2 : 0.8), size.y * 0.35);
    }
    die
      ..size = Vector2.all(min(size.x * 0.16, 140))
      ..position = Vector2(size.x / 2, size.y * 0.35);
    final row = gridLayout(berries.length, Vector2(size.x, size.y * 0.3), cols: berries.length, maxCard: 110, gap: 0.3);
    for (var i = 0; i < berries.length; i++) {
      berries[i]
        ..size = row.card
        ..position = row.centres[i] + Vector2(0, size.y * 0.7);
    }
  }

  @override
  Future<void> announceTurn() async {
    // Full tummies sit out; the game ends when everyone is full.
    if (fed[turns.index] >= goal) {
      if (fed.every((f) => f >= goal)) return endGame();
      turns.next();
    }
    die.enabled = !turns.pipsTurn;
    await super.announceTurn();
  }

  @override
  Future<void> playPipTurn() => die.roll();

  void _rolled(int n) {
    toFeed = min(n, goal - fed[turns.index]);
    counted = 0;
    host.audio.say(numberKey(n), interrupt: true);
    if (turns.pipsTurn) {
      _pipFeeds();
    } else {
      host.audio.say('feedRaceTap');
      for (final b in berries) {
        b.hint();
      }
    }
  }

  Future<void> _pipFeeds() async {
    while (counted < toFeed) {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      await _feedOne(berries[counted % berries.length]);
    }
  }

  void _berry(GameCard b) {
    if (ended || turns.pipsTurn || counted >= toFeed) return;
    _feedOne(b);
  }

  Future<void> _feedOne(GameCard b) async {
    counted++;
    final p = turns.index;
    fed[p]++;
    for (final x in berries) {
      x.clearHint();
    }
    host.audio.say(numberKey(counted), interrupt: true);
    if (!host.reducedMotion) {
      b.add(ScaleEffect.to(Vector2.all(1.2), EffectController(duration: 0.1, reverseDuration: 0.1)));
    }
    animals[p]
      ..face = _Belly(turns.players[p].token, fed[p], goal)
      ..pop();
    if (counted < toFeed) return;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (fed[p] >= goal) {
      host.correct();
      animals[p].done = true;
      await host.audio.say('feedRaceFull', interrupt: true);
    }
    if (fed.every((f) => f >= goal)) {
      await endGame();
      return;
    }
    await nextTurn();
  }
}

/// An animal with a tummy meter showing how many berries it has had.
class _Belly extends CardFace {
  const _Belly(this.token, this.fed, this.goal);

  final String token;
  final int fed;
  final int goal;

  @override
  void paint(Canvas canvas, Rect rect) {
    paintPicture(canvas, EmojiPicture(token), Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.75));
    final bar = Rect.fromLTWH(
      rect.left + rect.width * 0.08,
      rect.bottom - rect.height * 0.16,
      rect.width * 0.84,
      rect.height * 0.12,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(12)), Paint()..color = const Color(0x22000000));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bar.left, bar.top, bar.width * fed / goal, bar.height),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFFE53935),
    );
    // One notch per berry, so the meter can be counted (not colour alone).
    for (var i = 1; i < goal; i++) {
      final x = bar.left + bar.width * i / goal;
      canvas.drawLine(
        Offset(x, bar.top + 3),
        Offset(x, bar.bottom - 3),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );
    }
  }
}
