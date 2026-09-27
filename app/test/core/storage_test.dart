import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/core/mastery/mastery.dart';
import 'package:pips_world/core/profile/child_profile.dart';
import 'package:pips_world/core/storage/database.dart';
import 'package:pips_world/core/storage/drift_mastery_store.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('DriftMasteryStore upserts per skill', () async {
    final store = DriftMasteryStore(db);
    await store.save('a', const SkillStats(attempts: 1, correct: 1, independent: 1));
    await store.save('a', const SkillStats(attempts: 2, correct: 1, independent: 1, hints: 1));
    await store.save('b', const SkillStats(attempts: 1));
    expect(await store.loadAll(), {
      'a': const SkillStats(attempts: 2, correct: 1, independent: 1, hints: 1),
      'b': const SkillStats(attempts: 1),
    });
  });

  test('ProfileRepository saves, updates and deletes', () async {
    final repo = ProfileRepository(db);
    final fox = await repo.save(
      const ChildProfile(nickname: 'Dita', avatar: 'fox_orange', ageBand: AgeBand.preschool, locale: 'sq'),
    );
    expect(fox.id, isNotNull);
    await repo.save(fox.copyWith(ageBand: AgeBand.school));
    final all = await repo.all();
    expect(all.single.ageBand, AgeBand.school);
    expect(all.single.locale, 'sq');
    await repo.delete(fox.id!);
    expect(await repo.all(), isEmpty);
  });
}
