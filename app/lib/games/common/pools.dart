import 'dart:math';

import '../../content/content_loader.dart';
import '../../content/vocab.dart';

/// Resolves an `items` param: ids (`"cow"`), one tag (`"tag:farm"`) or several
/// (`"tags:animal+farm"`). Unknown ids are reported by the engine's validate().
List<VocabItem> resolveItems(ContentLibrary lib, Object? spec) {
  final entries = spec is List ? spec.cast<Object?>() : [spec];
  final out = <VocabItem>[];
  for (final e in entries) {
    if (e is! String) continue;
    if (e.startsWith('tag:')) {
      out.addAll(lib.itemsTagged({e.substring(4)}));
    } else if (e.startsWith('tags:')) {
      out.addAll(lib.itemsTagged(e.substring(5).split('+').toSet()));
    } else if (lib.vocab[e] case final item?) {
      out.add(item);
    }
  }
  final seen = <String>{};
  return [
    for (final i in out)
      if (seen.add(i.id)) i,
  ];
}

/// Ids in [spec] that don't name a vocab item (for validate()).
List<String> unknownItems(ContentLibrary lib, Object? spec) => [
  for (final e in spec is List ? spec.cast<Object?>() : [spec])
    if (e is String && !e.startsWith('tag') && !lib.vocab.containsKey(e)) e,
];

/// [n] distinct random picks from [pool], never [exclude].
List<T> pick<T>(Random r, List<T> pool, int n, {Iterable<T> exclude = const []}) {
  final options = [
    for (final p in pool)
      if (!exclude.contains(p)) p,
  ]..shuffle(r);
  return options.take(n).toList();
}

/// Letters of each alphabet, digraphs first so they match as one letter.
/// Albanian has 36 letters; dh, gj, ll, nj, rr, sh, th, xh, zh are single letters (CLAUDE.md).
const sqLetters = [
  'dh', 'gj', 'll', 'nj', 'rr', 'sh', 'th', 'xh', 'zh', //
  'a', 'b', 'c', 'ç', 'd', 'e', 'ë', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u',
  'v', 'x', 'y', 'z',
];

const enLetters = [
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
];

/// Splits [word] into letters of [locale]'s alphabet ("mollë" → m, o, ll, ë).
List<String> graphemes(String word, String locale) {
  final letters = locale == 'sq' ? sqLetters : enLetters;
  final w = word.toLowerCase().replaceAll(RegExp(r'[^a-zçë]'), '');
  final out = <String>[];
  var i = 0;
  while (i < w.length) {
    final match = letters.firstWhere((l) => w.startsWith(l, i), orElse: () => w[i]);
    out.add(match);
    i += match.length;
  }
  return out;
}

String? firstLetter(String word, String locale) {
  final g = graphemes(word, locale);
  return g.isEmpty ? null : g.first;
}

/// Narration/caption key for a letter's sound, e.g. `letter.sq.sh`, `letter.sq.cCedilla`.
String letterKey(String locale, String letter) =>
    'letter.$locale.${switch (letter) {
      'ç' => 'cCedilla',
      'ë' => 'eDiaeresis',
      _ => letter,
    }}';

/// Narration/caption key for a number word, e.g. `num5`.
String numberKey(int n) => 'num$n';
