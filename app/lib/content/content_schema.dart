import 'package:json_schema/json_schema.dart';

/// Validates content files against `assets/content/schema.json`.
class ContentSchema {
  factory ContentSchema(Map<String, dynamic> schema) {
    final root = JsonSchema.create(schema);
    JsonSchema sub(String def) => root.resolvePath(Uri.parse('#/\$defs/$def'));
    return ContentSchema._({for (final k in ContentKind.values) k: sub(k.name)});
  }

  ContentSchema._(this._schemas);

  final Map<ContentKind, JsonSchema> _schemas;

  /// Returns human-readable errors; empty when [json] is valid.
  List<String> validate(ContentKind kind, Object? json) => [
        for (final e in _schemas[kind]!.validate(json).errors)
          '${e.instancePath.isEmpty ? '/' : e.instancePath}: ${e.message}',
      ];
}

/// Kinds of content file; each name matches a `$defs` entry in schema.json.
enum ContentKind { world, game, vocab }
