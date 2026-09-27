import 'dart:math';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/pools.dart';

/// `sound_match`: hear a prompt, tap the right card (2–6 choices).
///
/// Params (all optional except what the mode needs):
/// - `mode`: `name` (default) · `sound` · `colour` · `shape` · `number` ·
///   `letter` · `starts_with` · `more` · `fewer` · `bond` · `sum` · `take_away`
/// - `choices` (2–6, default 2) — usually raised by `difficulty.steps`
/// - `items`: vocab ids / `tag:x` / `tags:a+b` (picture modes, counting objects)
/// - `numbers`: `[min, max]` (number modes, default [1, 5])
/// - `show`: `numeral` · `dots` · `group` (number mode cards, default numeral)
/// - `letters`: letter list (letter / starts_with modes)
/// - `total`: 5 or 10 (bond mode)
/// - `rounds`, `hintAfter`: see RoundController
class SoundMatchConfig {
  SoundMatchConfig._(this.params, this.items);

  factory SoundMatchConfig.parse(Map<String, dynamic> params, ContentLibrary lib) =>
      SoundMatchConfig._(params, resolveItems(lib, params['items']));

  static const modes = {
    'name',
    'sound',
    'colour',
    'shape',
    'number',
    'letter',
    'starts_with',
    'more',
    'fewer',
    'bond',
    'sum',
    'take_away', //
  };

  final Map<String, dynamic> params;
  final List<VocabItem> items;

  String get mode => params['mode'] as String? ?? 'name';
  int get choices => ((params['choices'] as int?) ?? 2).clamp(2, 6);
  (int, int) get numbers {
    final n = (params['numbers'] as List<dynamic>?)?.cast<int>() ?? const [1, 5];
    return (n.first, n.last);
  }

  String get show => params['show'] as String? ?? 'numeral';
  List<String> get letters => (params['letters'] as List<dynamic>?)?.cast<String>() ?? const [];
  int get total => (params['total'] as int?) ?? 5;

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final errors = <String>[];
    final steps = [
      def.params,
      for (final s in def.difficulty?.steps ?? const <Map<String, dynamic>>[]) {...def.params, ...s},
    ];
    for (final p in steps) {
      final c = SoundMatchConfig.parse(p, lib);
      if (!modes.contains(c.mode)) errors.add('${def.id}: unknown mode "${c.mode}"');
      errors.addAll(unknownItems(lib, p['items']).map((i) => '${def.id}: unknown item "$i"'));
      final needsItems = {'name', 'sound', 'colour', 'shape', 'starts_with'}.contains(c.mode);
      final pool = c.mode == 'sound' ? c.items.where((i) => i.soundKey != null).length : c.items.length;
      if (needsItems && pool < c.choices) errors.add('${def.id}: ${c.choices} choices but only $pool items');
      if (c.mode == 'letter' && c.letters.length < c.choices) errors.add('${def.id}: not enough letters');
      final (lo, hi) = c.numbers;
      if ({'number', 'more', 'fewer'}.contains(c.mode) && hi - lo + 1 < c.choices) {
        errors.add('${def.id}: number range too small for ${c.choices} choices');
      }
    }
    return errors;
  }
}

/// One round: the cards, which one is right, what Pip says, and an optional
/// picture above the cards (sums, frames).
class ChoiceRound {
  const ChoiceRound({required this.faces, required this.answer, required this.prompt, this.stage = const [], this.op});

  final List<CardFace> faces;
  final int answer;
  final List<String> prompt;

  /// Non-tappable cards shown above the choices.
  final List<CardFace> stage;

  /// `+` or `−` drawn between stage cards.
  final String? op;
}

/// Builds rounds. [text] gives item names in the current language (starts_with).
class ChoiceRounds {
  ChoiceRounds(this.random, {required this.text, required this.locale});

  final Random random;
  final String? Function(String key) text;
  final String locale;
  Object? _last;

  static const _star = EmojiPicture('⭐');

  ChoiceRound next(SoundMatchConfig c) {
    final r = switch (c.mode) {
      'sound' => _pictures(c, [
        for (final i in c.items)
          if (i.soundKey != null) i,
      ], (t) => ['gameWhoSays', t.soundKey!]),
      'colour' => _pictures(c, c.items, (t) => ['gameFindColour', t.nameKey]),
      'shape' => _pictures(c, c.items, (t) => ['gameFindShape', t.nameKey]),
      'number' => _number(c),
      'letter' => _letter(c),
      'starts_with' => _startsWith(c),
      'more' || 'fewer' => _compare(c, more: c.mode == 'more'),
      'bond' => _bond(c),
      'sum' => _sum(c),
      'take_away' => _takeAway(c),
      _ => _pictures(c, c.items, (t) => ['gameFindThis', t.nameKey]),
    };
    return r;
  }

  T _fresh<T>(List<T> pool) {
    final options = pool.length > 1
        ? [
            for (final p in pool)
              if (p != _last) p,
          ]
        : pool;
    final t = options[random.nextInt(options.length)];
    _last = t;
    return t;
  }

