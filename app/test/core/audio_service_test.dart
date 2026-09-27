import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/core/audio/audio_service.dart';

import '../helpers.dart';

void main() {
  late FakeAudioBackend backend;
  var locale = 'sq';
  late AudioService audio;

  setUp(() {
    backend = FakeAudioBackend();
    locale = 'sq';
    audio = AudioService(backend, locale: () => locale);
  });

  test('narration keys map to audio/{locale}/{key}.ogg', () async {
    await audio.say('helloPip');
    locale = 'en';
    await audio.say('helloPip');
    expect(backend.played, ['audio/sq/helloPip.ogg', 'audio/en/helloPip.ogg']);
  });

  test('queued lines play in order and music ducks around them', () async {
    final first = audio.say('a');
    final second = audio.say('b');
    await Future.wait([first, second]);
    expect(backend.played, ['audio/sq/a.ogg', 'audio/sq/b.ogg']);
    expect(backend.musicVolumes, [AudioService.duckedMusicVolume, AudioService.musicVolume]);
    expect(audio.caption.value, isNull);
  });

  test('hear again repeats the last line', () async {
    await audio.say('worldAnimals');
    await audio.hearAgain();
    expect(backend.played, ['audio/sq/worldAnimals.ogg', 'audio/sq/worldAnimals.ogg']);
  });

  test('hear again with nothing said does nothing', () async {
    await audio.hearAgain();
    expect(backend.played, isEmpty);
  });

  test('interrupt stops the current line and clears the queue', () async {
    final a = audio.say('a');
    audio.say('b');
    await audio.say('c', interrupt: true);
    await a;
    expect(backend.stops, 1);
    expect(backend.played, isNot(contains('audio/sq/b.ogg')));
    expect(backend.played.last, 'audio/sq/c.ogg');
  });

  test('sayAll plays keys in order, named by ARB key', () async {
    await audio.sayAll(['gameFindThis', 'vocab.cow']);
    expect(backend.played, ['audio/sq/gameFindThis.ogg', 'audio/sq/vocabCow.ogg']);
  });

  test('animal noises are language-independent', () async {
    await audio.say('sfx.animal.cow');
    expect(backend.played, ['audio/sfx/animalCow.ogg']);
  });

  test('effects play unless muted', () async {
    await audio.effect(Effect.correct);
    audio.muted = true;
    await audio.effect(Effect.tap);
    expect(backend.effects, ['audio/sfx/correct.mp3']);
  });

  test('a missing recording keeps the caption up long enough to read', () {
    fakeAsync((async) {
      backend.recordingsExist = false;
      audio.say('helloPip');
      async.flushMicrotasks();
      expect(audio.caption.value, 'helloPip');
      async.elapse(const Duration(milliseconds: 1000));
      expect(audio.caption.value, 'helloPip');
      async.elapse(const Duration(milliseconds: 500));
      expect(audio.caption.value, isNull);
    });
  });

  test('an interrupt ends a held caption straight away (web: audio blocked before first tap)', () {
    fakeAsync((async) {
      backend.recordingsExist = false;
      audio.say('helloPip');
      async.elapse(const Duration(milliseconds: 200));
      expect(audio.caption.value, 'helloPip');
      audio.say('worldNumbers', interrupt: true);
      async.elapse(const Duration(milliseconds: 150));
      expect(audio.caption.value, 'worldNumbers');
      expect(backend.played.last, 'audio/sq/worldNumbers.ogg');
      async.elapse(const Duration(seconds: 2));
      expect(audio.caption.value, isNull);
      expect(audio.speaking.value, isFalse);
    });
  });

  test('missing recordings: Pip babbles about as long as the line, a question babbles up', () async {
    backend.recordingsExist = false;
    final lines = {'hi': 'Hi!', 'ask': 'Can you find the cow?', 'long': 'x' * 200};
    audio = AudioService(backend, locale: () => 'en', text: (k) => lines[k], missingHold: Duration.zero);
    await audio.sayAll(['hi', 'ask', 'long', 'sfx.animal.cow']);
    expect(backend.played, [
      'audio/en/hi.ogg',
      'audio/babble/say1.mp3',
      'audio/en/ask.ogg',
      'audio/babble/ask4.mp3',
      'audio/en/long.ogg',
      'audio/babble/say6.mp3',
      'audio/sfx/animalCow.ogg',
    ]);
  });

  test('recorded lines never babble', () async {
    audio = AudioService(backend, locale: () => 'en', text: (k) => 'Hello');
    await audio.say('helloPip');
    expect(backend.played, ['audio/en/helloPip.ogg']);
  });

  test('music waits for the first tap and stops for mute, holds and the parent switch', () async {
    audio.music = true;
    expect(backend.music, isEmpty);
    audio.userInteracted();
    expect(backend.music, [AudioService.musicTrack]);
    audio.holdMusic('bedtime', true);
    audio.holdMusic('background', true);
    audio.holdMusic('bedtime', false);
    expect(backend.music.last, 'stop');
    audio.holdMusic('background', false);
    audio.muted = true;
    audio.muted = false;
    audio.music = false;
    expect(backend.music, [
      AudioService.musicTrack,
      'stop',
      AudioService.musicTrack,
      'stop',
      AudioService.musicTrack,
      'stop',
    ]);
  });
}
