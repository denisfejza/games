import 'voice_service.dart';

// TODO(native): Android/iOS plugin (record to memory, pitch-shift, discard).
Recorder createRecorder() => UnsupportedRecorder();

ClipPlayer createPlayer() => _NoPlayer();

class _NoPlayer implements ClipPlayer {
  @override
  Future<void> play(EchoClip clip, double rate) async {}
}