  ChoiceRound _shuffled(
    CardFace answer,
    List<CardFace> others,
    List<String> prompt, {
    List<CardFace> stage = const [],
    String? op,
  }) {
    final faces = [answer, ...others]..shuffle(random);
    return ChoiceRound(faces: faces, answer: faces.indexOf(answer), prompt: prompt, stage: stage, op: op);
  }

  ChoiceRound _pictures(SoundMatchConfig c, List<VocabItem> pool, List<String> Function(VocabItem) prompt) {
    final target = _fresh(pool);
    final others = pick(random, pool, c.choices - 1, exclude: [target]);
    return _shuffled(PictureFace(target.picture), [for (final o in others) PictureFace(o.picture)], prompt(target));
  }

  CardFace _numberFace(SoundMatchConfig c, int n) {
    final pic = c.items.isEmpty ? _star : c.items[n % c.items.length].picture;
    return switch (c.show) {
      'dots' => DotsFace(n),
      'group' => GroupFace(pic, n),
      _ => TextFace('$n'),
    };
  }

  List<int> _range(SoundMatchConfig c) {
    final (lo, hi) = c.numbers;
    return [for (var i = lo; i <= hi; i++) i];
  }

  ChoiceRound _number(SoundMatchConfig c) {
    final range = _range(c);
    final n = _fresh(range);
    final others = pick(random, range, c.choices - 1, exclude: [n]);
    return _shuffled(_numberFace(c, n), [for (final o in others) _numberFace(c, o)], ['gameFindNumber', numberKey(n)]);
  }

  ChoiceRound _letter(SoundMatchConfig c) {
    final l = _fresh(c.letters);
    final others = pick(random, c.letters, c.choices - 1, exclude: [l]);
    return _shuffled(TextFace(l), [for (final o in others) TextFace(o)], ['gameFindLetter', letterKey(locale, l)]);
  }

  ChoiceRound _startsWith(SoundMatchConfig c) {
    String? first(VocabItem i) => firstLetter(text(i.nameKey) ?? '', locale);
    final letters = c.letters.isEmpty ? {for (final i in c.items) ?first(i)}.toList() : c.letters;
    final usable = [
      for (final l in letters)
        if (c.items.any((i) => first(i) == l)) l,
    ];
    final letter = _fresh(usable);
    final target = pick(random, [
      for (final i in c.items)
        if (first(i) == letter) i,
    ], 1).single;
    final others = pick(random, [
      for (final i in c.items)
        if (first(i) != letter) i,
    ], c.choices - 1);
    return _shuffled(
      PictureFace(target.picture),
      [for (final o in others) PictureFace(o.picture)],
      ['gameStartsWith', letterKey(locale, letter)],
    );
  }

  ChoiceRound _compare(SoundMatchConfig c, {required bool more}) {
    final range = _range(c);
    final counts = pick(random, range, min(c.choices, range.length))..sort();
    final pic = c.items.isEmpty ? _star : _fresh(c.items).picture;
    final answer = more ? counts.last : counts.first;
    return _shuffled(
      GroupFace(pic, answer),
      [
        for (final n in counts)
          if (n != answer) GroupFace(pic, n),
      ],
      [more ? 'gameWhichMore' : 'gameWhichFewer'],
    );
  }

  List<CardFace> _numerals(SoundMatchConfig c, int answer, int max) {
    final pool = [
      for (var i = 0; i <= max; i++)
        if (i != answer) i,
    ];
    return [for (final n in pick(random, pool, c.choices - 1)) TextFace('$n')];
  }

  ChoiceRound _bond(SoundMatchConfig c) {
    final t = c.total;
    final have = _fresh([for (var i = 1; i < t; i++) i]);
    return _shuffled(
      TextFace('${t - have}'),
      _numerals(c, t - have, t),
      [t == 10 ? 'gameBondTo10' : 'gameBondTo5'],
      stage: [FrameFace(t, have)],
    );
  }

  ChoiceRound _sum(SoundMatchConfig c) {
    final (_, hi) = c.numbers;
    final a = 1 + random.nextInt(max(1, hi - 1));
    final b = 1 + random.nextInt(max(1, hi - a));
    final pic = c.items.isEmpty ? _star : _fresh(c.items).picture;
    return _shuffled(
      TextFace('${a + b}'),
      _numerals(c, a + b, hi),
      ['gameSumWhat'],
      stage: [GroupFace(pic, a), GroupFace(pic, b)],
      op: '+',
    );
  }

  ChoiceRound _takeAway(SoundMatchConfig c) {
    final (_, hi) = c.numbers;
    final a = 2 + random.nextInt(max(1, hi - 1));
    final b = 1 + random.nextInt(a - 1);
    final pic = c.items.isEmpty ? _star : _fresh(c.items).picture;
    return _shuffled(
      TextFace('${a - b}'),
      _numerals(c, a - b, hi),
      ['gameTakeAway'],
      stage: [CrossedGroupFace(pic, a, b)],
    );
  }
}
