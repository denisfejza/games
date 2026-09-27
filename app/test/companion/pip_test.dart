import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/companion/pip_controller.dart';
import 'package:pips_world/companion/pip_painter.dart';
import 'package:pips_world/companion/pip_view.dart';
import 'package:pips_world/content/vocab.dart';

import '../helpers.dart';

void main() {
  group('PipController', () {
    test('reactions return to idle; errors make Pip curious, not sad', () {
      fakeAsync((async) {
        final pip = PipController();
        pip.onEvent(PipEvent.correct);
        expect(pip.mood, PipMood.happy);
        async.elapse(const Duration(seconds: 2));
        expect(pip.mood, PipMood.idle);
        pip.onEvent(PipEvent.tryAgain);
        expect(pip.mood, PipMood.thinking);
        pip.onEvent(PipEvent.levelDone);
        expect(pip.mood, PipMood.celebrate);
        async.elapse(const Duration(seconds: 3));
        expect(pip.mood, PipMood.idle);
      });
    });

    test('at bedtime Pip stays sleepy after a reaction', () {
      fakeAsync((async) {
        final pip = PipController()..onEvent(PipEvent.bedtime);
        pip.onEvent(PipEvent.poked);
        async.elapse(const Duration(seconds: 2));
        expect(pip.mood, PipMood.sleepy);
        pip.onEvent(PipEvent.wake);
        expect(pip.mood, PipMood.idle);
      });
    });

    test('listening while the child speaks', () {
      final pip = PipController()..onEvent(PipEvent.childSpeaking);
      expect(pip.mood, PipMood.listening);
      pip.onEvent(PipEvent.childDone);
      expect(pip.mood, PipMood.idle);
    });
  });

  test('tap areas map to body parts', () {
    const size = Size(100, 120);
    expect(PipPainter.partAt(const Offset(50, 42), size), PipPart.nose);
    expect(PipPainter.partAt(const Offset(12, 8), size), PipPart.ear);
    expect(PipPainter.partAt(const Offset(50, 95), size), PipPart.belly);
    expect(PipPainter.partAt(const Offset(50, 112), size), PipPart.feet);
  });

  testWidgets('every mood draws', (tester) async {
    for (final mood in PipMood.values) {
      await tester.pumpWidget(
        Center(
          child: CustomPaint(
            size: const Size(200, 240),
            painter: PipPainter(mood: mood, mouthOpen: 0.5),
          ),
        ),
      );
    }
    expect(tester.takeException(), isNull);
  });

  group('PokeablePip', () {
    Future<(TestDeps, Offset, Size)> pump(WidgetTester tester) async {
      setScreen(tester, tablet);
      final deps = TestDeps();
      await tester.pumpWidget(
        testApp(
          deps: deps,
          child: const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PokeablePip(width: 200),
                  SizedBox(height: 40),
                  FoodItem(
                    key: Key('food'),
                    item: VocabItem(id: 'apple', nameKey: 'vocab.apple', picture: EmojiPicture('🍎'), tags: {}),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final box = tester.getRect(find.byKey(const Key('pip')));
      return (deps, box.topLeft, box.size);
    }

    Offset at(Offset origin, Size size, double x, double y) => origin + Offset(x * size.width, y * size.width);

    testWidgets('poking the nose names it and responds straight away', (tester) async {
      final (deps, origin, size) = await pump(tester);
      await tester.tapAt(at(origin, size, 0.5, 0.43));
      await tester.pump();
      expect(deps.audio.effects, contains('audio/sfx/pop.mp3'));
      expect(deps.audio.played.last, 'audio/en/vocabNose.ogg');
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('three quick belly taps are a tickle', (tester) async {
      final (deps, origin, size) = await pump(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tapAt(at(origin, size, 0.5, 0.9));
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(deps.audio.played.last, 'audio/en/pipTickle.ogg');
      expect(deps.audio.effects, contains('audio/sfx/giggle.mp3'));
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('dragging food onto Pip feeds him', (tester) async {
      final (deps, origin, size) = await pump(tester);
      final food = tester.getCenter(find.byKey(const Key('food')));
      final g = await tester.startGesture(food);
      await g.moveTo(at(origin, size, 0.5, 0.5), timeStamp: const Duration(milliseconds: 100));
      await tester.pump();
      await g.up();
      await tester.pump();
      expect(deps.audio.played.last, 'audio/en/pipYum.ogg');
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
