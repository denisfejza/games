import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/ui/big_button.dart';
import '../../app/ui/outlined_text.dart';
import '../../app/ui/tokens.dart';
import '../../companion/pip_view.dart';
import '../../content/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/card_face.dart';
import '../common/game_host.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';

/// Board Games world (PLAN phase 4): pass-and-play or solo with a gentle Pip.
/// No timers, turns are narrated, nobody loses, everyone is celebrated.
enum BoardMode { twoPlayers, withPip }

class BoardPlayer {
  const BoardPlayer(this.token, this.turnKey, {this.isPip = false, this.color = const Color(0xFFFF8C1A)});

  /// Placeholder token art. TODO(asset): illustrated tokens.
  final String token;
  final String turnKey;
  final bool isPip;
  final Color color;
}

const rabbit = BoardPlayer('🐰', 'turnRabbit', color: Color(0xFFFF8C1A));
const turtle = BoardPlayer('🐢', 'turnTurtle', color: Color(0xFF1FB5E3));
const pipPlayer = BoardPlayer('🦊', 'turnPip', isPip: true, color: Color(0xFFE8322B));

List<BoardPlayer> playersFor(BoardMode mode) =>
    mode == BoardMode.twoPlayers ? const [rabbit, turtle] : const [rabbit, pipPlayer];

/// Whose turn it is. Pip's turns play themselves after a short pause.
class Turns {
  Turns(this.players);

  final List<BoardPlayer> players;
  int index = 0;

  BoardPlayer get current => players[index];
  bool get pipsTurn => current.isPip;

  void next() => index = (index + 1) % players.length;
}

/// Base for board games: [turns], narrated turn changes, and a shared ending.
abstract class BoardGame extends PipGame {
  BoardGame(super.host, this.mode) : turns = Turns(playersFor(mode));

  final BoardMode mode;
  final Turns turns;
  bool _ended = false;

  /// Moves to the next player and says whose turn it is; runs Pip's turn.
  Future<void> nextTurn() async {
    turns.next();
    await announceTurn();
  }

  Future<void> announceTurn() async {
    await host.audio.say(turns.current.turnKey, interrupt: true);
    if (turns.pipsTurn && !_ended) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      await playPipTurn();
    }
  }

  /// Pip plays gently: he doesn't always pick the best move.
  Future<void> playPipTurn();

  /// Everyone is celebrated, whoever got there first (no lose state).
  Future<void> endGame({int errors = 0}) async {
    if (_ended) return;
    _ended = true;
    locked = true;
    for (var i = 0; i < errors; i++) {
      host.rounds.wrong();
    }
    await host.audio.say('boardEveryoneWins', interrupt: true);
    await host.roundSolved();
    await host.finish();
  }

  bool get ended => _ended;
}

/// Asks "two friends or with Pip?" unless the level fixed it (`players`: 1 = with Pip, 2 = friends).
class BoardGameScreen extends ConsumerStatefulWidget {
  const BoardGameScreen({super.key, required this.context, required this.create});

  final GameContext context;
  final BoardGame Function(GameHost host, BoardMode mode) create;

  @override
  ConsumerState<BoardGameScreen> createState() => _BoardGameScreenState();
}

class _BoardGameScreenState extends ConsumerState<BoardGameScreen> {
  BoardMode? _mode;

  @override
  void initState() {
    super.initState();
    _mode = switch (widget.context.def.params['players']) {
      1 => BoardMode.withPip,
      2 => BoardMode.twoPlayers,
      _ => null,
    };
    if (_mode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(audioServiceProvider).say('boardChoosePlayers'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = _mode;
    // Board games are one round: the whole game.
    final ctx = GameContext(
      def: GameDef.fromJsonWithParams(widget.context.def, {...widget.context.def.params, 'rounds': 1, 'hintAfter': 0}),
      content: widget.context.content,
      band: widget.context.band,
      locale: widget.context.locale,
      random: widget.context.random,
      text: widget.context.text,
      onFinished: widget.context.onFinished,
    );
    if (mode != null) return GameScreen(context: ctx, create: (host) => widget.create(host, mode));
    final l = AppLocalizations.of(context);
    final tokens = AgeBandTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFF8C1A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedText(l.boardChoosePlayers, fontSize: 36),
              const SizedBox(height: 32),
              Wrap(
                spacing: 40,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  BigButton(
                    key: const Key('board.twoFriends'),
                    icon: Icons.people_alt_rounded,
                    size: 150,
                    speakKey: 'boardTwoFriends',
                    label: l.boardTwoFriends,
                    outlinedLabel: true,
                    color: tokens.secondary,
                    onPressed: () => setState(() => _mode = BoardMode.twoPlayers),
                  ),
                  BigButton(
                    key: const Key('board.withPip'),
                    art: (s) => SizedBox(
                      height: s * 0.8,
                      child: const FittedBox(child: PipView(width: 100, interactive: false)),
                    ),
                    size: 150,
                    speakKey: 'boardWithPip',
                    label: l.boardWithPip,
                    outlinedLabel: true,
                    color: tokens.success,
                    onPressed: () => setState(() => _mode = BoardMode.withPip),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A big die. Tap to roll; it tumbles briefly (not a timer), then lands.
class DieComponent extends PositionComponent with TapCallbacks, HasGameReference<PipGame> {
  DieComponent({required this.sides, required this.onRolled, required this.random}) : super(anchor: Anchor.center);

  /// 3 (dots 1–3, for the youngest) or 6.
  final int sides;
  final void Function(int value) onRolled;
  final Random random;
  int value = 1;
  bool enabled = true;
  bool _rolling = false;

  @override
  void render(Canvas canvas) {
    final r = size.toRect();
    final rr = RRect.fromRectAndRadius(r, Radius.circular(size.x * 0.2));
    canvas.drawRRect(rr.shift(const Offset(0, 6)), Paint()..color = const Color(0x44000000));
    canvas.drawRRect(rr, Paint()..color = enabled ? Colors.white : const Color(0xFFE0E0E0));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = enabled ? const Color(0xFFFFC928) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = enabled ? 6 : 3,
    );
    DotsFace(value, color: const Color(0xFFE8322B)).paint(canvas, r.deflate(size.x * 0.04));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!enabled || _rolling || !game.acceptTap()) return;
    roll();
  }

  Future<void> roll() async {
    if (_rolling) return;
    _rolling = true;
    enabled = false;
    if (!game.host.reducedMotion) {
      add(RotateEffect.by(pi * 2, EffectController(duration: 0.5)));
      for (var i = 0; i < 5; i++) {
        value = 1 + random.nextInt(sides);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    value = 1 + random.nextInt(sides);
    _rolling = false;
    onRolled(value);
  }
}
