import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/common/card_face.dart';
import 'package:pips_world/games/common/game_card.dart';
import 'package:pips_world/games/pairs_memory/pairs_memory_config.dart';
import 'package:pips_world/games/pairs_memory/pairs_memory_game.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  List<MemoryCardSpec> deal(Map<String, dynamic> p, {String locale = 'en'}) =>
      dealMemory(PairsMemoryConfig.parse(p, lib), Random(1), text: stringsFor(locale), locale: locale);

  test('every pair appears exactly twice', () {
    for (final pairing in PairsMemoryConfig.pairings) {
      final cards = deal({
        'pairs': 4,
        'pairing': pairing,
        'items': 'tag:animal',
        'numbers': [1, 9],
      });
      expect(cards, hasLength(8), reason: pairing);
      final counts = <int, int>{};
      for (final c in cards) {
        counts[c.pair] = (counts[c.pair] ?? 0) + 1;
      }
      expect(counts.values.every((n) => n == 2), isTrue, reason: pairing);
    }
  });

  test('picture/sound pairs have one speaker card', () {
    final cards = deal({'pairs': 3, 'pairing': 'picture_sound', 'items': 'tag:animal'});
    expect(cards.whereType<MemoryCardSpec>().where((c) => c.face is SoundFace), hasLength(3));
  });

  test('letter/picture pairs match the first letter in Albanian', () {
    final cards = deal({
      'pairs': 3,
      'pairing': 'letter_picture',
      'items': ['sheep', 'goat', 'cat', 'dog', 'rain'],
    }, locale: 'sq');
    for (final letter in cards.where((c) => c.face is TextFace)) {
      final picture = cards.firstWhere((c) => c.pair == letter.pair && c.face is PictureFace);
      final name = stringsFor('sq')(picture.sayKey!)!.toLowerCase();
      expect(name.startsWith((letter.face as TextFace).text), isTrue, reason: name);
    }
  });

  Future<void> playPair(WidgetTester tester, PairsMemoryGame game, {bool mismatchFirst = false}) async {
    final left = game.cards.where((c) => !c.done).toList();
    int pair(GameCard c) => (c.value! as MemoryCardSpec).pair;
    final a = left.first;
    if (mismatchFirst) {
      final other = left.firstWhere((c) => pair(c) != pair(a));
      await tapGame(tester, a.position);
      await tapGame(tester, other.position);
      await settle(tester, seconds: 3);
    }
    final b = left.firstWhere((c) => c != a && pair(c) == pair(a));
    await tapGame(tester, a.position);
    await tapGame(tester, b.position);
    await settle(tester, seconds: 1);
  }

  testWidgets('find every pair; a mismatch turns cards back', (tester) async {
    final def = gameDef('pairs_memory', {'pairs': 3});
    final (game, results, deps) = await pumpEngine<PairsMemoryGame>(tester, const PairsMemoryEngine(), def, lib);
    expect(game.cards, hasLength(6));
    expect(game.cards.every((c) => !c.faceUp), isTrue);
    await playPair(tester, game, mismatchFirst: true);
    expect(game.cards.where((c) => c.done), hasLength(2));
    expect(game.cards.where((c) => c.faceUp && !c.done), isEmpty, reason: 'mismatched cards turned back');
    await playPair(tester, game);
    await playPair(tester, game);
    await settle(tester);
    expect(results.single.rounds, 3);
    expect(results.single.hints, 0, reason: 'hints only after 3 mismatches');
    expect(deps.audio.played, contains('audio/en/praisePair.ogg'));
  });

  testWidgets('two players: a mismatch passes the turn, a match keeps it', (tester) async {
    final def = gameDef('pairs_memory', {'pairs': 3, 'players': 2});
    final (game, _, _) = await pumpEngine<PairsMemoryGame>(tester, const PairsMemoryEngine(), def, lib);
    expect(game.player, 0);
    await playPair(tester, game, mismatchFirst: true);
    expect(game.player, 1);
    expect(game.found, [0, 1]);
    await playPair(tester, game);
    expect(game.player, 1);
    await settle(tester);
  });

  testWidgets('golden', (tester) async {
    final (game, _, _) = await pumpEngine<PairsMemoryGame>(
      tester,
      const PairsMemoryEngine(),
      gameDef('pairs_memory', {'pairs': 4, 'players': 2}),
      lib,
    );
    await tapGame(tester, game.cards.first.position);
    await expectGolden(tester, 'pairs_memory');
  });
}
