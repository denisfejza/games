import 'dart:math';
import 'dart:ui';

import 'glyph_strokes.dart';

/// Tracks a finger along a glyph's strokes, checkpoint by checkpoint.
///
/// Generous by design: the finger only has to come within [tolerance] of one
/// of the next few checkpoints to move on, so wobbly lines still count.
class TraceProgress {
  TraceProgress(this.glyph, {this.tolerance = 0.14, this.lookAhead = 4, double spacing = 0.05})
    : checkpoints = [for (final s in glyph.strokes) _resample(s, spacing)];

  final Glyph glyph;
  final double tolerance;
  final int lookAhead;
  final List<List<Offset>> checkpoints;

  int stroke = 0;

  /// Last checkpoint reached on the current stroke (-1: not started).
  int reached = -1;

  bool get done => stroke >= checkpoints.length;

  /// Progress along the current stroke, 0–1.
  double get strokeProgress => done ? 1 : (reached + 1) / checkpoints[stroke].length;

  /// Where the next checkpoint is (for the "start here" dot and hints).
  Offset? get next => done ? null : checkpoints[stroke][reached + 1];

  /// Feeds a finger position (glyph units). Returns true if it moved things on.
  bool update(Offset p) {
    if (done) return false;
    final pts = checkpoints[stroke];
    var moved = false;
    for (var i = reached + 1; i <= min(reached + lookAhead, pts.length - 1); i++) {
      if ((pts[i] - p).distance <= tolerance) {
        reached = i;
        moved = true;
      }
    }
    // Close enough to the end of the stroke: count it and move to the next.
    if (reached >= pts.length - 2) {
      stroke++;
      reached = -1;
      moved = true;
    }
    return moved;
  }

  static List<Offset> _resample(List<Offset> pts, double spacing) {
    final out = <Offset>[pts.first];
    var carry = 0.0;
    for (var i = 1; i < pts.length; i++) {
      var a = pts[i - 1];
      final b = pts[i];
      var seg = (b - a).distance;
      while (carry + seg >= spacing) {
        final t = (spacing - carry) / seg;
        a = Offset.lerp(a, b, t)!;
        out.add(a);
        seg = (b - a).distance;
        carry = 0;
      }
      carry += seg;
    }
    if ((out.last - pts.last).distance > spacing * 0.3) out.add(pts.last);
    return out;
  }
}
