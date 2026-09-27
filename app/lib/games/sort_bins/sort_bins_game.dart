import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/drag_card.dart';
import '../common/game_card.dart';
import '../common/game_screen.dart';
import '../common/mini_game.dart';
import '../common/pip_game.dart';
import '../common/pools.dart';

/// `sort_bins`: drag several items into 2–3 bins.
///
/// Params:
/// - `by`: `size` · `lives` · `colour` · `first_letter` · `tag` (which fact to sort by)
/// - `bins`: list of `{"value": "big", "item": "elephant", "say": "binBig"}`; for
///   `first_letter` use `{"value": "sh"}` (the bin shows the letter)
/// - `items` pool, `perRound` items to sort (default 4), `rounds`
class SortBinsConfig {
  SortBinsConfig._(this.params, this.items);

  factory SortBinsConfig.parse(Map<String, dynamic> params, ContentLibrary lib) =>
      SortBinsConfig._(params, resolveItems(lib, params['items'] ?? 'tag:animal'));

  static const sorts = {'size', 'lives', 'colour', 'first_letter', 'tag'};

  final Map<String, dynamic> params;
  final List<VocabItem> items;

  String get by => params['by'] as String? ?? 'size';
  List<Map<String, dynamic>> get bins => [
    for (final b in (params['bins'] as List<dynamic>? ?? const [])) Map<String, dynamic>.from(b as Map),
  ];
  int get perRound => ((params['perRound'] as int?) ?? 4).clamp(2, 8);

  /// The value [item] sorts under, in [locale].
  String? valueOf(VocabItem item, String? Function(String) text, String locale) => switch (by) {
    'first_letter' => firstLetter(text(item.nameKey) ?? '', locale),
    'tag' => bins.map((b) => b['value'] as String).where(item.tags.contains).firstOrNull,
    _ => item.props[by],
  };

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final c = SortBinsConfig.parse(def.params, lib);
    return [
      if (!sorts.contains(c.by)) '${def.id}: unknown sort "${c.by}"',
      if (c.bins.length < 2 || c.bins.length > 3) '${def.id}: needs 2–3 bins',
      ...unknownItems(lib, def.params['items']).map((i) => '${def.id}: unknown item "$i"'),
      for (final b in c.bins)
        if (b['item'] is String && !lib.vocab.containsKey(b['item'])) '${def.id}: unknown bin item "${b['item']}"',
    ];
  }
}

class SortRound {
  const SortRound({required this.items, required this.values, required this.bins});

  final List<VocabItem> items;

  /// Bin index for each item.
  final List<int> values;
  final List<Map<String, dynamic>> bins;
}

SortRound nextSort(SortBinsConfig c, Random r, {required String? Function(String) text, required String locale}) {
  final byBin = <int, List<VocabItem>>{};
  for (final item in c.items) {
    final v = c.valueOf(item, text, locale);
    final bin = c.bins.indexWhere((b) => b['value'] == v);
    if (bin >= 0) byBin.putIfAbsent(bin, () => []).add(item);
  }
  // Balanced: take turns across bins so every bin gets something.
  final chosen = <(VocabItem, int)>[];
  final pools = {
    for (final e in byBin.entries) e.key: ([...e.value]..shuffle(r)),
  };
  var bin = r.nextInt(max(1, c.bins.length));
  while (chosen.length < c.perRound && pools.values.any((p) => p.isNotEmpty)) {
    final pool = pools[bin % c.bins.length];
    if (pool != null && pool.isNotEmpty) chosen.add((pool.removeLast(), bin % c.bins.length));
    bin++;
  }
  chosen.shuffle(r);
  return SortRound(items: [for (final (i, _) in chosen) i], values: [for (final (_, b) in chosen) b], bins: c.bins);
}

class SortBinsEngine implements GameEngine {
  const SortBinsEngine();

  @override
  String get type => 'sort_bins';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => SortBinsConfig.validate(def, content);

