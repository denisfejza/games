import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/strings.dart';
import '../app/ui/big_button.dart';
import '../app/ui/hear_again_button.dart';
import '../app/ui/patterns.dart';
import '../app/ui/tokens.dart';
import '../content/models.dart';
import '../l10n/app_localizations.dart';
import 'ground.dart';
import 'title_banner.dart';
import 'world_style.dart';

/// Levels inside one world, on the world's own colour and pattern.
/// TODO(1.5): level path with stars and the episode runner.
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
    final style = WorldStyle.of(widget.world.icon);
    final levels = widget.world.levelsFor(ref.watch(ageBandProvider));
    final tile = MediaQuery.sizeOf(context).shortestSide >= 600 ? 170.0 : 130.0;
    return Scaffold(
      body: PatternBackground(
        color: style.color,
        pattern: style.pattern,
        child: SafeArea(
          bottom: false,
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: TitleBanner(
                            title: lookupString(l, widget.world.titleKey) ?? '',
                            color: style.color,
                            height: 84,
                          ),
                        ),
                      ),
                    ),
                    const HearAgainButton(),
                  ],
                ),
              ),
              Expanded(
                child: levels.isEmpty
                    // Not built yet: Pip says so; never a padlock (CLAUDE.md / PLAN 1.4).
                    ? Center(
                        child: BigButton(
                          key: const Key('comingSoon'),
                          art: style.art,
                          sticker: true,
                          size: tile * 1.4,
                          color: style.color,
                          onPressed: () => ref.read(audioServiceProvider).say('comingSoon', interrupt: true),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Wrap(
                            spacing: 28,
                            runSpacing: 28,
                            children: [
                              for (final level in levels)
                                BigButton(
                                  key: Key('level.${level.number}'),
                                  art: (s) => levelArt(level.number, style.color, s),
                                  sticker: true,
                                  outlinedLabel: true,
                                  size: tile,
                                  color: style.color,
                                  label: l.levelNumber(level.number),
                                  // TODO(1.5): start the episode runner.
                                  onPressed: () {},
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
              const GroundWithPip(pipSize: 96),
            ],
          ),
        ),
      ),
    );
  }
}
