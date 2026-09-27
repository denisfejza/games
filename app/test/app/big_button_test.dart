import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/ui/big_button.dart';
import 'package:pips_world/app/ui/tokens.dart';
import 'package:pips_world/content/models.dart';

import '../helpers.dart';

void main() {
  late FakeAudioBackend audio;
  late int pressed;

  setUp(() {
    audio = FakeAudioBackend();
    pressed = 0;
  });

  Widget button({String? speakKey = 'worldAnimals', AgeBand band = AgeBand.preschool}) => testApp(
    audio: audio,
    band: band,
    child: Scaffold(
      body: Center(
        child: BigButton(
          key: const Key('b'),
          icon: Icons.pets,
          label: 'Animals',
          speakKey: speakKey,
          onPressed: () => pressed++,
        ),
      ),
    ),
  );

  Future<void> tapAndWait(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('b')));
    await tester.pump(const Duration(milliseconds: 400)); // past the debounce
  }

  testWidgets('first tap speaks, second tap activates', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button());
    await tapAndWait(tester);
    expect(audio.played, ['audio/en/worldAnimals.ogg']);
    expect(pressed, 0);
    await tapAndWait(tester);
    expect(pressed, 1);
  });

  testWidgets('arming wears off, so a later tap speaks again', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button());
    await tapAndWait(tester);
    await tester.pump(const Duration(seconds: 7));
    await tapAndWait(tester);
    expect(pressed, 0);
    expect(audio.played, hasLength(2));
  });

  testWidgets('without a speak key every tap activates', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button(speakKey: null));
    await tapAndWait(tester);
    await tapAndWait(tester);
    expect(pressed, 2);
  });

  testWidgets('rapid repeat taps are debounced', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button(speakKey: null));
    await tester.tap(find.byKey(const Key('b')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const Key('b')));
    await tester.pump();
    expect(pressed, 1);
  });

  testWidgets('palm-sized touches are ignored', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button(speakKey: null));
    final center = tester.getCenter(find.byKey(const Key('b')));
    await tester.sendEventToBinding(PointerDownEvent(position: center, radiusMajor: 60, pointer: 9));
    await tester.sendEventToBinding(PointerUpEvent(position: center, pointer: 9));
    await tester.pump();
    expect(pressed, 0);
  });

  testWidgets('a second finger cancels the tap', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button(speakKey: null));
    final center = tester.getCenter(find.byKey(const Key('b')));
    final one = await tester.startGesture(center, pointer: 1);
    final two = await tester.startGesture(center + const Offset(10, 0), pointer: 2);
    await one.up();
    await two.up();
    await tester.pump();
    expect(pressed, 0);
  });

  testWidgets('dragging off is not a tap', (tester) async {
    setScreen(tester, phone);
    await tester.pumpWidget(button(speakKey: null));
    final g = await tester.startGesture(tester.getCenter(find.byKey(const Key('b'))));
    await g.moveBy(const Offset(60, 0));
    await g.up();
    await tester.pump();
    expect(pressed, 0);
  });

  for (final band in AgeBand.values) {
    for (final (name, size) in [('phone', phone), ('tablet', tablet)]) {
      testWidgets('touch target ≥ 76 dp ($name, ${band.json})', (tester) async {
        setScreen(tester, size);
        await tester.pumpWidget(button(band: band));
        final face = tester.getSize(
          find.descendant(of: find.byKey(const Key('b')), matching: find.byType(AnimatedContainer)),
        );
        expect(face.shortestSide, greaterThanOrEqualTo(76));
        expect(face.shortestSide, AgeBandTokens.of(band).minTarget * (size == tablet ? 1.25 : 1));
      });
    }
  }
}
