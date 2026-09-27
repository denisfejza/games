import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/games/common/pools.dart';
import 'package:pips_world/games/trace_path/glyph_strokes.dart';
import 'package:pips_world/games/trace_path/trace_path_config.dart';
import 'package:pips_world/games/trace_path/trace_path_game.dart';
import 'package:pips_world/games/trace_path/trace_progress.dart';

import '../engine_harness.dart';

void main() {
  test('stroke data exists for all 36 Albanian letters, 26 English letters, digits and shapes', () {
    for (final l in {...sqLetters, ...enLetters}) {
      expect(glyphFor(l), isNotNull, reason: l);
    }
    for (var d = 0; d <= 9; d++) {
      expect(glyphFor('$d'), isNotNull);
    }
    expect(glyphFor('sh')!.width, greaterThan(1), reason: 'digraphs are one wide tile');
  });

  test('following each glyph exactly completes it', () {
    for (final id in traceableIds) {
      final p = TraceProgress(glyphFor(id)!);
      for (final s in glyphFor(id)!.strokes) {
        for (final pt in s) {
          p.update(pt);
        }
      }
      expect(p.done, isTrue, reason: id);
    }
  });

  test('a wobbly trace still counts; a scribble elsewhere does not', () {
    final r = Random(4);
    final wobbly = TraceProgress(glyphFor('o')!);
    for (final pt in glyphFor('o')!.strokes.single) {
      wobbly.update(pt + Offset(r.nextDouble() * 0.16 - 0.08, r.nextDouble() * 0.16 - 0.08));
    }
    expect(wobbly.done, isTrue);

    final scribble = TraceProgress(glyphFor('o')!);
    for (var i = 0; i < 100; i++) {
      scribble.update(Offset(0.95, 0.05 + i * 0.01));
    }
    expect(scribble.done, isFalse);
  });

  test('you cannot skip to the end of a stroke', () {
    final p = TraceProgress(glyphFor('l')!);
    p.update(glyphFor('l')!.strokes.single.last);
    expect(p.done, isFalse);
  });

  test('prompt keys: letters, numbers and shapes', () {
    expect(TracePathConfig.promptKey('sh', 'sq'), 'letter.sq.sh');
    expect(TracePathConfig.promptKey('7', 'en'), 'num7');
    expect(TracePathConfig.promptKey('star', 'en'), 'shape.star');
    expect(
      TracePathConfig.validate(
        gameDef('trace_path', {
          'glyphs': ['a', 'ŋ'],
        }),
        _emptyLib,
      ),
      hasLength(1),
    );
  });

  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContentForTest());

  testWidgets('tracing with a finger; lifting off the path gives a hint', (tester) async {
    final def = gameDef('trace_path', {
      'glyphs': ['l', 'i'],
    }, world: 'letters');
    final (game, results, deps) = await pumpEngine<TracePathGame>(tester, const TracePathEngine(), def, lib);
    expect(deps.audio.played.last, 'audio/en/letterEnL.ogg');

    Vector2 at(Offset g) => game.board!.position + Vector2(g.dx, g.dy) * game.board!.unit;
    // A drag nowhere near the letter: a miss (hint after one on step 1).
    await dragGame(tester, at(const Offset(0.05, 0.1)), at(const Offset(0.1, 0.2)));
    expect(results, isEmpty);

    // Trace "l" top to bottom.
    await dragGame(tester, at(const Offset(0.5, 0.0)), at(const Offset(0.5, 1.0)));
    await settle(tester, seconds: 2);
    expect(game.glyphId, 'i');
    // "i": the line, then the dot.
    await dragGame(tester, at(const Offset(0.5, 0.42)), at(const Offset(0.5, 1.0)));
    await dragGame(tester, at(const Offset(0.5, 0.19)), at(const Offset(0.5, 0.26)));
    await settle(tester);
    expect(results.single.rounds, 2);
    expect(results.single.hints, 1);
  });

  for (final g in ['a', 'sh']) {
    testWidgets('golden $g', (tester) async {
      await pumpEngine<TracePathGame>(
        tester,
        const TracePathEngine(),
        gameDef('trace_path', {
          'glyphs': [g],
        }, world: 'letters'),
        lib,
        locale: 'sq',
      );
      await expectGolden(tester, 'trace_path_$g');
    });
  }
}

final _emptyLib = ContentLibrary.fromFiles(const {}, schemaForTest());
