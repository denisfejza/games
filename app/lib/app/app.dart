import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/audio_service.dart';
import '../l10n/app_localizations.dart';
import '../worlds/world_map_screen.dart';
import 'bedtime.dart';
import 'providers.dart';
import 'ui/tokens.dart';

class PipsWorldApp extends ConsumerWidget {
  const PipsWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    debugShowCheckedModeBanner: false,
    locale: ref.watch(localeProvider),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: buildTheme(ref.watch(ageBandProvider)),
    builder: (context, child) => MusicHost(
      child: LargeTargets(
        enabled: ref.watch(largeTargetsProvider),
        child: PlayTimeGuard(child: child!),
      ),
    ),
    home: const WorldMapScreen(),
  );
}

/// Starts the music on the first touch (browsers block sound before one) and
/// pauses it while the app is in the background.
class MusicHost extends ConsumerStatefulWidget {
  const MusicHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MusicHost> createState() => _MusicHostState();
}

class _MusicHostState extends ConsumerState<MusicHost> with WidgetsBindingObserver {
  late final AudioService _audio = ref.read(audioServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _audio.holdMusic(
    'background',
    const {AppLifecycleState.hidden, AppLifecycleState.paused, AppLifecycleState.detached}.contains(state),
  );

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (_) => _audio.userInteracted(),
    child: widget.child,
  );
}
