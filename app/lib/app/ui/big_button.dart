import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'motion.dart';
import 'palm_rejecting_gesture_detector.dart';
import 'tokens.dart';

/// The one button children use: big, icon-first, and it talks.
///
/// With a [speakKey], the first tap says what the button does and highlights
/// it; tapping again within [armedFor] activates it. Without one, every tap
/// activates straight away.
class BigButton extends ConsumerStatefulWidget {
  const BigButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.speakKey,
    this.label,
    this.color,
    this.armedFor = const Duration(seconds: 6),
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Narration key spoken on the first tap (also the caption).
  final String? speakKey;

  /// Short text under the icon, for grown-ups and early readers. Never the only cue.
  final String? label;
  final Color? color;
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
    final size = tokens.targetFor(context);
    final color = widget.color ?? tokens.primary;
    final still = reduceMotion(context, ref);
    final label = widget.label;

    final face = AnimatedContainer(
      duration: still ? Duration.zero : const Duration(milliseconds: 80),
      width: size,
      height: size,
      transform: _pressed && !still ? Matrix4.diagonal3Values(0.94, 0.94, 1) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        color: _pressed ? Color.lerp(color, Colors.black, 0.12) : color,
        borderRadius: BorderRadius.circular(size * 0.28),
        // Armed state uses a thick ring *and* a raised shadow, never colour alone.
        border: Border.all(color: _armed ? tokens.ink : Colors.transparent, width: 5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), offset: Offset(0, _armed ? 8 : 5), blurRadius: 0),
        ],
      ),
      child: Icon(widget.icon, size: size * 0.5, color: Colors.white),
    );

    return Semantics(
      button: true,
      label: label,
      enabled: widget.onPressed != null,
      child: PalmRejectingGestureDetector(
        onTapDown: () => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed == null ? null : _tap,
        child: SizedBox(
          // 30% extra room so Albanian labels fit (CLAUDE.md localization rules).
          width: size * 1.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              face,
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: size * 0.2, fontWeight: FontWeight.w800, color: tokens.ink, height: 1.1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
