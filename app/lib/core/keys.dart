/// Content JSON names strings and recordings by key (`worldAnimals`,
/// `offscreen.walk_like_penguin`, `vocab.cow`). ARB keys and narration file
/// names use the camelCase form: `vocab.cow` → `vocabCow`.
String arbKey(String contentKey) {
  final parts = contentKey.split(RegExp(r'[._]')).where((p) => p.isNotEmpty).toList();
  return [parts.first, for (final p in parts.skip(1)) p[0].toUpperCase() + p.substring(1)].join();
}
