import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/pip_controller.dart';
import '../companion/pip_view.dart';
import '../core/audio/audio_service.dart';
import '../core/parental_gate/parental_gate.dart';
import '../l10n/app_localizations.dart';
import '../parent/parent_area.dart';
import 'providers.dart';
import 'ui/outlined_text.dart';
import 'ui/patterns.dart';

/// True while an episode is running; bedtime then waits for its wind-down.
final episodeActiveProvider = NotifierProvider<Setting<bool>, bool>(() => Setting(false));

/// Counts play time while the app is in front and shows [BedtimeScreen] over
/// everything once today's limit is used up (PLAN 1.6).
class PlayTimeGuard extends ConsumerStatefulWidget {
  const PlayTimeGuard({super.key, required this.child, this.tick = const Duration(seconds: 10)});

  final Widget child;
  final Duration tick;

  @override
  ConsumerState<PlayTimeGuard> createState() => _PlayTimeGuardState();
}

class _PlayTimeGuardState extends ConsumerState<PlayTimeGuard> with WidgetsBindingObserver {
  Timer? _ticker;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(widget.tick, (_) {
      if (_foreground) ref.read(playTimerProvider).add(widget.tick);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _foreground = state == AppLifecycleState.resumed;

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(playTimerProvider);
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        final show = timer.timeUp && !ref.watch(episodeActiveProvider);
        return Stack(
          children: [
            widget.child,
            if (show) const Positioned.fill(child: BedtimeScreen()),
          ],
        );
      },
    );
  }
}

/// "All done for today": Pip goes to sleep. Only a grown-up can continue.
/// Has its own navigator so the gate and settings open on top of it.
class BedtimeScreen extends StatelessWidget {
  const BedtimeScreen({super.key});

  @override
  Widget build(BuildContext context) => HeroControllerScope.none(
    child: Navigator(onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const _Bedtime())),
  );
}

class _Bedtime extends ConsumerStatefulWidget {
  const _Bedtime();

  @override
  ConsumerState<_Bedtime> createState() => _BedtimeState();
}

class _BedtimeState extends ConsumerState<_Bedtime> {
  late final PipController _pip = ref.read(pipControllerProvider);
  late final AudioService _audio = ref.read(audioServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pip.onEvent(PipEvent.bedtime);
      _audio
        ..holdMusic('bedtime', true)
        ..effect(Effect.yawn)
        ..say('bedtimePipSleepy', interrupt: true);
    });
  }

  @override
  void dispose() {
    _pip.onEvent(PipEvent.wake);
    _audio.holdMusic('bedtime', false);
    super.dispose();
  }

  Future<void> _grownUp() async {
    final navigator = Navigator.of(context);
    if (!await ParentalGate.request(context)) return;
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Wrap(
          children: [
            for (final m in const [10, 30])
              ListTile(
                key: Key('extra.$m'),
                leading: const Icon(Icons.more_time),
                title: Text(l.parentExtraTime(m)),
                onTap: () {
                  Navigator.of(sheet).pop();
                  ref.read(playTimerProvider).grantExtra(Duration(minutes: m));
                },
              ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l.parentTitle),
              onTap: () {
                Navigator.of(sheet).pop();
                navigator.push(MaterialPageRoute<void>(builder: (_) => const ParentArea()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: const Key('bedtime'),
        body: PatternBackground(
          color: const Color(0xFF26215C),
          pattern: Pattern.stars,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      key: const Key('bedtime.grownUp'),
                      tooltip: l.parentTitle,
                      color: Colors.white70,
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: _grownUp,
                    ),
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 40,
                  child: Icon(Icons.nightlight_round, size: 90, color: Color(0xFFFFE07A)),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PipView(width: 200, interactive: false),
                      const SizedBox(height: 24),
                      OutlinedText(l.bedtimeAllDone, fontSize: 36),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
