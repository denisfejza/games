import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/vocab.dart';
import 'package:pips_world/games/common/card_face.dart';
import 'package:pips_world/games/drag_to_target/drag_to_target_config.dart';
import 'package:pips_world/games/drag_to_target/drag_to_target_game.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  DragRound round(Map<String, dynamic> p, {int seed = 1}) =>
      DragRounds(Random(seed), lib).next(DragToTargetConfig.parse(p, lib));

  String emoji(CardFace f) => ((f as PictureFace).picture as EmojiPicture).emoji;

  test('food: the right zone is the animal that eats the food', () {
    for (var seed = 0; seed < 20; seed++) {
      final r = round({'mode': 'food', 'items': 'tag:animal', 'targets': 3}, seed: seed);
      final food = lib.vocab.values.firstWhere((v) => v.nameKey == r.itemName);
      final eater = lib.vocab.values.firstWhere(
        (v) =>
            v.props['food'] == food.id &&
            v.picture is EmojiPicture &&
            (v.picture as EmojiPicture).emoji == emoji(r.zones[r.answer]),
      );
      expect(eater.props['food'], food.id);
      expect(r.zones, hasLength(3));
    }
  });

  test('habitat: zones are different homes and the answer is the animal\'s', () {
    final r = round({
      'mode': 'habitat',
      'items': ['cow', 'whale', 'lion', 'penguin'],
      'targets': 3,
    });
    final animal = lib.vocab.values.firstWhere((v) => v.nameKey == r.itemName);
    expect(emoji(r.zones[r.answer]), (lib.item(animal.props['habitat']!).picture as EmojiPicture).emoji);
    expect({for (final z in r.zones) emoji(z)}, hasLength(3));
  });

  test('shape holes are silhouettes; baby is small', () {
    expect(round({'mode': 'shape_hole', 'targets': 3}).zones.first, isA<SilhouetteFace>());
    expect(round({'mode': 'baby', 'items': 'tags:animal+farm'}).item, isA<SmallFace>());
  });

  test('validate: needs enough different targets', () {
    expect(
      DragToTargetConfig.validate(
        gameDef('drag_to_target', {
          'mode': 'habitat',
          'items': ['cow', 'pig'],
          'targets': 2,
        }),
        lib,
      ),
      isNotEmpty,
    );
    expect(
      DragToTargetConfig.validate(
        gameDef('drag_to_target', {'mode': 'food', 'items': 'tag:animal', 'targets': 3}),
        lib,
      ),
      isEmpty,
    );
  });

  testWidgets('dragging to the wrong zone bounces back and hints; the right zone solves', (tester) async {
    final def = gameDef('drag_to_target', {'mode': 'food', 'items': 'tag:animal', 'targets': 2, 'rounds': 2});
    final (game, results, deps) = await pumpEngine<DragToTargetGame>(tester, const DragToTargetEngine(), def, lib);
    var r = game.round!;
    final home = game.item!.position.clone();
    final wrong = game.zones.firstWhere((z) => z.value != r.answer);
    await dragGame(tester, game.item!.position, wrong.position);
    await settle(tester, seconds: 1);
    expect(game.item!.position.distanceTo(home), lessThan(2), reason: 'went home');
    expect(game.zones[r.answer].hinting, isTrue);
    await dragGame(tester, game.item!.position, game.zones[r.answer].position);
    await settle(tester, seconds: 2);

    r = game.round!;
    await dragGame(tester, game.item!.position, game.zones[r.answer].position);
    await settle(tester);
    expect(results.single.rounds, 2);
    expect(results.single.firstTry, 1);
    expect(deps.mastery.data['test.skill']!.attempts, 2);
  });

  testWidgets('tapping the item names it', (tester) async {
    final def = gameDef('drag_to_target', {'mode': 'habitat', 'items': 'tag:animal', 'targets': 2});
    final (game, _, deps) = await pumpEngine<DragToTargetGame>(tester, const DragToTargetEngine(), def, lib);
    await tapGame(tester, game.item!.position);
    expect(deps.audio.played.last, startsWith('audio/en/vocab'));
    await settle(tester);
  });

  for (final mode in ['food', 'shape_hole']) {
    testWidgets('golden $mode', (tester) async {
      final def = gameDef('drag_to_target', {'mode': mode, 'targets': 3, if (mode == 'food') 'items': 'tag:animal'});
      await pumpEngine<DragToTargetGame>(
        tester,
        const DragToTargetEngine(),
        def,
        lib,
        locale: mode == 'food' ? 'sq' : 'en',
      );
      await expectGolden(tester, 'drag_to_target_$mode');
    });
  }
}
