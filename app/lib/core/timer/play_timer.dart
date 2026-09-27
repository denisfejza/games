import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

import '../storage/settings_store.dart';

/// Counts today's play time against the parent's daily limit. Usage is kept
/// per calendar day in [SettingsStore], so it survives restarts.
class PlayTimer extends ChangeNotifier {
  PlayTimer(this._store, Map<String, String> initial, {required int Function() limitMinutes})
    : _limit = limitMinutes,
      _values = Map.of(initial);

  final SettingsStore _store;
  final int Function() _limit;
  final Map<String, String> _values;

  static String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String get _usageKey => 'usage.${_day(clock.now())}';
  String get _extraKey => 'extra.${_day(clock.now())}';

  int _get(String key) => int.tryParse(_values[key] ?? '') ?? 0;

  Duration get playedToday => Duration(seconds: _get(_usageKey));

  /// Extra minutes a grown-up granted today.
  int get extraMinutesToday => _get(_extraKey) ~/ 60;

  /// Today's allowance, or null when there is no limit.
  Duration? get allowance {
    final limit = _limit();
    return limit <= 0 ? null : Duration(minutes: limit, seconds: _get(_extraKey));
  }

  bool get timeUp {
    final a = allowance;
    return a != null && playedToday >= a;
  }

  /// Adds play time; called every few seconds while the app is in front.
  Future<void> add(Duration played) async {
    final wasUp = timeUp;
    final key = _usageKey;
    _values[key] = '${_get(key) + played.inSeconds}';
    await _store.write(key, _values[key]!);
    if (timeUp != wasUp) notifyListeners();
  }

  /// Parent action (behind the gate): more time today.
  Future<void> grantExtra(Duration extra) async {
    final key = _extraKey;
    _values[key] = '${_get(key) + extra.inSeconds}';
    await _store.write(key, _values[key]!);
    notifyListeners();
  }

  /// Call when the limit setting changes.
  void limitChanged() => notifyListeners();
}
