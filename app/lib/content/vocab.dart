import 'dart:ui';

/// How a card is drawn. Emoji are placeholders. TODO(asset): illustrations.
sealed class Picture {
  const Picture();

  factory Picture.fromJson(Map<String, dynamic> json) {
    if (json['emoji'] case final String e) return EmojiPicture(e);
    if (json['colour'] case final String c) return ColourPicture(Color(int.parse('FF${c.substring(1)}', radix: 16)));
    if (json['shape'] case final String s) return ShapePicture(s);
    return ImagePicture(json['image'] as String);
  }
}

class EmojiPicture extends Picture {
  const EmojiPicture(this.emoji);
  final String emoji;
}

class ColourPicture extends Picture {
  const ColourPicture(this.colour);
  final Color colour;
}

class ShapePicture extends Picture {
  const ShapePicture(this.shape);
  final String shape;
}

class ImagePicture extends Picture {
  const ImagePicture(this.path);
  final String path;
}

/// A thing a card can show and Pip can name: an animal, a food, a colour…
class VocabItem {
  const VocabItem({
    required this.id,
    required this.nameKey,
    required this.picture,
    required this.tags,
    this.soundKey,
    this.props = const {},
  });

  factory VocabItem.fromJson(Map<String, dynamic> json) => VocabItem(
    id: json['id'] as String,
    nameKey: json['nameKey'] as String,
    picture: Picture.fromJson(json),
    tags: {for (final t in json['tags'] as List<dynamic>) t as String},
    soundKey: json['soundKey'] as String?,
    props: {for (final e in (json['props'] as Map<String, dynamic>? ?? const {}).entries) e.key: e.value as String},
  );

  final String id;

  /// Narration + caption key for the item's name, e.g. `vocab.cow`.
  final String nameKey;
  final Picture picture;
  final Set<String> tags;

  /// Narration key of the item's noise (animals), e.g. `sfx.animal.cow`.
  final String? soundKey;

  /// Facts used by games: `habitat`, `food`, `size`, `lives`, `colour`, `shape`.
  final Map<String, String> props;
}
