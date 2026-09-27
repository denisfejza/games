import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/worlds/world_map_screen.dart';

import 'helpers.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) => {
  for (final k in arb.keys)
    if (!k.startsWith('@')) k,
};

/// `{name}` placeholders used in a message (ICU plural bodies included).
Set<String> _placeholders(String message) => {for (final m in RegExp(r'\{(\w+)[,}]').allMatches(message)) m.group(1)!};

void main() {
  final en = _arb('en');
  final sq = _arb('sq');

  test('every English key exists in Albanian, and nothing extra', () {
    expect(_keys(sq).difference(_keys(en)), isEmpty, reason: 'keys only in sq');
    expect(_keys(en).difference(_keys(sq)), isEmpty, reason: 'keys missing from sq');
  });

  test('translations use the same placeholders', () {
    for (final key in _keys(en)) {
      expect(_placeholders(sq[key] as String), _placeholders(en[key] as String), reason: key);
    }
  });

  test('counts use ICU plurals, never concatenation', () {
    expect(sq['levelGames'], contains('plural'));
    expect(en['levelGames'], contains('plural'));
  });

  testWidgets('map screen greets Pip in Albanian with ë rendered', (tester) async {
    setScreen(tester, tablet);
    final content = await tester.runAsync(loadBundledContent);
    await tester.pumpWidget(
      testApp(child: const WorldMapScreen(), audio: FakeAudioBackend(), locale: 'sq', content: content),
    );
    await tester.pump();
    expect(find.text('Përshëndetje, Pip!'), findsOneWidget);
    expect(find.text('Kafshët'), findsOneWidget);
  });

  testWidgets('map screen greets Pip in English', (tester) async {
    setScreen(tester, tablet);
    final content = await tester.runAsync(loadBundledContent);
    await tester.pumpWidget(testApp(child: const WorldMapScreen(), audio: FakeAudioBackend(), content: content));
    await tester.pump();
    expect(find.text('Hello, Pip!'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
  });
}
