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

/// Parent settings and small counters (daily play time), as text key/values.
class SettingRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Best result per level. Only completed levels have a row (no 0-star state).
class LevelProgressRows extends Table {
  /// `<world>.l<number>`, e.g. `animals.l1`.
  TextColumn get level => text()();
  IntColumn get stars => integer()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {level};
}

/// The app's single on-device database. Nothing in it ever leaves the device.
@DriftDatabase(tables: [SkillStatsRows, ProfileRows, SettingRows, LevelProgressRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(settingRows);
        await m.createTable(levelProgressRows);
      }
    },
  );

  static QueryExecutor _open() => driftDatabase(
    name: 'pips_world',
    // Served from web/ next to index.html (see docs/DEPENDENCIES.md).
    web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js')),
  );
}
