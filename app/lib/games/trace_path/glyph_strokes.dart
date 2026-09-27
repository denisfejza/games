import 'dart:math';
import 'dart:ui';

/// Stroke paths children trace. Units: a box 1 wide; letters sit on a
/// baseline at y = 1 with the x-height from 0.42 and descenders to 1.25;
/// digits and shapes fill 0–1. Simplified school print, one path per stroke,
/// in writing order. TODO(pedagogy): the educator checks stroke order per
/// language (docs/CURRICULUM.md); Albanian and English share letter shapes.
class Glyph {
  const Glyph(this.strokes, {this.width = 1, this.height = 1.25});

  final List<List<Offset>> strokes;
  final double width;
  final double height;
}

List<Offset> _line(List<Offset> pts) {
  final out = <Offset>[pts.first];
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final n = max(1, ((b - a).distance / 0.02).ceil());
    for (var s = 1; s <= n; s++) {
      out.add(Offset.lerp(a, b, s / n)!);
    }
  }
  return out;
}

/// Arc from [from]° to [to]° (0 = right, 90 = down; decreasing = anticlockwise).
List<Offset> _arc(double cx, double cy, double rx, double ry, double from, double to) {
  final n = max(8, ((to - from).abs() / 6).ceil());
  return [
    for (var i = 0; i <= n; i++)
      Offset(
        cx + rx * cos((from + (to - from) * i / n) * pi / 180),
        cy + ry * sin((from + (to - from) * i / n) * pi / 180),
      ),
  ];
}

List<Offset> _join(List<List<Offset>> parts) => [for (final p in parts) ...p];

const _o = Offset.new;

