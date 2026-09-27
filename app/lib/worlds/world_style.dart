import 'package:flutter/material.dart';

import '../app/ui/patterns.dart';

/// Look of each world on the map: stripe colour, background pattern and the
/// picture on its tile. Keyed by the world's `icon` field in content JSON.
/// TODO(asset): replace the drawn tile pictures with illustrated world art.
class WorldStyle {
  const WorldStyle({required this.color, required this.pattern, required this.art});

  final Color color;
  final Pattern pattern;

  /// Draws the tile picture at the given face size.
  final Widget Function(double size) art;

  static WorldStyle of(String icon) => _styles[icon] ?? _fallback;
}

const _green = Color(0xFF4CBB47);
const _purple = Color(0xFF8E5CF7);
const _yellow = Color(0xFFFFC62E);
const _cyan = Color(0xFF1FB5E3);
const _orange = Color(0xFFFF8C1A);
const _pink = Color(0xFFFF5C8A);
const _red = Color(0xFFE8322B);
const _blue = Color(0xFF1E6FE0);
const _amber = Color(0xFFF5A300);
const _magenta = Color(0xFFD63AF9);

final _styles = <String, WorldStyle>{
  'animals': WorldStyle(color: _green, pattern: Pattern.waves, art: (s) => _icon(Icons.pets, _green, s)),
  'numbers': WorldStyle(
    color: _purple,
    pattern: Pattern.dots,
    art: (s) => _glyphs(const ['1', '2', '3'], const [_purple, _amber, _green], s),
  ),
  'letters': WorldStyle(
    color: _yellow,
    pattern: Pattern.stars,
    art: (s) => _glyphs(const ['A', 'B', 'C'], const [_red, _blue, _green], s),
  ),
  'shapes_colours': WorldStyle(color: _cyan, pattern: Pattern.confetti, art: _shapes),
  'board_games': WorldStyle(color: _orange, pattern: Pattern.zigzag, art: (s) => _icon(Icons.casino_rounded, _red, s)),
  'pips_house': WorldStyle(color: _pink, pattern: Pattern.diagonal, art: (s) => _icon(Icons.cottage_rounded, _pink, s)),
};

final _fallback = WorldStyle(color: _blue, pattern: Pattern.dots, art: (s) => _icon(Icons.public, _blue, s));

Widget _icon(IconData icon, Color color, double s) => Icon(icon, size: s * 0.56, color: color);

/// A few chunky characters in different colours, set at playful heights.
Widget _glyphs(List<String> chars, List<Color> colors, double s) => Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    for (var i = 0; i < chars.length; i++)
      Transform.translate(
        offset: Offset(0, i.isOdd ? -s * 0.06 : s * 0.04),
        child: Text(
          chars[i],
          style: TextStyle(fontSize: s * 0.36, fontWeight: FontWeight.w800, color: colors[i], height: 1),
        ),
      ),
  ],
);

/// Star, triangle and circle, as in the Shapes & Colours world.
Widget _shapes(double s) => SizedBox.square(
  dimension: s * 0.7,
  child: CustomPaint(painter: _ShapesPainter()),
);

class _ShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawPath(starPath(Offset(w * 0.5, w * 0.24), w * 0.24, w * 0.11), Paint()..color = _amber);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.24, w * 0.56)
        ..lineTo(w * 0.44, w * 0.92)
        ..lineTo(w * 0.04, w * 0.92)
        ..close(),
      Paint()..color = _magenta,
    );
    canvas.drawCircle(Offset(w * 0.74, w * 0.74), w * 0.19, Paint()..color = _green);
  }

  @override
  bool shouldRepaint(_ShapesPainter old) => false;
}

/// Level number drawn in the world's colour.
Widget levelArt(int number, Color color, double s) => Text(
  '$number',
  style: TextStyle(fontSize: s * 0.55, fontWeight: FontWeight.w800, color: color, height: 1),
);
