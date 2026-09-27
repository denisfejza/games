import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/mini_game.dart';
import '../common/pools.dart';
import 'board_common.dart';

/// `i_spy` (PLAN 4.7): "Find something red!" in a busy scene, or spot the
/// differences between two scenes. Players take turns finding.
/// Params: `mode` `colour` (default) · `animal` · `difference`; `items`;
/// `count` objects in the scene (default 9); `rounds`; `players`.
class ISpyEngine implements GameEngine {
  const ISpyEngine();

  @override
  String get type => 'i_spy';

  @override
  List<String> validate(GameDef def, ContentLibrary content) {
    final mode = def.params['mode'] as String? ?? 'colour';
    return [
      if (!{'colour', 'animal', 'difference'}.contains(mode)) '${def.id}: unknown mode "$mode"',
      ...unknownItems(content, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
    ];
  }

  @override
  Widget build(GameContext context) => BoardGameScreen(context: context, create: ISpyGame.new);
}

class ISpyRound {
  const ISpyRound({required this.left, required this.right, required this.answers, required this.prompt});

  /// Scene items; for `difference`, [right] is the changed copy.
  final List<VocabItem> left;
  final List<VocabItem>? right;

  /// Indexes (in the right scene for `difference`) that count as found.
  final Set<int> answers;
  final List<String> prompt;
}

ISpyRound nextISpy(String mode, List<VocabItem> pool, int count, Random r) {
  switch (mode) {
    case 'difference':
      final n = min(6, count);
      final left = pick(r, pool, n);
      final right = [...left];
      final changed = pick(r, [for (var i = 0; i < n; i++) i], 2).toSet();
      final spare = pick(r, pool, 2, exclude: left);
      var k = 0;
      for (final i in changed) {
        right[i] = spare[k++];
      }
      return ISpyRound(left: left, right: right, answers: changed, prompt: const ['ispyDifference']);
    case 'animal':
      final scene = pick(r, pool, count);
      final target = scene[r.nextInt(scene.length)];
      return ISpyRound(
        left: scene,
        right: null,
        answers: {scene.indexOf(target)},
        prompt: ['ispyAnimal', target.nameKey],
      );
    default:
      final coloured = [
        for (final v in pool)
          if (v.props['colour'] != null) v,
      ];
      final scene = pick(r, coloured, count);
      final colours = {for (final v in scene) v.props['colour']!}.toList();
      final colour = colours[r.nextInt(colours.length)];
      return ISpyRound(
        left: scene,
        right: null,
        answers: {
          for (var i = 0; i < scene.length; i++)
            if (scene[i].props['colour'] == colour) i,
        },
        prompt: ['ispyColour', 'colour.$colour'],
      );
  }
}

class ISpyGame extends BoardGame {
  ISpyGame(super.host, super.mode);

  late final String spyMode = host.rounds.params['mode'] as String? ?? 'colour';
  late final int rounds = ((host.rounds.params['rounds'] as int?) ?? 4).clamp(1, 10);
  late final List<VocabItem> pool = resolveItems(
    host.context.content,
    host.rounds.params['items'] ??
        (spyMode == 'animal' ? 'tag:animal' : (spyMode == 'difference' ? 'tag:animal' : ['tag:food', 'tag:object'])),
  );
  ISpyRound? round;
  final List<GameCard> left = [];
  final List<GameCard> right = [];
  final Set<int> found = {};
  final List<RectangleComponent> _panels = [];
  int played = 0;
  int errors = 0;

  @override
  Future<void> startRound() async => _newScene();

  Future<void> _newScene() async {
    removeAll([...left, ...right, ..._panels]);
    _panels.clear();
    left.clear();
    right.clear();
    found.clear();
    final r = round = nextISpy(spyMode, pool, ((host.rounds.params['count'] as int?) ?? 9).clamp(4, 12), host.random);
    for (var i = 0; i < r.left.length; i++) {
      left.add(
        GameCard(
          face: PictureFace(r.left[i].picture),
          size: Vector2.all(80),
          value: i,
          onTap: r.right == null ? _tapped : null,
        ),
      );
    }
    for (var i = 0; i < (r.right?.length ?? 0); i++) {
      right.add(GameCard(face: PictureFace(r.right![i].picture), size: Vector2.all(80), value: i, onTap: _tapped));
    }
    if (r.right != null) {
      // Two pale panels so the two pictures read as separate scenes.
      for (var i = 0; i < 2; i++) {
        _panels.add(RectangleComponent(paint: Paint()..color = const Color(0x55FFFFFF), priority: -1));
      }
    }
    await addAll([..._panels, ...left, ...right]);
    layout(size);
    await host.prompt(r.prompt);
    await announceTurn();
  }

  @override
  void layout(Vector2 size) {
    if (round == null) return;
    if (right.isEmpty) {
      final g = gridLayout(left.length, size, maxCard: 150, gap: 0.2);
      for (var i = 0; i < left.length; i++) {
        left[i]
          ..size = g.card
          ..position = g.centres[i];
      }
      return;
    }
    final half = Vector2(size.x / 2 * 0.94, size.y);
    for (var i = 0; i < _panels.length; i++) {
      _panels[i]
        ..size = Vector2(size.x / 2 * 0.96, size.y * 0.96)
        ..position = Vector2(i * size.x / 2 + size.x * 0.01, size.y * 0.02);
    }
    final g = gridLayout(left.length, half, cols: 2, maxCard: 130, gap: 0.15);
    for (var i = 0; i < left.length; i++) {
      left[i]
        ..size = g.card
        ..position = g.centres[i];
      right[i]
        ..size = g.card
        ..position = g.centres[i] + Vector2(size.x / 2 + size.x * 0.03, 0);
    }
  }

  void _tapped(GameCard c) {
    if (ended || locked || turns.pipsTurn) return;
    _pick(c.value! as int, c);
  }

  Future<void> _pick(int i, GameCard c) async {
    final r = round!;
    if (found.contains(i)) return;
    if (!r.answers.contains(i)) {
      c.wiggle();
      errors++;
      if (host.tryAgain()) {
        final cards = right.isEmpty ? left : right;
        cards[r.answers.firstWhere((a) => !found.contains(a))].hint();
      }
      return;
    }
    found.add(i);
    c
      ..done = true
      ..pop();
    host.correct();
    // Colour / animal: one find per turn. Differences: find them all.
    final roundOver = r.right == null || found.length == r.answers.length;
    if (!roundOver) return;
    locked = true;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    played++;
    if (played >= rounds) {
      await endGame(errors: errors);
      return;
    }
    turns.next();
    locked = false;
    await _newScene();
  }

  @override
  Future<void> playPipTurn() async {
    final r = round!;
    final cards = right.isEmpty ? left : right;
    for (final a in r.answers) {
      if (found.contains(a)) continue;
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (ended) return;
      await _pick(a, cards[a]);
      if (r.right == null) return;
    }
  }
}
