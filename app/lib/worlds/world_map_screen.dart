import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../parent/parent_area.dart';
import '../app/providers.dart';
import '../app/strings.dart';
import '../app/ui/big_button.dart';
import '../app/ui/hear_again_button.dart';
import '../app/ui/patterns.dart';
import '../content/models.dart';
import '../core/parental_gate/parental_gate.dart';
import '../l10n/app_localizations.dart';
import 'ground.dart';
import 'pips_house/pips_house_screen.dart';
import 'title_banner.dart';
import 'world_screen.dart';
import 'world_style.dart';

/// Shows developer extras (Pip demo) in the parent area in debug builds and in
/// preview builds made with `--dart-define=PIP_DEBUG_MENU=true`.
const showDebugMenu = kDebugMode || bool.fromEnvironment('PIP_DEBUG_MENU');

const _headerHeight = 136.0;
const _skyColor = Color(0xFF7FD3FF);

/// Main menu: one colourful stripe per world with a big tile. Pip names a
/// world on the first tap; the second tap goes in. TODO(1.4): scrolling map.
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
    final content = ref.watch(contentProvider);
    final band = ref.watch(ageBandProvider);
    return Scaffold(
      backgroundColor: _skyColor,
      body: switch (content) {
        AsyncData(:final value) => _Map(
          worlds: [
            for (final w in value.worlds)
              if (w.ageBands.contains(band)) w,
          ],
        ),
        AsyncError(:final error) => Center(child: Text('$error')),
        _ => const Center(child: CircularProgressIndicator(color: Colors.white)),
      },
    );
  }
}

class _Map extends ConsumerWidget {
  const _Map({required this.worlds});

  final List<World> worlds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final padding = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final n = worlds.length;
        final landscape = box.maxWidth > box.maxHeight;
        final cols = n == 0 ? 1 : (landscape ? (box.maxWidth / n >= 150 ? n : (n / 2).ceil()) : 2);
        final rows = n == 0 ? 1 : (n / cols).ceil();
        final top = _headerHeight + padding.top;
        final bottom = groundHeight + padding.bottom;
        final cellW = box.maxWidth / cols;
        final cellH = (box.maxHeight - top - bottom) / rows;
        final tile = (cellW * 0.62).clamp(0.0, cellH * 0.56).clamp(0.0, 170.0);

        List<Widget> grid(Widget Function(int index) cell) => [
          for (var r = 0; r < rows; r++)
            Expanded(
              child: Row(children: [for (var c = 0; c < cols; c++) Expanded(child: cell(r * cols + c))]),
            ),
        ];

        Widget stripe(int i) => i < n
            ? PatternBackground(
                color: WorldStyle.of(worlds[i].icon).color,
                pattern: WorldStyle.of(worlds[i].icon).pattern,
                seed: i,
              )
            : const PatternBackground(color: Color(0xFFB39DFF), pattern: Pattern.dots);

        return Stack(
          children: [
            // Colour stripes. With one row they run the full height, behind the header.
            Positioned.fill(
              child: rows == 1
                  ? Row(children: [for (var i = 0; i < cols; i++) Expanded(child: stripe(i))])
                  : Column(
                      children: [
                        SizedBox(height: top, child: const _Sky()),
                        ...grid(stripe),
                        SizedBox(height: bottom),
                      ],
                    ),
            ),
            // World tiles, centred in their stripe.
            Positioned(
              top: top,
              bottom: bottom,
              left: 0,
              right: 0,
              child: Column(
                children: grid(
                  (i) => i < n
                      ? Center(
                          child: _WorldTile(world: worlds[i], size: tile, label: lookupString(l, worlds[i].titleKey)),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: GroundWithPip(pipSize: landscape ? 110 : 88)),
            // Header: hear again, title ribbons, settings.
            Positioned(
              top: padding.top,
              left: 0,
              right: 0,
              height: _headerHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HearAgainButton(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: TitleBanner(
                            title: l.appTitle,
                            subtitle: l.helloPip,
                            subtitleKey: const Key('greeting'),
                          ),
                        ),
                      ),
                    ),
                    const _SettingsButton(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorldTile extends StatelessWidget {
  const _WorldTile({required this.world, required this.size, required this.label});

  final World world;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final style = WorldStyle.of(world.icon);
    return BigButton(
      key: Key('world.${world.id}'),
      art: style.art,
      sticker: true,
      outlinedLabel: true,
      size: size,
      color: style.color,
      speakKey: world.titleKey,
      label: label,
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => world.id == 'pips_house' ? const PipsHouseScreen() : WorldScreen(world: world),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    elevation: 3,
    child: IconButton(
      key: const Key('openSettings'),
      tooltip: AppLocalizations.of(context).parentTitle,
      iconSize: 30,
      color: const Color(0xFF3B2C4A),
      icon: const Icon(Icons.settings_rounded),
      onPressed: () => ParentalGate.open(context, (_) => const ParentArea()),
    ),
  );
}

/// Light-blue sky with a few clouds, used above the stripes on tall screens.
class _Sky extends StatelessWidget {
  const _Sky();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _SkyPainter(), child: const SizedBox.expand());
}

class _SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _skyColor);
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final (x, y, r) in [(0.12, 0.8, 22.0), (0.5, 0.92, 26.0), (0.86, 0.78, 20.0)]) {
      final c = Offset(size.width * x, size.height * y);
      canvas.drawCircle(c, r, cloud);
      canvas.drawCircle(c + Offset(r * 0.9, r * 0.2), r * 0.8, cloud);
      canvas.drawCircle(c - Offset(r * 0.9, -r * 0.2), r * 0.7, cloud);
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) => false;
}
