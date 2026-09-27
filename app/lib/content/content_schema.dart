import 'package:json_schema/json_schema.dart';

/// Validates content files against `assets/content/schema.json`.
class ContentSchema {
  ContentSchema(Map<String, dynamic> schema) : _world = _sub(schema, 'world'), _game = _sub(schema, 'game');

  final JsonSchema _world;
  final JsonSchema _game;

  static JsonSchema _sub(Map<String, dynamic> root, String def) =>
      JsonSchema.create(root).resolvePath(Uri.parse('#/\$defs/$def'));

  /// Returns human-readable errors; empty when [json] is valid.
  List<String> validate(ContentKind kind, Object? json) {
    final schema = switch (kind) {
      ContentKind.world => _world,
      ContentKind.game => _game,
    };
    return [
      for (final e in schema.validate(json).errors) '${e.instancePath.isEmpty ? '/' : e.instancePath}: ${e.message}',
    ];
  }
}

enum ContentKind { world, game }
