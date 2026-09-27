/// Mastery rules from CLAUDE.md (pure logic, no storage).
library;

/// Share of rounds a child must get right without hints to master a skill.
const masteryThreshold = 0.8;

/// Rounds needed before a skill can count as mastered, so one lucky tap isn't mastery.
/// TODO(pedagogy): placeholder until the educator confirms it in docs/CURRICULUM.md.
const minAttemptsForMastery = 5;

class SkillStats {
  const SkillStats({this.attempts = 0, this.correct = 0, this.independent = 0, this.hints = 0});

  /// Rounds played.
  final int attempts;

  /// Rounds answered correctly (with or without hints).
  final int correct;

  /// Rounds answered correctly with no hints ("independent completion").
  final int independent;

  /// Hints shown in total.
  final int hints;

  double get accuracy => attempts == 0 ? 0 : correct / attempts;
  double get independentRate => attempts == 0 ? 0 : independent / attempts;
  bool get isMastered => attempts >= minAttemptsForMastery && independentRate >= masteryThreshold;

  SkillStats record({required bool correct, required int hintsUsed}) {
    if (hintsUsed < 0) throw ArgumentError.value(hintsUsed, 'hintsUsed', 'must be ≥ 0');
    return SkillStats(
      attempts: attempts + 1,
      correct: this.correct + (correct ? 1 : 0),
      independent: independent + (correct && hintsUsed == 0 ? 1 : 0),
      hints: hints + hintsUsed,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SkillStats &&
      other.attempts == attempts &&
      other.correct == correct &&
      other.independent == independent &&
      other.hints == hints;

  @override
  int get hashCode => Object.hash(attempts, correct, independent, hints);

  @override
  String toString() => 'SkillStats($correct/$attempts correct, $independent independent, $hints hints)';
}

/// Stars for a completed level: 3 with no hints, 2 with up to 2, otherwise 1.
/// There is no 0-star result: an unfinished level simply has no stars yet.
int levelStars({required int hintsUsed}) => switch (hintsUsed) {
  0 => 3,
  <= 2 => 2,
  _ => 1,
};
