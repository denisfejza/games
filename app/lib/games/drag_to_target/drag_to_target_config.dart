import 'dart:math';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/card_face.dart';
import '../common/pools.dart';

/// `drag_to_target`: drag one item onto the right zone.
///
/// Params:
/// - `mode`: `food` (food → the animal that eats it) · `habitat` (animal → where it
///   lives) · `baby` (small animal → its big mummy) · `shape_hole` (shape → its hole)
/// - `items`: pool (animals for food/habitat/baby, shapes for shape_hole)
/// - `targets`: zones per round (2–4, default 2)
/// - `rounds`, `hintAfter`
class DragToTargetConfig {
  DragToTargetConfig._(this.params, this.items);

  factory DragToTargetConfig.parse(Map<String, dynamic> params, ContentLibrary lib) {
    final mode = params['mode'] as String? ?? 'food';
    var items = resolveItems(lib, params['items'] ?? (mode == 'shape_hole' ? 'tag:shape' : 'tag:animal'));
    items = switch (mode) {
      'food' => [
        for (final i in items)
          if (lib.vocab.containsKey(i.props['food'])) i,
      ],
      'habitat' => [
        for (final i in items)
          if (lib.vocab.containsKey(i.props['habitat'])) i,
      ],
      _ => items,
    };
    return DragToTargetConfig._(params, items);
  }

  static const modes = {'food', 'habitat', 'baby', 'shape_hole'};

  final Map<String, dynamic> params;
  final List<VocabItem> items;

  String get mode => params['mode'] as String? ?? 'food';
  int get targets => ((params['targets'] as int?) ?? 2).clamp(2, 4);

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final errors = <String>[];
    for (final p in [
      def.params,
      for (final s in def.difficulty?.steps ?? const <Map<String, dynamic>>[]) {...def.params, ...s},
    ]) {
      final c = DragToTargetConfig.parse(p, lib);
      if (!modes.contains(c.mode)) errors.add('${def.id}: unknown mode "${c.mode}"');
      errors.addAll(unknownItems(lib, p['items']).map((i) => '${def.id}: unknown item "$i"'));
      final distinct = switch (c.mode) {
        'food' => {for (final i in c.items) i.props['food']}.length,
        'habitat' => {for (final i in c.items) i.props['habitat']}.length,
        _ => c.items.length,
      };
      if (distinct < c.targets) errors.add('${def.id}: needs ${c.targets} different targets, has $distinct');
    }
    return errors;
  }
}

class DragRound {
  const DragRound({required this.item, required this.zones, required this.answer, required this.prompt, this.itemName});

  final CardFace item;
  final List<CardFace> zones;
  final int answer;
  final List<String> prompt;

  /// Said when the child taps the item.
  final String? itemName;
}

class DragRounds {
  DragRounds(this.random, this.lib);

  final Random random;
  final ContentLibrary lib;
  String? _last;

  VocabItem _fresh(List<VocabItem> pool) {
    final options = [
      for (final p in pool)
        if (p.id != _last) p,
    ];
    final t = (options.isEmpty ? pool : options)[random.nextInt((options.isEmpty ? pool : options).length)];
    _last = t.id;
    return t;
  }

  DragRound next(DragToTargetConfig c) {
    switch (c.mode) {
      case 'food' || 'habitat':
        final prop = c.mode;
        final target = _fresh(c.items);
        final others = <VocabItem>[];
        final used = {target.props[prop]};
        for (final o in [...c.items]..shuffle(random)) {
          if (others.length == c.targets - 1) break;
          if (used.add(o.props[prop])) others.add(o);
        }
        if (prop == 'food') {
          final zones = [target, ...others]..shuffle(random);
          final food = lib.item(target.props['food']!);
          return DragRound(
            item: PictureFace(food.picture),
            itemName: food.nameKey,
            zones: [for (final z in zones) PictureFace(z.picture)],
            answer: zones.indexOf(target),
            prompt: const ['gameFeed'],
          );
        }
        final homes = [lib.item(target.props['habitat']!), for (final o in others) lib.item(o.props['habitat']!)]
          ..shuffle(random);
        return DragRound(
          item: PictureFace(target.picture),
          itemName: target.nameKey,
          zones: [for (final h in homes) PictureFace(h.picture)],
          answer: homes.indexWhere((h) => h.id == target.props['habitat']),
          prompt: ['gameWhereLives', target.nameKey],
        );
      case 'baby':
        final target = _fresh(c.items);
        final zones = [
          target,
          ...pick(random, c.items, c.targets - 1, exclude: [target]),
        ]..shuffle(random);
        return DragRound(
          item: SmallFace(target.picture, scale: 0.55),
          itemName: target.nameKey,
          zones: [for (final z in zones) PictureFace(z.picture)],
          answer: zones.indexOf(target),
          prompt: const ['gameFindMummy'],
        );
      default:
        final target = _fresh(c.items);
        final zones = [
          target,
          ...pick(random, c.items, c.targets - 1, exclude: [target]),
        ]..shuffle(random);
        return DragRound(
          item: PictureFace(target.picture),
          itemName: target.nameKey,
          zones: [for (final z in zones) SilhouetteFace(z.picture)],
          answer: zones.indexOf(target),
          prompt: ['gameShapeHole', target.nameKey],
        );
    }
  }
}
