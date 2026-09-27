import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content_loader.dart';
import '../content/models.dart';
import '../core/audio/audio_service.dart';
import '../core/audio/audioplayers_backend.dart';
import '../core/mastery/mastery_tracker.dart';
import '../core/storage/database.dart';
import '../core/storage/drift_mastery_store.dart';

const supportedLanguages = ['sq', 'en'];

/// A simple settable value (locale, age band, parent toggles).
class Setting<T> extends Notifier<T> {
  Setting(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) => state = value;
}

/// Albanian when the device asks for it, otherwise English.
Locale defaultLocale([List<Locale>? device]) {
  final locales = device ?? PlatformDispatcher.instance.locales;
  return locales.any((l) => l.languageCode == 'sq') ? const Locale('sq') : const Locale('en');
}

final localeProvider = NotifierProvider<Setting<Locale>, Locale>(() => Setting(defaultLocale()));

// TODO(profile): read from the active ChildProfile once profile setup exists.
final ageBandProvider = NotifierProvider<Setting<AgeBand>, AgeBand>(() => Setting(AgeBand.preschool));

/// Parent setting; combined with the OS setting in `reduceMotion()`.
final reducedMotionProvider = NotifierProvider<Setting<bool>, bool>(() => Setting(false));

final captionsProvider = NotifierProvider<Setting<bool>, bool>(() => Setting(true));

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(AudioplayersBackend(), locale: () => ref.read(localeProvider).languageCode);
  ref.onDispose(service.dispose);
  return service;
});

final masteryTrackerProvider = Provider<MasteryTracker>(
  (ref) => MasteryTracker(DriftMasteryStore(ref.watch(databaseProvider))),
);

final contentProvider = FutureProvider<ContentLibrary>((ref) => ContentLoader(rootBundle).load());
