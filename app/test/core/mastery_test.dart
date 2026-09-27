import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/core/mastery/mastery.dart';
import 'package:pips_world/core/mastery/mastery_tracker.dart';

void main() {
  group('SkillStats', () {
    test('counts correct, independent and hints', () {
      final s = const SkillStats()
          .record(correct: true, hintsUsed: 0)
          .record(correct: true, hintsUsed: 2)
          .record(correct: false, hintsUsed: 1);
      expect(s, const SkillStats(attempts: 3, correct: 2, independent: 1, hints: 3));
      expect(s.accuracy, closeTo(2 / 3, 1e-9));
      expect(s.independentRate, closeTo(1 / 3, 1e-9));
    });

    test('mastered at ≥ 80% independent after enough rounds', () {
      var s = const SkillStats();
      for (var i = 0; i < 4; i++) {
        s = s.record(correct: true, hintsUsed: 0);
      }
      expect(s.isMastered, isFalse, reason: 'too few rounds');
      s = s.record(correct: true, hintsUsed: 1); // 4/5 independent = 80%
      expect(s.isMastered, isTrue);
      s = s.record(correct: false, hintsUsed: 0); // 4/6 ≈ 67%
      expect(s.isMastered, isFalse);
    });

    test('empty stats are safe', () {
      expect(const SkillStats().accuracy, 0);
      expect(const SkillStats().isMastered, isFalse);
    });

    test('rejects negative hints', () {
      expect(() => const SkillStats().record(correct: true, hintsUsed: -1), throwsArgumentError);
    });
  });

  test('stars: 3 without hints, 2 with up to 2, otherwise 1 — never 0', () {
    expect(levelStars(hintsUsed: 0), 3);
    expect(levelStars(hintsUsed: 1), 2);
    expect(levelStars(hintsUsed: 2), 2);
    expect(levelStars(hintsUsed: 3), 1);
    expect(levelStars(hintsUsed: 50), 1);
  });

  test('MasteryTracker persists and reloads', () async {
    final store = MemoryMasteryStore();
    final tracker = MasteryTracker(store);
    for (var i = 0; i < 5; i++) {
      await tracker.record('count.to3', correct: true, hintsUsed: 0);
    }
    await tracker.record('listening', correct: false, hintsUsed: 1);

    final reloaded = MasteryTracker(store);
    await reloaded.load();
    expect(reloaded.stats('count.to3').attempts, 5);
    expect(reloaded.allMastered(['count.to3']), isTrue);
    expect(reloaded.allMastered(['count.to3', 'listening']), isFalse);
  });
}
