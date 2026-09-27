import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/ui/big_button.dart';
import 'package:pips_world/app/ui/tokens.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/core/audio/audio_service.dart';
import 'package:pips_world/core/mastery/mastery.dart';
import 'package:pips_world/parent/dashboard.dart';
import 'package:pips_world/parent/parent_area.dart';
import 'package:pips_world/parent/privacy_screen.dart';
import 'package:pips_world/parent/purchases.dart';
import 'package:pips_world/worlds/world_screen.dart';

import '../helpers.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContent());

  test('dashboard: levels, stars, mastered skills, unfinished games, a daily idea', () {
    final d = buildDashboard(
      lib,
      progress: {'animals.l1': 3, 'animals.l2': 2},
      stats: (s) =>
          s == 'vocab.animals.farm' ? const SkillStats(attempts: 5, correct: 5, independent: 5) : const SkillStats(),
      settings: {'abandon.numbers.to3.l1.count3': '4', 'abandon.animals.farm.l1.farm_pairs': '1', 'locale': 'sq'},
      today: DateTime(2026, 10, 1),
    );
    final animals = d.worlds.firstWhere((w) => w.worldId == 'animals');
    expect(animals.levelsDone, 2);
    expect(animals.stars, 5);
    expect(animals.skillsMastered, 1);
    expect(d.leftUnfinished.first, ('numbers.to3.l1.count3', 4));
    expect(d.todayIdea, startsWith('offscreen.'));
  });

  test('sampler: first two levels only until unlocked', () {
    expect(visibleLevels([1, 2, 3, 4], unlocked: false), [1, 2]);
    expect(visibleLevels([1, 2, 3, 4], unlocked: true), [1, 2, 3, 4]);
  });

  testWidgets('children see only sampler levels — no locks or prices on their screens', (tester) async {
    setScreen(tester, tablet);
    await tester.pumpWidget(
      testApp(
        content: lib,
        child: WorldScreen(world: lib.world('numbers')),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('level.1')), findsOneWidget);
    expect(find.byKey(const Key('level.2')), findsOneWidget);
    expect(find.byKey(const Key('level.3')), findsNothing);
    expect(find.textContaining('€'), findsNothing);
    expect(find.byIcon(Icons.lock), findsNothing);
  });

  testWidgets('parent area: dashboard, price up front, buying unlocks everything', (tester) async {
    setScreen(tester, tablet);
    final deps = TestDeps();
    await tester.pumpWidget(testApp(deps: deps, content: lib, child: const ParentArea()));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard.animals')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('store.buy')), 300);
    expect(find.textContaining('€4.99'), findsOneWidget);
    await tester.tap(find.byKey(const Key('store.buy')));
    expect(deps.store.buys, 1);
    deps.store.completePurchase();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('store.buy')), findsNothing);
    expect(deps.settings.data['fullUnlock'], 'true');
  });

  testWidgets('no store (web): says where to buy instead', (tester) async {
    setScreen(tester, tablet);
    final deps = TestDeps()..store.storeAvailable = false;
    await tester.pumpWidget(testApp(deps: deps, content: lib, child: const ParentArea()));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('store.unavailable')), 300);
    expect(find.byKey(const Key('store.unavailable')), findsOneWidget);
  });

  for (final (locale, text) in [('en', 'Nothing leaves this device'), ('sq', 'Asgjë nuk largohet nga kjo pajisje')]) {
    testWidgets('privacy page ($locale)', (tester) async {
      await tester.pumpWidget(testApp(locale: locale, child: const PrivacyScreen()));
      await tester.pump();
      expect(find.text(text), findsOneWidget);
    });
  }

  test('bilingual mode says names in both languages, instructions once', () async {
    final backend = FakeAudioBackend();
    final audio = AudioService(backend, locale: () => 'sq', secondLocale: () => 'en');
    await audio.sayAll(['gameFindThis', 'vocab.cow']);
    expect(backend.played, ['audio/sq/gameFindThis.ogg', 'audio/sq/vocabCow.ogg', 'audio/en/vocabCow.ogg']);
  });

  testWidgets('extra-large buttons grow every touch target by 30%', (tester) async {
    setScreen(tester, phone);
    Future<double> faceSize(bool large) async {
      await tester.pumpWidget(
        testApp(
          child: LargeTargets(
            enabled: large,
            child: Scaffold(
              body: Center(
                child: BigButton(key: const Key('b'), icon: Icons.pets, onPressed: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      return tester
          .getSize(find.descendant(of: find.byKey(const Key('b')), matching: find.byType(AnimatedContainer)))
          .width;
    }

    final normal = await faceSize(false);
    final large = await faceSize(true);
    expect(large, closeTo(normal * 1.3, 0.5));
    expect(normal, AgeBandTokens.preschool.minTarget);
  });
}
