import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/worlds/world_map_screen.dart';

import '../helpers.dart';

/// PLAN 1.4: the map at the three age-band themes, in both languages.
/// Refresh with: flutter test --update-goldens test/worlds/map_golden_test.dart
void main() {
  for (final band in AgeBand.values) {
    for (final locale in ['en', 'sq']) {
      testWidgets('map ${band.json} $locale', (tester) async {
        setScreen(tester, band == AgeBand.school ? tablet : phone);
        final content = await tester.runAsync(loadBundledContent);
        await tester.pumpWidget(testApp(child: const WorldMapScreen(), content: content, band: band, locale: locale));
        await tester.pump(const Duration(seconds: 2));
        await expectLater(find.byType(WorldMapScreen), matchesGoldenFile('../goldens/map_${band.json}_$locale.png'));
        // Every world is reachable by picture: six tiles, each with an icon/drawing.
        expect(
          find.byWidgetPredicate(
            (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('world.'),
          ),
          findsNWidgets(6),
        );
      });
    }
  }
}
