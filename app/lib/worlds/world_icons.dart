import 'package:flutter/material.dart';

/// Placeholder icons per world until the map art arrives.
/// TODO(asset): replace with illustrated world islands.
IconData worldIcon(String icon) => switch (icon) {
  'animals' => Icons.pets,
  'numbers' => Icons.looks_one_rounded,
  'letters' => Icons.abc_rounded,
  'shapes_colours' => Icons.category_rounded,
  'board_games' => Icons.casino_rounded,
  'pips_house' => Icons.cottage_rounded,
  _ => Icons.public,
};

const _levelIcons = [
  Icons.looks_one_rounded,
  Icons.looks_two_rounded,
  Icons.looks_3_rounded,
  Icons.looks_4_rounded,
  Icons.looks_5_rounded,
  Icons.looks_6_rounded,
];

/// Level buttons show the number as a picture so pre-readers can still pick one.
IconData levelIcon(int number) => number <= _levelIcons.length ? _levelIcons[number - 1] : Icons.star_rounded;
