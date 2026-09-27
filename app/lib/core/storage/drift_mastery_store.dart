import '../mastery/mastery.dart';
import '../mastery/mastery_tracker.dart';
import 'database.dart';

class DriftMasteryStore implements MasteryStore {
  DriftMasteryStore(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, SkillStats>> loadAll() async {
    final rows = await _db.select(_db.skillStatsRows).get();
    return {
      for (final r in rows)
        r.skill: SkillStats(attempts: r.attempts, correct: r.correct, independent: r.independent, hints: r.hints),
    };
  }

  @override
  Future<void> save(String skill, SkillStats stats) => _db
      .into(_db.skillStatsRows)
      .insertOnConflictUpdate(
        SkillStatsRowsCompanion.insert(
          skill: skill,
          attempts: stats.attempts,
          correct: stats.correct,
          independent: stats.independent,
          hints: stats.hints,
        ),
      );
}
