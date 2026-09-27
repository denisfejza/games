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

/// `blend_tiles`: drag letter-sound tiles into order to build a word; the
/// word then turns into its picture. Albanian digraphs are one tile.
///
/// Params: `words`: vocab ids, or `{"en": [...], "sq": [...]}` per language
/// (spelling comes from the item's name in that language); `rounds`.
class BlendTilesConfig {
  BlendTilesConfig(this.params);

  final Map<String, dynamic> params;

  List<String> wordsFor(String locale) => switch (params['words']) {
    final List<dynamic> l => l.cast<String>(),
    final Map<String, dynamic> m => (m[locale] as List<dynamic>? ?? const []).cast<String>(),
    _ => const [],
  };

  static List<String> validate(GameDef def, ContentLibrary lib) {
    final c = BlendTilesConfig(def.params);
    return [
      for (final l in ['en', 'sq'])
        for (final w in c.wordsFor(l))
          if (!lib.vocab.containsKey(w)) '${def.id}: unknown word item "$w"',
      if (c.wordsFor('en').isEmpty && c.wordsFor('sq').isEmpty) '${def.id}: no words',
    ];
  }
}

class BlendTilesEngine implements GameEngine {
  const BlendTilesEngine();

  @override
  String get type => 'blend_tiles';

  @override
  List<String> validate(GameDef def, ContentLibrary content) => BlendTilesConfig.validate(def, content);

  @override
  Widget build(GameContext context) => GameScreen(context: context, create: BlendTilesGame.new);
}

class BlendTilesGame extends PipGame {
  BlendTilesGame(super.host);

  VocabItem? word;
  List<String> letters = const [];
  GameCard? picture;
  final List<GameCard> slots = [];
  final List<DragCard> tiles = [];
  final Set<int> _filled = {};

  /// Slot each placed tile sits in (a repeated letter can go in either of its slots).
  final Map<DragCard, int> _placed = {};
  String? _last;

  @override
  Future<void> startRound() async {
    final ids = BlendTilesConfig(host.rounds.params).wordsFor(host.context.locale);
    final options = ids.length > 1
        ? [
            for (final i in ids)
              if (i != _last) i,
          ]
        : ids;
    final item = word = host.context.content.item(options[host.random.nextInt(options.length)]);
    _last = item.id;
    letters = graphemes(host.context.text(item.nameKey) ?? item.id, host.context.locale);
    _filled.clear();
    _placed.clear();
    picture = GameCard(face: _Faded(PictureFace(item.picture)), size: Vector2.all(100));
    slots
      ..clear()
      ..addAll([
        for (var i = 0; i < letters.length; i++) GameCard(face: const BlankFace(), size: Vector2.all(80), value: i),
      ]);
    final order = [for (var i = 0; i < letters.length; i++) i]..shuffle(host.random);
    tiles
      ..clear()
      ..addAll([
        for (final i in order)
          DragCard(
            face: TextFace(letters[i]),
            size: Vector2.all(80),
            value: i,
            onDrop: _dropped,
            onTap: (_) => host.audio.say(letterKey(host.context.locale, letters[i]), interrupt: true),
          ),
      ]);
    await addAll([picture!, ...slots, ...tiles]);
    layout(size);
    await host.prompt(const ['gameBuildWord']);
  }

  @override
  void layout(Vector2 size) {
    final p = picture;
    if (p == null) return;
    final s = min(size.y * 0.3, 190.0);
    p
      ..size = Vector2.all(s)
      ..position = Vector2(size.x / 2, s / 2 + 8);
    final row = gridLayout(slots.length, Vector2(size.x, size.y * 0.3), cols: slots.length, maxCard: 130, gap: 0.12);
    for (var i = 0; i < slots.length; i++) {
      slots[i]
        ..size = row.card
        ..position = row.centres[i] + Vector2(0, size.y * 0.33);
    }
    final bottom = gridLayout(tiles.length, Vector2(size.x, size.y * 0.3), cols: tiles.length, maxCard: 130, gap: 0.3);
    for (var i = 0; i < tiles.length; i++) {
      final t = tiles[i];
      t.size = row.card;
      final slot = _placed[t];
      t.home = slot != null ? slots[slot].position.clone() : bottom.centres[i] + Vector2(0, size.y * 0.68);
      if (!t.dragging) t.position = t.home.clone();
    }
  }

  bool _dropped(DragCard tile, Vector2 at) {
    if (locked) return false;
    final slot = nearestTarget(slots, at);
    if (slot == null) return false;
    final i = slot.value! as int;
    final letter = letters[tile.value! as int];
    // Any tile with the right letter fits (words can repeat a letter).
    if (!_filled.contains(i) && letters[i] == letter) {
      _filled.add(i);
      _placed[tile] = i;
      tile
        ..done = true
        ..snapTo(slot.position);
      host.audio.say(letterKey(host.context.locale, letter), interrupt: true);
      for (final s in slots) {
        s.clearHint();
      }
      if (_filled.length == letters.length) _complete();
      return true;
    }
    slot.wiggle();
    if (host.tryAgain()) {
      final next = [for (var k = 0; k < letters.length; k++) k].firstWhere((k) => !_filled.contains(k));
      slots[next].hint();
      host.hintShown();
    }
    return false;
  }

  Future<void> _complete() async {
    host.correct();
    picture!
      ..face = PictureFace(word!.picture)
      ..done = true
      ..pop();
    await host.audio.say(word!.nameKey, interrupt: true);
    await solved();
  }
}

/// A picture shown faintly until the word is built.
class _Faded extends CardFace {
  const _Faded(this.inner);
  final CardFace inner;

  @override
  void paint(Canvas canvas, Rect rect) {
    canvas.saveLayer(rect, Paint()..color = const Color(0x40FFFFFF));
    inner.paint(canvas, rect);
    canvas.restore();
  }
}
