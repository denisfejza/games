import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/strings.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/vocab.dart';

import '../../tool/gen_lookup.dart' as gen;
import '../helpers.dart';

void main() {
  late ContentLibrary lib;
  setUpAll(() async => lib = await loadBundledContent());

  test('lib/l10n/lookup.g.dart is up to date (run: dart run tool/gen_lookup.dart)', () {
    final arb = jsonDecode(File(gen.arbPath).readAsStringSync()) as Map<String, dynamic>;
    expect(File(gen.outPath).readAsStringSync(), gen.generate(arb));
  });

  test('vocab loads with every kind of picture', () {
    expect(lib.vocab.length, greaterThan(100));
    expect(lib.item('cow').picture, isA<EmojiPicture>());
    expect(lib.item('red').picture, isA<ColourPicture>());
    expect(lib.item('circle').picture, isA<ShapePicture>());
    expect(lib.itemsTagged({'animal', 'farm'}).map((v) => v.id), containsAll(['cow', 'sheep', 'pig', 'hen']));
  });

  test('every vocab name has an en and sq string', () {
    for (final v in lib.vocab.values) {
      expect(hasString(v.nameKey), isTrue, reason: v.nameKey);
    }
  });

  test('food and habitat facts point at real items', () {
    for (final v in lib.vocab.values) {
      final food = v.props['food'];
      if (food != null) expect(lib.vocab, contains(food), reason: '${v.id} eats $food');
      final colour = v.props['colour'];
      if (colour != null) expect(lib.vocab, contains(colour), reason: '${v.id} is $colour');
    }
  });

  test('every emoji used by vocab is in the bundled PipEmoji font list', () {
    final listed = File('tool/emoji_used.txt').readAsStringSync();
    for (final v in lib.vocab.values) {
      if (v.picture case EmojiPicture(:final emoji)) expect(listed, contains(emoji), reason: v.id);
    }
  });
}
