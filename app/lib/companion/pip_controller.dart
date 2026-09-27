import 'dart:async';

import 'package:flutter/foundation.dart';

/// Pip's states. The order is the Rive `mood` number input (docs/PIP_RIVE_SPEC.md).
enum PipMood { idle, listening, talking, happy, thinking, sleepy, celebrate }

/// Things that happen in the app that Pip reacts to.
enum PipEvent { correct, tryAgain, levelDone, childSpeaking, childDone, poked, fed, tickled, bedtime, wake }

/// Tappable parts of Pip, checked by `PipPainter.partAt`.
enum PipPart { nose, ear, belly, feet, mouth, hand }

/// Maps app events to Pip's moods. One-shot moods (happy, thinking,
/// celebrate) fall back to the base mood (idle, or sleepy at bedtime).
class PipController extends ChangeNotifier {
  PipMood _mood = PipMood.idle;
  PipMood _base = PipMood.idle;
  Timer? _revert;

  PipMood get mood => _mood;

  /// Increases on every one-shot reaction, so the view can replay it.
  int reaction = 0;

  void onEvent(PipEvent e) {
    switch (e) {
      case PipEvent.correct || PipEvent.poked || PipEvent.fed || PipEvent.tickled:
        _show(PipMood.happy, const Duration(milliseconds: 1500));
      case PipEvent.tryAgain:
        // Errors make Pip curious, never sad (CLAUDE.md hard rule 5).
        _show(PipMood.thinking, const Duration(milliseconds: 1500));
      case PipEvent.levelDone:
        _show(PipMood.celebrate, const Duration(seconds: 2));
      case PipEvent.childSpeaking:
        _set(PipMood.listening);
      case PipEvent.childDone:
        _set(_base);
      case PipEvent.bedtime:
        _base = PipMood.sleepy;
        _set(PipMood.sleepy);
      case PipEvent.wake:
        _base = PipMood.idle;
        _set(PipMood.idle);
    }
  }

  /// Sets a mood directly (demo screen).
  void debugSet(PipMood mood) => _set(mood);

  void _show(PipMood m, Duration d) {
    reaction++;
    _set(m);
    _revert = Timer(d, () => _set(_base));
  }

  void _set(PipMood m) {
    _revert?.cancel();
    _mood = m;
    notifyListeners();
  }

  @override
  void dispose() {
    _revert?.cancel();
    super.dispose();
  }
}
