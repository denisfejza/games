import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/debug_menu.dart';
import '../app/providers.dart';
import '../app/strings.dart';
import '../app/ui/big_button.dart';
import '../app/ui/caption_bar.dart';
import '../app/ui/hear_again_button.dart';
import '../content/models.dart';
import '../core/parental_gate/parental_gate.dart';
import '../l10n/app_localizations.dart';
import 'world_icons.dart';
import 'world_screen.dart';

/// Shows the settings button in debug builds and in preview builds made with
/// `--dart-define=PIP_DEBUG_MENU=true`. It is behind the parental gate either way.
const showDebugMenu = kDebugMode || bool.fromEnvironment('PIP_DEBUG_MENU');

/// Main menu: one big button per world. Pip names a world on the first tap;
/// the second tap goes in. TODO(1.4): scrollable illustrated map.
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({super.key});

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(audioServiceProvider).say('helloPip');
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = ref.watch(contentProvider);
    final band = ref.watch(ageBandProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const HearAgainButton(),
                  Expanded(
                    child: Text(
                      l.helloPip,
                      key: const Key('greeting'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (showDebugMenu)
                    IconButton(
                      key: const Key('openSettings'),
                      tooltip: l.debugMenu,
                      iconSize: 32,
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () => ParentalGate.open(context, (_) => const DebugMenu()),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: switch (content) {
                AsyncData(:final value) => _WorldGrid(
                  worlds: [
                    for (final w in value.worlds)
                      if (w.ageBands.contains(band)) w,
                  ],
                ),
                AsyncError(:final error) => Center(child: Text('$error')),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            const CaptionBar(),
          ],
        ),
      ),
    );
  }
}

class _WorldGrid extends StatelessWidget {
  const _WorldGrid({required this.worlds});

  final List<World> worlds;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            for (final w in worlds)
              BigButton(
                key: Key('world.${w.id}'),
                icon: worldIcon(w.icon),
                speakKey: w.titleKey,
                label: lookupString(l, w.titleKey),
                onPressed: () =>
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WorldScreen(world: w))),
              ),
          ],
        ),
      ),
    );
  }
}
