import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/bedtime.dart';
import 'package:pips_world/app/providers.dart';
import 'package:pips_world/app/ui/tokens.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/core/audio/audio_service.dart';
import 'package:pips_world/core/mastery/mastery_tracker.dart';
import 'package:pips_world/core/progress/progress_store.dart';
import 'package:pips_world/core/storage/settings_store.dart';
import 'package:pips_world/core/voice/voice_service.dart';
import 'package:pips_world/games/common/mini_game.dart';
import 'package:pips_world/games/common/round_controller.dart';
import 'package:pips_world/l10n/app_localizations.dart';
import 'package:pips_world/parent/purchases.dart';

/// Records what would have played instead of playing it.
class FakeAudioBackend implements AudioBackend {
  final List<String> played = [];
  final List<double> musicVolumes = [];
  final List<String> effects = [];
  int stops = 0;

  /// Pretend every recording exists unless told otherwise.
  bool recordingsExist = true;

  @override
  Future<bool> playNarration(String assetPath) async {
    played.add(assetPath);
    return recordingsExist;
  }

  @override
  Future<void> playEffect(String assetPath) async => effects.add(assetPath);

  @override
  Future<void> stopNarration() async => stops++;

  @override
  Future<void> setMusicVolume(double volume) async => musicVolumes.add(volume);
}

/// In-memory microphone driven by the test.
class FakeRecorder implements Recorder {
  MicPermission state = MicPermission.notAsked;
  MicPermission onRequest = MicPermission.granted;
  final StreamController<double> _levels = StreamController.broadcast();
  final List<FakeClip> clips = [];
  bool recording = false;
  int requests = 0;

  void level(double v) => _levels.add(v);

  @override
  bool get supported => true;

  @override
  Future<MicPermission> permission() async => state;

  @override
  Future<MicPermission> requestPermission() async {
    requests++;
    return state = onRequest;
  }

  @override
  Future<void> start() async => recording = true;

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<EchoClip> stop() async {
    recording = false;
    final clip = FakeClip();
    clips.add(clip);
    return clip;
  }
}

class FakeClip implements EchoClip {
  bool _discarded = false;

  @override
  bool get discarded => _discarded;

  @override
  void discard() => _discarded = true;
}

class FakePlayer implements ClipPlayer {
  final List<double> rates = [];
  final List<bool> discardedWhenPlayed = [];

  @override
  Future<void> play(EchoClip clip, double rate) async {
    rates.add(rate);
    discardedWhenPlayed.add(clip.discarded);
  }
}

/// A store that answers from memory.
class FakePurchaseService implements PurchaseService {
  bool storeAvailable = true;
  String? storePrice = '€4.99';
  int buys = 0;
  int restores = 0;
  VoidCallback? _unlock;

  /// What the store would report after a successful purchase.
  void completePurchase() => _unlock?.call();

  @override
  Future<bool> available() async => storeAvailable;

  @override
  Future<String?> price() async => storePrice;

  @override
  Future<void> buy() async => buys++;

  @override
  Future<void> restore() async => restores++;

  @override
  set onUnlocked(VoidCallback callback) => _unlock = callback;

  @override
  void dispose() {}
}

/// A game engine that finishes straight away with the given result, for runner tests.
class StubEngine implements GameEngine {
  StubEngine(this.type, {this.hints = 0});

  @override
  final String type;
  final int hints;
  final List<String> played = [];

  @override
  List<String> validate(GameDef def, ContentLibrary content) => const [];

  @override
  Widget build(GameContext context) => _StubGame(engine: this, context: context);
}

class _StubGame extends ConsumerStatefulWidget {
  const _StubGame({required this.engine, required this.context});

  final StubEngine engine;
  final GameContext context;

  @override
  ConsumerState<_StubGame> createState() => _StubGameState();
}

class _StubGameState extends ConsumerState<_StubGame> {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        key: const Key('stub.finish'),
        onPressed: () async {
          final def = widget.context.def;
          widget.engine.played.add(def.id);
          final rounds = RoundController(def: def, mastery: ref.read(masteryTrackerProvider));
          for (var i = 0; i < rounds.totalRounds; i++) {
            await rounds.solved();
          }
          widget.context.onFinished(
            MiniGameResult(rounds: rounds.round, firstTry: rounds.round, hints: widget.engine.hints),
          );
        },
        child: Text(widget.context.def.id),
      ),
    ),
  );
}

const phone = Size(390, 844);
const tablet = Size(1024, 768);

void setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Loads the real bundled content (outside the fake-async test zone).
Future<ContentLibrary> loadBundledContent() => ContentLoader(rootBundle).load();

/// Everything a test may want to inspect after pumping [testApp].
class TestDeps {
  TestDeps({
    FakeAudioBackend? audio,
    MemorySettingsStore? settings,
    MemoryMasteryStore? mastery,
    MemoryProgressStore? progress,
    FakeRecorder? recorder,
    FakePlayer? player,
    Map<String, GameEngine>? engines,
    FakePurchaseService? store,
  }) : store = store ?? FakePurchaseService(),
       audio = audio ?? FakeAudioBackend(),
       settings = settings ?? MemorySettingsStore(),
       mastery = mastery ?? MemoryMasteryStore(),
       progress = progress ?? MemoryProgressStore(),
       recorder = recorder ?? FakeRecorder(),
       player = player ?? FakePlayer(),
       engines = engines ?? const {};

  final FakeAudioBackend audio;
  final MemorySettingsStore settings;
  final MemoryMasteryStore mastery;
  final MemoryProgressStore progress;
  final FakeRecorder recorder;
  final FakePlayer player;
  final Map<String, GameEngine> engines;
  final FakePurchaseService store;
}

/// Wraps [child] like the real app does, with fakes for everything with side effects.
Widget testApp({
  required Widget child,
  FakeAudioBackend? audio,
  TestDeps? deps,
  String locale = 'en',
  AgeBand band = AgeBand.preschool,
  ContentLibrary? content,
  bool playTimeGuard = false,
  Map<String, String> initialSettings = const {},
}) {
  final d = deps ?? TestDeps(audio: audio);
  return ProviderScope(
    overrides: [
      initialSettingsProvider.overrideWithValue({...initialSettings, ...d.settings.data}),
      settingsStoreProvider.overrideWithValue(d.settings),
      localeProvider.overrideWith(() => Setting(Locale(locale))),
      ageBandProvider.overrideWith(() => Setting(band)),
      audioServiceProvider.overrideWith((ref) {
        final s = AudioService(d.audio, locale: () => ref.read(localeProvider).languageCode);
        ref.onDispose(s.dispose);
        return s;
      }),
      masteryTrackerProvider.overrideWithValue(MasteryTracker(d.mastery)),
      progressStoreProvider.overrideWithValue(d.progress),
      talkBackProvider.overrideWithValue(TalkBack(d.recorder, d.player)),
      gameRegistryProvider.overrideWithValue(d.engines),
      purchaseServiceProvider.overrideWith((ref) {
        d.store.onUnlocked = () => ref.read(fullUnlockProvider.notifier).set(true);
        return d.store;
      }),
      if (content != null) contentProvider.overrideWith((ref) => content),
    ],
    child: Consumer(
      builder: (context, ref, _) => MaterialApp(
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
        builder: playTimeGuard ? (context, child) => PlayTimeGuard(child: child!) : null,
        home: child,
      ),
    ),
  );
}
