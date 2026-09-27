import 'package:clock/clock.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import 'game_host.dart';

/// Base Flame game for all engines: transparent over the world background,
/// rebuilds its round on resize, debounces taps, and runs the round loop.
abstract class PipGame extends FlameGame {
  PipGame(this.host);

  final GameHost host;
  DateTime? _lastTap;
  bool locked = false;

  /// Sound played on tap-down.
  Effect get tapEffect => Effect.tap;

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await startRound();
  }

  /// Builds a new round (called at start and after each solved round).
  Future<void> startRound();

  /// Positions the current round's components for [size].
  void layout(Vector2 size);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) layout(size);
  }

  /// Ignores taps while [locked] (animations) and repeats within 250 ms.
  bool acceptTap() {
    if (locked) return false;
    final now = clock.now();
    if (_lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 250)) return false;
    _lastTap = now;
    return true;
  }

  /// Round solved: praise, then the next round or the end of the game.
  Future<void> solved({String? praiseKey, Duration pause = const Duration(milliseconds: 700)}) async {
    locked = true;
    final over = await host.roundSolved(praiseKey: praiseKey ?? host.praise);
    await Future<void>.delayed(pause);
    if (over) {
      await host.finish();
      return;
    }
    removeAll(children.toList());
    locked = false;
    await startRound();
  }
}
