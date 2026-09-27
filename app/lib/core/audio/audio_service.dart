import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../keys.dart';

/// Plays sound files; the real one wraps audioplayers, tests use a fake.
abstract interface class AudioBackend {
  /// Plays a narration asset and completes when it has finished.
  /// Returns false when the recording doesn't exist (yet) or failed.
  Future<bool> playNarration(String assetPath);

  Future<void> stopNarration();

  /// Fire-and-forget interface sound (tap, correct, celebrate…).
  Future<void> playEffect(String assetPath);

  /// Background music volume, 0–1.
  Future<void> setMusicVolume(double volume);
}

/// Short interface sounds. Language-independent, never captioned.
enum Effect { tap, correct, tryAgain, celebrate, pop, giggle, yawn }

/// Narration for every screen: `say(key)` plays `audio/{locale}/{arbKey(key)}.ogg`.
/// Keys starting with `sfx.` (animal noises) play `audio/sfx/{rest}.ogg` in any language.
///
/// Lines play one after another. Music ducks while anything is speaking.
/// [caption] exposes the key being spoken so the caption bar can show it.
class AudioService {
  AudioService(this._backend, {required this.locale, this.missingHold = const Duration(milliseconds: 1400)});

  static const musicVolume = 0.6;
  static const duckedMusicVolume = 0.15;

  final AudioBackend _backend;

  /// Current language code, read each time a line starts.
  final String Function() locale;

  /// How long a caption stays up when its recording is missing, so it can be read.
  final Duration missingHold;
  final Queue<String> _queue = Queue();
  final ValueNotifier<String?> caption = ValueNotifier(null);

  /// True while narration is playing (drives Pip's talking animation).
  final ValueNotifier<bool> speaking = ValueNotifier(false);
  bool _playing = false;
  bool _muted = false;
  String? _lastKey;

  /// The last line spoken, for the "hear again" button.
  String? get lastKey => _lastKey;

  static String assetPath(String locale, String key) =>
      key.startsWith('sfx.') ? 'audio/sfx/${arbKey(key.substring(4))}.ogg' : 'audio/$locale/${arbKey(key)}.ogg';

  static String effectPath(Effect e) =>
      'audio/sfx/${switch (e) {
        Effect.tryAgain => 'try_again',
        _ => e.name,
      }}.wav';

  /// Parent setting: silences narration and effects (captions still show).
  set muted(bool value) => _muted = value;

  /// Queues [key]. With [interrupt], drops anything queued and cuts the current line.
  Future<void> say(String key, {bool interrupt = false}) async {
    if (interrupt) {
      _queue.clear();
      if (_playing) await _backend.stopNarration();
    }
    _queue.add(key);
    if (!_playing) await _drain();
  }

  /// Says every key in order, e.g. an instruction followed by an item name.
  Future<void> sayAll(List<String> keys, {bool interrupt = false}) async {
    if (keys.isEmpty) return;
    final done = say(keys.first, interrupt: interrupt);
    for (final k in keys.skip(1)) {
      _queue.add(k);
    }
    await done;
  }

  /// Repeats the last line spoken, interrupting whatever is playing.
  Future<void> hearAgain() async {
    final key = _lastKey;
    if (key != null) await say(key, interrupt: true);
  }

  Future<void> effect(Effect e) async {
    if (!_muted) await _backend.playEffect(effectPath(e));
  }

  Future<void> stop() async {
    _queue.clear();
    await _backend.stopNarration();
  }

  Future<void> _drain() async {
    _playing = true;
    speaking.value = true;
    await _backend.setMusicVolume(duckedMusicVolume);
    while (_queue.isNotEmpty) {
      final key = _queue.removeFirst();
      _lastKey = key;
      caption.value = key;
      final played = !_muted && await _backend.playNarration(assetPath(locale(), key));
      // TODO(asset): recordings are missing; keep the caption up long enough to read.
      if (!played && _queue.isEmpty) await Future<void>.delayed(missingHold);
    }
    caption.value = null;
    speaking.value = false;
    _playing = false;
    await _backend.setMusicVolume(musicVolume);
  }

  void dispose() {
    caption.dispose();
    speaking.dispose();
  }
}