final Map<String, Glyph> _letters = {
  'a': Glyph([
    _arc(0.46, 0.71, 0.24, 0.29, -30, -390),
    _line([_o(0.72, 0.42), _o(0.72, 1.0)]),
  ]),
  'b': Glyph([
    _line([_o(0.3, 0.0), _o(0.3, 1.0)]),
    _arc(0.52, 0.71, 0.22, 0.29, 180, 540),
  ]),
  'c': Glyph([_arc(0.52, 0.71, 0.26, 0.29, -40, -320)]),
  'd': Glyph([
    _arc(0.46, 0.71, 0.24, 0.29, -30, -390),
    _line([_o(0.72, 0.0), _o(0.72, 1.0)]),
  ]),
  'e': Glyph([
    _join([
      _line([_o(0.25, 0.71), _o(0.77, 0.71)]),
      _arc(0.51, 0.71, 0.26, 0.29, 0, -310),
    ]),
  ]),
  'f': Glyph([
    _join([
      _arc(0.64, 0.18, 0.14, 0.16, -20, -180),
      _line([_o(0.5, 0.18), _o(0.5, 1.0)]),
    ]),
    _line([_o(0.3, 0.46), _o(0.72, 0.46)]),
  ]),
  'g': Glyph([
    _arc(0.46, 0.66, 0.24, 0.24, -30, -390),
    _join([
      _line([_o(0.72, 0.42), _o(0.72, 1.05)]),
      _arc(0.5, 1.05, 0.22, 0.15, 0, 160),
    ]),
  ]),
  'h': Glyph([
    _line([_o(0.3, 0.0), _o(0.3, 1.0)]),
    _join([
      _arc(0.5, 0.64, 0.2, 0.2, 180, 360),
      _line([_o(0.7, 0.64), _o(0.7, 1.0)]),
    ]),
  ]),
  'i': Glyph([
    _line([_o(0.5, 0.42), _o(0.5, 1.0)]),
    _line([_o(0.5, 0.2), _o(0.5, 0.25)]),
  ]),
  'j': Glyph([
    _join([
      _line([_o(0.56, 0.42), _o(0.56, 1.05)]),
      _arc(0.4, 1.05, 0.16, 0.14, 0, 170),
    ]),
    _line([_o(0.56, 0.2), _o(0.56, 0.25)]),
  ]),
  'k': Glyph([
    _line([_o(0.3, 0.0), _o(0.3, 1.0)]),
    _line([_o(0.72, 0.42), _o(0.32, 0.74), _o(0.74, 1.0)]),
  ]),
  'l': Glyph([
    _line([_o(0.5, 0.0), _o(0.5, 1.0)]),
  ]),
  'm': Glyph([
    _line([_o(0.18, 0.42), _o(0.18, 1.0)]),
    _join([
      _arc(0.34, 0.62, 0.16, 0.2, 180, 360),
      _line([_o(0.5, 0.62), _o(0.5, 1.0)]),
    ]),
    _join([
      _arc(0.66, 0.62, 0.16, 0.2, 180, 360),
      _line([_o(0.82, 0.62), _o(0.82, 1.0)]),
    ]),
  ]),
  'n': Glyph([
    _line([_o(0.3, 0.42), _o(0.3, 1.0)]),
    _join([
      _arc(0.5, 0.64, 0.2, 0.22, 180, 360),
      _line([_o(0.7, 0.64), _o(0.7, 1.0)]),
    ]),
  ]),
  'o': Glyph([_arc(0.5, 0.71, 0.26, 0.29, -90, -450)]),
  'p': Glyph([
    _line([_o(0.3, 0.42), _o(0.3, 1.25)]),
    _arc(0.52, 0.71, 0.22, 0.29, 180, 540),
  ]),
  'q': Glyph([
    _arc(0.46, 0.71, 0.24, 0.29, -30, -390),
    _line([_o(0.72, 0.42), _o(0.72, 1.25)]),
  ]),
  'r': Glyph([
    _line([_o(0.36, 0.42), _o(0.36, 1.0)]),
    _arc(0.56, 0.64, 0.2, 0.22, 180, 310),
  ]),
  's': Glyph([
    _join([_arc(0.5, 0.56, 0.2, 0.14, -20, -270), _arc(0.5, 0.85, 0.22, 0.15, -90, 160)]),
  ]),
  't': Glyph([
    _join([
      _line([_o(0.48, 0.15), _o(0.48, 0.88)]),
      _arc(0.6, 0.88, 0.12, 0.12, 180, 90),
    ]),
    _line([_o(0.28, 0.44), _o(0.7, 0.44)]),
  ]),
  'u': Glyph([
    _join([
      _line([_o(0.3, 0.42), _o(0.3, 0.8)]),
      _arc(0.5, 0.8, 0.2, 0.2, 180, 0),
    ]),
    _line([_o(0.7, 0.42), _o(0.7, 1.0)]),
  ]),
  'v': Glyph([
    _line([_o(0.24, 0.42), _o(0.5, 1.0), _o(0.76, 0.42)]),
  ]),
  'w': Glyph([
    _line([_o(0.12, 0.42), _o(0.3, 1.0), _o(0.5, 0.6), _o(0.7, 1.0), _o(0.88, 0.42)]),
  ]),
  'x': Glyph([
    _line([_o(0.28, 0.42), _o(0.72, 1.0)]),
    _line([_o(0.72, 0.42), _o(0.28, 1.0)]),
  ]),
  'y': Glyph([
    _line([_o(0.28, 0.42), _o(0.5, 0.86)]),
    _line([_o(0.72, 0.42), _o(0.38, 1.25)]),
  ]),
  'z': Glyph([
    _line([_o(0.28, 0.42), _o(0.72, 0.42), _o(0.28, 1.0), _o(0.72, 1.0)]),
  ]),
};

final Map<String, Glyph> _digits = {
  '0': Glyph([_arc(0.5, 0.5, 0.3, 0.46, -90, -450)], height: 1),
  '1': Glyph([
    _line([_o(0.34, 0.2), _o(0.56, 0.04), _o(0.56, 1.0)]),
  ], height: 1),
  '2': Glyph([
    _join([
      _arc(0.5, 0.3, 0.26, 0.26, -160, 20),
      _line([_o(0.72, 0.42), _o(0.24, 1.0), _o(0.78, 1.0)]),
    ]),
  ], height: 1),
  '3': Glyph([
    _join([_arc(0.48, 0.27, 0.24, 0.23, -160, 90), _arc(0.48, 0.74, 0.27, 0.26, -90, 160)]),
  ], height: 1),
  '4': Glyph([
    _line([_o(0.62, 1.0), _o(0.62, 0.04), _o(0.2, 0.68), _o(0.82, 0.68)]),
  ], height: 1),
  '5': Glyph([
    _join([
      _line([_o(0.72, 0.05), _o(0.32, 0.05), _o(0.3, 0.44)]),
      _arc(0.5, 0.7, 0.26, 0.27, -130, 150),
    ]),
  ], height: 1),
  '6': Glyph([
    _join([_arc(0.56, 0.52, 0.3, 0.46, -80, -180), _arc(0.5, 0.74, 0.24, 0.24, 180, 540)]),
  ], height: 1),
  '7': Glyph([
    _line([_o(0.25, 0.05), _o(0.78, 0.05), _o(0.4, 1.0)]),
  ], height: 1),
  '8': Glyph([
    _join([_arc(0.5, 0.27, 0.2, 0.23, 90, -270), _arc(0.5, 0.74, 0.26, 0.26, -90, 270)]),
  ], height: 1),
  '9': Glyph([
    _join([
      _arc(0.5, 0.3, 0.24, 0.26, 0, -360),
      _line([_o(0.74, 0.3), _o(0.7, 1.0)]),
    ]),
  ], height: 1),
};

