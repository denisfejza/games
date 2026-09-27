import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import 'round_controller.dart';

/// Everything an engine needs to run one game from content JSON.
class GameContext {
  GameContext({
    required this.def,
    required this.content,
    required this.band,
    required this.locale,
    required this.onFinished,
    required this.text,
    Random? random,
  }) : random = random ?? Random();

  final GameDef def;
  final ContentLibrary content;
  final AgeBand band;
  final String locale;
  final Random random;

  /// The string for a content key in the current language (names, letters).
  final String? Function(String key) text;

  /// Called once, after the game's short celebration.
  final void Function(MiniGameResult result) onFinished;
}

/// An engine: validates a game's params and builds its screen.
abstract interface class GameEngine {
  String get type;

  /// Problems with [def]'s params (unknown items, bad counts). Empty when fine.
  List<String> validate(GameDef def, ContentLibrary content);

  Widget build(GameContext context);
}

/// Engines by `game` type (lib/games/registry.dart). Overridden in tests with stub engines.
final gameRegistryProvider = Provider<Map<String, GameEngine>>((ref) => throw UnimplementedError('set in main.dart'));
