import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pips_world/app/strings.dart';
import 'package:pips_world/content/content_loader.dart';
import 'package:pips_world/content/models.dart';
import 'package:pips_world/games/common/mini_game.dart';
import 'package:pips_world/games/common/round_controller.dart';
import 'package:pips_world/l10n/app_localizations_en.dart';
import 'package:pips_world/l10n/app_localizations_sq.dart';

import '../helpers.dart';

GameDef gameDef(
  String type,
  Map<String, dynamic> params, {
  Map<String, dynamic>? difficulty,
  String world = 'animals',
  List<String> skills = const ['test.skill'],
}) => GameDef.fromJson({
  'id': 'test.$type',
  'world': world,
  'level': 1,
  'game': type,
  'ageBands': ['4-5'],
  'skills': skills,
  'params': params,
  'pillars': {'active': 2, 'engaged': 2, 'meaningful': 2, 'social': 2},
  'offscreen': 'offscreen.walk_like_penguin',
  'difficulty': ?difficulty,
});

String? Function(String) stringsFor(String locale) {
  final l = locale == 'sq' ? AppLocalizationsSq() : AppLocalizationsEn();
  return (k) => lookupString(l, k);
}

/// Pumps [engine] running [def] and returns the Flame game and a result slot.
Future<(G, List<MiniGameResult>, TestDeps)> pumpEngine<G extends FlameGame>(
  WidgetTester tester,
  GameEngine engine,
  GameDef def,
  ContentLibrary content, {
  int seed = 1,
  String locale = 'en',
  Size screen = tablet,
  TestDeps? deps,
}) async {
  setScreen(tester, screen);
  final d = deps ?? TestDeps();
  final results = <MiniGameResult>[];
  await tester.pumpWidget(
    testApp(
      deps: d,
      locale: locale,
      content: content,
      child: Builder(
        builder: (context) => engine.build(
          GameContext(
            def: def,
            content: content,
            band: AgeBand.preschool,
            locale: locale,
            random: Random(seed),
            text: stringsFor(locale),
            onFinished: results.add,
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  final game = tester.widget<GameWidget<FlameGame>>(find.byType(GameWidget<FlameGame>)).game! as G;
  return (game, results, d);
}

/// Screen position of a point in game coordinates.
Offset onScreen(WidgetTester tester, Vector2 gamePoint) =>
    tester.getTopLeft(find.byType(GameWidget<FlameGame>)) + Offset(gamePoint.x, gamePoint.y);

Future<void> tapGame(WidgetTester tester, Vector2 gamePoint) async {
  await tester.tapAt(onScreen(tester, gamePoint));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> dragGame(WidgetTester tester, Vector2 from, Vector2 to) async {
  final g = await tester.startGesture(onScreen(tester, from));
  const steps = 12;
  for (var i = 1; i <= steps; i++) {
    await g.moveTo(onScreen(tester, from + (to - from) * (i / steps)));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Lets round transitions and the end celebration run.
Future<void> settle(WidgetTester tester, {int seconds = 3}) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Golden of the whole game screen. Refresh: flutter test --update-goldens test/games
Future<void> expectGolden(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 200));
  await expectLater(find.byType(Scaffold).first, matchesGoldenFile('../../goldens/games/$name.png'));
  await settle(tester, seconds: 3);
}

Future<ContentLibrary> loadBundledContentForTest() => loadBundledContent();
