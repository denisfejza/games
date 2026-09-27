import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/core/voice/voice_service.dart';

import '../helpers.dart';

/// Fails the test if anything tries to touch the file system.
final class _NoFiles extends IOOverrides {
  @override
  File createFile(String path) => fail('talk-back tried to create a file: $path');

  @override
  Directory createDirectory(String path) => fail('talk-back tried to create a directory: $path');
}

void main() {
  late FakeRecorder recorder;
  late FakePlayer player;
  late TalkBack talkBack;

  setUp(() {
    recorder = FakeRecorder();
    player = FakePlayer();
    talkBack = TalkBack(recorder, player);
  });

  EchoResult? run(FakeAsync async, void Function() speak) {
    EchoResult? result;
    talkBack.listenAndEcho().then((r) => result = r);
    async.flushMicrotasks();
    speak();
    async.elapse(const Duration(seconds: 7));
    return result;
  }

  test('echoes the child pitched up, then discards the recording — with no file access', () {
    IOOverrides.runWithIOOverrides(() {
      fakeAsync((async) {
        recorder.state = MicPermission.granted;
        var spoke = false;
        EchoResult? result;
        talkBack.listenAndEcho(onChildSpoke: () => spoke = true).then((r) => result = r);
        async.flushMicrotasks();
        for (var i = 0; i < 10; i++) {
          recorder.level(0.3);
          async.elapse(const Duration(milliseconds: 50));
        }
        recorder.level(0.0);
        async.elapse(const Duration(seconds: 1));
        expect(spoke, isTrue);
        expect(result, EchoResult.echoed);
        expect(player.rates, [TalkBack.pitchRate]);
        expect(player.discardedWhenPlayed, [false]);
        expect(recorder.clips.single.discarded, isTrue, reason: 'buffer cleared after playback');
        expect(recorder.recording, isFalse);
      });
    }, _NoFiles());
  });

  test('silence: nothing is played and the recording is still discarded', () {
    fakeAsync((async) {
      recorder.state = MicPermission.granted;
      final result = run(async, () {});
      expect(result, EchoResult.silence);
      expect(player.rates, isEmpty);
      expect(recorder.clips.single.discarded, isTrue);
    });
  });

  test('a short noise below the start count is not speech', () {
    fakeAsync((async) {
      recorder.state = MicPermission.granted;
      final result = run(async, () {
        recorder
          ..level(0.5)
          ..level(0.5)
          ..level(0.0);
      });
      expect(result, EchoResult.silence);
    });
  });

  test('without permission it never records and never asks', () {
    fakeAsync((async) {
      final result = run(async, () => recorder.level(0.5));
      expect(result, EchoResult.unavailable);
      expect(recorder.requests, 0);
      expect(recorder.clips, isEmpty);
    });
  });

  test('works (does nothing) where the platform has no microphone', () async {
    final none = TalkBack(UnsupportedRecorder(), player);
    expect(none.supported, isFalse);
    expect(await none.listenAndEcho(), EchoResult.unavailable);
  });
}
