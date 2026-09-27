import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/ui/motion.dart';
import '../app/ui/palm_rejecting_gesture_detector.dart';
import '../content/vocab.dart';
import '../core/audio/audio_service.dart';
import 'pip_controller.dart';
import 'pip_painter.dart';
import 'pip_rive.dart';

final pipControllerProvider = Provider<PipController>((ref) {
  final c = PipController();
  ref.onDispose(c.dispose);
  return c;
});

/// Pip on screen. Talks (mouth flaps) while narration plays, replays a short
/// reaction whenever [PipController.reaction] changes, and reports taps by
/// body part. Idle Pip stays still so nothing moves while a child decides.
class PipView extends ConsumerStatefulWidget {
  const PipView({super.key, this.width = 160, this.onPart, this.interactive = true});

  final double width;
  final void Function(PipPart part)? onPart;
  final bool interactive;

  @override
  ConsumerState<PipView> createState() => _PipViewState();
}

class _PipViewState extends ConsumerState<PipView> with TickerProviderStateMixin {
  late final AnimationController _flap = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  late final AnimationController _oneShot = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final PipController _pip = ref.read(pipControllerProvider);
  late final AudioService _audio = ref.read(audioServiceProvider);
  int _lastReaction = 0;

  @override
  void initState() {
    super.initState();
    _pip.addListener(_onPip);
    _audio.speaking.addListener(_onSpeaking);
    _onSpeaking();
  }

  void _onPip() {
    if (_pip.reaction != _lastReaction) {
      _lastReaction = _pip.reaction;
      if (!_still) _oneShot.forward(from: 0);
    }
    setState(() {});
  }

  bool get _still => mounted && reduceMotion(context, ref);

  void _onSpeaking() {
    // TODO(asset): drive the mouth from the recording's loudness once recordings exist.
    if (_audio.speaking.value && !_still) {
      _flap.repeat(reverse: true);
    } else {
      _flap.stop();
      _flap.value = 0;
    }
  }

  @override
  void dispose() {
    _pip.removeListener(_onPip);
    _audio.speaking.removeListener(_onSpeaking);
    _flap.dispose();
    _oneShot.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(widget.width, widget.width * PipPainter.aspect);
    final riveReady = ref.watch(pipRiveAvailableProvider).value ?? false;
    final speaking = _audio.speaking.value;
    final mood = speaking && _pip.mood == PipMood.idle ? PipMood.talking : _pip.mood;

    final drawn = AnimatedBuilder(
      animation: Listenable.merge([_flap, _oneShot]),
      builder: (context, _) => CustomPaint(
        size: size,
        painter: PipPainter(mood: mood, mouthOpen: speaking ? _flap.value : 0, bounce: _oneShot.value),
      ),
    );
    final pip = riveReady
        ? SizedBox.fromSize(
            size: size,
            child: RivePip(mood: mood, mouth: speaking ? _flap.value : 0, fallback: drawn),
          )
        : drawn;

    return Semantics(
      label: 'Pip',
      button: widget.onPart != null,
      child: widget.interactive && widget.onPart != null
          ? PalmRejectingGestureDetector(
              // Tickling is several quick taps, so allow faster repeats than buttons do.
              debounce: const Duration(milliseconds: 90),
              onTapAt: (pos) {
                final part = PipPainter.partAt(pos, size);
                if (part != null) widget.onPart!(part);
              },
              child: pip,
            )
          : pip,
    );
  }
}

/// Pip that reacts to pokes: names the body part, giggles when tickled
/// (three quick belly taps), and eats food dragged onto his face.
class PokeablePip extends ConsumerStatefulWidget {
  const PokeablePip({super.key, this.width = 180, this.feedable = true});

  final double width;
  final bool feedable;

  @override
  ConsumerState<PokeablePip> createState() => _PokeablePipState();
}

class _PokeablePipState extends ConsumerState<PokeablePip> {
  final List<DateTime> _bellyTaps = [];

  static const partNames = {
    PipPart.nose: 'vocab.nose',
    PipPart.ear: 'vocab.ear',
    PipPart.belly: 'pipBelly',
    PipPart.feet: 'vocab.foot',
    PipPart.mouth: 'vocab.mouth',
    PipPart.hand: 'vocab.hand',
  };

