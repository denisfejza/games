import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Per-skill results for [MasteryTracker].
class SkillStatsRows extends Table {
  TextColumn get skill => text()();
  IntColumn get attempts => integer()();
  IntColumn get correct => integer()();
  IntColumn get independent => integer()();
  IntColumn get hints => integer()();

  @override
  Set<Column<Object>> get primaryKey => {skill};
}

/// Local child profiles. Nickname + avatar + age band + locale only (CLAUDE.md hard rule 1).
class ProfileRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text().withLength(min: 1, max: 24)();
  TextColumn get avatar => text()();
  TextColumn get ageBand => text()();
  TextColumn get locale => text()();
}

/// The app's single on-device database. Nothing in it ever leaves the device.
@DriftDatabase(tables: [SkillStatsRows, ProfileRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() => driftDatabase(
    name: 'pips_world',
    // Served from web/ next to index.html (see docs/DEPENDENCIES.md).
    web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
  );
}
