import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/bedtime.dart';
import 'package:pips_world/core/parental_gate/gate_logic.dart';

import '../helpers.dart';

void main() {
  testWidgets('at the limit Pip goes to bed; only a grown-up can continue', (tester) async {
    setScreen(tester, tablet);
    final deps = TestDeps();
    final today = DateTime.now();
    final day =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    deps.settings.data
      ..['dailyLimitMinutes'] = '5'
      ..['usage.$day'] = '${5 * 60}';
    await tester.pumpWidget(
      testApp(
        deps: deps,
        playTimeGuard: true,
        child: const Scaffold(body: Text('child screen')),
      ),
    );
    await tester.pump();
    expect(find.byType(BedtimeScreen), findsOneWidget);
    expect(deps.audio.played, contains('audio/en/bedtimePipSleepy.ogg'));

    // Back does not dismiss it.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(BedtimeScreen), findsOneWidget);

    // Grown-up: pass the gate and add 10 minutes.
    await tester.tap(find.byKey(const Key('bedtime.grownUp')));
    await tester.pumpAndSettle();
    final words = tester.widget<Text>(find.byKey(const Key('gate.words'))).data!;
    int? number;
    for (var n = 100; n < 1000 && number == null; n++) {
      if (GateChallenge.wordsFor(n, 'en') == words) number = n;
    }
    for (final c in '$number'.split('')) {
      await tester.tap(find.byKey(Key('gate.digit.$c')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('extra.10')));
    await tester.pumpAndSettle();
    expect(find.byType(BedtimeScreen), findsNothing);
    expect(find.text('child screen'), findsOneWidget);
  });
}
