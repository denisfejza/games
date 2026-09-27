import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/board/bingo_game.dart';
import 'package:pips_world/games/board/board_common.dart';
import 'package:pips_world/games/board/dominoes_game.dart';
import 'package:pips_world/games/board/feed_race_game.dart';
import 'package:pips_world/games/board/i_spy_game.dart';
import 'package:pips_world/games/board/jigsaw_game.dart';
import 'package:pips_world/games/board/roll_and_move_game.dart';
import 'package:pips_world/games/board/tic_tac_zoo_game.dart';
import 'package:pips_world/games/common/pools.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  group('rules', () {
    test('tic-tac-toe lines', () {
      expect(ticTacWinner([0, 0, 0, null, 1, 1, null, null, null]), 0);
      expect(ticTacWinner([1, 0, null, 1, 0, null, 1, null, null]), 1);
      expect(ticTacWinner([0, 1, 0, 1, 0, 1, 1, 0, 1]), -1);
    });

    test('Pip is beatable: he sometimes misses a block', () {
      // X (0) threatens 0-1-2; Pip (1) to move.
      final board = <int?>[0, 0, null, null, 1, null, null, null, null];
      final moves = [for (var s = 0; s < 200; s++) pipMove(board, 1, Random(s))];
      expect(moves.where((m) => m == 2).length, inInclusiveRange(20, 180), reason: 'blocks often, not always');
    });

    test('domino set has every pair once', () {
      expect(dominoSet(4, Random(1)), hasLength(10));
    });

    test('I Spy colour answers all have that colour; differences are two swaps', () {
      final pool = resolveItems(lib, ['tag:food', 'tag:object']);
      for (var s = 0; s < 10; s++) {
        final r = nextISpy('colour', pool, 9, Random(s));
        final colour = r.prompt.last.split('.').last;
        for (final a in r.answers) {
          expect(r.left[a].props['colour'], colour);
        }
        final d = nextISpy('difference', resolveItems(lib, 'tag:animal'), 6, Random(s));
        expect(d.answers, hasLength(2));
        for (var i = 0; i < 6; i++) {
          expect(d.left[i].id == d.right![i].id, !d.answers.contains(i));
        }
      }
    });

    test('jigsaw grids', () {
      expect(jigsawGrid(4), (2, 2));
      expect(jigsawGrid(12), (4, 3));
    });
  });

  testWidgets('choosing players: two friends are Rabbit and Turtle', (tester) async {
    final (game, _, deps) = await pumpEngine<TicTacZooGame>(
      tester,
      const TicTacZooEngine(),
      gameDef('tic_tac_zoo', {'boards': 1}, world: 'board_games'),
      lib,
      twoFriends: true,
    );
    expect(game.turns.players, [rabbit, turtle]);
    expect(deps.audio.played, contains('audio/en/turnRabbit.ogg'));
    await settle(tester);
  });

  testWidgets('two-player turn flow (PLAN 4 acceptance): turns alternate and are narrated', (tester) async {
    final def = gameDef('tic_tac_zoo', {'boards': 1}, world: 'board_games');
    final (game, results, deps) = await pumpEngine<TicTacZooGame>(
      tester,
      const TicTacZooEngine(),
      def,
      lib,
      twoFriends: true,
    );
    // Rabbit takes the top row while Turtle plays the middle row.
    for (final i in [0, 3, 1, 4, 2]) {
      final who = game.turns.index;
      await tapGame(tester, game.cells[i].position);
      await settle(tester, seconds: 1);
      if (!game.ended) expect(game.turns.index, 1 - who);
    }
    expect(game.owner.sublist(0, 3), [0, 0, 0]);
    await settle(tester, seconds: 4);
    expect(
      deps.audio.played,
      containsAllInOrder(['audio/en/turnRabbit.ogg', 'audio/en/turnTurtle.ogg', 'audio/en/turnRabbit.ogg']),
    );
    expect(deps.audio.played, contains('audio/en/ticTacLine.ogg'));
    expect(deps.audio.played, contains('audio/en/boardEveryoneWins.ogg'));
    expect(results, hasLength(1));
  });

  testWidgets('tic-tac-zoo with Pip: Pip takes his own turns', (tester) async {
    final (game, results, _) = await pumpEngine<TicTacZooGame>(
      tester,
      const TicTacZooEngine(),
      gameDef('tic_tac_zoo', {'boards': 1}, world: 'board_games'),
      lib,
    );
    for (var guard = 0; guard < 10 && results.isEmpty; guard++) {
      final free = [
        for (var i = 0; i < 9; i++)
          if (game.owner[i] == null) i,
      ];
      if (free.isEmpty) break;
      await tapGame(tester, game.cells[free.first].position);
      await settle(tester, seconds: 2);
    }
    await settle(tester, seconds: 4);
    expect(results, hasLength(1));
    expect(game.owner.whereType<int>().where((o) => o == 1), isNotEmpty, reason: 'Pip played');
  });

  testWidgets('Jungle Race: roll, hop by tapping your animal, reach the end', (tester) async {
    final def = gameDef('roll_and_move', {
      'dice': 6,
      'squares': 10,
      'vines': {'2': 5},
      'slides': {'7': 3},
      'questions': [4],
    }, world: 'board_games');
    final (game, results, deps) = await pumpEngine<RollAndMoveGame>(
      tester,
      const RollAndMoveEngine(),
      def,
      lib,
      seed: 5,
    );
    for (var guard = 0; guard < 60 && results.isEmpty; guard++) {
      final q = game.question;
      if (q != null) {
        await tapGame(tester, q.cards.firstWhere((c) => c.value == true).position);
        await settle(tester, seconds: 2);
        continue;
      }
      if (game.turns.pipsTurn) {
        await settle(tester, seconds: 2);
        continue;
      }
      if (game.hopsLeft > 0) {
        await tapGame(tester, game.tokens[game.turns.index].position);
        await settle(tester, seconds: 1);
      } else if (game.die.enabled) {
        await tapGame(tester, game.die.position);
        await settle(tester, seconds: 1);
      } else {
        await settle(tester, seconds: 1);
      }
    }
    await settle(tester, seconds: 4);
    expect(results, hasLength(1));
    expect(game.positions, contains(9));
    expect(deps.audio.played, contains('audio/en/num1.ogg'), reason: 'hops are counted aloud');
  });

  testWidgets('Feed the Animals: tap one berry per dot until every tummy is full', (tester) async {
    final def = gameDef('feed_race', {'dice': 3, 'goal': 4}, world: 'board_games');
    final (game, results, _) = await pumpEngine<FeedRaceGame>(tester, const FeedRaceEngine(), def, lib);
    for (var guard = 0; guard < 60 && results.isEmpty; guard++) {
      if (game.turns.pipsTurn) {
        await settle(tester, seconds: 2);
      } else if (game.counted < game.toFeed) {
        await tapGame(tester, game.berries.first.position);
        await settle(tester, seconds: 1);
      } else if (game.die.enabled) {
        await tapGame(tester, game.die.position);
        await settle(tester, seconds: 1);
      } else {
        await settle(tester, seconds: 1);
      }
    }
    await settle(tester, seconds: 4);
    expect(results, hasLength(1));
    expect(game.fed, everyElement(4));
  });

  testWidgets('Dominoes: play a matching tile or draw', (tester) async {
    final def = gameDef('dominoes', {'mode': 'picture', 'values': 4, 'hand': 3}, world: 'board_games');
    final (game, results, _) = await pumpEngine<DominoesGame>(tester, const DominoesEngine(), def, lib);
    for (var guard = 0; guard < 40 && results.isEmpty; guard++) {
      if (game.turns.pipsTurn || game.locked) {
        await settle(tester, seconds: 2);
        continue;
      }
      final playable = game.handTiles.where((t) => t.domino!.matches(game.leftEnd) || t.domino!.matches(game.rightEnd));
      await tapGame(tester, playable.isNotEmpty ? playable.first.position : game.pileButton.position);
      await settle(tester, seconds: 2);
    }
    await settle(tester, seconds: 4);
    expect(results, hasLength(1));
  });

  testWidgets('Bingo: mark each called picture; ends when everyone has a row', (tester) async {
    final def = gameDef('bingo', {'items': 'tag:animal', 'size': 3}, world: 'board_games');
    final (game, results, deps) = await pumpEngine<BingoGame>(tester, const BingoEngine(), def, lib);
    for (var guard = 0; guard < 60 && results.isEmpty; guard++) {
      final called = game.called;
      final i = called == null ? -1 : game.sheets[0].indexOf(called);
      if (i >= 0 && !game.marked[0].contains(i)) {
        await tapGame(tester, game.cells[0][i].position);
      }
      await settle(tester, seconds: 2);
    }
    await settle(tester, seconds: 4);
    expect(results, hasLength(1));
    expect(deps.audio.played, contains('audio/en/bingoLine.ogg'));
  });

  testWidgets('Jigsaw: drag each piece to its place', (tester) async {
    final def = gameDef('jigsaw', {
      'pieces': 4,
      'items': ['lion'],
      'rounds': 1,
    }, world: 'board_games');
    final (game, results, deps) = await pumpEngine<JigsawGame>(tester, const JigsawEngine(), def, lib);
    for (final p in [...game.pieces]) {
      await dragGame(tester, p.position, game.slot(p.index));
    }
    await settle(tester);
    expect(results, hasLength(1));
    expect(deps.audio.played, contains('audio/en/vocabLion.ogg'));
  });

  testWidgets('I Spy with Pip: turns alternate finding things', (tester) async {
    final def = gameDef('i_spy', {'mode': 'colour', 'rounds': 2}, world: 'board_games');
    final (game, results, _) = await pumpEngine<ISpyGame>(tester, const ISpyEngine(), def, lib);
    final r = game.round!;
    await tapGame(tester, game.left[r.answers.first].position);
    await settle(tester, seconds: 5);
    expect(results, hasLength(1), reason: 'Pip found the second one');
  });

  for (final (name, engine, params) in [
    ('roll_and_move', const RollAndMoveEngine(), <String, dynamic>{}),
    ('dominoes', const DominoesEngine(), <String, dynamic>{'mode': 'numeral_dots', 'values': 5}),
    ('bingo', const BingoEngine(), <String, dynamic>{}),
    (
      'jigsaw',
      const JigsawEngine(),
      <String, dynamic>{
        'pieces': 6,
        'items': ['elephant'],
      },
    ),
    ('i_spy', const ISpyEngine(), <String, dynamic>{'mode': 'difference'}),
    ('feed_race', const FeedRaceEngine(), <String, dynamic>{}),
  ]) {
    testWidgets('golden $name', (tester) async {
      await pumpEngine(tester, engine, gameDef(name, params, world: 'board_games'), lib, twoFriends: true);
      await expectGolden(tester, 'board_$name');
    });
  }

  testWidgets('golden: who is playing?', (tester) async {
    setScreenForTest(tester);
    await tester.pumpWidget(
      testAppFor(const TicTacZooEngine(), gameDef('tic_tac_zoo', const {}, world: 'board_games'), lib),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(find.byType(Scaffold).first, matchesGoldenFile('../../goldens/games/board_chooser.png'));
    await settle(tester);
  });
}
