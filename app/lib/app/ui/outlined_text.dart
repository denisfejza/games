import 'dart:math';

import 'package:flutter/material.dart';

/// Shadows that draw a solid outline around text, plus a small drop shadow.
/// One Text widget (not a stroke/fill pair), so it reads well on any colour.
List<Shadow> outlineShadows(Color color, {double width = 3}) => [
  for (var i = 0; i < 16; i++) Shadow(color: color, offset: Offset.fromDirection(i * pi / 8, width)),
  Shadow(color: color, offset: Offset(0, width + 2)),
];

/// Chunky white "sticker" lettering with a dark outline.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    required this.fontSize,
    this.color = Colors.white,
    this.outline = const Color(0xFF3B2C4A),
    this.maxLines = 2,
  });

  final String text;
  final double fontSize;
  final Color color;
  final Color outline;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: color,
      height: 1.15,
      shadows: outlineShadows(outline, width: max(2, fontSize / 9)),
    ),
  );
}
