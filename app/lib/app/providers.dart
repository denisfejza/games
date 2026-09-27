import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../content/content_loader.dart';
import '../content/models.dart';
import '../core/audio/audio_service.dart';
import '../core/audio/audioplayers_backend.dart';
import '../core/mastery/mastery_tracker.dart';
import '../core/progress/progress_store.dart';
import '../core/storage/database.dart';
import '../core/storage/drift_mastery_store.dart';
import '../core/storage/settings_store.dart';
import '../core/timer/play_timer.dart';
import '../core/voice/voice_platform.dart';
import '../core/voice/voice_service.dart';
import '../parent/purchases.dart';

const supportedLanguages = ['sq', 'en'];

/// A simple settable value. [PersistedSetting] also saves it on the device.
class Setting<T> extends Notifier<T> {
  Setting(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  void set(T value) {
    // Ignore late updates (e.g. from a screen's dispose) once the app is gone.
    if (ref.mounted) state = value;
  }
}

/// A setting stored in [settingsStoreProvider] under [key].
class PersistedSetting<T> extends Setting<T> {
  PersistedSetting(this.key, T fallback, {required this.decode, required this.encode}) : super(fallback);

  final String key;
  final T? Function(String raw) decode;
  final String Function(T value) encode;

  @override
  T build() {
    final raw = ref.read(initialSettingsProvider)[key];
    return (raw == null ? null : decode(raw)) ?? _initial;
  }

  @override
  void set(T value) {
    if (!ref.mounted) return;
    state = value;
    ref.read(settingsStoreProvider).write(key, encode(value));
  }
}

PersistedSetting<bool> _bool(String key, bool fallback) =>
    PersistedSetting(key, fallback, decode: (r) => r == 'true', encode: (v) => '$v');

/// Albanian when the device asks for it, otherwise English.
Locale defaultLocale([List<Locale>? device]) {
  final locales = device ?? PlatformDispatcher.instance.locales;
  return locales.any((l) => l.languageCode == 'sq') ? const Locale('sq') : const Locale('en');
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsStoreProvider = Provider<SettingsStore>((ref) => DriftSettingsStore(ref.watch(databaseProvider)));

/// Settings read once at startup (see main.dart), so the first frame already uses them.
final initialSettingsProvider = Provider<Map<String, String>>((ref) => const {});

abstract final class SettingKeys {
  static const locale = 'locale';
  static const ageBand = 'ageBand';
  static const reducedMotion = 'reducedMotion';
  static const captions = 'captions';
  static const sound = 'sound';
  static const mic = 'micEnabled';
  static const dailyLimit = 'dailyLimitMinutes';
  static const bilingual = 'bilingual';
  static const largeTargets = 'largeTargets';
  static const fullUnlock = 'fullUnlock';
}

final localeProvider = NotifierProvider<Setting<Locale>, Locale>(
  () => PersistedSetting(
    SettingKeys.locale,
    defaultLocale(),
    decode: (r) => supportedLanguages.contains(r) ? Locale(r) : null,
    encode: (l) => l.languageCode,
  ),
);

// TODO(profile): per-child profiles; for now one age band for the device.
final ageBandProvider = NotifierProvider<Setting<AgeBand>, AgeBand>(
  () => PersistedSetting(
    SettingKeys.ageBand,
    AgeBand.preschool,
    decode: (r) => AgeBand.values.where((b) => b.json == r).firstOrNull,
    encode: (b) => b.json,
  ),
);

/// Parent setting; combined with the OS setting in `reduceMotion()`.
final reducedMotionProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.reducedMotion, false));

final captionsProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.captions, true));

final soundProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.sound, true));

/// Talk-back microphone. Off until a grown-up turns it on in the parent area.
final micEnabledProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.mic, false));

/// Daily play limit in minutes; 0 means no limit.
final dailyLimitProvider = NotifierProvider<Setting<int>, int>(
  () => PersistedSetting(SettingKeys.dailyLimit, 0, decode: int.tryParse, encode: (v) => '$v'),
);

/// Names are said in the main language, then the other one (PLAN 5.1 "bilingual mode").
final bilingualProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.bilingual, false));

/// Switch-access / motor support: every touch target grows by 30% (PLAN 6.4).
final largeTargetsProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.largeTargets, false));

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(
    AudioplayersBackend(),
    locale: () => ref.read(localeProvider).languageCode,
    secondLocale: () =>
        ref.read(bilingualProvider) ? (ref.read(localeProvider).languageCode == 'sq' ? 'en' : 'sq') : null,
  );
  service.muted = !ref.read(soundProvider);
  ref.listen(soundProvider, (_, on) => service.muted = !on);
  ref.onDispose(service.dispose);
  return service;
});

final masteryTrackerProvider = Provider<MasteryTracker>(
  (ref) => MasteryTracker(DriftMasteryStore(ref.watch(databaseProvider))),
);

final progressStoreProvider = Provider<ProgressStore>((ref) => DriftProgressStore(ref.watch(databaseProvider)));

final contentProvider = FutureProvider<ContentLibrary>((ref) => ContentLoader(rootBundle).load());

final playTimerProvider = Provider<PlayTimer>((ref) {
  final timer = PlayTimer(
    ref.watch(settingsStoreProvider),
    ref.watch(initialSettingsProvider),
    limitMinutes: () => ref.read(dailyLimitProvider),
  );
  ref.listen(dailyLimitProvider, (_, _) => timer.limitChanged());
  ref.onDispose(timer.dispose);
  return timer;
});

final talkBackProvider = Provider<TalkBack>((ref) => createTalkBack());

/// Full version bought (or restored). Preview builds can unlock everything.
final fullUnlockProvider = NotifierProvider<Setting<bool>, bool>(() => _bool(SettingKeys.fullUnlock, unlockAllBuild));

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final PurchaseService s = kIsWeb ? NoStorePurchaseService() : StorePurchaseService();
  s.onUnlocked = () => ref.read(fullUnlockProvider.notifier).set(true);
  ref.onDispose(s.dispose);
  return s;
});
