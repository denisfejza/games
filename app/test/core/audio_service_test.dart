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
}
