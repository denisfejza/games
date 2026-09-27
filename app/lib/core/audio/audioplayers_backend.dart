import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_service.dart';

/// [AudioBackend] on top of audioplayers. Only ever plays bundled assets.
class AudioplayersBackend implements AudioBackend {
  AudioplayersBackend({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  /// Formats tried for each sound, in order (Safari plays no Ogg, so recordings
  /// may come as .m4a or .mp3 too).
  static const extensions = ['.ogg', '.m4a', '.mp3', '.wav'];

  /// Longest a single line may take before we move on anyway.
  static const maxLine = Duration(seconds: 12);

  final AssetBundle _bundle;
  final AudioPlayer _narration = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();
  final List<AudioPlayer> _effects = [for (var i = 0; i < 3; i++) AudioPlayer()];
  int _nextEffect = 0;
  Future<Set<String>>? _available;

  /// Completes when the current line ends, fails, or is stopped.
  Completer<void>? _current;

  /// Bundled audio files, so missing recordings are skipped without a failed request.
  Future<Set<String>> get _assets => _available ??= AssetManifest.loadFromAssetBundle(_bundle).then(
    (m) => {
      for (final a in m.listAssets())
        if (a.startsWith('assets/audio/')) a.substring(7),
    },
  );

  /// The bundled file for [assetPath] in whichever format exists, or null.
  Future<String?> _resolve(String assetPath) async {
    final assets = await _assets;
    if (assets.contains(assetPath)) return assetPath;
    final dot = assetPath.lastIndexOf('.');
    final stem = dot < 0 ? assetPath : assetPath.substring(0, dot);
    for (final ext in extensions) {
      if (assets.contains('$stem$ext')) return '$stem$ext';
    }
    return null;
  }

  @override
  Future<bool> playNarration(String assetPath) async {
    final file = await _resolve(assetPath);
    _finishCurrent();
    if (file == null) return false;
    final done = _current = Completer<void>();
    final sub = _narration.onPlayerComplete.listen((_) => _finish(done));
    try {
      // In browsers play() can stay pending while audio is blocked (before the
      // first tap), so never wait on it alone: a stop or the time limit also ends the line.
      final started = _narration.play(AssetSource(file));
      unawaited(started.then((_) {}, onError: (Object e) => _finish(done)));
      await done.future.timeout(maxLine, onTimeout: () {});
      return true;
    } catch (e) {
      // Browsers block audio until the first tap; a failed line just moves on.
      debugPrint('Narration unavailable: $assetPath ($e)');
      return false;
    } finally {
      await sub.cancel();
      _finish(done);
    }
  }

  void _finish(Completer<void> c) {
    if (!c.isCompleted) c.complete();
  }

  void _finishCurrent() {
    final c = _current;
    if (c != null) _finish(c);
  }

  @override
  Future<void> stopNarration() async {
    // Release whoever is waiting for this line first, so an interrupt is instant.
    _finishCurrent();
    // Don't let a stuck player hold up the next line.
    await _narration.stop().timeout(const Duration(milliseconds: 300), onTimeout: () {}).catchError((Object _) {});
  }

  @override
  Future<void> playEffect(String assetPath) async {
    final player = _effects[_nextEffect++ % _effects.length];
    // Fire and forget: effects must never delay anything.
    unawaited(
      player
          .stop()
          .then((_) => player.play(AssetSource(assetPath), volume: 0.7))
          .timeout(const Duration(seconds: 2))
          .catchError((Object e) => debugPrint('Effect failed: $assetPath ($e)')),
    );
  }

  @override
  Future<void> startMusic(String assetPath, double volume) async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.play(AssetSource(assetPath), volume: volume).timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Music unavailable: $assetPath ($e)');
    }
  }

  @override
  Future<void> stopMusic() async {
    await _music.stop().timeout(const Duration(milliseconds: 300), onTimeout: () {}).catchError((Object _) {});
  }

  @override
  Future<void> setMusicVolume(double volume) async {
    await _music
        .setVolume(volume)
        .timeout(const Duration(milliseconds: 300), onTimeout: () {})
        .catchError((Object _) {});
  }
}
