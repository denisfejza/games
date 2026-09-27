import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/companion/costumes.dart';
import 'package:pips_world/companion/pip_controller.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/core/voice/voice_service.dart';
import 'package:pips_world/worlds/pips_house/pips_house_screen.dart';

import '../helpers.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContent());

  test('every sticker and costume is in the placeholder emoji font', () {
    final inFont = File('tool/emoji_used.txt').readAsStringSync() + File('tool/emoji_extra.txt').readAsStringSync();
    for (final e in [...stickers, for (final c in costumes) c.emoji]) {
      expect(inFont, contains(e.replaceAll('\u{FE0F}', '')), reason: e);
    }
  });

  test('costumes unlock by stars in a fixed order (no random rewards)', () {
    final thresholds = [for (final c in costumes) c.stars];
    expect(thresholds, orderedEquals([...thresholds]..sort()));
  });

  Future<TestDeps> pump(WidgetTester tester, {int stars = 0, bool mic = false}) async {
    setScreen(tester, tablet);
    final deps = TestDeps();
    for (var i = 0; i < stars; i++) {
      deps.progress.data['animals.l${i + 1}'] = 1;
    }
    if (mic) {
      deps.settings.data['micEnabled'] = 'true';
      deps.recorder.state = MicPermission.granted;
    }
    await tester.pumpWidget(testApp(deps: deps, content: lib, child: const PipsHouseScreen()));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    return deps;
  }

  testWidgets('feed Pip by dragging food onto him', (tester) async {
    final deps = await pump(tester);
    expect(deps.audio.played.first, 'audio/en/pipHouseHello.ogg');
    final g = await tester.startGesture(tester.getCenter(find.byKey(const Key('food.apple'))));
    await g.moveTo(tester.getCenter(find.byKey(const Key('house.pip'))), timeStamp: const Duration(milliseconds: 100));
    await tester.pump();
    await g.up();
    await tester.pump();
    expect(deps.audio.played.last, 'audio/en/pipYum.ogg');
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('costumes need stars; worn costume is remembered', (tester) async {
    final deps = await pump(tester, stars: 3);
    await tester.tap(find.byKey(const Key('house.wardrobe')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('house.wardrobe')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('costume.crown')));
    await tester.pump();
    expect(deps.audio.played.last, 'audio/en/costumeMore.ogg');
    await tester.tap(find.byKey(const Key('costume.bow')));
    await tester.pump();
    expect(deps.settings.data['pipCostume'], 'bow');
    expect(find.text('🎀'), findsWidgets);
    await tester.pump(const Duration(seconds: 7));
  });

  testWidgets('sticker book shows one sticker per star', (tester) async {
    await pump(tester, stars: 4);
    await tester.tap(find.byKey(const Key('house.stickers')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('house.stickers')));
    await tester.pumpAndSettle();
    expect(find.text(stickers[3]), findsOneWidget);
    expect(find.text(stickers[4]), findsNothing);
    await tester.pump(const Duration(seconds: 7));
  });

  testWidgets('no talk button until a grown-up turns the mic on', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('house.talk')), findsNothing);
  });

  testWidgets('talk-back: Pip listens, echoes, and the recording is discarded', (tester) async {
    final deps = await pump(tester, mic: true);
    await tester.tap(find.byKey(const Key('house.talk')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('house.talk')));
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      deps.recorder.level(0.3);
      await tester.pump(const Duration(milliseconds: 50));
    }
    deps.recorder.level(0);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(deps.player.rates, [TalkBack.pitchRate]);
    expect(deps.recorder.clips.single.discarded, isTrue);
    await tester.pump(const Duration(seconds: 7));
  });

  testWidgets('bedtime puts Pip to sleep and wakes him', (tester) async {
    final deps = await pump(tester);
    await tester.tap(find.byKey(const Key('house.bedtime')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('house.bedtime')));
    await tester.pump();
    expect(deps.audio.played.last, 'audio/en/pipGoodnight.ogg');
    expect(PipMood.values, contains(PipMood.sleepy));
    await tester.pump(const Duration(seconds: 7));
  });
}
