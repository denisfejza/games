import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'motion.dart';
import 'outlined_text.dart';
import 'palm_rejecting_gesture_detector.dart';
import 'tokens.dart';

/// The one button children use: big, icon-first, and it talks.
///
/// With a [speakKey], the first tap says what the button does and highlights
/// it; tapping again within [armedFor] activates it. Without one, every tap
/// activates straight away.
///
/// Two looks: a glossy coloured button with a white [icon] (default), or a
/// white [sticker] tile showing [art] in colour, for world and level tiles.
class BigButton extends ConsumerStatefulWidget {
  const BigButton({
    super.key,
    this.icon,
    this.art,
    required this.onPressed,
    this.speakKey,
    this.label,
    this.color,
    this.sticker = false,
    this.outlinedLabel = false,
    this.size,
    this.armedFor = const Duration(seconds: 6),
  }) : assert(icon != null || art != null, 'Give BigButton an icon or art');

  final IconData? icon;

  /// Custom picture drawn inside the button, given the face size.
  final Widget Function(double size)? art;
  final VoidCallback? onPressed;

  /// Narration key spoken on the first tap (also the caption).
  final String? speakKey;

  /// Short text under the icon, for grown-ups and early readers. Never the only cue.
  final String? label;
  final Color? color;

  /// White tile with a coloured shadow instead of a coloured face.
  final bool sticker;

  /// White label with a dark outline, for coloured backgrounds.
  final bool outlinedLabel;

  /// Face size; never smaller than the age band's minimum touch target.
  final double? size;
  final Duration armedFor;

  @override
  ConsumerState<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends ConsumerState<BigButton> {
  bool _pressed = false;
  bool _armed = false;
  Timer? _disarm;

  @override
  void dispose() {
    _disarm?.cancel();
    super.dispose();
  }

  void _tap() {
    setState(() => _pressed = false);
    final key = widget.speakKey;
    if (key != null && !_armed) {
      ref.read(audioServiceProvider).say(key, interrupt: true);
      setState(() => _armed = true);
      _disarm?.cancel();
      _disarm = Timer(widget.armedFor, () {
        if (mounted) setState(() => _armed = false);
      });
      return;
    }
    _disarm?.cancel();
    setState(() => _armed = false);
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AgeBandTheme.of(context);
    final minSize = tokens.targetFor(context);
    final size = widget.size == null || widget.size! < minSize ? minSize : widget.size!;
    final color = widget.color ?? tokens.primary;
    final still = reduceMotion(context, ref);
    final label = widget.label;
    final shade = HSLColor.fromColor(color);
    final darker = shade.withLightness((shade.lightness - 0.18).clamp(0.0, 1.0)).toColor();
    final lighter = shade.withLightness((shade.lightness + 0.12).clamp(0.0, 1.0)).toColor();
    final radius = BorderRadius.circular(size * 0.28);
    final lift = _armed && !still ? -6.0 : 0.0;

    final face = AnimatedContainer(
      duration: still ? Duration.zero : const Duration(milliseconds: 80),
      width: size,
      height: size,
      transform: _pressed && !still
          ? (Matrix4.translationValues(0, 3, 0)..multiply(Matrix4.diagonal3Values(0.94, 0.94, 1)))
          : Matrix4.translationValues(0, lift, 0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.sticker ? Colors.white : null,
        gradient: widget.sticker
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _pressed ? [color, darker] : [lighter, color],
              ),
        borderRadius: radius,
        // Armed = thick dark ring *and* lifted, never colour alone.
        border: Border.all(color: _armed ? tokens.ink : Colors.white, width: _armed ? 6 : 4),
        boxShadow: [
          BoxShadow(color: darker, offset: Offset(0, _pressed ? 2 : 7), blurRadius: 0),
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), offset: const Offset(0, 10), blurRadius: 12),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!widget.sticker)
            // Glossy highlight across the top.
            Positioned(
              top: size * 0.07,
              left: size * 0.14,
              right: size * 0.14,
              height: size * 0.2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
          widget.art?.call(size) ??
              Icon(
                widget.icon,
                size: size * 0.52,
                color: widget.sticker ? color : Colors.white,
                shadows: widget.sticker ? null : [Shadow(color: darker, offset: const Offset(0, 3))],
              ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: label,
      enabled: widget.onPressed != null,
      child: PalmRejectingGestureDetector(
        onTapDown: () => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed == null ? null : _tap,
        child: ConstrainedBox(
          // 30% extra room so Albanian labels fit (CLAUDE.md localization rules).
          constraints: BoxConstraints(maxWidth: size * 1.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              face,
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: widget.outlinedLabel
                      ? OutlinedText(label, fontSize: (size * 0.19).clamp(16, 30))
                      : Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: (size * 0.19).clamp(16, 30),
                            fontWeight: FontWeight.w800,
                            color: tokens.ink,
                            height: 1.1,
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
