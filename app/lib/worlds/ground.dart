import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/ui/caption_bar.dart';
import '../app/ui/palm_rejecting_gesture_detector.dart';
import '../companion/pip_placeholder.dart';

const groundHeight = 84.0;
const _groundColor = Color(0xFFFF4F6D);

/// Wavy ground along the bottom of a screen, with Pip standing on the left
/// and the caption bar next to him. Tapping Pip repeats his greeting.
class GroundWithPip extends ConsumerWidget {
  const GroundWithPip({super.key, this.pipSize = 110, this.pipLine = 'helloPip'});

  final double pipSize;

  /// Narration key Pip says when tapped.
  final String pipLine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: groundHeight + 24 + bottom + (pipSize - 90).clamp(0, 40),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: groundHeight + 24 + bottom,
            child: CustomPaint(painter: _GroundPainter()),
          ),
          Positioned(
            left: 12,
            bottom: 8 + bottom,
            child: PalmRejectingGestureDetector(
              onTap: () => ref.read(audioServiceProvider).say(pipLine, interrupt: true),
              child: Semantics(
                label: 'Pip',
                button: true,
                child: PipPlaceholder(size: pipSize),
              ),
            ),
          ),
          Positioned(
            left: pipSize + 20,
            right: 12,
            bottom: 4 + bottom,
            child: const Center(child: CaptionBar()),
          ),
        ],
      ),
    );
  }
}

class _GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path wave(double top, double amp, double period) {
      final path = Path()..moveTo(0, size.height);
      path.lineTo(0, top);
      for (var x = 0.0; x <= size.width; x += period) {
        path.quadraticBezierTo(x + period / 2, top - amp, x + period, top);
      }
      return path
        ..lineTo(size.width, size.height)
        ..close();
    }

    canvas.drawPath(wave(20, 26, 180), Paint()..color = Colors.white);
    canvas.drawPath(wave(28, 22, 180), Paint()..color = _groundColor);
    canvas.drawPath(wave(54, 12, 90), Paint()..color = const Color(0xFFE63E5C));
  }

  @override
  bool shouldRepaint(_GroundPainter old) => false;
}
