import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/strings.dart';
import '../app/ui/big_button.dart';
import '../app/ui/caption_bar.dart';
import '../app/ui/hear_again_button.dart';
import '../app/ui/tokens.dart';
import '../content/models.dart';
import '../l10n/app_localizations.dart';
import 'world_icons.dart';

/// Levels inside one world. TODO(1.5): level path with stars and the episode runner.
class WorldScreen extends ConsumerStatefulWidget {
  const WorldScreen({super.key, required this.world});

  final World world;

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasLevels = widget.world.levelsFor(ref.read(ageBandProvider)).isNotEmpty;
      ref.read(audioServiceProvider).say(hasLevels ? widget.world.titleKey : 'comingSoon', interrupt: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = AgeBandTheme.of(context);
    final levels = widget.world.levelsFor(ref.watch(ageBandProvider));
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  BigButton(
                    key: const Key('back'),
                    icon: Icons.arrow_back_rounded,
                    color: tokens.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      lookupString(l, widget.world.titleKey) ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const HearAgainButton(),
                ],
              ),
            ),
            Expanded(
              child: levels.isEmpty
                  // Not yet built: Pip says so; never a padlock (CLAUDE.md / PLAN 1.4).
                  ? Center(child: Icon(worldIcon(widget.world.icon), size: 160, color: tokens.primary))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            for (final level in levels)
                              BigButton(
                                key: Key('level.${level.number}'),
                                icon: levelIcon(level.number),
                                color: tokens.success,
                                label: l.levelNumber(level.number),
                                // TODO(1.5): start the episode runner.
                                onPressed: () {},
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
            const CaptionBar(),
          ],
        ),
      ),
    );
  }
}
