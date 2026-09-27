import 'dart:math';

import '../../companion/pip_controller.dart';
import '../../core/audio/audio_service.dart';
import 'mini_game.dart';
import 'round_controller.dart';

/// What a running game can ask of the app: narration, Pip, feedback,
/// progress and finishing. Created by `GameScreen`, passed to the Flame game.
class GameHost {
  GameHost({
    required this.context,
    required this.rounds,
    required this.audio,
    required this.pip,
    required this.reducedMotion,
    required this.onProgress,
    required this.onDone,
  });

  final GameContext context;
  final RoundController rounds;
  final AudioService audio;
  final PipController pip;
  final bool reducedMotion;

  /// Called when the round number changes (progress dots).
  final void Function() onProgress;
  final void Function(MiniGameResult) onDone;

  Random get random => context.random;
  List<String> _prompt = const [];
  bool _finished = false;

  /// Narrates the round's instruction, e.g. `['gameFindThis', 'vocab.cow']`.
  /// "Hear again" repeats the whole prompt.
  Future<void> prompt(List<String> keys) {
    _prompt = keys;
    return audio.sayAll(keys, interrupt: true);
  }

  Future<void> repeatPrompt() => audio.sayAll(_prompt, interrupt: true);

  /// Instant feedback for a right answer (well under 100 ms: sound + Pip).
  void correct() {
    audio.effect(Effect.correct);
    pip.onEvent(PipEvent.correct);
  }

  /// A wrong attempt: Pip gets curious, never sad. Returns true if the game should hint now.
  bool tryAgain() {
    audio.effect(Effect.tryAgain);
    pip.onEvent(PipEvent.tryAgain);
    return rounds.wrong();
  }

  void hintShown() => rounds.hintShown();

  /// Marks the round solved, says specific praise, and reports whether the game is over.
  Future<bool> roundSolved({String? praiseKey}) async {
    final over = await rounds.solved();
    onProgress();
    if (praiseKey != null) await audio.say(praiseKey, interrupt: true);
    return over;
  }

  /// Short celebration (< 2 s), then hands the result back.
  Future<void> finish() async {
    if (_finished) return;
    _finished = true;
    audio.effect(Effect.celebrate);
    pip.onEvent(PipEvent.levelDone);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    onDone(rounds.result);
  }

  /// Picks one of the generic praise lines at random.
  String get praise => const ['praiseGreat', 'praiseWellDone', 'praiseYouDidIt', 'praiseSuper'][random.nextInt(4)];
}
