import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/strings.dart';
import 'package:pips_world/app/ui/big_button.dart';
import 'package:pips_world/l10n/app_localizations.dart';
import 'package:pips_world/worlds/world_style.dart';

import '../helpers.dart';

/// Goldens are rendered on Linux (like CI). Refresh with:
///   flutter test --update-goldens test/app/big_button_golden_test.dart
void main() {
  for (final locale in ['en', 'sq']) {
    for (final (name, size) in [('phone', phone), ('tablet', tablet)]) {
      testWidgets('BigButton $locale $name', (tester) async {
        setScreen(tester, size);
        await tester.pumpWidget(
          testApp(
            audio: FakeAudioBackend(),
            locale: locale,
            child: Builder(
              builder: (context) {
                final l = AppLocalizations.of(context);
                return Scaffold(
                  body: Center(
                    child: RepaintBoundary(
                      key: const Key('golden'),
                      child: Container(
                        color: const Color(0xFF8E5CF7),
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final (key, icon) in [
                              ('worldAnimals', Icons.pets),
                              ('worldShapesColours', Icons.category_rounded),
                              ('worldPipsHouse', Icons.cottage_rounded),
                            ])
                              BigButton(
                                key: Key(key),
                                icon: icon,
                                speakKey: key,
                                label: lookupString(l, key),
                                onPressed: () {},
                              ),
                            // Sticker tiles as used on the world map.
                            for (final (key, world) in [('worldNumbers', 'numbers'), ('worldLetters', 'letters')])
                              BigButton(
                                key: Key(key),
                                art: WorldStyle.of(world).art,
                                sticker: true,
                                outlinedLabel: true,
                                color: WorldStyle.of(world).color,
                                speakKey: key,
                                label: lookupString(l, key),
                                onPressed: () {},
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        // Arm the last button so the golden also covers the highlighted state.
        await tester.tap(find.byKey(const Key('worldPipsHouse')));
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(const Key('golden')),
          matchesGoldenFile('../goldens/big_button_${locale}_$name.png'),
        );
        await tester.pump(const Duration(seconds: 7)); // let the arm timer finish
      });
    }
  }
}
