import 'dart:async';
import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'voice_service.dart';

Recorder createRecorder() => WebRecorder();

ClipPlayer createPlayer() => WebClipPlayer();

/// Browser microphone via getUserMedia + MediaRecorder. Audio chunks stay in
/// memory as Blobs; nothing is uploaded or stored.
class WebRecorder implements Recorder {
  web.MediaStream? _stream;
  web.MediaRecorder? _recorder;
  web.AudioContext? _context;
  Timer? _poll;
  final List<web.Blob> _chunks = [];
  final StreamController<double> _levels = StreamController.broadcast();

  @override
  bool get supported => web.window.navigator.mediaDevices.isDefinedAndNotNull;

  @override
  Future<MicPermission> permission() async {
    try {
      final status = await web.window.navigator.permissions.query({'name': 'microphone'}.jsify()! as JSObject).toDart;
      return switch (status.state) {
        'granted' => MicPermission.granted,
        'denied' => MicPermission.denied,
        _ => MicPermission.notAsked,
      };
    } catch (_) {
      // Some browsers can't query microphone permission.
      return MicPermission.notAsked;
    }
  }

  @override
  Future<MicPermission> requestPermission() async {
    try {
      final stream = await _getStream();
      for (final t in stream.getTracks().toDart) {
        t.stop();
      }
      return MicPermission.granted;
    } catch (_) {
      return MicPermission.denied;
    }
  }

  Future<web.MediaStream> _getStream() =>
      web.window.navigator.mediaDevices.getUserMedia(web.MediaStreamConstraints(audio: true.toJS)).toDart;

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<void> start() async {
    final stream = _stream = await _getStream();
    _chunks.clear();
    final recorder = _recorder = web.MediaRecorder(stream);
    recorder.ondataavailable = ((web.BlobEvent e) => _chunks.add(e.data)).toJS;
    recorder.start();

    final context = _context = web.AudioContext();
    final analyser = context.createAnalyser()..fftSize = 1024;
    context.createMediaStreamSource(stream).connect(analyser);
    final samples = Float32List(analyser.fftSize);
    _poll = Timer.periodic(const Duration(milliseconds: 50), (_) {
      analyser.getFloatTimeDomainData(samples.toJS);
      var sum = 0.0;
      for (final s in samples) {
        sum += s * s;
      }
      _levels.add(sqrt(sum / samples.length));
    });
  }

  @override
  Future<EchoClip> stop() async {
    _poll?.cancel();
    final recorder = _recorder;
    if (recorder != null && recorder.state != 'inactive') {
      final stopped = Completer<void>();
      recorder.onstop = ((web.Event _) => stopped.complete()).toJS;
      recorder.stop();
      await stopped.future;
    }
    for (final t in _stream?.getTracks().toDart ?? <web.MediaStreamTrack>[]) {
      t.stop();
    }
    await _context?.close().toDart;
    final clip = WebClip(web.Blob(_chunks.toJS));
    _chunks.clear();
    _stream = null;
    _recorder = null;
    _context = null;
    return clip;
  }
}

class WebClip implements EchoClip {
  WebClip(this._blob);

  web.Blob? _blob;
  String? _url;

  String get url => _url ??= web.URL.createObjectURL(_blob!);

  @override
  bool get discarded => _blob == null;

  @override
  void discard() {
    if (_url != null) web.URL.revokeObjectURL(_url!);
    _url = null;
    _blob = null;
  }
}

class WebClipPlayer implements ClipPlayer {
  @override
  Future<void> play(EchoClip clip, double rate) async {
    if (clip is! WebClip || clip.discarded) return;
    final audio = web.HTMLAudioElement()
      ..src = clip.url
      ..preservesPitch = false
      ..playbackRate = rate;
    final ended = Completer<void>();
    audio.onended = ((web.Event _) => ended.complete()).toJS;
    await audio.play().toDart;
    await ended.future.timeout(const Duration(seconds: 10), onTimeout: () {});
    audio.src = '';
  }
}