  @override
  Widget build(GameContext context) => GameScreen(context: context, create: SortBinsGame.new);
}

class SortBinsGame extends PipGame {
  SortBinsGame(super.host);

  SortRound? round;
  final List<GameCard> bins = [];
  final List<DragCard> items = [];
  final Map<int, int> _inBin = {};

  @override
  Future<void> startRound() async {
    final c = SortBinsConfig.parse(host.rounds.params, host.context.content);
    final r = round = nextSort(c, host.random, text: host.context.text, locale: host.context.locale);
    _inBin.clear();
    bins
      ..clear()
      ..addAll([
        for (var i = 0; i < r.bins.length; i++)
          GameCard(
            face: _binFace(r.bins[i], host.context.content),
            size: Vector2.all(100),
            value: i,
            onTap: (_) {
              final say = r.bins[i]['say'] as String? ?? _binSay(r.bins[i], host.context.content, host.context.locale);
              if (say != null) host.audio.say(say, interrupt: true);
            },
          ),
      ]);
    items
      ..clear()
      ..addAll([
        for (var i = 0; i < r.items.length; i++)
          DragCard(
            face: PictureFace(r.items[i].picture),
            size: Vector2.all(80),
            value: i,
            onDrop: _dropped,
            onTap: (_) => host.audio.say(r.items[i].nameKey, interrupt: true),
          ),
      ]);
    await addAll([...bins, ...items]);
    layout(size);
    await host.prompt(const ['gameSortBins']);
  }

  static CardFace _binFace(Map<String, dynamic> b, ContentLibrary lib) {
    if (b['item'] case final String id) return PictureFace(lib.item(id).picture);
    return TextFace(b['value'] as String);
  }

  static String? _binSay(Map<String, dynamic> b, ContentLibrary lib, String locale) {
    if (b['item'] case final String id) return lib.item(id).nameKey;
    return letterKey(locale, b['value'] as String);
  }

  @override
  void layout(Vector2 size) {
    if (round == null) return;
    final g = gridLayout(bins.length, Vector2(size.x, size.y * 0.5), cols: bins.length, maxCard: 220, gap: 0.3);
    for (var i = 0; i < bins.length; i++) {
      bins[i]
        ..size = g.card
        ..position = g.centres[i];
    }
    final row = gridLayout(items.length, Vector2(size.x, size.y * 0.42), maxCard: 130, gap: 0.2);
    for (var i = 0; i < items.length; i++) {
      final card = items[i];
      card.size = row.card;
      final sorted = _inBin[i];
      if (sorted != null) {
        card
          ..size = row.card * 0.55
          ..home = _slot(bins[sorted], i);
      } else {
        card.home = row.centres[i] + Vector2(0, size.y * 0.56);
      }
      if (!card.dragging) card.position = card.home.clone();
    }
  }

  /// Where a sorted item sits inside its bin.
  Vector2 _slot(GameCard bin, int item) {
    final inThisBin = _inBin.entries.where((e) => e.value == bin.value).map((e) => e.key).toList();
    final k = inThisBin.indexOf(item);
    final a = k * 2.4;
    return bin.position + Vector2(cos(a), sin(a)) * bin.size.x * 0.26;
  }

  bool _dropped(DragCard card, Vector2 at) {
    final r = round;
    if (r == null || locked) return false;
    final bin = nearestTarget(bins, at, reach: 0.9);
    if (bin == null) return false;
    final i = card.value! as int;
    if (bin.value == r.values[i]) {
      _inBin[i] = bin.value! as int;
      card
        ..done = true
        ..size = card.size * 0.55
        ..snapTo(_slot(bin, i));
      bin.pop();
      for (final b in bins) {
        b.clearHint();
      }
      host.correct();
      if (_inBin.length == items.length) solved();
      return true;
    }
    bin.wiggle();
    if (host.tryAgain()) {
      bins[r.values[i]].hint();
      host.hintShown();
    }
    return false;
  }
}