  void _onPart(PipPart part) {
    final audio = ref.read(audioServiceProvider);
    final pip = ref.read(pipControllerProvider);
    if (part == PipPart.belly) {
      final now = clock.now();
      _bellyTaps
        ..removeWhere((t) => now.difference(t) > const Duration(milliseconds: 1500))
        ..add(now);
      if (_bellyTaps.length >= 3) {
        _bellyTaps.clear();
        audio.effect(Effect.giggle);
        pip.onEvent(PipEvent.tickled);
        audio.say('pipTickle', interrupt: true);
        return;
      }
    }
    audio.effect(Effect.pop);
    pip.onEvent(PipEvent.poked);
    audio.say(partNames[part]!, interrupt: true);
  }

  void _feed(VocabItem food) {
    ref.read(audioServiceProvider).effect(Effect.pop);
    ref.read(pipControllerProvider).onEvent(PipEvent.fed);
    ref.read(audioServiceProvider).sayAll(['pipYum'], interrupt: true);
  }

  @override
  Widget build(BuildContext context) {
    final pip = PipView(key: const Key('pip'), width: widget.width, onPart: _onPart);
    if (!widget.feedable) return pip;
    return DragTarget<VocabItem>(
      // Big, forgiving target: anywhere on Pip counts as "to the mouth".
      onAcceptWithDetails: (d) => _feed(d.data),
      builder: (context, candidates, _) =>
          AnimatedScale(scale: candidates.isEmpty ? 1 : 1.06, duration: const Duration(milliseconds: 120), child: pip),
    );
  }
}

/// A food a child can drag to Pip.
class FoodItem extends StatelessWidget {
  const FoodItem({super.key, required this.item, this.size = 84});

  final VocabItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget face(double s) => Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Color(0x33000000), offset: Offset(0, 5))],
      ),
      child: PictureView(picture: item.picture, size: s * 0.62),
    );
    return Draggable<VocabItem>(
      data: item,
      feedback: Material(color: Colors.transparent, child: face(size * 1.2)),
      childWhenDragging: Opacity(opacity: 0.3, child: face(size)),
      child: face(size),
    );
  }
}

/// Draws a vocab picture: emoji (placeholder font), colour blob, or shape.
class PictureView extends StatelessWidget {
  const PictureView({super.key, required this.picture, required this.size});

  final Picture picture;
  final double size;

  @override
  Widget build(BuildContext context) => switch (picture) {
    EmojiPicture(:final emoji) => Text(
      emoji,
      style: TextStyle(fontFamily: 'PipEmoji', fontSize: size * 0.82, height: 1.15),
    ),
    ColourPicture(:final colour) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colour,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33000000), width: 3),
      ),
    ),
    ShapePicture(:final shape) => CustomPaint(size: Size.square(size), painter: ShapePainter(shape)),
    ImagePicture(:final path) => Image.asset(path, width: size, height: size),
  };
}

/// Flat coloured shapes for the Shapes world.
class ShapePainter extends CustomPainter {
  ShapePainter(this.shape, {this.color = const Color(0xFF1E88E5)});

  final String shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final paint = Paint()..color = color;
    final c = r.center;
    final w = size.width;
    switch (shape) {
      case 'circle':
        canvas.drawCircle(c, w * 0.45, paint);
      case 'square':
        canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(w * 0.08), Radius.circular(w * 0.06)), paint);
      case 'rectangle':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: w * 0.94, height: w * 0.56),
            Radius.circular(w * 0.06),
          ),
          paint,
        );
      case 'triangle':
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, w * 0.06)
            ..lineTo(w * 0.96, w * 0.92)
            ..lineTo(w * 0.04, w * 0.92)
            ..close(),
          paint,
        );
      case 'oval':
        canvas.drawOval(Rect.fromCenter(center: c, width: w * 0.96, height: w * 0.62), paint);
      case 'diamond':
        canvas.drawPath(
          Path()
            ..moveTo(c.dx, w * 0.02)
            ..lineTo(w * 0.8, c.dy)
            ..lineTo(c.dx, w * 0.98)
            ..lineTo(w * 0.2, c.dy)
            ..close(),
          paint,
        );
      case 'heart':
        final path = Path()
          ..moveTo(c.dx, w * 0.92)
          ..cubicTo(w * -0.1, w * 0.5, w * 0.2, w * 0.02, c.dx, w * 0.28)
          ..cubicTo(w * 0.8, w * 0.02, w * 1.1, w * 0.5, c.dx, w * 0.92);
        canvas.drawPath(path, paint);
      case 'star':
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final rad = i.isEven ? w * 0.48 : w * 0.2;
          final a = -pi / 2 + i * pi / 5;
          final pt = c + Offset(cos(a) * rad, sin(a) * rad);
          i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(path..close(), paint);
    }
  }

  @override
  bool shouldRepaint(ShapePainter old) => old.shape != shape || old.color != color;
}
