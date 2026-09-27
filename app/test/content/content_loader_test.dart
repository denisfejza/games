import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/strings.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/content_schema.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/l10n/app_localizations_en.dart';
import 'package:pips_world/l10n/app_localizations_sq.dart';

import '../helpers.dart';

final schema = ContentSchema(jsonDecode(File('assets/content/schema.json').readAsStringSync()) as Map<String, dynamic>);

const world = {
  'id': 'animals',
  'order': 1,
  'titleKey': 'worldAnimals',
  'icon': 'animals',
  'ageBands': ['2-3'],
};

Map<String, dynamic> game({String id = 'animals.farm.l1.moo', int level = 1, Map<String, dynamic> extra = const {}}) =>
    {
      'id': id,
      'world': 'animals',
      'level': level,
      'game': 'sound_match',
      'ageBands': ['2-3', '4-5'],
      'skills': ['vocab.animals.farm'],
      'params': {'choices': 2},
      'pillars': {'active': 2, 'engaged': 3, 'meaningful': 2, 'social': 2},
      'offscreen': 'offscreen.walk_like_penguin',
      ...extra,
    };

Map<String, String> files(Map<String, Object> byPath) => {
  for (final e in byPath.entries) 'assets/content/${e.key}': jsonEncode(e.value),
};

void main() {
  group('schema', () {
    test('accepts the CLAUDE.md example', () {
      final json = jsonDecode(File('assets/content/games/animals/farm_l1_who_says_moo.json').readAsStringSync());
      expect(schema.validate(ContentKind.game, json), isEmpty);
    });

    final bad = <String, Map<String, dynamic>>{
      'a pillar below 2': game(
        extra: {
          'pillars': {'active': 1, 'engaged': 3, 'meaningful': 2, 'social': 2},
        },
      ),
      'an unknown game type': game(extra: {'game': 'slot_machine'}),
      'an unknown age band': game(
        extra: {
          'ageBands': ['8-9'],
        },
      ),
      'no off-screen challenge': game()..remove('offscreen'),
      'an unexpected field': game(extra: {'coins': 10}),
    };
    for (final MapEntry(key: why, value: json) in bad.entries) {
      test('rejects $why', () => expect(schema.validate(ContentKind.game, json), isNotEmpty));
    }
  });

  group('ContentLibrary', () {
    test('builds worlds → levels → games', () {
      final lib = ContentLibrary.fromFiles(
        files({
          'worlds/animals.json': world,
          'games/animals/a.json': game(id: 'animals.l2.a', level: 2),
          'games/animals/b.json': game(id: 'animals.l1.b'),
          'games/animals/c.json': game(id: 'animals.l1.c'),
        }),
        schema,
      );
      final animals = lib.world('animals');
      expect(animals.levels.map((l) => l.number), [1, 2]);
      expect(animals.levels.first.games.map((g) => g.id), ['animals.l1.b', 'animals.l1.c']);
      expect(animals.levels.first.skills, {'vocab.animals.farm'});
      expect(animals.levelsFor(AgeBand.school), isEmpty);
    });

    test('a new level is just a new JSON file', () {
      final base = files({'worlds/animals.json': world, 'games/animals/a.json': game()});
      final more = {
        ...base,
        ...files({'games/animals/new.json': game(id: 'animals.l9.new', level: 9)}),
      };
      expect(ContentLibrary.fromFiles(base, schema).world('animals').levels, hasLength(1));
      expect(ContentLibrary.fromFiles(more, schema).world('animals').levels.last.number, 9);
    });

    test('reports every bad file at once', () {
      final broken = {
        ...files({
          'worlds/animals.json': world,
          'games/animals/lost.json': game(id: 'x.lost', extra: {'world': 'space'}),
          'games/animals/cheap.json': game(
            extra: {
              'pillars': {'active': 0, 'engaged': 0, 'meaningful': 0, 'social': 0},
            },
          ),
        }),
        'assets/content/games/animals/typo.json': '{"id": ',
      };
      expect(
        () => ContentLibrary.fromFiles(broken, schema),
        throwsA(isA<ContentException>().having((e) => e.errors, 'errors', hasLength(greaterThanOrEqualTo(3)))),
      );
    });

    test('rejects duplicate ids', () {
      expect(
        () => ContentLibrary.fromFiles(
          files({'worlds/animals.json': world, 'games/a.json': game(), 'games/b.json': game()}),
          schema,
        ),
        throwsA(isA<ContentException>()),
      );
    });
  });

  group('bundled content', () {
    late ContentLibrary lib;
    setUpAll(() async => lib = await loadBundledContent());

    test('loads the six worlds in map order', () {
      expect(lib.worlds.map((w) => w.id), [
        'animals',
        'numbers',
        'letters',
        'shapes_colours',
        'board_games',
        'pips_house',
      ]);
      expect(lib.world('animals').levels.first.games.single.id, 'animals.farm.l1.who_says_moo');
    });

    test('every string key used by content exists in en and sq', () {
      final keys = {for (final w in lib.worlds) w.titleKey, for (final g in lib.allGames) g.offscreenKey};
      for (final l in [AppLocalizationsEn(), AppLocalizationsSq()]) {
        for (final k in keys) {
          expect(lookupString(l, k), isNotNull, reason: '$k in ${l.localeName}');
        }
      }
    });
  });

  test('arbKey camel-cases content keys', () {
    expect(arbKey('offscreen.walk_like_penguin'), 'offscreenWalkLikePenguin');
    expect(arbKey('worldAnimals'), 'worldAnimals');
  });
}
