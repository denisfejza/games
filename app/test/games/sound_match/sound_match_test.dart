import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/vocab.dart';
import 'package:pips_world/games/common/card_face.dart';
import 'package:pips_world/games/sound_match/sound_match_config.dart';
import 'package:pips_world/games/sound_match/sound_match_game.dart';

import '../../helpers.dart';
import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContent());

  ChoiceRound round(Map<String, dynamic> params, {String locale = 'en', int seed = 3}) =>
      ChoiceRounds(Random(seed), text: stringsFor(locale), locale: locale).next(SoundMatchConfig.parse(params, lib));

  group('rounds', () {
    test('name: the answer card shows the item Pip names', () {
      for (var seed = 0; seed < 20; seed++) {
        final r = round({'items': 'tags:animal+farm', 'choices': 3}, seed: seed);
        expect(r.faces, hasLength(3));
        final answer = r.faces[r.answer] as PictureFace;
        final named = lib.vocab.values.firstWhere((v) => v.nameKey == r.prompt.last);
        expect(answer.picture, isA<EmojiPicture>());
        expect((answer.picture as EmojiPicture).emoji, (named.picture as EmojiPicture).emoji);
        expect(r.faces.toSet(), hasLength(3), reason: 'no duplicate cards');
      }
    });

    test('sound mode only uses animals with a sound', () {
      final r = round({'mode': 'sound', 'items': 'tag:animal', 'choices': 4});
      expect(r.prompt.first, 'gameWhoSays');
      expect(r.prompt.last, startsWith('sfx.animal.'));
    });

    test('numbers: the answer matches the spoken number', () {
      for (final show in ['numeral', 'dots', 'group']) {
        final r = round({
          'mode': 'number',
          'numbers': [1, 5],
          'choices': 3,
          'show': show,
        });
        final n = int.parse(r.prompt.last.substring(3));
        final face = r.faces[r.answer];
        expect(switch (face) {
          TextFace(:final text) => int.parse(text),
          DotsFace(:final count) => count,
          GroupFace(:final count) => count,
          _ => -1,
        }, n);
      }
    });

    test('more / fewer pick the biggest / smallest group', () {
      final more = round({
        'mode': 'more',
        'numbers': [1, 6],
        'choices': 2,
      });
      final counts = [for (final f in more.faces) (f as GroupFace).count];
      expect((more.faces[more.answer] as GroupFace).count, counts.reduce(max));
      final fewer = round({
        'mode': 'fewer',
        'numbers': [1, 6],
        'choices': 3,
      });
      expect(
        (fewer.faces[fewer.answer] as GroupFace).count,
        [for (final f in fewer.faces) (f as GroupFace).count].reduce(min),
      );
    });

    test('bond to 5, sums and take-away have the right answer', () {
      final b = round({'mode': 'bond', 'total': 5, 'choices': 3});
      final have = (b.stage.single as FrameFace).filled;
      expect(int.parse((b.faces[b.answer] as TextFace).text), 5 - have);
      final s = round({
        'mode': 'sum',
        'numbers': [1, 10],
        'choices': 3,
      });
      expect(
        int.parse((s.faces[s.answer] as TextFace).text),
        [for (final f in s.stage) (f as GroupFace).count].reduce((a, b) => a + b),
      );
      final t = round({
        'mode': 'take_away',
        'numbers': [1, 10],
        'choices': 3,
      });
      final g = t.stage.single as CrossedGroupFace;
      expect(int.parse((t.faces[t.answer] as TextFace).text), g.count - g.crossed);
    });

    test('starts_with uses Albanian digraphs as one letter', () {
      final items = ['sheep', 'grapes', 'goat', 'rain', 'cow', 'dog'];
      for (var seed = 0; seed < 10; seed++) {
        final r = round(
          {
            'mode': 'starts_with',
            'items': items,
            'letters': ['dh', 'd', 'rr', 'sh'],
            'choices': 3,
          },
          locale: 'sq',
          seed: seed,
        );
        expect(r.prompt.last, anyOf('letter.sq.dh', 'letter.sq.d', 'letter.sq.rr', 'letter.sq.sh'));
        final answer = (r.faces[r.answer] as PictureFace).picture as EmojiPicture;
        final item = lib.vocab.values.firstWhere(
          (v) => v.picture is EmojiPicture && (v.picture as EmojiPicture).emoji == answer.emoji && items.contains(v.id),
        );
        final name = stringsFor('sq')(item.nameKey)!.toLowerCase();
        final letter = r.prompt.last.split('.').last;
        expect(name.startsWith(letter), isTrue, reason: '$name / $letter');
        // "dele" must not count for "dh": d-e-l-e starts with d.
        if (letter == 'dh') expect(name, isNot('dele'));
      }
    });
  });

  test('validate catches bad content', () {
    expect(
      SoundMatchConfig.validate(
        gameDef('sound_match', {
          'items': ['cow', 'unicorn'],
          'choices': 2,
        }),
        lib,
      ),
      contains(contains('unicorn')),
    );
    expect(
      SoundMatchConfig.validate(
        gameDef('sound_match', {
          'items': ['cow'],
          'choices': 3,
        }),
        lib,
      ),
      isNotEmpty,
    );
    expect(SoundMatchConfig.validate(gameDef('sound_match', {'mode': 'dance'}), lib), isNotEmpty);
    expect(SoundMatchConfig.validate(gameDef('sound_match', {'items': 'tag:farm', 'choices': 4}), lib), isEmpty);
  });

  testWidgets('plays a whole game: right taps solve rounds, wrong taps hint, mastery recorded', (tester) async {
    final def = gameDef('sound_match', {'items': 'tags:animal+farm', 'choices': 3, 'rounds': 3});
    final (game, results, deps) = await pumpEngine<SoundMatchGame>(tester, const SoundMatchEngine(), def, lib);
    expect(deps.audio.played.first, 'audio/en/gameFindThis.ogg');

    // Round 1: one wrong tap first → hint on the answer (step 1 hints after 1 wrong).
    var r = game.round!;
    final wrong = game.cards.firstWhere((c) => c.value != r.answer);
    await tapGame(tester, wrong.absolutePosition);
    expect(game.cards[r.answer].hinting, isTrue);
    await tapGame(tester, game.cards[r.answer].absolutePosition);
    await settle(tester, seconds: 1);

    for (var i = 0; i < 2; i++) {
      r = game.round!;
      await tapGame(tester, game.cards[r.answer].absolutePosition);
      await settle(tester, seconds: 1);
    }
    await settle(tester);
    expect(results, hasLength(1));
    expect(results.single.rounds, 3);
    expect(results.single.firstTry, 2);
    expect(results.single.hints, 1);
    expect(deps.mastery.data['test.skill']!.attempts, 3);
    expect(deps.mastery.data['test.skill']!.independent, 2);
    expect(deps.audio.effects, contains('audio/sfx/try_again.mp3'));
  });

  for (final locale in ['en', 'sq']) {
    testWidgets('golden $locale', (tester) async {
      final def = gameDef('sound_match', {'items': 'tags:animal+farm', 'choices': 3});
      await pumpEngine<SoundMatchGame>(tester, const SoundMatchEngine(), def, lib, locale: locale);
      await expectGolden(tester, 'sound_match_$locale');
    });
  }
}
