import 'package:drift/drift.dart';

import '../../content/models.dart';
import '../storage/database.dart';

/// A child's local profile. No real name, no birthday, no account.
class ChildProfile {
  const ChildProfile({
    this.id,
    required this.nickname,
    required this.avatar,
    required this.ageBand,
    required this.locale,
  });

  final int? id;
  final String nickname;

  /// Avatar id, e.g. `fox_orange`. TODO(asset): avatar art.
  final String avatar;
  final AgeBand ageBand;

  /// `en` or `sq`.
  final String locale;

  ChildProfile copyWith({String? nickname, String? avatar, AgeBand? ageBand, String? locale}) => ChildProfile(
    id: id,
    nickname: nickname ?? this.nickname,
    avatar: avatar ?? this.avatar,
    ageBand: ageBand ?? this.ageBand,
    locale: locale ?? this.locale,
  );
}

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Future<List<ChildProfile>> all() async => [
    for (final r in await _db.select(_db.profileRows).get())
      ChildProfile(
        id: r.id,
        nickname: r.nickname,
        avatar: r.avatar,
        ageBand: AgeBand.fromJson(r.ageBand),
        locale: r.locale,
      ),
  ];

  /// Inserts a new profile or updates an existing one; returns it with its id.
  Future<ChildProfile> save(ChildProfile p) async {
    final row = ProfileRowsCompanion(
      id: p.id == null ? const Value.absent() : Value(p.id!),
      nickname: Value(p.nickname),
      avatar: Value(p.avatar),
      ageBand: Value(p.ageBand.json),
      locale: Value(p.locale),
    );
    final id = await _db.into(_db.profileRows).insertOnConflictUpdate(row);
    return ChildProfile(id: p.id ?? id, nickname: p.nickname, avatar: p.avatar, ageBand: p.ageBand, locale: p.locale);
  }

  Future<void> delete(int id) => (_db.delete(_db.profileRows)..where((r) => r.id.equals(id))).go();
}
