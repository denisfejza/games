import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/core/storage/settings_store.dart';
import 'package:pips_world/core/timer/play_timer.dart';

void main() {
  final monday = DateTime(2026, 9, 28, 10);

  test('counts against the daily limit and survives a restart', () async {
    await withClock(Clock.fixed(monday), () async {
      final store = MemorySettingsStore();
      final timer = PlayTimer(store, const {}, limitMinutes: () => 20);
      await timer.add(const Duration(minutes: 15));
      expect(timer.timeUp, isFalse);

      // App restarts: a new timer reads the saved usage.
      final again = PlayTimer(store, await store.loadAll(), limitMinutes: () => 20);
      expect(again.playedToday, const Duration(minutes: 15));
      await again.add(const Duration(minutes: 5));
      expect(again.timeUp, isTrue);
    });
  });

  test('no limit means never time up', () async {
    final timer = PlayTimer(MemorySettingsStore(), const {}, limitMinutes: () => 0);
    await timer.add(const Duration(hours: 5));
    expect(timer.timeUp, isFalse);
    expect(timer.allowance, isNull);
  });

  test('a grown-up can add time for today only', () async {
    final store = MemorySettingsStore();
    await withClock(Clock.fixed(monday), () async {
      final timer = PlayTimer(store, const {}, limitMinutes: () => 10);
      await timer.add(const Duration(minutes: 10));
      expect(timer.timeUp, isTrue);
      await timer.grantExtra(const Duration(minutes: 10));
      expect(timer.timeUp, isFalse);
    });
    await withClock(Clock.fixed(monday.add(const Duration(days: 1))), () async {
      final tomorrow = PlayTimer(store, await store.loadAll(), limitMinutes: () => 10);
      expect(tomorrow.playedToday, Duration.zero);
      expect(tomorrow.extraMinutesToday, 0);
    });
  });
}
