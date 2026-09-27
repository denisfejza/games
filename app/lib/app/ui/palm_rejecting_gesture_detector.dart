import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';

/// Tap detector for small hands.
///
/// - Ignores palm/forearm contacts (large touch radius).
/// - A second finger cancels the tap (no multi-finger gestures).
/// - Drops repeat taps within [debounce].
/// - Calls [onTapDown] immediately so feedback lands well within 100 ms.
class PalmRejectingGestureDetector extends StatefulWidget {
  const PalmRejectingGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onTapCancel,
    this.debounce = const Duration(milliseconds: 300),
    this.maxContactRadius = 28,
    this.slop = 24,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapCancel;
  final Duration debounce;

  /// Touches with a larger radius (logical px) count as a palm and are ignored.
  final double maxContactRadius;

  /// A finger that moves further than this (logical px) is a drag, not a tap.
  final double slop;

  @override
  State<PalmRejectingGestureDetector> createState() => _PalmRejectingGestureDetectorState();
}

class _PalmRejectingGestureDetectorState extends State<PalmRejectingGestureDetector> {
  final Set<int> _down = {};
  int? _candidate;
  Offset _start = Offset.zero;
  DateTime? _lastTap;

  void _cancel() {
    if (_candidate == null) return;
    _candidate = null;
    widget.onTapCancel?.call();
  }

  void _onDown(PointerDownEvent e) {
    _down.add(e.pointer);
    if (_down.length > 1) return _cancel();
    if (e.radiusMajor > widget.maxContactRadius) return;
    _candidate = e.pointer;
    _start = e.position;
    widget.onTapDown?.call();
  }

  void _onMove(PointerMoveEvent e) {
    if (e.pointer == _candidate && (e.position - _start).distance > widget.slop) _cancel();
  }

  void _onUp(PointerUpEvent e) {
    _down.remove(e.pointer);
    if (e.pointer != _candidate) return;
    _candidate = null;
    final now = clock.now();
    final last = _lastTap;
    if (last != null && now.difference(last) < widget.debounce) {
      widget.onTapCancel?.call();
      return;
    }
    _lastTap = now;
    widget.onTap?.call();
  }

  void _onCancel(PointerCancelEvent e) {
    _down.remove(e.pointer);
    if (e.pointer == _candidate) _cancel();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: _onDown,
    onPointerMove: _onMove,
    onPointerUp: _onUp,
    onPointerCancel: _onCancel,
    child: widget.child,
  );
}
