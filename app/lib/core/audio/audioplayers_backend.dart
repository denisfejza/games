import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_service.dart';

/// [AudioBackend] on top of audioplayers. Only ever plays bundled assets.
class AudioplayersBackend implements AudioBackend {
  AudioplayersBackend({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const placeholder = 'audio/placeholder.wav';

  final AssetBundle _bundle;
  final AudioPlayer _narration = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();
  final List<AudioPlayer> _effects = [for (var i = 0; i < 3; i++) AudioPlayer()];
  int _nextEffect = 0;
  Future<Set<String>>? _available;

  /// Bundled audio files, so missing recordings are skipped without a failed request.
  Future<Set<String>> get _assets => _available ??= AssetManifest.loadFromAssetBundle(_bundle).then(
    (m) => {
      for (final a in m.listAssets())
        if (a.startsWith('assets/audio/')) a.substring(7),
    },
  );

  @override
  Future<bool> playNarration(String assetPath) async {
    final exists = (await _assets).contains(assetPath);
    try {
      await _narration.stop();
      final done = _narration.onPlayerComplete.first;
      // TODO(asset): until recordings exist, a soft blip stands in for each line.
      await _narration.play(AssetSource(exists ? assetPath : placeholder));
      await done.timeout(const Duration(seconds: 20));
      return exists;
    } catch (e) {
      debugPrint('Narration failed: $assetPath ($e)');
      return false;
    }
  }

  @override
  Future<void> stopNarration() => _narration.stop();

  @override
  Future<void> playEffect(String assetPath) async {
    final player = _effects[_nextEffect++ % _effects.length];
    try {
      await player.stop();
      await player.play(AssetSource(assetPath), volume: 0.7);
    } catch (e) {
      debugPrint('Effect failed: $assetPath ($e)');
    }
  }

  @override
  Future<void> setMusicVolume(double volume) => _music.setVolume(volume);
}
