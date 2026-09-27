import 'dart:async';
import 'dart:collection';

import 'package:clock/clock.dart';
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

  /// Starts looping [assetPath] as background music.
  Future<void> startMusic(String assetPath, double volume);

  Future<void> stopMusic();
}

/// Short interface sounds. Language-independent, never captioned.
enum Effect { tap, correct, tryAgain, celebrate, pop, giggle, yawn, flip, hop, slide, climb, dice, snap, star, munch }

/// Narration for every screen: `say(key)` plays `audio/{locale}/{arbKey(key)}.ogg`.
/// Keys starting with `sfx.` (animal noises) play `audio/sfx/{rest}.ogg` in any language.
///
/// Lines play one after another. Music ducks while anything is speaking.
/// [caption] exposes the key being spoken so the caption bar can show it.
class AudioService {
  AudioService(
    this._backend, {
    required this.locale,
    this.secondLocale,
    this.missingHold = const Duration(milliseconds: 1400),
    this.text,
  });

  /// The words of a line in the current language, so Pip can babble for about
  /// as long as the line while its recording doesn't exist yet.
  final String? Function(String key)? text;

  /// Lengths (seconds) of the babble clips `audio/babble/{say|ask}{1…}.mp3`.
  static const babbleLengths = [0.5, 0.9, 1.3, 1.8, 2.4, 3.0];

  static const musicTrack = 'audio/music/meadow.mp3';

  /// Bilingual mode: names are also said in this language, straight after.
  final String? Function()? secondLocale;

  /// Keys that are names of things (said in both languages in bilingual mode).
  static bool isName(String key) =>
      key.startsWith('vocab.') ||
      key.startsWith('colour.') ||
      key.startsWith('shape.') ||
      RegExp(r'^num\d+$').hasMatch(key);

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

  /// Bumped on every interrupt so a pending caption hold ends early.
  int _generation = 0;
  String? _lastKey;

  /// The last line spoken, for the "hear again" button.
  String? get lastKey => _lastKey;

  static String assetPath(String locale, String key) =>
      key.startsWith('sfx.') ? 'audio/sfx/${arbKey(key.substring(4))}.ogg' : 'audio/$locale/${arbKey(key)}.ogg';

  static String effectPath(Effect e) =>
      'audio/sfx/${switch (e) {
        Effect.tryAgain => 'try_again',
        _ => e.name,
      }}.mp3';

  /// The babble clip closest in length to [line] read aloud (a question babbles up).
  static String babblePath(String line) {
    final t = line.trim();
    final seconds = t.length / 13;
    var n = babbleLengths.indexWhere((l) => l >= seconds);
    if (n < 0) n = babbleLengths.length - 1;
    return 'audio/babble/${t.endsWith('?') ? 'ask' : 'say'}${n + 1}.mp3';
  }

  /// Parent setting: silences narration, effects and music (captions still show).
  set muted(bool value) {
    _muted = value;
    _updateMusic();
  }

  bool _musicOn = false;
  bool _musicPlaying = false;
  bool _interacted = false;
  final Set<String> _musicHolds = {};

  /// Parent setting: gentle background music.
  set music(bool on) {
    _musicOn = on;
    _updateMusic();
  }

  /// Browsers only allow sound after the first tap, so music waits for one.
  void userInteracted() {
    if (_interacted) return;
    _interacted = true;
    _updateMusic();
  }

  /// Pauses music for a [reason] (bedtime, app in the background) until released.
  void holdMusic(String reason, bool hold) {
    hold ? _musicHolds.add(reason) : _musicHolds.remove(reason);
    _updateMusic();
  }

  void _updateMusic() {
    final want = _interacted && _musicOn && !_muted && _musicHolds.isEmpty;
    if (want == _musicPlaying) return;
    _musicPlaying = want;
    unawaited(
      want ? _backend.startMusic(musicTrack, _playing ? duckedMusicVolume : musicVolume) : _backend.stopMusic(),
    );
  }

  /// Queues [key]. With [interrupt], drops anything queued and cuts the current line.
  Future<void> say(String key, {bool interrupt = false}) async {
    if (interrupt) {
      _queue.clear();
      _generation++;
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
      var played = !_muted && await _backend.playNarration(assetPath(locale(), key));
      // TODO(asset): no recording yet, so Pip babbles for about as long as the line.
      final line = played || _muted || key.startsWith('sfx.') ? null : text?.call(key);
      if (line != null && line.isNotEmpty) played = await _backend.playNarration(babblePath(line));
      final second = secondLocale?.call();
      if (second != null && isName(key) && !_muted) await _backend.playNarration(assetPath(second, key));
      // TODO(asset): recordings are missing; keep the caption up long enough to read,
      // unless something else interrupts.
      if (!played && _queue.isEmpty) {
        final gen = _generation;
        final until = clock.now().add(missingHold);
        while (gen == _generation && _queue.isEmpty && clock.now().isBefore(until)) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }
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
