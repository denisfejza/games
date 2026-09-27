import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/mini_game.dart';
import '../common/pools.dart';
import 'board_common.dart';

/// `bingo` — Picture Bingo (PLAN 4.3): Pip calls a picture; tap it on your
/// card. A full row gets a cheer; the game goes on until everyone has a row.
/// Params: `items` (default farm + pets), `size` (3 → 3×3), `players`.
class BingoEngine implements GameEngine {
  const BingoEngine();

  @override
  String get type => 'bingo';

  @override
  List<String> validate(GameDef def, ContentLibrary content) {
    final n = (def.params['size'] as int?) ?? 3;
    final items = resolveItems(content, def.params['items'] ?? 'tag:animal');
    return [
      ...unknownItems(content, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
      if (items.length < n * n + 2) '${def.id}: need at least ${n * n + 2} pictures',
    ];
  }

  @override
  Widget build(GameContext context) => BoardGameScreen(context: context, create: BingoGame.new);
}

class BingoGame extends BoardGame {
  BingoGame(super.host, super.mode);

  late final int n = ((host.rounds.params['size'] as int?) ?? 3).clamp(2, 4);
  late final List<VocabItem> pool = resolveItems(host.context.content, host.rounds.params['items'] ?? 'tag:animal');
  final List<List<VocabItem>> sheets = [];
  final List<List<GameCard>> cells = [];
  final List<GameCard> owners = [];
  final List<Set<int>> marked = [];
  final Set<int> rowDone = {};
  late List<VocabItem> _calls;
  VocabItem? called;
  int errors = 0;

  @override
  Future<void> startRound() async {
    for (var p = 0; p < turns.players.length; p++) {
      final sheet = pick(host.random, pool, n * n);
      sheets.add(sheet);
      marked.add({});
      cells.add([
        for (var i = 0; i < sheet.length; i++)
          GameCard(face: PictureFace(sheet[i].picture), size: Vector2.all(80), value: (p, i), onTap: _tapped),
      ]);
    }
    // Each card has its player's token on top, so everyone knows which is theirs.
    for (final player in turns.players) {
      owners.add(GameCard(face: PictureFace(EmojiPicture(player.token)), size: Vector2.all(64)));
    }
    // Only call pictures that are on someone's card, each once.
    _calls = {for (final s in sheets) ...s}.toList()..shuffle(host.random);
    await addAll([for (final c in cells) ...c, ...owners]);
    layout(size);
    await host.prompt(const ['bingoFind']);
    await _nextCall();
  }

  @override
  void layout(Vector2 size) {
    for (var p = 0; p < cells.length; p++) {
      final area = Vector2(size.x / cells.length, size.y);
      const top = 76.0;
      final g = gridLayout(n * n, Vector2(area.x * 0.94, area.y - top), cols: n, maxCard: 140, gap: 0.08);
      for (var i = 0; i < cells[p].length; i++) {
        cells[p][i]
          ..size = g.card
          ..position = g.centres[i] + Vector2(area.x * p + area.x * 0.03, top);
      }
      if (p < owners.length) {
        owners[p]
          ..size = Vector2.all(64)
          ..position = Vector2(area.x * (p + 0.5), 36);
      }
    }
  }

  bool _needed(int p) =>
      called != null && sheets[p].contains(called) && !marked[p].contains(sheets[p].indexOf(called!));

  Future<void> _nextCall() async {
    if (ended) return;
    if (_calls.isEmpty || rowDone.length == sheets.length) {
      await endGame(errors: errors);
      return;
    }
    called = _calls.removeLast();
    await host.audio.sayAll(['bingoFind', called!.nameKey], interrupt: true);
    // Pip marks his own card.
    for (var p = 0; p < turns.players.length; p++) {
      if (turns.players[p].isPip && _needed(p)) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        await _mark(p, sheets[p].indexOf(called!));
      }
    }
    if (!List.generate(sheets.length, _needed).contains(true)) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await _nextCall();
    }
  }

  void _tapped(GameCard c) {
    if (ended || locked) return;
    final (p, i) = c.value! as (int, int);
    if (turns.players[p].isPip) return;
    if (sheets[p][i] != called) {
      if (!marked[p].contains(i)) {
        c.wiggle();
        errors++;
        if (host.tryAgain() && _needed(p)) cells[p][sheets[p].indexOf(called!)].hint();
      }
      return;
    }
    _mark(p, i);
  }

  Future<void> _mark(int p, int i) async {
    if (marked[p].contains(i)) return;
    marked[p].add(i);
    cells[p][i]
      ..done = true
      ..clearHint()
      ..pop();
    host.correct();
    if (!rowDone.contains(p) && _hasRow(p)) {
      rowDone.add(p);
      await host.audio.say('bingoLine', interrupt: true);
    }
    if (!List.generate(sheets.length, _needed).contains(true)) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _nextCall();
    }
  }

  bool _hasRow(int p) {
    final m = marked[p];
    for (var r = 0; r < n; r++) {
      if (List.generate(n, (c) => r * n + c).every(m.contains)) return true;
      if (List.generate(n, (c) => c * n + r).every(m.contains)) return true;
    }
    return false;
  }

  @override
  Future<void> playPipTurn() async {}

  // Bingo has no turn order: everyone listens to the same call.
  @override
  Future<void> announceTurn() async {}
}
