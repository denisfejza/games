import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/tap_count/tap_count_config.dart';
import 'package:pips_world/games/tap_count/tap_count_game.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  test('counts stay in range and vary', () {
    final rounds = CountRounds(Random(2));
    final c = TapCountConfig.parse({
      'numbers': [2, 5],
    }, lib);
    final counts = [for (var i = 0; i < 20; i++) rounds.next(c).count];
    expect(counts.every((n) => n >= 2 && n <= 5), isTrue);
    for (var i = 1; i < counts.length; i++) {
      expect(counts[i], isNot(counts[i - 1]), reason: 'no same count twice in a row');
    }
  });

  testWidgets('each tap counts aloud; tapping one twice is the mistake', (tester) async {
    final def = gameDef('tap_count', {
      'numbers': [3, 3],
      'rounds': 1,
    });
    final (game, results, deps) = await pumpEngine<TapCountGame>(tester, const TapCountEngine(), def, lib);
    await tapGame(tester, game.objects[0].position);
    expect(deps.audio.played.last, 'audio/en/num1.ogg');
    await tapGame(tester, game.objects[0].position);
    expect(game.objects[1].hinting, isTrue, reason: 'uncounted ones highlighted');
    await tapGame(tester, game.objects[1].position);
    await tapGame(tester, game.objects[2].position);
    expect(deps.audio.played, contains('audio/en/num3.ogg'));
    await settle(tester);
    expect(results.single.firstTry, 0);
    expect(results.single.hints, 1);
    expect(deps.audio.played, contains('audio/en/praiseCountedAll.ogg'));
  });

  testWidgets('golden', (tester) async {
    await pumpEngine<TapCountGame>(
      tester,
      const TapCountEngine(),
      gameDef('tap_count', {
        'numbers': [5, 5],
      }),
      lib,
    );
    await expectGolden(tester, 'tap_count');
  });
}
