import '../../content/content_loader.dart';
import '../../content/models.dart';
import '../common/pools.dart';
import 'glyph_strokes.dart';

/// `trace_path`: trace a letter, numeral or shape with a finger.
///
/// Params: `glyphs`: list of ids — letters (`a`, `ë`, `sh`…), digits (`0`–`9`)
/// or shapes (`circle`, `square`, `triangle`, `rectangle`, `star`, `heart`, `diamond`);
/// one glyph per round, in order (`rounds` defaults to the number of glyphs).
class TracePathConfig {
  TracePathConfig(this.params);

  final Map<String, dynamic> params;

  List<String> get glyphs => (params['glyphs'] as List<dynamic>?)?.cast<String>() ?? const ['o'];

  /// Narration key naming [glyph] in [locale].
  static String promptKey(String glyph, String locale) {
    if (int.tryParse(glyph) != null) return numberKey(int.parse(glyph));
    if (glyph.length > 2) return 'shape.$glyph';
    return letterKey(locale, glyph);
  }

  static List<String> validate(GameDef def, ContentLibrary lib) => [
    for (final g in TracePathConfig(def.params).glyphs)
      if (glyphFor(g) == null) '${def.id}: no stroke data for "$g"',
  ];
}
