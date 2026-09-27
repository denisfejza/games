import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Plays sound files; the real one wraps audioplayers, tests use a fake.
abstract interface class AudioBackend {
  /// Plays a narration asset and completes when it has finished (or failed).
  Future<void> playNarration(String assetPath);

  Future<void> stopNarration();

  /// Background music volume, 0–1.
  Future<void> setMusicVolume(double volume);
}

/// Narration for every screen: `say(key)` plays `audio/{locale}/{key}.ogg`.
///
/// Lines play one after another. Music ducks while anything is speaking.
/// [caption] exposes the key being spoken so the caption bar can show it.
class AudioService {
  AudioService(this._backend, {required this.locale});

  static const musicVolume = 0.6;
  static const duckedMusicVolume = 0.15;

  final AudioBackend _backend;

  /// Current language code, read each time a line starts.
  final String Function() locale;
  final Queue<String> _queue = Queue();
  final ValueNotifier<String?> caption = ValueNotifier(null);
  bool _playing = false;
  String? _lastKey;

  /// The last line spoken, for the "hear again" button.
  String? get lastKey => _lastKey;

  static String assetPath(String locale, String key) => 'audio/$locale/$key.ogg';

  /// Queues [key]. With [interrupt], drops anything queued and cuts the current line.
  Future<void> say(String key, {bool interrupt = false}) async {
    if (interrupt) {
      _queue.clear();
      if (_playing) await _backend.stopNarration();
    }
    _queue.add(key);
    if (!_playing) await _drain();
  }

  /// Repeats the last line spoken, interrupting whatever is playing.
  Future<void> hearAgain() async {
    final key = _lastKey;
    if (key != null) await say(key, interrupt: true);
  }

  Future<void> stop() async {
    _queue.clear();
    await _backend.stopNarration();
  }

  Future<void> _drain() async {
    _playing = true;
    await _backend.setMusicVolume(duckedMusicVolume);
    while (_queue.isNotEmpty) {
      final key = _queue.removeFirst();
      _lastKey = key;
      caption.value = key;
      await _backend.playNarration(assetPath(locale(), key));
    }
    caption.value = null;
    _playing = false;
    await _backend.setMusicVolume(musicVolume);
  }

  void dispose() => caption.dispose();
}
