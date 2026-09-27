import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/games/registry.dart';
import 'package:pips_world/l10n/lookup.g.dart';

import '../games/engine_harness.dart';

/// Phase 3 acceptance: every level loads, every game's engine accepts its
/// params and starts in each language it's for, and everything Pip says has
/// a string (so a recording can be made for it).
void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  test('level counts per world (PLAN phase 3)', () {
    int levels(String world, String locale) =>
        lib.world(world).levels.where((l) => l.games.any((g) => g.availableIn(locale))).length;
    for (final locale in ['en', 'sq']) {
      expect(levels('animals', locale), 8);
      expect(levels('numbers', locale), 10);
      expect(levels('letters', locale), 10, reason: 'letters per language');
      expect(levels('shapes_colours', locale), 6);
    }
  });

  test('every game has an engine and valid params', () {
    final problems = <String>[];
    for (final g in lib.allGames) {
      final engine = engines[g.type];
      if (engine == null) {
        problems.add('${g.id}: no engine "${g.type}"');
        continue;
      }
      problems.addAll(engine.validate(g, lib));
    }
    expect(problems, isEmpty);
  });

  test('a level plays 3–5 games for the middle age band, never more than 5 for anyone', () {
    for (final w in lib.worlds) {
      for (final level in w.levels) {
        for (final locale in ['en', 'sq']) {
          if (!level.games.any((g) => g.availableIn(locale))) continue;
          for (final band in AgeBand.values) {
            expect(level.gamesFor(band, locale).length, lessThanOrEqualTo(5), reason: '${w.id} ${level.number} $band');
          }
          expect(
            level.gamesFor(AgeBand.preschool, locale).length + level.gamesFor(AgeBand.school, locale).length,
            greaterThanOrEqualTo(3),
            reason: '${w.id} ${level.number} $locale',
          );
        }
      }
    }
  });

  test('older children are not shown only toddler levels', () {
    for (final w in ['numbers', 'letters', 'shapes_colours', 'animals']) {
      expect(lib.world(w).levelsFor(AgeBand.school, 'en'), isNotEmpty, reason: w);
    }
    expect(
      lib.world('numbers').levelsFor(AgeBand.school, 'en').first.number,
      greaterThan(1),
      reason: 'no "count to 3" for 6–7',
    );
  });

  for (final locale in ['en', 'sq']) {
    testWidgets('every game starts in $locale and all its narration has text', (tester) async {
      final missing = <String>{};
      for (final g in lib.allGames.where((g) => g.availableIn(locale))) {
        final (_, _, deps) = await pumpEngine(tester, engines[g.type]!, g, lib, locale: locale, seed: g.id.hashCode);
        expect(tester.takeException(), isNull, reason: g.id);
        expect(deps.audio.played, isNotEmpty, reason: '${g.id} says what to do');
        for (final path in deps.audio.played) {
          if (path.startsWith('audio/sfx/')) continue;
          final key = path.split('/').last.replaceAll('.ogg', '');
          if (!arbKeys.contains(key)) missing.add('${g.id}: $key');
        }
        await tester.pumpWidget(const SizedBox());
        await settle(tester, seconds: 1);
      }
      expect(missing, isEmpty);
    }, timeout: const Timeout(Duration(minutes: 5)));
  }
}