final Map<String, Glyph> _shapes = {
  'circle': Glyph([_arc(0.5, 0.5, 0.42, 0.42, -90, -450)], height: 1),
  'square': Glyph([
    _line([_o(0.12, 0.12), _o(0.88, 0.12), _o(0.88, 0.88), _o(0.12, 0.88), _o(0.12, 0.12)]),
  ], height: 1),
  'rectangle': Glyph([
    _line([_o(0.05, 0.25), _o(0.95, 0.25), _o(0.95, 0.75), _o(0.05, 0.75), _o(0.05, 0.25)]),
  ], height: 1),
  'triangle': Glyph([
    _line([_o(0.5, 0.08), _o(0.92, 0.9), _o(0.08, 0.9), _o(0.5, 0.08)]),
  ], height: 1),
  'diamond': Glyph([
    _line([_o(0.5, 0.05), _o(0.85, 0.5), _o(0.5, 0.95), _o(0.15, 0.5), _o(0.5, 0.05)]),
  ], height: 1),
  'star': Glyph([
    _line([
      for (var i = 0; i <= 10; i++)
        Offset(
          0.5 + (i.isEven ? 0.45 : 0.19) * cos(-pi / 2 + i * pi / 5),
          0.53 + (i.isEven ? 0.45 : 0.19) * sin(-pi / 2 + i * pi / 5),
        ),
    ]),
  ], height: 1),
  'heart': Glyph([
    _join([
      _arc(0.3, 0.35, 0.2, 0.2, 0, -200),
      _line([_o(0.11, 0.42), _o(0.5, 0.9), _o(0.89, 0.42)]),
      _arc(0.7, 0.35, 0.2, 0.2, 20, -180),
    ]),
  ], height: 1),
};

Glyph _shift(Glyph g, double dx, double scaleX, {List<List<Offset>> extra = const []}) => Glyph(
  [
    for (final s in [...g.strokes, ...extra]) [for (final p in s) Offset(dx + p.dx * scaleX, p.dy)],
  ],
  width: g.width,
  height: g.height,
);

/// The glyph to trace for [id]: a letter (including Albanian ë, ç and the nine
/// digraphs, traced as one tile of two parts), a digit, or a shape name.
Glyph? glyphFor(String id) {
  if (_shapes[id] case final g?) return g;
  if (_digits[id] case final g?) return g;
  if (_letters[id] case final g?) return g;
  if (id == 'ë') {
    return _shift(
      _letters['e']!,
      0,
      1,
      extra: [
        _line([_o(0.36, 0.22), _o(0.36, 0.27)]),
        _line([_o(0.64, 0.22), _o(0.64, 0.27)]),
      ],
    );
  }
  if (id == 'ç') {
    return _shift(
      _letters['c']!,
      0,
      1,
      extra: [
        _line([_o(0.52, 1.0), _o(0.56, 1.1), _o(0.44, 1.2)]),
      ],
    );
  }
  if (id.length == 2 && _letters[id[0]] != null && _letters[id[1]] != null) {
    final a = _shift(_letters[id[0]]!, 0, 0.8);
    final b = _shift(_letters[id[1]]!, 0.8, 0.8);
    return Glyph([...a.strokes, ...b.strokes], width: 1.6);
  }
  return null;
}

/// Everything that can be traced.
Iterable<String> get traceableIds => [
  ..._letters.keys,
  'ë',
  'ç',
  'dh',
  'gj',
  'll',
  'nj',
  'rr',
  'sh',
  'th',
  'xh',
  'zh',
  ..._digits.keys,
  ..._shapes.keys,
];
