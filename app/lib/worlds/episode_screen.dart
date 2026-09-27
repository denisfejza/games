import '../core/audio/audio_service.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/bedtime.dart';
import '../app/providers.dart';
import '../app/strings.dart';
import '../app/ui/big_button.dart';
import '../app/ui/caption_bar.dart';
import '../app/ui/outlined_text.dart';
import '../app/ui/patterns.dart';
import '../app/ui/tokens.dart';
import '../companion/pip_controller.dart';
import '../companion/pip_view.dart';
import '../content/content_loader.dart';
import '../content/models.dart';
import '../core/mastery/mastery.dart';
import '../core/progress/progress_store.dart';
import '../games/common/mini_game.dart';
import '../games/common/round_controller.dart';
import '../l10n/app_localizations.dart';
import 'level_status.dart';
import 'world_style.dart';

enum EpisodeStep { intro, game, companion, offscreen, windDown }

/// One level, start to finish: intro → 3–5 games → companion moment →
/// off-screen challenge → wind-down. Never autoplays into the next level.
class EpisodeScreen extends ConsumerStatefulWidget {
  const EpisodeScreen({super.key, required this.world, required this.level, required this.content, this.random});

  final World world;
  final Level level;
  final ContentLibrary content;
  final Random? random;

  /// Games for [band] in [locale], at most five.
  static List<GameDef> gamesFor(Level level, AgeBand band, [String locale = 'en']) {
    final games = level.gamesFor(band, locale);
    return (games.isEmpty
            ? [
                for (final g in level.games)
                  if (g.availableIn(locale)) g,
              ]
            : games)
        .take(5)
        .toList();
  }

  @override
  ConsumerState<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends ConsumerState<EpisodeScreen> {
  EpisodeStep _step = EpisodeStep.intro;
  int _game = 0;
  int _hints = 0;
  int? _stars;
  late final List<GameDef> _games = EpisodeScreen.gamesFor(
    widget.level,
    ref.read(ageBandProvider),
    ref.read(localeProvider).languageCode,
  );
  late final Setting<bool> _active = ref.read(episodeActiveProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _active.set(true);
    });
  }

  @override
  void dispose() {
    // After the frame: providers can't change while the tree is being torn down.
    Future.microtask(() => _active.set(false));
    super.dispose();
  }

  void _next() {
    // Out of play time: skip straight to the calm ending.
    if (ref.read(playTimerProvider).timeUp && _step != EpisodeStep.windDown) return _windDown();
    setState(() {
      switch (_step) {
        case EpisodeStep.intro:
          _step = _games.isEmpty ? EpisodeStep.companion : EpisodeStep.game;
        case EpisodeStep.game:
          _game++;
          if (_game >= _games.length) _step = EpisodeStep.companion;
        case EpisodeStep.companion:
          _step = EpisodeStep.offscreen;
        case EpisodeStep.offscreen:
          _windDown();
        case EpisodeStep.windDown:
          break;
      }
    });
  }

  void _windDown() {
    final stars = levelStars(hintsUsed: _hints);
    ref.read(progressStoreProvider).complete(levelKey(widget.world.id, widget.level.number), stars);
    ref.invalidate(levelStatusProvider(widget.world.id));
    setState(() {
      _stars = stars;
      _step = EpisodeStep.windDown;
    });
  }

  void _gameFinished(MiniGameResult r) {
    _hints += r.hints;
    _next();
  }

  String get _offscreenKey => (_games.isNotEmpty ? _games.last : widget.level.games.first).offscreenKey;

  @override
  Widget build(BuildContext context) {
    final style = WorldStyle.of(widget.world.icon);
    if (_step == EpisodeStep.game) {
      final def = _games[_game];
      final engine = ref.watch(gameRegistryProvider)[def.type];
      if (engine == null) {
        // Engine not built yet: skip it rather than block the child.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _gameFinished(const MiniGameResult(rounds: 0, firstTry: 0, hints: 0)),
        );
        return const SizedBox.shrink();
      }
      return KeyedSubtree(
        key: ValueKey('game.$_game.${def.id}'),
        child: engine.build(
          GameContext(
            def: def,
            content: widget.content,
            band: ref.read(ageBandProvider),
            locale: ref.read(localeProvider).languageCode,
            random: widget.random,
            text: (k) => lookupString(AppLocalizations.of(context), k),
            onFinished: _gameFinished,
          ),
        ),
      );
    }
    return Scaffold(
      body: PatternBackground(
        color: style.color,
        pattern: style.pattern,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: switch (_step) {
                  EpisodeStep.intro => _Intro(world: widget.world, onStart: _next),
                  EpisodeStep.companion => _Companion(onDone: _next),
                  EpisodeStep.offscreen => _Offscreen(challengeKey: _offscreenKey, onDone: _next),
                  _ => _WindDown(stars: _stars ?? 1),
                },
              ),
              const CaptionBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Intro extends ConsumerStatefulWidget {
  const _Intro({required this.world, required this.onStart});

  final World world;
  final VoidCallback onStart;

  @override
  ConsumerState<_Intro> createState() => _IntroState();
}

class _IntroState extends ConsumerState<_Intro> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(audioServiceProvider).sayAll([widget.world.titleKey, 'episodeIntro'], interrupt: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedText(lookupString(l, widget.world.titleKey) ?? '', fontSize: 40),
          const SizedBox(height: 16),
          const PokeablePip(width: 190, feedable: false),
          const SizedBox(height: 16),
          BigButton(
            key: const Key('episode.start'),
            icon: Icons.play_arrow_rounded,
            size: 120,
            color: AgeBandTheme.of(context).success,
            onPressed: widget.onStart,
          ),
        ],
      ),
    );
  }
}

