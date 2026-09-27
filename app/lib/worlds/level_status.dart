import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../core/progress/progress_store.dart';

class LevelStatus {
  const LevelStatus({required this.unlocked, this.stars});

  final bool unlocked;

  /// Best stars, or null if never completed (there is no 0-star state).
  final int? stars;
}

/// Unlock rule (CLAUDE.md): level 1 is open; level N opens once level N-1 is
/// completed and its skills are mastered (≥ 80% independent).
final levelStatusProvider = FutureProvider.family<Map<int, LevelStatus>, String>((ref, worldId) async {
  final content = await ref.watch(contentProvider.future);
  final world = content.world(worldId);
  final mastery = ref.watch(masteryTrackerProvider);
  await mastery.load();
  final progress = await ref.watch(progressStoreProvider).loadAll();
  final status = <int, LevelStatus>{};
  for (var i = 0; i < world.levels.length; i++) {
    final level = world.levels[i];
    final prev = i == 0 ? null : world.levels[i - 1];
    final unlocked =
        prev == null || (progress.containsKey(levelKey(worldId, prev.number)) && mastery.allMastered(prev.skills));
    status[level.number] = LevelStatus(unlocked: unlocked, stars: progress[levelKey(worldId, level.number)]);
  }
  return status;
});
