import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';

/// A costume for Pip, unlocked by total stars (mastery), never bought or random.
class Costume {
  const Costume(this.id, this.emoji, this.stars);

  final String id;

  /// Placeholder art. TODO(asset): costume layers in the Rive file.
  final String emoji;

  /// Stars needed to unlock.
  final int stars;
}

const costumes = [
  Costume('bow', '🎀', 2),
  Costume('crown', '👑', 5),
  Costume('top_hat', '🎩', 9),
  Costume('glasses', '🕶️', 14),
  Costume('scarf', '🧣', 20),
  Costume('star', '🌟', 28),
];

/// Stickers for the sticker book, one per star, in a fixed order (no random rewards).
const stickers = [
  '🐶', '🐱', '🐰', '🦊', '🐻', '🐼', '🐸', '🐵', '🦁', '🐯', '🐮', '🐷', '🐔', '🐧', '🦉', '🐝', '🦋', '🐞', //
  '🐢', '🐙', '🐳', '🐬', '🦀', '🦒', '🦓', '🐘', '🦘', '🦜', '🌈', '⭐', '🌸', '🍎', '🍓', '🎈', '🎁', '🎂',
];

final pipCostumeProvider = NotifierProvider<Setting<String?>, String?>(
  () => PersistedSetting<String?>('pipCostume', null, decode: (r) => r.isEmpty ? null : r, encode: (v) => v ?? ''),
);

/// Total stars across all levels (best result per level).
final totalStarsProvider = FutureProvider<int>((ref) async {
  final progress = await ref.watch(progressStoreProvider).loadAll();
  return progress.values.fold<int>(0, (a, b) => a + b);
});
