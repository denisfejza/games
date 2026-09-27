import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/blend_tiles/blend_tiles_game.dart';
import 'package:pips_world/games/common/pools.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  test('Albanian words split into Albanian letters', () {
    expect(graphemes('mollë', 'sq'), ['m', 'o', 'll', 'ë']);
    expect(graphemes('rrush', 'sq'), ['rr', 'u', 'sh']);
    expect(graphemes('Xhaketë', 'sq'), ['xh', 'a', 'k', 'e', 't', 'ë']);
    expect(graphemes('dele', 'sq'), ['d', 'e', 'l', 'e']);
    expect(graphemes('shoe', 'en'), ['s', 'h', 'o', 'e'], reason: 'English phonics order is separate');
  });

  test('per-language word lists', () {
    final c = BlendTilesConfig({
      'words': {
        'en': ['cat', 'dog'],
        'sq': ['mouse', 'grapes'],
      },
    });
    expect(c.wordsFor('sq'), ['mouse', 'grapes']);
    expect(
      BlendTilesConfig.validate(
        gameDef('blend_tiles', {
          'words': ['cat', 'yeti'],
        }),
        lib,
      ),
      hasLength(2),
    );
  });

  testWidgets('build "mollë" from tiles; the picture appears', (tester) async {
    final def = gameDef('blend_tiles', {
      'words': {
        'sq': ['apple'],
      },
      'rounds': 1,
    }, world: 'letters');
    final (game, results, deps) = await pumpEngine<BlendTilesGame>(
      tester,
      const BlendTilesEngine(),
      def,
      lib,
      locale: 'sq',
    );
    expect(game.letters, ['m', 'o', 'll', 'ë']);
    // Wrong slot first.
    final ll = game.tiles.firstWhere((t) => game.letters[t.value! as int] == 'll');
    await dragGame(tester, ll.position, game.slots[0].position);
    expect(ll.done, isFalse);
    for (var i = 0; i < game.letters.length; i++) {
      final tile = game.tiles.firstWhere((t) => !t.done && game.letters[t.value! as int] == game.letters[i]);
      await dragGame(tester, tile.position, game.slots[i].position);
    }
    expect(deps.audio.played, contains('audio/sq/letterSqLl.ogg'));
    await settle(tester);
    expect(deps.audio.played, contains('audio/sq/vocabApple.ogg'));
    expect(results.single.rounds, 1);
  });

  testWidgets('a repeated letter fits either of its slots', (tester) async {
    final def = gameDef('blend_tiles', {
      'words': {
        'sq': ['sheep'],
      },
      'rounds': 1,
    }, world: 'letters');
    final (game, results, _) = await pumpEngine<BlendTilesGame>(
      tester,
      const BlendTilesEngine(),
      def,
      lib,
      locale: 'sq',
    );
    expect(game.letters, ['d', 'e', 'l', 'e']);
    // Put the "e" tile that belongs in slot 1 into slot 3 instead.
    final e1 = game.tiles.firstWhere((t) => t.value == 1);
    await dragGame(tester, e1.position, game.slots[3].position);
    expect(e1.done, isTrue);
    for (final i in [0, 1, 2]) {
      final tile = game.tiles.firstWhere((t) => !t.done && game.letters[t.value! as int] == game.letters[i]);
      await dragGame(tester, tile.position, game.slots[i].position);
    }
    await settle(tester);
    expect(results.single.firstTry, 1);
  });

  testWidgets('golden', (tester) async {
    await pumpEngine<BlendTilesGame>(
      tester,
      const BlendTilesEngine(),
      gameDef('blend_tiles', {
        'words': {
          'sq': ['grapes'],
        },
      }, world: 'letters'),
      lib,
      locale: 'sq',
    );
    await expectGolden(tester, 'blend_tiles');
  });
}
