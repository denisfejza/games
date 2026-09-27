import 'dart:math';

import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../../content/vocab.dart';
import '../common/pools.dart';

/// `tap_count`: tap each object once; Pip counts aloud (one-to-one correspondence).
///
/// Params: `numbers` `[min, max]` (how many objects, default [1, 3]; up to 20),
/// `items` (what to count, default farm animals), `rounds`, `hintAfter`.
/// Tapping an object twice is the "mistake" (a hint then highlights the ones not yet counted).
class TapCountConfig {
  TapCountConfig._(this.params, this.items);

  factory TapCountConfig.parse(Map<String, dynamic> params, ContentLibrary lib) =>
      TapCountConfig._(params, resolveItems(lib, params['items'] ?? 'tags:animal+farm'));

  final Map<String, dynamic> params;
  final List<VocabItem> items;

  (int, int) get numbers {
    final n = (params['numbers'] as List<dynamic>?)?.cast<int>() ?? const [1, 3];
    return (max(1, n.first), min(20, n.last));
  }

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final errors = <String>[];
    for (final p in [
      def.params,
      for (final s in def.difficulty?.steps ?? const <Map<String, dynamic>>[]) {...def.params, ...s},
    ]) {
      final c = TapCountConfig.parse(p, lib);
      errors.addAll(unknownItems(lib, p['items']).map((i) => '${def.id}: unknown item "$i"'));
      if (c.items.isEmpty) errors.add('${def.id}: nothing to count');
      final (lo, hi) = c.numbers;
      if (lo > hi) errors.add('${def.id}: bad numbers range');
    }
    return errors;
  }
}

class CountRound {
  const CountRound(this.item, this.count);
  final VocabItem item;
  final int count;
}

class CountRounds {
  CountRounds(this.random);

  final Random random;
  int? _last;

  CountRound next(TapCountConfig c) {
    final (lo, hi) = c.numbers;
    final options = [
      for (var i = lo; i <= hi; i++)
        if (i != _last || lo == hi) i,
    ];
    final n = options[random.nextInt(options.length)];
    _last = n;
    return CountRound(c.items[random.nextInt(c.items.length)], n);
  }
}
