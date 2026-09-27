import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/core/parental_gate/gate_logic.dart';
import 'package:pips_world/core/parental_gate/number_words.dart';
import 'package:pips_world/core/parental_gate/parental_gate.dart';

import '../helpers.dart';

List<int> digitsOf(int n) => [for (final c in '$n'.split('')) int.parse(c)];

void main() {
  group('numberToWords', () {
    test('English', () {
      expect(numberToWords(427, 'en'), 'four hundred twenty-seven');
      expect(numberToWords(305, 'en'), 'three hundred five');
      expect(numberToWords(910, 'en'), 'nine hundred ten');
      expect(numberToWords(118, 'en'), 'one hundred eighteen');
      expect(numberToWords(760, 'en'), 'seven hundred sixty');
    });

    test('Albanian', () {
      expect(numberToWords(427, 'sq'), 'katërqind e njëzet e shtatë');
      expect(numberToWords(305, 'sq'), 'treqind e pesë');
      expect(numberToWords(910, 'sq'), 'nëntëqind e dhjetë');
      expect(numberToWords(118, 'sq'), 'njëqind e tetëmbëdhjetë');
      expect(numberToWords(760, 'sq'), 'shtatëqind e gjashtëdhjetë');
      expect(numberToWords(200, 'sq'), 'dyqind');
    });

    test('rejects out-of-range numbers', () {
      expect(() => numberToWords(0, 'en'), throwsRangeError);
      expect(() => numberToWords(1000, 'sq'), throwsRangeError);
    });
  });

  group('GateChallenge', () {
    test('always three digits and never all the same', () {
      for (var seed = 0; seed < 200; seed++) {
        final n = GateChallenge(random: Random(seed)).number;
        expect(n, inInclusiveRange(100, 999));
        expect(n % 111, isNot(0));
      }
    });

    test('passes on the right digits', () {
      final gate = GateChallenge(random: Random(1));
      final d = digitsOf(gate.number);
      expect(gate.enter(d[0]), GateResult.pending);
      expect(gate.enter(d[1]), GateResult.pending);
      expect(gate.enter(d[2]), GateResult.passed);
    });

    test('a wrong answer picks a new number and clears input', () {
      final gate = GateChallenge(random: Random(2));
      final before = gate.number;
      final wrong = before == 123 ? 124 : 123;
      final d = digitsOf(wrong);
      gate
        ..enter(d[0])
        ..enter(d[1]);
      expect(gate.enter(d[2]), GateResult.failed);
      expect(gate.input, isEmpty);
      expect(gate.number, isNot(before));
    });

    test('delete removes the last digit', () {
      final gate = GateChallenge(random: Random(3))
        ..enter(1)
        ..enter(2)
        ..deleteLast();
      expect(gate.input, '1');
    });
  });

  group('ParentalGate widget', () {
    Future<List<bool>> openGate(WidgetTester tester) async {
      setScreen(tester, tablet);
      final results = <bool>[];
      await tester.pumpWidget(
        testApp(
          audio: FakeAudioBackend(),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async => results.add(await ParentalGate.request(context, random: Random(7))),
                  child: const Text('protected'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('protected'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('typing the spoken number passes', (tester) async {
      final results = await openGate(tester);
      final number = GateChallenge(random: Random(7)).number;
      expect(find.text(numberToWords(number, 'en')), findsOneWidget);
      for (final d in digitsOf(number)) {
        await tester.tap(find.byKey(Key('gate.digit.$d')));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('back navigation cannot bypass the gate', (tester) async {
      final results = await openGate(tester);
      final handled = await tester.binding.handlePopRoute(); // Android back button
      await tester.pumpAndSettle();
      expect(handled, isTrue);
      expect(results, [false]);
      expect(find.text('protected'), findsOneWidget);
    });

    testWidgets('cancel denies access', (tester) async {
      final results = await openGate(tester);
      await tester.tap(find.byKey(const Key('gate.cancel')));
      await tester.pumpAndSettle();
      expect(results, [false]);
    });

    testWidgets('open() never shows the page when the gate is dismissed', (tester) async {
      setScreen(tester, tablet);
      await tester.pumpWidget(
        testApp(
          audio: FakeAudioBackend(),
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => ParentalGate.open(context, (_) => const Text('settings page')),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('settings page'), findsNothing);
    });
  });
}
