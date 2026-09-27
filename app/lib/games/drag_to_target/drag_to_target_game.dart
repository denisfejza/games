import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../common/drag_card.dart';
import '../common/game_card.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import 'drag_to_target_config.dart';

class DragToTargetEngine implements GameEngine {
  const DragToTargetEngine();

  @override
  String get type => 'drag_to_target';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => DragToTargetConfig.validate(def, content);

  @override
  Widget build(GameContext context) => GameScreen(context: context, create: DragToTargetGame.new);
}

/// Drag the item at the bottom onto the right zone at the top.
class DragToTargetGame extends PipGame {
  DragToTargetGame(super.host) : _rounds = DragRounds(host.random, host.context.content);

  final DragRounds _rounds;
  DragRound? round;
  final List<GameCard> zones = [];
  DragCard? item;

  @override
  Future<void> startRound() async {
    final r = round = _rounds.next(DragToTargetConfig.parse(host.rounds.params, host.context.content));
    zones
      ..clear()
      ..addAll([for (var i = 0; i < r.zones.length; i++) GameCard(face: r.zones[i], size: Vector2.all(100), value: i)]);
    item = DragCard(
      face: r.item,
      size: Vector2.all(100),
      onDrop: _dropped,
      onTap: (_) {
        if (r.itemName != null) host.audio.say(r.itemName!, interrupt: true);
      },
    );
    await addAll([...zones, item!]);
    layout(size);
    await host.prompt(r.prompt);
  }

  @override
  void layout(Vector2 size) {
    final it = item;
    if (it == null) return;
    final g = gridLayout(zones.length, Vector2(size.x, size.y * 0.55), maxCard: 200, gap: 0.3);
    for (var i = 0; i < zones.length; i++) {
      zones[i]
        ..size = g.card
        ..position = g.centres[i];
    }
    final s = (g.card.x * 0.8).clamp(80.0, 170.0);
    it
      ..size = Vector2.all(s)
      ..home = Vector2(size.x / 2, size.y * 0.78);
    if (!it.dragging && !it.done) it.position = it.home.clone();
  }

  bool _dropped(DragCard card, Vector2 at) {
    final r = round;
    if (r == null || locked) return false;
    final zone = nearestTarget(zones, at);
    if (zone == null) return false;
    if (zone.value == r.answer) {
      card
        ..done = true
        ..snapTo(zone.position)
        ..pop();
      zone.done = true;
      host.correct();
      solved();
      return true;
    }
    zone.wiggle();
    if (host.tryAgain()) {
      zones[r.answer].hint();
      host.hintShown();
    }
    return false;
  }
}
