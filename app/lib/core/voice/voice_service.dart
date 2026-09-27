import 'dart:async';

/// Microphone permission state. Only the parent area may ask for it.
enum MicPermission { granted, denied, notAsked, unsupported }

enum EchoResult { echoed, silence, unavailable }

/// A recording held in memory only. Never written to disk or sent anywhere
/// (CLAUDE.md hard rule 2); [discard] frees it right after playback.
abstract interface class EchoClip {
  void discard();
  bool get discarded;
}

/// Platform microphone. Web: Web Audio (voice_platform_web.dart).
/// TODO(native): Kotlin/Swift plugin with in-memory buffers (PLAN 1.3).
abstract interface class Recorder {
  bool get supported;

  /// Current permission, without prompting.
  Future<MicPermission> permission();

  /// Prompts for permission. Call only from behind the parental gate.
  Future<MicPermission> requestPermission();

  /// Starts recording; [levels] then reports loudness (0–1) about 20×/s.
  Future<void> start();
  Stream<double> get levels;

  /// Stops and hands over the in-memory recording.
  Future<EchoClip> stop();
}

abstract interface class ClipPlayer {
  /// Plays [clip] at [rate] with pitch following speed (rate 1.414 ≈ +6 semitones).
  Future<void> play(EchoClip clip, double rate);
}

/// Voice-activity detection settings.
class VadSettings {
  const VadSettings({
    this.threshold = 0.04,
    this.startSamples = 3,
    this.endSilence = const Duration(milliseconds: 800),
    this.waitForSpeech = const Duration(seconds: 6),
    this.maxSpeech = const Duration(seconds: 5),
  });

  final double threshold;

  /// Loud samples in a row that count as "the child started talking".
  final int startSamples;
  final Duration endSilence;
  final Duration waitForSpeech;
  final Duration maxSpeech;
}

/// Pip's talk-back: listen until the child has said something, play it back
/// in a squeaky voice, then throw the recording away.
///
/// Speech recognition for Albanian is unreliable, so this only detects that
/// the child made a sound and rewards the attempt (CLAUDE.md).
class TalkBack {
  TalkBack(this._recorder, this._player, {this.vad = const VadSettings()});

  /// +6 semitones.
  static const pitchRate = 1.4142;

  final Recorder _recorder;
  final ClipPlayer _player;
  final VadSettings vad;
  bool _busy = false;

  bool get supported => _recorder.supported;
  Future<MicPermission> permission() => _recorder.permission();
  Future<MicPermission> requestPermission() => _recorder.requestPermission();

  /// [onChildSpoke] fires as soon as the child starts making sound.
  Future<EchoResult> listenAndEcho({void Function()? onChildSpoke}) async {
    if (_busy || !_recorder.supported || await _recorder.permission() != MicPermission.granted) {
      return EchoResult.unavailable;
    }
    _busy = true;
    try {
      await _recorder.start();
      final spoke = await _waitForSpeech(onChildSpoke);
      final clip = await _recorder.stop();
      try {
        if (spoke) await _player.play(clip, pitchRate);
      } finally {
        clip.discard();
      }
      return spoke ? EchoResult.echoed : EchoResult.silence;
    } finally {
      _busy = false;
    }
  }

  Future<bool> _waitForSpeech(void Function()? onChildSpoke) {
    final done = Completer<bool>();
    var loud = 0;
    var speaking = false;
    Timer? endTimer;
    Timer? maxTimer;
    final waitTimer = Timer(vad.waitForSpeech, () {
      if (!speaking && !done.isCompleted) done.complete(false);
    });
    late final StreamSubscription<double> sub;
    void finish() {
      if (!done.isCompleted) done.complete(true);
    }

    sub = _recorder.levels.listen((level) {
      if (level >= vad.threshold) {
        loud++;
        endTimer?.cancel();
        endTimer = null;
        if (!speaking && loud >= vad.startSamples) {
          speaking = true;
          waitTimer.cancel();
          onChildSpoke?.call();
          maxTimer = Timer(vad.maxSpeech, finish);
        }
      } else {
        loud = 0;
        if (speaking) endTimer ??= Timer(vad.endSilence, finish);
      }
    });
    return done.future.whenComplete(() {
      sub.cancel();
      waitTimer.cancel();
      endTimer?.cancel();
      maxTimer?.cancel();
    });
  }
}

class UnsupportedRecorder implements Recorder {
  @override
  bool get supported => false;

  @override
  Future<MicPermission> permission() async => MicPermission.unsupported;

  @override
  Future<MicPermission> requestPermission() async => MicPermission.unsupported;

  @override
  Future<void> start() => throw UnsupportedError('No microphone support on this platform yet');

  @override
  Stream<double> get levels => const Stream.empty();

  @override
  Future<EchoClip> stop() => throw UnsupportedError('No microphone support on this platform yet');
}
