import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/providers.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/core/storage/settings_store.dart';

void main() {
  test('settings are saved and read back on the next start', () async {
    final store = MemorySettingsStore();
    var container = ProviderContainer(overrides: [settingsStoreProvider.overrideWithValue(store)]);
    container.read(localeProvider.notifier).set(const Locale('sq'));
    container.read(ageBandProvider.notifier).set(AgeBand.school);
    container.read(dailyLimitProvider.notifier).set(30);
    container.read(micEnabledProvider.notifier).set(true);
    container.dispose();

    container = ProviderContainer(
      overrides: [
        settingsStoreProvider.overrideWithValue(store),
        initialSettingsProvider.overrideWithValue(await store.loadAll()),
      ],
    );
    expect(container.read(localeProvider), const Locale('sq'));
    expect(container.read(ageBandProvider), AgeBand.school);
    expect(container.read(dailyLimitProvider), 30);
    expect(container.read(micEnabledProvider), isTrue);
    expect(container.read(captionsProvider), isTrue, reason: 'default');
    container.dispose();
  });

  test('bad stored values fall back to defaults', () {
    final container = ProviderContainer(
      overrides: [
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
        initialSettingsProvider.overrideWithValue(const {'locale': 'de', 'ageBand': '9-10', 'dailyLimitMinutes': 'x'}),
      ],
    );
    expect(supportedLanguages, contains(container.read(localeProvider).languageCode));
    expect(container.read(ageBandProvider), AgeBand.preschool);
    expect(container.read(dailyLimitProvider), 0);
    container.dispose();
  });
}
