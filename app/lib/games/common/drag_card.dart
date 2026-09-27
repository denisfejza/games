import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

import 'game_card.dart';

/// A card the child drags with a big finger movement. Dropped cards snap to a
/// target or glide home; [onDrop] decides which.
class DragCard extends GameCard with DragCallbacks {
  DragCard({required super.face, required super.size, super.value, this.onDrop, super.onTap});

  /// Returns true if the card was accepted where it was dropped.
  bool Function(DragCard card, Vector2 at)? onDrop;

  /// Where the card rests between drags.
  Vector2 home = Vector2.zero();
  bool _dragging = false;
  int _basePriority = 0;

  bool get dragging => _dragging;

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (dimmed || game.locked || done) return;
    _dragging = true;
    _basePriority = priority;
    priority = 100;
    scale = Vector2.all(1.08);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragging) position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_dragging) return;
    _dragging = false;
    priority = _basePriority;
    scale = Vector2.all(1);
    final accepted = onDrop?.call(this, position.clone()) ?? false;
    if (!accepted) goHome();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (_dragging) {
      _dragging = false;
      priority = _basePriority;
      scale = Vector2.all(1);
      goHome();
    }
  }

  void goHome() {
    if (game.host.reducedMotion) {
      position = home.clone();
      return;
    }
    add(MoveToEffect(home.clone(), EffectController(duration: 0.25)));
  }

  /// Glides into [target] and stays there.
  void snapTo(Vector2 target) {
    home = target.clone();
    if (game.host.reducedMotion) {
      position = target.clone();
    } else {
      add(MoveToEffect(target.clone(), EffectController(duration: 0.15)));
    }
  }
}

/// The target whose centre is nearest [at], if within a generous reach.
T? nearestTarget<T extends PositionComponent>(Iterable<T> targets, Vector2 at, {double reach = 0.8}) {
  T? best;
  var bestD = double.infinity;
  for (final t in targets) {
    final d = t.position.distanceTo(at);
    if (d < bestD && d <= t.size.x * reach) {
      bestD = d;
      best = t;
    }
  }
  return best;
}
