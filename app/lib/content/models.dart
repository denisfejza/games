/// Typed content tree built from `assets/content/**/*.json`.
library;

enum AgeBand {
  toddler('2-3'),
  preschool('4-5'),
  school('6-7');

  const AgeBand(this.json);

  /// The value used in content JSON, e.g. `"4-5"`.
  final String json;

  static AgeBand fromJson(String value) =>
      values.firstWhere((b) => b.json == value, orElse: () => throw FormatException('Unknown age band "$value"'));
}

class Pillars {
  const Pillars({required this.active, required this.engaged, required this.meaningful, required this.social});

  factory Pillars.fromJson(Map<String, dynamic> json) => Pillars(
    active: json['active'] as int,
    engaged: json['engaged'] as int,
    meaningful: json['meaningful'] as int,
    social: json['social'] as int,
  );

  final int active;
  final int engaged;
  final int meaningful;
  final int social;
}

class Difficulty {
  const Difficulty({required this.raiseAfter, required this.lowerAfter, required this.steps});

  factory Difficulty.fromJson(Map<String, dynamic> json) => Difficulty(
    raiseAfter: json['raiseAfter'] as int,
    lowerAfter: json['lowerAfter'] as int,
    steps: [for (final s in json['steps'] as List<dynamic>) Map<String, dynamic>.from(s as Map)],
  );

  final int raiseAfter;
  final int lowerAfter;

  /// Parameter overrides, easiest first. Each engine merges a step into its params.
  final List<Map<String, dynamic>> steps;
}

/// One mini-game definition: which engine runs it and with which params.
class GameDef {
  const GameDef({
    required this.id,
    required this.world,
    required this.level,
    required this.type,
    required this.ageBands,
    required this.skills,
    required this.params,
    required this.pillars,
    required this.offscreenKey,
    this.difficulty,
    this.curriculum = const {},
    this.locales = const {},
  });

  factory GameDef.fromJson(Map<String, dynamic> json) => GameDef(
    id: json['id'] as String,
    world: json['world'] as String,
    level: json['level'] as int,
    type: json['game'] as String,
    ageBands: _ageBands(json['ageBands']),
    skills: [for (final s in json['skills'] as List<dynamic>) s as String],
    params: Map<String, dynamic>.from(json['params'] as Map),
    pillars: Pillars.fromJson(Map<String, dynamic>.from(json['pillars'] as Map)),
    offscreenKey: json['offscreen'] as String,
    difficulty: json['difficulty'] == null
        ? null
        : Difficulty.fromJson(Map<String, dynamic>.from(json['difficulty'] as Map)),
    curriculum: {
      for (final e in (json['curriculum'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: [for (final c in e.value as List<dynamic>) c as String],
    },
    locales: {for (final l in json['locales'] as List<dynamic>? ?? const []) l as String},
  );

  /// A copy with different params (engines that derive defaults, e.g. rounds).
  static GameDef fromJsonWithParams(GameDef d, Map<String, dynamic> params) => GameDef(
    id: d.id,
    world: d.world,
    level: d.level,
    type: d.type,
    ageBands: d.ageBands,
    skills: d.skills,
    params: params,
    pillars: d.pillars,
    offscreenKey: d.offscreenKey,
    difficulty: d.difficulty,
    curriculum: d.curriculum,
    locales: d.locales,
  );

  final String id;
  final String world;
  final int level;

  /// Engine name, e.g. `sound_match` (a folder under `lib/games/`).
  final String type;
  final Set<AgeBand> ageBands;
  final List<String> skills;
  final Map<String, dynamic> params;
  final Pillars pillars;

  /// Content key of the off-screen challenge, e.g. `offscreen.walk_like_penguin`.
  final String offscreenKey;
  final Difficulty? difficulty;
  final Map<String, List<String>> curriculum;

  /// Languages this game is for (e.g. per-language phonics); empty = all.
  final Set<String> locales;

  bool availableIn(String locale) => locales.isEmpty || locales.contains(locale);
}

class Level {
  const Level({required this.world, required this.number, required this.games});

  final String world;
  final int number;
  final List<GameDef> games;

  Set<String> get skills => {for (final g in games) ...g.skills};

  /// Age bands that have at least one game in this level.
  Set<AgeBand> get ageBands => {for (final g in games) ...g.ageBands};

  /// The games a child of [band] plays in [locale].
  List<GameDef> gamesFor(AgeBand band, String locale) => [
    for (final g in games)
      if (g.ageBands.contains(band) && g.availableIn(locale)) g,
  ];
}

class World {
  const World({
    required this.id,
    required this.order,
    required this.titleKey,
    required this.icon,
    required this.ageBands,
    required this.levels,
  });

  final String id;
  final int order;

  /// ARB key of the world's name (and its narration key).
  final String titleKey;
  final String icon;
  final Set<AgeBand> ageBands;

  /// Levels in play order (1…N), derived from the games that name this world.
  final List<Level> levels;

  /// Levels with at least one game for [band] (and [locale], if given).
  List<Level> levelsFor(AgeBand band, [String? locale]) => [
    for (final l in levels)
      if (locale == null ? l.ageBands.contains(band) : l.gamesFor(band, locale).isNotEmpty) l,
  ];
}

Set<AgeBand> _ageBands(Object? json) => {for (final b in json as List<dynamic>) AgeBand.fromJson(b as String)};

/// Builds a [World] (without levels) from its JSON file.
World worldFromJson(Map<String, dynamic> json, {List<Level> levels = const []}) => World(
  id: json['id'] as String,
  order: json['order'] as int,
  titleKey: json['titleKey'] as String,
  icon: json['icon'] as String,
  ageBands: _ageBands(json['ageBands']),
  levels: levels,
);
