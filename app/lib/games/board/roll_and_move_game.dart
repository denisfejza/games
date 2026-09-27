import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/game_card.dart';
import '../common/mini_game.dart';
import '../common/pools.dart';
import 'board_common.dart';

/// `roll_and_move` — Jungle Race (PLAN 4.1): roll the big die, tap your animal
/// once per dot to hop (counting aloud), climb vines, slide down slides (both
/// fun), answer tiny questions on ❓ squares. Nobody loses.
///
/// Params: `squares` (default 20), `dice` sides (3 or 6, default 6),
/// `vines` / `slides` as `{"from": to}` maps, `questions` (square list),
/// `items` for the questions (animals with sounds), `players` (1 = with Pip, 2 = friends).
class RollAndMoveEngine implements GameEngine {
  const RollAndMoveEngine();

  @override
  String get type => 'roll_and_move';

  @override
  List<String> validate(GameDef def, ContentLibrary content) {
    final squares = (def.params['squares'] as int?) ?? 20;
    Map<int, int> jumps(String k) => {
      for (final e in (def.params[k] as Map<String, dynamic>? ?? const {}).entries) int.parse(e.key): e.value as int,
    };
    return [
      for (final e in {...jumps('vines'), ...jumps('slides')}.entries)
        if (e.key <= 0 || e.key >= squares - 1 || e.value < 0 || e.value >= squares - 1)
          '${def.id}: jump ${e.key}→${e.value} is off the board',
      ...unknownItems(content, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
    ];
  }

  @override
  Widget build(GameContext context) => BoardGameScreen(context: context, create: RollAndMoveGame.new);
}

class RollAndMoveGame extends BoardGame {
  RollAndMoveGame(super.host, super.mode);

  late final Map<String, dynamic> _p = host.rounds.params;
  late final int squares = (_p['squares'] as int?) ?? 20;
  late final Map<int, int> vines = _jumps('vines', const {3: 9, 8: 14});
  late final Map<int, int> slides = _jumps('slides', const {12: 5, 17: 10});
  late final Set<int> questions = {
    ...((_p['questions'] as List<dynamic>?)?.cast<int>() ?? const [6, 15]),
  };
  late final List<VocabItem> questionItems = [
    for (final v in resolveItems(host.context.content, _p['items'] ?? 'tag:animal'))
      if (v.soundKey != null) v,
  ];

  Map<int, int> _jumps(String k, Map<int, int> fallback) => _p[k] == null
      ? fallback
      : {for (final e in (_p[k] as Map<String, dynamic>).entries) int.parse(e.key): e.value as int};

  final List<RaceSquare> board = [];
  final List<RaceToken> tokens = [];
  late final DieComponent die;
  final List<int> positions = [];
  int hopsLeft = 0;
  int hopped = 0;
  int errors = 0;
  RaceQuestion? question;

  @override
  Future<void> startRound() async {
    for (var i = 0; i < squares; i++) {
      board.add(
        RaceSquare(
          i,
          vine: vines.containsKey(i),
          slide: slides.containsKey(i),
          question: questions.contains(i),
          last: i == squares - 1,
        ),
      );
    }
    for (var p = 0; p < turns.players.length; p++) {
      positions.add(0);
      tokens.add(RaceToken(turns.players[p], p, onTap: _tokenTapped));
    }
    die = DieComponent(sides: ((_p['dice'] as int?) ?? 6).clamp(3, 6), onRolled: _rolled, random: host.random);
    await addAll([...board, ...tokens, die]);
    layout(size);
    await host.prompt(const ['boardRoll']);
    await announceTurn();
  }

  @override
  void layout(Vector2 size) {
    if (board.isEmpty) return;
    const cols = 5;
    final rows = (squares / cols).ceil();
    final boardW = size.x * 0.72;
    final cell = min(boardW / cols, size.y / rows) * 0.96;
    final x0 = (size.x * 0.76 - cell * cols) / 2;
    final y0 = (size.y - cell * rows) / 2;
    for (final s in board) {
      final row = s.index ~/ cols;
      final col = row.isEven ? s.index % cols : cols - 1 - s.index % cols;
      s
        ..size = Vector2.all(cell * 0.92)
        ..position = Vector2(x0 + col * cell + cell / 2, y0 + (rows - 1 - row) * cell + cell / 2);
    }
    for (final t in tokens) {
      t
        ..size = Vector2.all(cell * 0.5)
        ..position = _spot(positions[t.player], t.player);
    }
    die
      ..size = Vector2.all(min(size.x * 0.18, 150))
      ..position = Vector2(size.x * 0.88, size.y / 2);
    question?.layout(size);
  }

  Vector2 _spot(int square, int player) =>
      board[square].position + Vector2(player == 0 ? -1 : 1, 0) * board[square].size.x * 0.2;

  @override
  Future<void> announceTurn() async {
    die.enabled = !turns.pipsTurn;
    await super.announceTurn();
  }

  @override
  Future<void> playPipTurn() async {
    await die.roll();
  }

  void _rolled(int n) {
    hopsLeft = n;
    hopped = 0;
    host.audio.say(numberKey(n), interrupt: true);
    if (turns.pipsTurn) {
      _pipHops();
    } else {
      tokens[turns.index].hint();
      host.audio.say('boardHop');
    }
  }

  Future<void> _pipHops() async {
    while (hopsLeft > 0 && !ended) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await _hop(turns.index);
    }
  }

