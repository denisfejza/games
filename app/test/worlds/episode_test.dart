import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/providers.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/content_schema.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/worlds/episode_screen.dart';
import 'package:pips_world/worlds/level_status.dart';
import 'package:pips_world/worlds/world_screen.dart';

import '../helpers.dart';

final schema = ContentSchema(jsonDecode(File('assets/content/schema.json').readAsStringSync()) as Map<String, dynamic>);

ContentLibrary library() {
  Map<String, dynamic> game(String id, int level, {List<String> bands = const ['4-5']}) => {
    'id': id,
    'world': 'animals',
    'level': level,
    'game': 'sound_match',
    'ageBands': bands,
    'skills': ['skill.$level'],
    'params': {'rounds': 5},
    'pillars': {'active': 2, 'engaged': 2, 'meaningful': 2, 'social': 2},
    'offscreen': 'offscreen.walk_like_penguin',
  };
  final files = {
    'assets/content/worlds/animals.json': jsonEncode({
      'id': 'animals',
      'order': 1,
      'titleKey': 'worldAnimals',
      'icon': 'animals',
      'ageBands': ['2-3', '4-5', '6-7'],
    }),
    for (final (i, g) in [
      game('a.l1.one', 1),
      game('a.l1.two', 1),
      game('a.l1.three', 1),
      game('a.l1.toddlers', 1, bands: ['2-3']),
      game('a.l2.one', 2),
    ].indexed)
      'assets/content/games/g$i.json': jsonEncode(g),
  };
  return ContentLibrary.fromFiles(files, schema);
}

void main() {
  test('episodes pick the games for the child\'s age band', () {
    final level = library().world('animals').levels.first;
    expect(EpisodeScreen.gamesFor(level, AgeBand.preschool).map((g) => g.id), ['a.l1.one', 'a.l1.three', 'a.l1.two']);
    expect(EpisodeScreen.gamesFor(level, AgeBand.toddler).map((g) => g.id), ['a.l1.toddlers']);
  });

  testWidgets('a full episode: intro → games → companion → off-screen → wind-down', (tester) async {
    setScreen(tester, tablet);
    final lib = library();
    final engine = StubEngine('sound_match', hints: 1);
    final deps = TestDeps(engines: {'sound_match': engine});
    final world = lib.world('animals');
    await tester.pumpWidget(
      testApp(
        deps: deps,
        content: lib,
        child: EpisodeScreen(world: world, level: world.levels.first, content: lib),
      ),
    );
    await tester.pump();
    expect(deps.audio.played, contains('audio/en/episodeIntro.ogg'));

    await tester.tap(find.byKey(const Key('episode.start')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('stub.finish')));
      await tester.pumpAndSettle();
    }
    expect(engine.played, hasLength(3));

    // Companion moment.
    await tester.tap(find.byKey(const Key('companion.clap')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Off-screen challenge.
    expect(deps.audio.played, contains('audio/en/offscreenWalkLikePenguin.ogg'));
    await tester.tap(find.byKey(const Key('offscreen.done')));
    await tester.pumpAndSettle();

    // Wind-down: 3 hints in total → 1 star; saved; home is the only way on.
    expect(find.byKey(const Key('winddown.stars.1')), findsOneWidget);
    expect(deps.progress.data, {'animals.l1': 1});
    expect(deps.mastery.data['skill.1']?.attempts, 15);
    expect(find.byKey(const Key('winddown.home')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('level 2 opens only after level 1 is completed and mastered', (tester) async {
    final lib = library();
    final deps = TestDeps();
    late WidgetRef ref;
    await tester.pumpWidget(
      testApp(
        deps: deps,
        content: lib,
        child: Consumer(
          builder: (context, r, _) {
            ref = r;
            return const SizedBox();
          },
        ),
      ),
    );
    Future<Map<int, LevelStatus>> status() async {
      ref.invalidate(levelStatusProvider('animals'));
      return (await tester.runAsync(() => ref.read(levelStatusProvider('animals').future)))!;
    }

    var s = await status();
    expect(s[1]!.unlocked, isTrue);
    expect(s[2]!.unlocked, isFalse);

    // Completed, but every round needed a hint: not yet mastered.
    final tracker = ref.read(masteryTrackerProvider);
    await deps.progress.complete('animals.l1', 1);
    for (var i = 0; i < 5; i++) {
      await tracker.record('skill.1', correct: true, hintsUsed: 1);
    }
    s = await status();
    expect(s[2]!.unlocked, isFalse);
    expect(s[1]!.stars, 1);

    // 20 of 25 rounds without help = 80% independent.
    for (var i = 0; i < 20; i++) {
      await tracker.record('skill.1', correct: true, hintsUsed: 0);
    }
    s = await status();
    expect(s[2]!.unlocked, isTrue);
  });

  testWidgets('a locked level is faded and Pip explains, never a padlock', (tester) async {
    setScreen(tester, tablet);
    final lib = library();
    final deps = TestDeps();
    await tester.pumpWidget(
      testApp(
        deps: deps,
        content: lib,
        child: WorldScreen(world: lib.world('animals')),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    expect(find.byIcon(Icons.lock), findsNothing);
    await tester.tap(find.byKey(const Key('level.2')));
    await tester.pump();
    expect(deps.audio.played.last, 'audio/en/levelNotYet.ogg');
    expect(find.byType(EpisodeScreen), findsNothing);
  });
}
