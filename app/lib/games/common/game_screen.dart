import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/ui/big_button.dart';
import '../../app/ui/caption_bar.dart';
import '../../app/ui/motion.dart';
import '../../app/ui/patterns.dart';
import '../../app/ui/tokens.dart';
import '../../companion/pip_view.dart';
import '../../worlds/world_style.dart';
import 'game_host.dart';
import 'mini_game.dart';
import 'round_controller.dart';

/// Frame for every mini-game: world-coloured background, the Flame game,
/// home and "hear again" buttons, progress dots, Pip and captions.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.context, required this.create, this.onExit});

  final GameContext context;

  /// Builds the engine's Flame game once.
  final FlameGame Function(GameHost host) create;

  /// Home button. Defaults to closing the screen.
  final VoidCallback? onExit;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final RoundController _rounds = RoundController(
    def: widget.context.def,
    mastery: ref.read(masteryTrackerProvider),
  );
  late final GameHost _host = GameHost(
    context: widget.context,
    rounds: _rounds,
    audio: ref.read(audioServiceProvider),
    pip: ref.read(pipControllerProvider),
    reducedMotion: reduceMotion(context, ref),
    onProgress: () {
      if (mounted) setState(() {});
    },
    onDone: widget.context.onFinished,
  );
  late final FlameGame _game = widget.create(_host);

  @override
  Widget build(BuildContext context) {
    final tokens = AgeBandTheme.of(context);
    final world = widget.context.content.worlds.where((w) => w.id == widget.context.def.world).firstOrNull;
    final style = WorldStyle.of(world?.icon ?? '');
    return Scaffold(
      body: PatternBackground(
        color: style.color,
        pattern: style.pattern,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    BigButton(
                      key: const Key('game.home'),
                      icon: Icons.home_rounded,
                      color: tokens.secondary,
                      onPressed: widget.onExit ?? () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: _Progress(done: _rounds.round, total: _rounds.totalRounds),
                    ),
                    BigButton(
                      key: const Key('game.hearAgain'),
                      icon: Icons.hearing,
                      color: tokens.secondary,
                      onPressed: _host.repeatPrompt,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRect(child: GameWidget(game: _game)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PipView(width: 76, interactive: false),
                    Expanded(child: Center(child: CaptionBar())),
                    SizedBox(width: 76),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One dot per round; filled dots are done (shape + fill, not colour alone).
class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < total; i++)
        Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            i < done ? Icons.star_rounded : Icons.circle_outlined,
            size: i < done ? 30 : 22,
            color: Colors.white,
            shadows: const [Shadow(color: Color(0x55000000), offset: Offset(0, 2))],
          ),
        ),
    ],
  );
}