  void _tokenTapped(RaceToken t) {
    if (ended || turns.pipsTurn || hopsLeft == 0 || question != null) return;
    // Only your own animal hops; tapping the other one is simply ignored.
    if (t.player != turns.index) return;
    _hop(t.player);
  }

  Future<void> _hop(int player) async {
    if (hopsLeft == 0) return;
    hopsLeft--;
    hopped++;
    positions[player] = min(squares - 1, positions[player] + 1);
    tokens[player].clearHint();
    tokens[player].moveTo(_spot(positions[player], player), reduced: host.reducedMotion);
    host.audio.say(numberKey(hopped), interrupt: true);
    if (positions[player] == squares - 1) hopsLeft = 0;
    if (hopsLeft == 0) await _landed(player);
  }

  Future<void> _landed(int player) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final at = positions[player];
    if (at == squares - 1) {
      host.correct();
      await host.audio.say('boardFinish', interrupt: true);
      await endGame(errors: errors);
      return;
    }
    final jump = vines[at] ?? slides[at];
    if (jump != null) {
      await host.audio.say(vines.containsKey(at) ? 'boardVineUp' : 'boardSlideDown', interrupt: true);
      positions[player] = jump;
      tokens[player].moveTo(_spot(jump, player), reduced: host.reducedMotion, slow: true);
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    if (questions.contains(positions[player]) && questionItems.length >= 2) {
      await _ask(player);
    }
    await nextTurn();
  }

  Future<void> _ask(int player) async {
    final target = questionItems[host.random.nextInt(questionItems.length)];
    final other = pick(host.random, questionItems, 1, exclude: [target]).single;
    final q = question = RaceQuestion(this, target, other);
    await add(q);
    q.layout(size);
    await host.audio.sayAll(['boardQuestion', 'gameWhoSays', target.soundKey!], interrupt: true);
    if (turns.pipsTurn) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      q.answer(q.cards.firstWhere((c) => c.value == true));
    }
    await q.done;
    question = null;
  }
}

class RaceSquare extends PositionComponent {
  RaceSquare(this.index, {required this.vine, required this.slide, required this.question, required this.last})
    : super(anchor: Anchor.center);

  final int index;
  final bool vine;
  final bool slide;
  final bool question;
  final bool last;

  @override
  void render(Canvas canvas) {
    final r = size.toRect();
    final base = last ? const Color(0xFFFFC928) : (index.isEven ? const Color(0xFFB6F2A0) : const Color(0xFF8FE07A));
    canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(size.x * 0.2)), Paint()..color = base);
    String? mark;
    Color markColor = const Color(0xFF3B2C4A);
    if (vine) {
      mark = String.fromCharCode(Icons.north_rounded.codePoint);
      markColor = const Color(0xFF2E7D32);
    } else if (slide) {
      mark = String.fromCharCode(Icons.south_rounded.codePoint);
      markColor = const Color(0xFF1565C0);
    } else if (question) {
      mark = '?';
    } else if (last) {
      mark = String.fromCharCode(Icons.star_rounded.codePoint);
      markColor = Colors.white;
    }
    if (mark != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: mark,
          style: TextStyle(
            fontFamily: mark == '?' ? 'Nunito' : Icons.north_rounded.fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: size.x * 0.5,
            color: markColor.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, r.center - Offset(tp.width / 2, tp.height / 2));
    }
  }
}

class RaceToken extends GameCard {
  RaceToken(this.who, this.player, {required void Function(RaceToken) onTap})
    : super(face: PictureFace(EmojiPicture(who.token)), size: Vector2.all(60), onTap: (c) => onTap(c as RaceToken));

  final BoardPlayer who;
  final int player;

  void moveTo(Vector2 to, {required bool reduced, bool slow = false}) {
    if (reduced) {
      position = to;
      return;
    }
    add(MoveToEffect(to, EffectController(duration: slow ? 0.5 : 0.2)));
  }
}

/// "Who makes this sound?" with two pictures, over the board.
class RaceQuestion extends PositionComponent with TapCallbacks {
  RaceQuestion(this.game, VocabItem target, VocabItem other)
    : cards = [
        GameCard(face: PictureFace(target.picture), size: Vector2.all(100), value: true),
        GameCard(face: PictureFace(other.picture), size: Vector2.all(100), value: false),
      ]..shuffle(game.host.random);

  final RollAndMoveGame game;
  final List<GameCard> cards;
  final _done = <void Function()>[];
  bool _answered = false;

  Future<void> get done {
    if (_answered) return Future.value();
    final c = Completer<void>();
    _done.add(c.complete);
    return c.future;
  }

  @override
  Future<void> onLoad() async {
    for (final c in cards) {
      c.onTap = answer;
    }
    await addAll(cards);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  void layout(Vector2 size) {
    this.size = size;
    for (var i = 0; i < cards.length; i++) {
      cards[i]
        ..size = Vector2.all(min(size.y * 0.4, 180))
        ..position = Vector2(size.x * (i == 0 ? 0.3 : 0.62), size.y / 2);
    }
  }

  @override
  void render(Canvas canvas) => canvas.drawRect(size.toRect(), Paint()..color = const Color(0x88000000));

  void answer(GameCard card) {
    if (_answered) return;
    if (card.value == true) {
      _answered = true;
      card
        ..done = true
        ..pop();
      game.host.correct();
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        removeFromParent();
        for (final d in _done) {
          d();
        }
      });
    } else {
      card.wiggle();
      game.errors++;
      game.host.audio.effect(game.tapEffect);
      if (game.host.tryAgain()) cards.firstWhere((c) => c.value == true).hint();
    }
  }
}
