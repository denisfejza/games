import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/strings.dart';
import '../content/content_loader.dart';
import '../core/mastery/mastery.dart';
import '../core/progress/progress_store.dart';
import '../l10n/app_localizations.dart';
import '../worlds/world_style.dart';

class WorldProgress {
  const WorldProgress({
    required this.worldId,
    required this.titleKey,
    required this.levelsDone,
    required this.levels,
    required this.stars,
    required this.skillsMastered,
    required this.skills,
  });

  final String worldId;
  final String titleKey;
  final int levelsDone;
  final int levels;
  final int stars;
  final int skillsMastered;
  final int skills;
}

class DashboardData {
  const DashboardData({required this.worlds, required this.leftUnfinished, required this.todayIdea});

  final List<WorldProgress> worlds;

  /// Game ids children most often leave early, with counts (on-device only).
  final List<(String, int)> leftUnfinished;

  /// Off-screen challenge key suggested for today.
  final String? todayIdea;
}

/// Everything on the dashboard, computed from on-device data only.
DashboardData buildDashboard(
  ContentLibrary content, {
  required Map<String, int> progress,
  required SkillStats Function(String skill) stats,
  required Map<String, String> settings,
  required DateTime today,
}) {
  final worlds = [
    for (final w in content.worlds)
      if (w.levels.isNotEmpty)
        WorldProgress(
          worldId: w.id,
          titleKey: w.titleKey,
          levels: w.levels.length,
          levelsDone: w.levels.where((l) => progress.containsKey(levelKey(w.id, l.number))).length,
          stars: [for (final l in w.levels) progress[levelKey(w.id, l.number)] ?? 0].fold(0, (a, b) => a + b),
          skills: {for (final l in w.levels) ...l.skills}.length,
          skillsMastered: {for (final l in w.levels) ...l.skills}.where((s) => stats(s).isMastered).length,
        ),
  ];
  final left = [
    for (final e in settings.entries)
      if (e.key.startsWith('abandon.')) (e.key.substring(8), int.tryParse(e.value) ?? 0),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  final ideas = {for (final g in content.allGames) g.offscreenKey}.toList()..sort();
  final day = today.difference(DateTime(today.year)).inDays;
  return DashboardData(
    worlds: worlds,
    leftUnfinished: left.take(3).toList(),
    todayIdea: ideas.isEmpty ? null : ideas[day % ideas.length],
  );
}

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final content = await ref.watch(contentProvider.future);
  final mastery = ref.watch(masteryTrackerProvider);
  await mastery.load();
  return buildDashboard(
    content,
    progress: await ref.watch(progressStoreProvider).loadAll(),
    stats: mastery.stats,
    settings: await ref.watch(settingsStoreProvider).loadAll(),
    today: DateTime.now(),
  );
});

/// The progress part of the parent area (PLAN 5.1).
class ProgressDashboard extends ConsumerWidget {
  const ProgressDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = ref.watch(dashboardProvider).value;
    if (data == null) return const Padding(padding: EdgeInsets.all(24), child: LinearProgressIndicator());
    final content = ref.watch(contentProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final w in data.worlds)
          Card(
            key: Key('dashboard.${w.worldId}'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: WorldStyle.of(w.worldId).color,
                child: const Icon(Icons.public, color: Colors.white),
              ),
              title: Text(
                lookupString(l, w.titleKey) ?? w.worldId,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${l.parentLevelsDone(w.levelsDone, w.levels)} · ${l.parentSkillsMastered(w.skillsMastered, w.skills)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB020)),
                  Text(l.parentStars(w.stars)),
                ],
              ),
            ),
          ),
        if (data.todayIdea != null)
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.directions_run_rounded),
              title: Text(l.parentTodayIdea),
              subtitle: Text(lookupString(l, data.todayIdea!) ?? ''),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(l.parentLeftUnfinished, style: theme.textTheme.titleSmall),
        ),
        if (data.leftUnfinished.isEmpty)
          Padding(padding: const EdgeInsets.all(4), child: Text(l.parentNone))
        else
          for (final (id, n) in data.leftUnfinished)
            Padding(padding: const EdgeInsets.all(4), child: Text('• ${_gameName(content, id, l)} ×$n')),
      ],
    );
  }

  static String _gameName(ContentLibrary? content, String id, AppLocalizations l) {
    final g = content?.game(id);
    if (g == null) return id;
    final world = content!.worlds.where((w) => w.id == g.world).firstOrNull;
    return '${lookupString(l, world?.titleKey ?? '') ?? g.world} ${g.level} · ${g.type}';
  }
}
