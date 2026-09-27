import 'dart:math';

import '../../content/models.dart';
import '../../core/mastery/mastery_tracker.dart';

/// What a mini-game reports when it ends.
class MiniGameResult {
  const MiniGameResult({required this.rounds, required this.firstTry, required this.hints});

  final int rounds;

  /// Rounds solved with no wrong attempt.
  final int firstTry;
  final int hints;
}

/// Shared pedagogy rules for every engine (CLAUDE.md):
/// - adaptive difficulty: `raiseAfter` first-try rounds in a row → next step;
///   `lowerAfter` wrong attempts in a row → previous step and a hint;
/// - scaffolding: hint after 1 wrong attempt on step 1, after 2 on step 2,
///   never on step 3+ (a level can override with `params.hintAfter`);
/// - `MasteryTracker.record(skill, correct, hintsUsed)` after every round.
class RoundController {
  RoundController({required this.def, required this.mastery, int startStep = 0})
    : _step = startStep.clamp(0, max(0, (def.difficulty?.steps.length ?? 1) - 1));

  final GameDef def;
  final MasteryTracker mastery;

  int _step;
  int _nextStep = -1;
  int _round = 0;
  int _errors = 0;
  int _roundHints = 0;
  int _hints = 0;
  int _firstTry = 0;
  int _streak = 0;
  int _wrongInRow = 0;

  /// Difficulty step used for the current round (0-based).
  int get step => _step;
  int get round => _round;
  int get errorsThisRound => _errors;

  /// Params for the current round: the level's params with the step's overrides.
  Map<String, dynamic> get params => {...def.params, ...?def.difficulty?.steps.elementAtOrNull(_step)};

  int get totalRounds => (def.params['rounds'] as int?) ?? 5;
  bool get finished => _round >= totalRounds;

  /// Wrong attempts before a hint shows; null means no hints at this step.
  int? get hintAfter {
    if (params['hintAfter'] case final int n) return n <= 0 ? null : n;
    return switch (_step) {
      0 => 1,
      1 => 2,
      _ => null,
    };
  }

  /// A wrong attempt. Returns true when the game should show a hint now.
  bool wrong() {
    _errors++;
    _wrongInRow++;
    final lowerAfter = def.difficulty?.lowerAfter;
    if (lowerAfter != null && _wrongInRow >= lowerAfter && _step > 0) {
      _wrongInRow = 0;
      _nextStep = _step - 1;
      return true;
    }
    final after = hintAfter;
    return after != null && _errors >= after && _errors % after == 0;
  }

  /// The game showed a hint.
  void hintShown() {
    _roundHints++;
    _hints++;
  }

  /// The round was solved. Records mastery for each of the game's skills and
  /// moves to the next round. Returns true when the game is over.
  Future<bool> solved() async {
    final firstTry = _errors == 0;
    for (final skill in def.skills) {
      await mastery.record(skill, correct: firstTry, hintsUsed: _roundHints);
    }
    if (firstTry) {
      _firstTry++;
      _streak++;
      _wrongInRow = 0;
    } else {
      _streak = 0;
    }
    final raiseAfter = def.difficulty?.raiseAfter;
    final steps = def.difficulty?.steps.length ?? 1;
    if (_nextStep >= 0) {
      _step = _nextStep;
    } else if (raiseAfter != null && _streak >= raiseAfter && _step < steps - 1) {
      _step++;
      _streak = 0;
    }
    _nextStep = -1;
    _round++;
    _errors = 0;
    _roundHints = 0;
    return finished;
  }

  MiniGameResult get result => MiniGameResult(rounds: _round, firstTry: _firstTry, hints: _hints);
}
