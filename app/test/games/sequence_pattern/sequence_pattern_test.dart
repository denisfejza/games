import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/sequence_pattern/sequence_pattern_game.dart';

import '../engine_harness.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  test('the answer continues the pattern', () {
    for (final pattern in ['AB', 'AAB', 'ABB', 'ABC', 'AABB']) {
      final c = SequencePatternConfig.parse({
        'patterns': [pattern],
        'length': 5,
        'choices': 3,
      }, lib);
      final r = nextPattern(c, Random(pattern.length));
      final full = [...r.shown, r.answer];
      for (var i = pattern.length; i < full.length; i++) {
        expect(full[i].id, full[i - pattern.length].id, reason: pattern);
      }
      expect(r.choices[r.answerIndex].id, r.answer.id);
      expect({for (final c in r.choices) c.id}, hasLength(r.choices.length));
    }
  });

  test('validate', () {
    expect(
      SequencePatternConfig.validate(
        gameDef('sequence_pattern', {
          'patterns': ['AXB'],
        }),
        lib,
      ),
      isNotEmpty,
    );
    expect(
      SequencePatternConfig.validate(
        gameDef('sequence_pattern', {
          'patterns': ['ABC'],
          'items': ['red', 'blue'],
        }),
        lib,
      ),
      isNotEmpty,
    );
  });

  testWidgets('tap the next one to fill the gap', (tester) async {
    final def = gameDef('sequence_pattern', {'rounds': 2, 'choices': 2}, world: 'shapes_colours');
    final (game, results, _) = await pumpEngine<SequencePatternGame>(tester, const SequencePatternEngine(), def, lib);
    for (var i = 0; i < 2; i++) {
      final r = game.round!;
      await tapGame(tester, game.choices[1 - r.answerIndex].position);
      await tapGame(tester, game.choices[r.answerIndex].position);
      await settle(tester, seconds: 2);
    }
    await settle(tester);
    expect(results.single.firstTry, 0);
    expect(results.single.hints, 2);
  });

  testWidgets('golden', (tester) async {
    await pumpEngine<SequencePatternGame>(
      tester,
      const SequencePatternEngine(),
      gameDef('sequence_pattern', {
        'patterns': ['ABB'],
        'items': 'tag:shape',
        'length': 5,
      }, world: 'shapes_colours'),
      lib,
    );
    await expectGolden(tester, 'sequence_pattern');
  });
}
