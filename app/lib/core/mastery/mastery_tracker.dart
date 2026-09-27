import 'mastery.dart';

/// Where skill stats are kept. Always on-device (CLAUDE.md hard rule 1).
abstract interface class MasteryStore {
  Future<Map<String, SkillStats>> loadAll();
  Future<void> save(String skill, SkillStats stats);
}

class MemoryMasteryStore implements MasteryStore {
  final Map<String, SkillStats> data = {};

  @override
  Future<Map<String, SkillStats>> loadAll() async => Map.of(data);

  @override
  Future<void> save(String skill, SkillStats stats) async => data[skill] = stats;
}

/// Records every round's result per skill. Games call [record] after each round.
class MasteryTracker {
  MasteryTracker(this._store);

  final MasteryStore _store;
  final Map<String, SkillStats> _stats = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _stats.addAll(await _store.loadAll());
    _loaded = true;
  }

  SkillStats stats(String skill) => _stats[skill] ?? const SkillStats();

  Future<void> record(String skill, {required bool correct, required int hintsUsed}) async {
    await load();
    final next = stats(skill).record(correct: correct, hintsUsed: hintsUsed);
    _stats[skill] = next;
    await _store.save(skill, next);
  }

  /// True when every skill is mastered, e.g. to unlock the next level.
  bool allMastered(Iterable<String> skills) => skills.every((s) => stats(s).isMastered);
}
