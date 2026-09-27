import 'dart:math';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/pools.dart';

/// `pairs_memory`: turn over two cards, find the pairs (2×2 → 4×4).
///
/// Params:
/// - `pairs` (2–8, default 2) — each pair found is one round
/// - `pairing`: `picture` (same picture, default) · `picture_sound` (picture + speaker)
///   · `letter_picture` (letter + a picture starting with it) · `numeral_dots`
/// - `items`, `letters`, `numbers` as in sound_match
/// - `players`: 1 (default) or 2 (pass-and-play; Board Games world)
/// - `hintAfter` defaults to 3 here: mismatches are part of the game.
class PairsMemoryConfig {
  PairsMemoryConfig._(this.params, this.items);

  factory PairsMemoryConfig.parse(Map<String, dynamic> params, ContentLibrary lib) =>
      PairsMemoryConfig._(params, resolveItems(lib, params['items'] ?? 'tags:animal+farm'));

  static const pairings = {'picture', 'picture_sound', 'letter_picture', 'numeral_dots'};

  final Map<String, dynamic> params;
  final List<VocabItem> items;

  int get pairs => ((params['pairs'] as int?) ?? 2).clamp(2, 8);
  String get pairing => params['pairing'] as String? ?? 'picture';
  int get players => ((params['players'] as int?) ?? 1).clamp(1, 2);
  List<String> get letters => (params['letters'] as List<dynamic>?)?.cast<String>() ?? const [];
  (int, int) get numbers {
    final n = (params['numbers'] as List<dynamic>?)?.cast<int>() ?? const [1, 6];
    return (n.first, n.last);
  }

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final c = PairsMemoryConfig.parse(def.params, lib);
    return [
      if (!pairings.contains(c.pairing)) '${def.id}: unknown pairing "${c.pairing}"',
      ...unknownItems(lib, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
      if ({'picture', 'picture_sound'}.contains(c.pairing) && c.items.length < c.pairs)
        '${def.id}: ${c.pairs} pairs but only ${c.items.length} items',
      if (c.pairing == 'numeral_dots' && c.numbers.$2 - c.numbers.$1 + 1 < c.pairs) '${def.id}: number range too small',
    ];
  }
}

/// A card on the table: which pair it belongs to and what it shows / says.
class MemoryCardSpec {
  const MemoryCardSpec({required this.pair, required this.face, this.sayKey});

  final int pair;
  final CardFace face;

  /// Said when the card is turned over.
  final String? sayKey;
}

List<MemoryCardSpec> dealMemory(
  PairsMemoryConfig c,
  Random random, {
  required String? Function(String) text,
  required String locale,
}) {
  final cards = <MemoryCardSpec>[];
  switch (c.pairing) {
    case 'numeral_dots':
      final (lo, hi) = c.numbers;
      final nums = pick(random, [for (var i = lo; i <= hi; i++) i], c.pairs);
      for (final (i, n) in nums.indexed) {
        cards
          ..add(MemoryCardSpec(pair: i, face: TextFace('$n'), sayKey: numberKey(n)))
          ..add(MemoryCardSpec(pair: i, face: DotsFace(n), sayKey: numberKey(n)));
      }
    case 'letter_picture':
      String? first(VocabItem v) => firstLetter(text(v.nameKey) ?? '', locale);
      final letters = c.letters.isEmpty ? {for (final v in c.items) ?first(v)}.toList() : c.letters;
      final usable = [
        for (final l in letters)
          if (c.items.any((v) => first(v) == l)) l,
      ];
      for (final (i, l) in pick(random, usable, c.pairs).indexed) {
        final item = pick(random, [
          for (final v in c.items)
            if (first(v) == l) v,
        ], 1).single;
        cards
          ..add(MemoryCardSpec(pair: i, face: TextFace(l), sayKey: letterKey(locale, l)))
          ..add(MemoryCardSpec(pair: i, face: PictureFace(item.picture), sayKey: item.nameKey));
      }
    default:
      final sound = c.pairing == 'picture_sound';
      final pool = sound
          ? [
              for (final v in c.items)
                if (v.soundKey != null) v,
            ]
          : c.items;
      for (final (i, item) in pick(random, pool.isEmpty ? c.items : pool, c.pairs).indexed) {
        cards
          ..add(MemoryCardSpec(pair: i, face: PictureFace(item.picture), sayKey: item.nameKey))
          ..add(
            MemoryCardSpec(
              pair: i,
              face: sound ? const SoundFace() : PictureFace(item.picture),
              sayKey: sound ? (item.soundKey ?? item.nameKey) : item.nameKey,
            ),
          );
      }
  }
  return cards..shuffle(random);
}
