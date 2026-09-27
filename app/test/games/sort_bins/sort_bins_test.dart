import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/sort_bins/sort_bins_game.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  const sizeBins = [
    {'value': 'big', 'item': 'elephant', 'say': 'binBig'},
    {'value': 'small', 'item': 'mouse', 'say': 'binSmall'},
  ];

  test('each item belongs in the bin it is assigned; every bin gets some', () {
    final c = SortBinsConfig.parse({'by': 'size', 'bins': sizeBins, 'perRound': 6}, lib);
    final r = nextSort(c, Random(3), text: stringsFor('en'), locale: 'en');
    expect(r.items, hasLength(6));
    for (var i = 0; i < r.items.length; i++) {
      expect(r.items[i].props['size'], sizeBins[r.values[i]]['value']);
    }
    expect(r.values.toSet(), {0, 1});
  });

  test('sort by first letter uses the language\'s alphabet', () {
    final c = SortBinsConfig.parse({
      'by': 'first_letter',
      'bins': [
        {'value': 'sh'},
        {'value': 's'},
      ],
      'items': ['rain', 'watermelon', 'snake', 'sun', 'strawberry', 'jacket'],
      'perRound': 4,
    }, lib);
    final r = nextSort(c, Random(1), text: stringsFor('sq'), locale: 'sq');
    for (var i = 0; i < r.items.length; i++) {
      final name = stringsFor('sq')(r.items[i].nameKey)!.toLowerCase();
      final letter = r.bins[r.values[i]]['value'] as String;
      expect(name.startsWith(letter), isTrue, reason: name);
      if (letter == 's') expect(name.startsWith('sh'), isFalse, reason: 'sh is its own letter');
    }
  });

  testWidgets('drag each item to its bin; a wrong bin sends it home', (tester) async {
    final def = gameDef('sort_bins', {'by': 'size', 'bins': sizeBins, 'perRound': 3, 'rounds': 1});
    final (game, results, _) = await pumpEngine<SortBinsGame>(tester, const SortBinsEngine(), def, lib);
    final r = game.round!;
    final first = game.items.first;
    final right = r.values[first.value! as int];
    await dragGame(tester, first.position, game.bins[1 - right].position);
    await settle(tester, seconds: 1);
    expect(first.done, isFalse);
    for (final item in game.items) {
      await dragGame(tester, item.position, game.bins[r.values[item.value! as int]].position);
    }
    await settle(tester);
    expect(results.single.rounds, 1);
    expect(results.single.firstTry, 0);
  });

  testWidgets('golden', (tester) async {
    await pumpEngine<SortBinsGame>(
      tester,
      const SortBinsEngine(),
      gameDef('sort_bins', {'by': 'size', 'bins': sizeBins, 'perRound': 5}),
      lib,
    );
    await expectGolden(tester, 'sort_bins');
  });
}
