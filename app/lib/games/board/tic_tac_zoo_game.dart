import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/mini_game.dart';
import 'board_common.dart';

/// `tic_tac_zoo` (PLAN 4.5): tic-tac-toe with animal tokens. Pip plays
/// imperfectly so children can win; a full board is a "good game" too.
/// Params: `boards` to play (default 2), `players`.
class TicTacZooEngine implements GameEngine {
  const TicTacZooEngine();

  @override
  String get type => 'tic_tac_zoo';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => const [];

  @override
  Widget build(GameContext context) => BoardGameScreen(context: context, create: TicTacZooGame.new);
}

const _lines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6], //
];

/// Index of the winning line owner (0/1), -1 if none yet.
int ticTacWinner(List<int?> cells) {
  for (final l in _lines) {
    final a = cells[l[0]];
    if (a != null && a == cells[l[1]] && a == cells[l[2]]) return a;
  }
  return -1;
}

/// Pip's gentle move: takes a win or blocks only sometimes, otherwise any free square.
int pipMove(List<int?> cells, int me, Random r, {double skill = 0.5}) {
  final free = [
    for (var i = 0; i < 9; i++)
      if (cells[i] == null) i,
  ];
  int? finishing(int who) {
    for (final i in free) {
      final trial = [...cells]..[i] = who;
      if (ticTacWinner(trial) == who) return i;
    }
    return null;
  }

  if (r.nextDouble() < skill) {
    final win = finishing(me);
    if (win != null) return win;
  }
  if (r.nextDouble() < skill) {
    final block = finishing(1 - me);
    if (block != null) return block;
  }
  return free[r.nextInt(free.length)];
}

class TicTacZooGame extends BoardGame {
  TicTacZooGame(super.host, super.mode);

  late final int boards = ((host.rounds.params['boards'] as int?) ?? 2).clamp(1, 5);
  final List<GameCard> cells = [];
  final List<int?> owner = List.filled(9, null);
  int played = 0;

  @override
  Future<void> startRound() async {
    for (var i = 0; i < 9; i++) {
      cells.add(GameCard(face: const BlankFace(), size: Vector2.all(100), value: i, onTap: _tapped));
    }
    await addAll(cells);
    layout(size);
    await host.prompt(const ['ticTacTurn']);
    await announceTurn();
  }

  @override
  void layout(Vector2 size) {
    final g = gridLayout(9, size, cols: 3, maxCard: 170, gap: 0.08);
    for (var i = 0; i < cells.length; i++) {
      cells[i]
        ..size = g.card
        ..position = g.centres[i];
    }
  }

  void _tapped(GameCard c) {
    if (ended || turns.pipsTurn || locked) return;
    _place(c.value! as int);
  }

  @override
  Future<void> playPipTurn() async => _place(pipMove(owner, turns.index, host.random));

  Future<void> _place(int i) async {
    if (owner[i] != null) {
      cells[i].wiggle();
      return;
    }
    owner[i] = turns.index;
    cells[i]
      ..face = PictureFace(EmojiPicture(turns.current.token))
      ..pop();
    final winner = ticTacWinner(owner);
    if (winner >= 0 || owner.every((o) => o != null)) {
      locked = true;
      if (winner >= 0) {
        for (final l in _lines) {
          if (l.every((k) => owner[k] == winner)) {
            for (final k in l) {
              cells[k].done = true;
            }
          }
        }
        host.correct();
      }
      await host.audio.say(winner >= 0 ? 'ticTacLine' : 'ticTacDraw', interrupt: true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      played++;
      if (played >= boards) {
        await endGame();
        return;
      }
      for (var k = 0; k < 9; k++) {
        owner[k] = null;
        cells[k]
          ..face = const BlankFace()
          ..done = false;
      }
      locked = false;
    }
    await nextTurn();
  }
}
