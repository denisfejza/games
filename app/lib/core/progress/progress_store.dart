import '../storage/database.dart';

/// Best stars per level, keyed `<world>.l<number>`.
abstract interface class ProgressStore {
  Future<Map<String, int>> loadAll();

  /// Saves [stars] if they beat the previous best.
  Future<void> complete(String level, int stars);
}

String levelKey(String world, int number) => '$world.l$number';

class MemoryProgressStore implements ProgressStore {
  final Map<String, int> data = {};

  @override
  Future<Map<String, int>> loadAll() async => Map.of(data);

  @override
  Future<void> complete(String level, int stars) async {
    if (stars > (data[level] ?? 0)) data[level] = stars;
  }
}

class DriftProgressStore implements ProgressStore {
  DriftProgressStore(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, int>> loadAll() async => {
    for (final r in await _db.select(_db.levelProgressRows).get()) r.level: r.stars,
  };

  @override
  Future<void> complete(String level, int stars) async {
    final best = (await loadAll())[level] ?? 0;
    if (stars <= best) return;
    await _db
        .into(_db.levelProgressRows)
        .insertOnConflictUpdate(
          LevelProgressRowsCompanion.insert(level: level, stars: stars, completedAt: DateTime.now()),
        );
  }
}