class _Companion extends ConsumerStatefulWidget {
  const _Companion({required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<_Companion> createState() => _CompanionState();
}

class _CompanionState extends ConsumerState<_Companion> {
  bool _clapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(audioServiceProvider).say('companionClap', interrupt: true),
    );
  }

  Future<void> _clap(PipPart _) async {
    if (_clapped) return;
    setState(() => _clapped = true);
    ref.read(pipControllerProvider).onEvent(PipEvent.levelDone);
    await ref.read(audioServiceProvider).say('companionThanks', interrupt: true);
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PipView(key: const Key('companion.pip'), width: 240, onPart: _clap),
        const SizedBox(height: 24),
        BigButton(
          key: const Key('companion.clap'),
          icon: Icons.back_hand_rounded,
          size: 110,
          color: AgeBandTheme.of(context).primary,
          onPressed: () => _clap(PipPart.hand),
        ),
      ],
    ),
  );
}

class _Offscreen extends ConsumerStatefulWidget {
  const _Offscreen({required this.challengeKey, required this.onDone});

  final String challengeKey;
  final VoidCallback onDone;

  @override
  ConsumerState<_Offscreen> createState() => _OffscreenState();
}

class _OffscreenState extends ConsumerState<_Offscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(audioServiceProvider).sayAll(['offscreenIntro', widget.challengeKey], interrupt: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PipView(width: 170, interactive: false),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: OutlinedText(lookupString(l, widget.challengeKey) ?? '', fontSize: 30, maxLines: 4),
            ),
            const SizedBox(height: 24),
            BigButton(
              key: const Key('offscreen.done'),
              icon: Icons.check_rounded,
              size: 120,
              label: l.offscreenDone,
              outlinedLabel: true,
              color: AgeBandTheme.of(context).success,
              onPressed: widget.onDone,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindDown extends ConsumerStatefulWidget {
  const _WindDown({required this.stars});

  final int stars;

  @override
  ConsumerState<_WindDown> createState() => _WindDownState();
}

class _WindDownState extends ConsumerState<_WindDown> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pipControllerProvider).onEvent(PipEvent.levelDone);
      ref.read(audioServiceProvider)
        ..effect(Effect.star)
        ..say('episodeDone', interrupt: true);
    });
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          key: Key('winddown.stars.${widget.stars}'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Icon(
                i < widget.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 90,
                color: const Color(0xFFFFD23D),
                shadows: const [Shadow(color: Color(0x66000000), offset: Offset(0, 4))],
              ),
          ],
        ),
        const PipView(width: 180, interactive: false),
        const SizedBox(height: 24),
        BigButton(
          key: const Key('winddown.home'),
          icon: Icons.home_rounded,
          size: 120,
          color: AgeBandTheme.of(context).secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
