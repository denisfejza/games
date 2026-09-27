import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import '../common/pools.dart';

/// `sequence_pattern`: complete the pattern (red-blue-red-?).
///
/// Params: `items` (default the colours), `patterns` (default `["AB"]`; any of
/// `AB`, `AAB`, `ABB`, `ABC`, `AABB`), `length` shown before the gap (default 4,
/// up to 7), `choices` (2–3, default 2), `rounds`.
class SequencePatternConfig {
  SequencePatternConfig._(this.params, this.items);

  factory SequencePatternConfig.parse(Map<String, dynamic> params, ContentLibrary lib) =>
      SequencePatternConfig._(params, resolveItems(lib, params['items'] ?? 'tag:colour'));

  final Map<String, dynamic> params;
  final List<VocabItem> items;

  List<String> get patterns => (params['patterns'] as List<dynamic>?)?.cast<String>() ?? const ['AB'];
  int get length => ((params['length'] as int?) ?? 4).clamp(2, 7);
  int get choices => ((params['choices'] as int?) ?? 2).clamp(2, 3);

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final c = SequencePatternConfig.parse(def.params, lib);
    final letters = {for (final p in c.patterns) ...p.split('')}.length;
    return [
      ...unknownItems(lib, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
      for (final p in c.patterns)
        if (!RegExp(r'^[ABC]{2,4}$').hasMatch(p)) '${def.id}: bad pattern "$p"',
      if (c.items.length < max(letters, c.choices)) '${def.id}: not enough items',
    ];
  }
}

class PatternRound {
  const PatternRound({required this.shown, required this.answer, required this.choices, required this.answerIndex});

  final List<VocabItem> shown;
  final VocabItem answer;
  final List<VocabItem> choices;
  final int answerIndex;
}

PatternRound nextPattern(SequencePatternConfig c, Random r) {
  final pattern = c.patterns[r.nextInt(c.patterns.length)];
  final symbols = pattern.split('').toSet().toList();
  final chosen = pick(r, c.items, symbols.length);
  final map = {for (var i = 0; i < symbols.length; i++) symbols[i]: chosen[i]};
  final seq = [for (var i = 0; i <= c.length; i++) map[pattern[i % pattern.length]]!];
  final answer = seq.last;
  final others = pick(r, [...chosen, ...c.items], c.choices - 1, exclude: [answer]);
  final choices = [
    answer,
    ...{...others},
  ]..shuffle(r);
  return PatternRound(
    shown: seq.sublist(0, c.length),
    answer: answer,
    choices: choices,
    answerIndex: choices.indexOf(answer),
  );
}

class SequencePatternEngine implements GameEngine {
  const SequencePatternEngine();

  @override
  String get type => 'sequence_pattern';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => SequencePatternConfig.validate(def, content);

  @override
  Widget build(GameContext context) => GameScreen(context: context, create: SequencePatternGame.new);
}

class SequencePatternGame extends PipGame {
  SequencePatternGame(super.host);

  PatternRound? round;
  final List<GameCard> row = [];
  final List<GameCard> choices = [];
  GameCard? gap;

  @override
  Future<void> startRound() async {
    final r = round = nextPattern(SequencePatternConfig.parse(host.rounds.params, host.context.content), host.random);
    row
      ..clear()
      ..addAll([
        for (final v in r.shown)
          GameCard(
            face: PictureFace(v.picture),
            size: Vector2.all(80),
            onTap: (_) => host.audio.say(v.nameKey, interrupt: true),
          ),
      ]);
    gap = GameCard(face: const BlankFace(), size: Vector2.all(80));
    choices
      ..clear()
      ..addAll([
        for (var i = 0; i < r.choices.length; i++)
          GameCard(face: PictureFace(r.choices[i].picture), size: Vector2.all(100), value: i, onTap: _tapped),
      ]);
    await addAll([...row, gap!, ...choices]);
    layout(size);
    await host.prompt(const ['gameWhatNext']);
  }

  @override
  void layout(Vector2 size) {
    final g = gap;
    if (g == null) return;
    final all = [...row, g];
    final top = gridLayout(all.length, Vector2(size.x, size.y * 0.45), cols: all.length, maxCard: 150, gap: 0.12);
    for (var i = 0; i < all.length; i++) {
      all[i]
        ..size = top.card
        ..position = top.centres[i];
    }
    final bottom = gridLayout(
      choices.length,
      Vector2(size.x, size.y * 0.5),
      cols: choices.length,
      maxCard: 170,
      gap: 0.4,
    );
    for (var i = 0; i < choices.length; i++) {
      choices[i]
        ..size = bottom.card
        ..position = bottom.centres[i] + Vector2(0, size.y * 0.5);
    }
  }

  void _tapped(GameCard card) {
    final r = round;
    if (r == null || locked) return;
    if (card.value == r.answerIndex) {
      gap!
        ..face = card.face
        ..done = true
        ..pop();
      card.done = true;
      for (final c in choices) {
        c.clearHint();
      }
      host.correct();
      host.audio.say(r.answer.nameKey, interrupt: true);
      solved();
    } else {
      card.wiggle();
      if (host.tryAgain()) {
        choices[r.answerIndex].hint();
        host.hintShown();
      }
    }
  }
}
