import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/providers.dart';
import 'package:pips_world/app/ui/tokens.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/core/audio/audio_service.dart';
import 'package:pips_world/l10n/app_localizations.dart';

/// Records what would have played instead of playing it.
class FakeAudioBackend implements AudioBackend {
  final List<String> played = [];
  final List<double> musicVolumes = [];
  int stops = 0;

  final List<String> effects = [];

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

const phone = Size(390, 844);
const tablet = Size(1024, 768);

void setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Loads the real bundled content (outside the fake-async test zone).
Future<ContentLibrary> loadBundledContent() => ContentLoader(rootBundle).load();

/// Wraps [child] like the real app does, with fake audio.
Widget testApp({
  required Widget child,
  required FakeAudioBackend audio,
  String locale = 'en',
  AgeBand band = AgeBand.preschool,
  ContentLibrary? content,
}) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith(() => Setting(Locale(locale))),
      ageBandProvider.overrideWith(() => Setting(band)),
      audioServiceProvider.overrideWithValue(AudioService(audio, locale: () => locale)),
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
        home: child,
      ),
    ),
  );
}
