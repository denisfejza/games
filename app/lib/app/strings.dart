import '../l10n/app_localizations.dart';

/// Content JSON refers to strings by key (e.g. `worldAnimals`,
/// `offscreen.walk_like_penguin`). The ARB key is the camelCase form.
String arbKey(String contentKey) {
  final parts = contentKey.split(RegExp(r'[._]')).where((p) => p.isNotEmpty).toList();
  return [parts.first, for (final p in parts.skip(1)) p[0].toUpperCase() + p.substring(1)].join();
}

/// Looks up a string named in content. Returns null for unknown keys; a test
/// checks every key used by content resolves.
String? lookupString(AppLocalizations l, String contentKey) => switch (arbKey(contentKey)) {
  'appTitle' => l.appTitle,
  'helloPip' => l.helloPip,
  'worldAnimals' => l.worldAnimals,
  'worldNumbers' => l.worldNumbers,
  'worldLetters' => l.worldLetters,
  'worldShapesColours' => l.worldShapesColours,
  'worldBoardGames' => l.worldBoardGames,
  'worldPipsHouse' => l.worldPipsHouse,
  'hearAgain' => l.hearAgain,
  'back' => l.back,
  'comingSoon' => l.comingSoon,
  'offscreenWalkLikePenguin' => l.offscreenWalkLikePenguin,
  _ => null,
};
