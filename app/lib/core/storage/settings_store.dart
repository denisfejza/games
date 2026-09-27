import 'database.dart';

/// Key/value settings kept on the device.
abstract interface class SettingsStore {
  Future<Map<String, String>> loadAll();
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([Map<String, String>? initial]) : data = {...?initial};

  final Map<String, String> data;

  @override
  Future<Map<String, String>> loadAll() async => Map.of(data);

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> remove(String key) async => data.remove(key);
}

class DriftSettingsStore implements SettingsStore {
  DriftSettingsStore(this._db);

  final AppDatabase _db;

  @override
  Future<Map<String, String>> loadAll() async => {
    for (final r in await _db.select(_db.settingRows).get()) r.key: r.value,
  };

  @override
  Future<void> write(String key, String value) =>
      _db.into(_db.settingRows).insertOnConflictUpdate(SettingRowsCompanion.insert(key: key, value: value));

  @override
  Future<void> remove(String key) => (_db.delete(_db.settingRows)..where((r) => r.key.equals(key))).go();
}
