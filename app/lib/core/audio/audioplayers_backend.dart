import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'audio_service.dart';

/// [AudioBackend] on top of audioplayers. Only ever plays bundled assets.
class AudioplayersBackend implements AudioBackend {
  final AudioPlayer _narration = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();

  @override
  Future<void> playNarration(String assetPath) async {
    try {
      await _narration.stop();
      final done = _narration.onPlayerComplete.first;
      await _narration.play(AssetSource(assetPath));
      await done;
    } catch (e) {
      // TODO(asset): narration recordings don't exist yet; missing files are skipped.
      debugPrint('Narration unavailable: $assetPath ($e)');
    }
  }

  @override
  Future<void> stopNarration() => _narration.stop();

  @override
  Future<void> setMusicVolume(double volume) => _music.setVolume(volume);
}
