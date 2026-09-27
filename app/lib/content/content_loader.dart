import 'dart:convert';

import 'package:flutter/services.dart';

import 'content_schema.dart';
import 'models.dart';

const contentRoot = 'assets/content/';
const schemaPath = '${contentRoot}schema.json';

class ContentException implements Exception {
  ContentException(this.errors);

  final List<String> errors;

  @override
  String toString() => 'Invalid content:\n${errors.join('\n')}';
}

/// All worlds, levels and games, validated and linked.
class ContentLibrary {
  ContentLibrary._(this.worlds);

  /// Builds the tree from raw files keyed by asset path.
  ///
  /// The folder decides the kind: `worlds/` or `games/` (any depth below).
  /// Throws [ContentException] listing every problem found, not just the first.
  factory ContentLibrary.fromFiles(Map<String, String> files, ContentSchema schema) {
    final errors = <String>[];
    final worldJson = <String, Map<String, dynamic>>{};
    final games = <GameDef>[];
    final gameIds = <String>{};

    for (final MapEntry(key: path, value: source) in files.entries) {
      final kind = _kindOf(path);
      if (kind == null) {
        errors.add('$path: not under worlds/ or games/');
        continue;
      }
      final Object? json;
      try {
        json = jsonDecode(source);
      } on FormatException catch (e) {
        errors.add('$path: invalid JSON (${e.message})');
        continue;
      }
      final problems = schema.validate(kind, json);
      if (problems.isNotEmpty) {
        errors.addAll(problems.map((p) => '$path $p'));
        continue;
      }
      final map = json as Map<String, dynamic>;
      final id = map['id'] as String;
      if (kind == ContentKind.world) {
        if (worldJson.containsKey(id)) errors.add('$path: duplicate world id "$id"');
        worldJson[id] = map;
      } else {
        if (!gameIds.add(id)) errors.add('$path: duplicate game id "$id"');
        games.add(GameDef.fromJson(map));
      }
    }

    for (final g in games) {
      if (!worldJson.containsKey(g.world)) errors.add('${g.id}: unknown world "${g.world}"');
    }
    if (errors.isNotEmpty) throw ContentException(errors);

    final worlds = [
      for (final MapEntry(key: id, value: json) in worldJson.entries)
        worldFromJson(json, levels: _levels(id, games.where((g) => g.world == id))),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return ContentLibrary._(List.unmodifiable(worlds));
  }

  final List<World> worlds;

  World world(String id) => worlds.firstWhere((w) => w.id == id);

  Iterable<GameDef> get allGames => worlds.expand((w) => w.levels).expand((l) => l.games);

  static ContentKind? _kindOf(String path) {
    final rel = path.startsWith(contentRoot) ? path.substring(contentRoot.length) : path;
    if (rel.startsWith('worlds/')) return ContentKind.world;
    if (rel.startsWith('games/')) return ContentKind.game;
    return null;
  }

  static List<Level> _levels(String world, Iterable<GameDef> games) {
    final byNumber = <int, List<GameDef>>{};
    for (final g in games) {
      byNumber.putIfAbsent(g.level, () => []).add(g);
    }
    final numbers = byNumber.keys.toList()..sort();
    return [
      for (final n in numbers)
        Level(world: world, number: n, games: List.unmodifiable(byNumber[n]!..sort((a, b) => a.id.compareTo(b.id)))),
    ];
  }
}

/// Reads every JSON file under `assets/content/` from an [AssetBundle].
///
/// New files are picked up from the asset manifest, so adding a level only
/// needs a JSON file (and, for a new folder, a line in pubspec.yaml).
class ContentLoader {
  ContentLoader(this.bundle);

  final AssetBundle bundle;

  Future<ContentLibrary> load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final paths =
        manifest.listAssets().where((p) => p.startsWith(contentRoot) && p.endsWith('.json') && p != schemaPath).toList()
          ..sort();
    final schema = ContentSchema(jsonDecode(await bundle.loadString(schemaPath)) as Map<String, dynamic>);
    final files = {for (final p in paths) p: await bundle.loadString(p)};
    return ContentLibrary.fromFiles(files, schema);
  }
}
