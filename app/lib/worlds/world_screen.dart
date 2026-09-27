import 'dart:math';

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
import 'episode_screen.dart';
import 'ground.dart';
import 'level_status.dart';
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

  void _open(Level level, LevelStatus? status) {
    if (status?.unlocked != true) {
      // Not a padlock: Pip just points back to the level to play first.
      ref.read(audioServiceProvider).say('levelNotYet', interrupt: true);
      return;
    }
    final content = ref.read(contentProvider).value;
    if (content == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EpisodeScreen(world: widget.world, level: level, content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = AgeBandTheme.of(context);
    final style = WorldStyle.of(widget.world.icon);
    final levels = widget.world.levelsFor(ref.watch(ageBandProvider));
    final statuses = ref.watch(levelStatusProvider(widget.world.id)).value ?? const {};
    final tile = MediaQuery.sizeOf(context).shortestSide >= 600 ? 150.0 : 116.0;
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
                    : LevelPath(
                        levels: levels,
                        statuses: statuses,
                        tile: tile,
                        color: style.color,
                        label: (n) => l.levelNumber(n),
                        onOpen: _open,
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

/// Levels along a winding dotted path, left-right-left, scrolling down.
class LevelPath extends StatelessWidget {
  const LevelPath({
    super.key,
    required this.levels,
    required this.statuses,
    required this.tile,
    required this.color,
    required this.label,
    required this.onOpen,
  });

  final List<Level> levels;
  final Map<int, LevelStatus> statuses;
  final double tile;
  final Color color;
  final String Function(int number) label;
  final void Function(Level level, LevelStatus? status) onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final perRow = max(1, min(levels.length, (box.maxWidth / (tile * 1.7)).floor()));
      final rowHeight = tile * 1.75;
      final rows = (levels.length / perRow).ceil();
      final cellW = box.maxWidth / perRow;
      Offset centre(int i) {
        final row = i ~/ perRow;
        final col = row.isEven ? i % perRow : perRow - 1 - i % perRow;
        return Offset(cellW * (col + 0.5), rowHeight * (row + 0.5));
      }

      return SingleChildScrollView(
        child: SizedBox(
          height: rows * rowHeight + 24,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _PathPainter([for (var i = 0; i < levels.length; i++) centre(i)])),
              ),
              for (var i = 0; i < levels.length; i++)
                Positioned(
                  left: centre(i).dx - tile * 0.8,
                  top: centre(i).dy - tile * 0.62,
                  width: tile * 1.6,
                  child: _LevelTile(
                    level: levels[i],
                    status: statuses[levels[i].number],
                    tile: tile,
                    color: color,
                    label: label(levels[i].number),
                    onOpen: onOpen,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.level,
    required this.status,
    required this.tile,
    required this.color,
    required this.label,
    required this.onOpen,
  });

  final Level level;
  final LevelStatus? status;
  final double tile;
  final Color color;
  final String label;
  final void Function(Level level, LevelStatus? status) onOpen;

  @override
  Widget build(BuildContext context) {
    final open = status?.unlocked ?? level.number == 1;
    final stars = status?.stars;
    return Opacity(
      // Not-yet levels are faded, never padlocked (CLAUDE.md UI rules).
      opacity: open ? 1 : 0.55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BigButton(
            key: Key('level.${level.number}'),
            art: (s) => levelArt(level.number, color, s),
            sticker: true,
            outlinedLabel: true,
            size: tile,
            color: color,
            label: label,
            onPressed: () => onOpen(level, status),
          ),
          if (stars != null)
            Row(
              key: Key('level.${level.number}.stars.$stars'),
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: tile * 0.24,
                    color: const Color(0xFFFFD23D),
                    shadows: const [Shadow(color: Color(0x66000000), offset: Offset(0, 2))],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.75);
    for (var i = 0; i + 1 < points.length; i++) {
      final a = points[i];
      final b = points[i + 1];
      final steps = ((b - a).distance / 22).floor();
      for (var s = 1; s < steps; s++) {
        canvas.drawCircle(Offset.lerp(a, b, s / steps)!, 6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.points != points;
}
