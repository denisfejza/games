import 'package:flutter/material.dart';

import '../app/ui/outlined_text.dart';

/// Slightly tilted ribbons: a title and, optionally, a greeting under it.
class TitleBanner extends StatelessWidget {
  const TitleBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleKey,
    this.color = const Color(0xFFE8322B),
    this.height = 112,
  });

  final String title;
  final String? subtitle;
  final Key? subtitleKey;
  final Color color;

  /// The banner scales to fit this height (and the available width).
  final double height;

  @override
  Widget build(BuildContext context) {
    final shade = HSLColor.fromColor(color);
    final outline = shade.withLightness((shade.lightness - 0.25).clamp(0.0, 1.0)).toColor();
    final subtitle = this.subtitle;
    return SizedBox(
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Transform.rotate(
          angle: -0.035,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Ribbon(
                color: color,
                child: OutlinedText(title, fontSize: 34, outline: outline, maxLines: 1),
              ),
              if (subtitle != null)
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: _Ribbon(
                    color: const Color(0xFF1E6FE0),
                    child: Text(
                      subtitle,
                      key: subtitleKey,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
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

class _Ribbon extends StatelessWidget {
  const _Ribbon({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white, width: 4),
      boxShadow: const [BoxShadow(color: Color(0x40000000), offset: Offset(0, 5), blurRadius: 6)],
    ),
    child: child,
  );
}
