import 'package:flutter/material.dart';

import '../../content/models.dart';

/// Colours and sizes per age band. Younger bands get bigger targets and softer colours;
/// 6–7 is calmer and less "baby".
class AgeBandTokens {
  const AgeBandTokens({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.background,
    required this.surface,
    required this.ink,
    required this.minTarget,
  });

  final Color primary;
  final Color secondary;
  final Color success;
  final Color background;
  final Color surface;
  final Color ink;

  /// Smallest touch target on a phone, in logical pixels. Never below 76 (≈ 2 cm).
  final double minTarget;

  static const toddler = AgeBandTokens(
    primary: Color(0xFFFF8A3D),
    secondary: Color(0xFF3DB5FF),
    success: Color(0xFF4CC26A),
    background: Color(0xFFFFF6E8),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF3B2C4A),
    minTarget: 96,
  );

  static const preschool = AgeBandTokens(
    primary: Color(0xFFF2711C),
    secondary: Color(0xFF2E9BE6),
    success: Color(0xFF3FAF5C),
    background: Color(0xFFFFF3E0),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF33263F),
    minTarget: 84,
  );

  static const school = AgeBandTokens(
    primary: Color(0xFFD9601A),
    secondary: Color(0xFF2F6FD6),
    success: Color(0xFF2E9A55),
    background: Color(0xFFF4F1EA),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2233),
    minTarget: 76,
  );

  static AgeBandTokens of(AgeBand band) => switch (band) {
    AgeBand.toddler => toddler,
    AgeBand.preschool => preschool,
    AgeBand.school => school,
  };

  /// Touch target for this screen: 25% bigger on tablets.
  /// 30% bigger again in large-target mode (switch access / motor support).
  double targetFor(BuildContext context) =>
      (MediaQuery.sizeOf(context).shortestSide >= 600 ? minTarget * 1.25 : minTarget) *
      (LargeTargets.of(context) ? 1.3 : 1);
}

const fontFamily = 'Nunito';

ThemeData buildTheme(AgeBand band) {
  final t = AgeBandTokens.of(band);
  final scheme = ColorScheme.fromSeed(
    seedColor: t.primary,
    primary: t.primary,
    secondary: t.secondary,
    surface: t.surface,
  );
  final base = ThemeData(colorScheme: scheme, fontFamily: fontFamily, scaffoldBackgroundColor: t.background);
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: t.ink, displayColor: t.ink, fontFamily: fontFamily),
    extensions: [AgeBandTheme(t)],
  );
}

/// Makes the current band's tokens available via `Theme.of(context)`.
class AgeBandTheme extends ThemeExtension<AgeBandTheme> {
  const AgeBandTheme(this.tokens);

  final AgeBandTokens tokens;

  static AgeBandTokens of(BuildContext context) =>
      Theme.of(context).extension<AgeBandTheme>()?.tokens ?? AgeBandTokens.preschool;

  @override
  AgeBandTheme copyWith({AgeBandTokens? tokens}) => AgeBandTheme(tokens ?? this.tokens);

  @override
  AgeBandTheme lerp(AgeBandTheme? other, double t) => t < 0.5 || other == null ? this : other;
}

/// Whether the parent turned on extra-large buttons (set above the app by PipsWorldApp).
class LargeTargets extends InheritedWidget {
  const LargeTargets({super.key, required this.enabled, required super.child});

  final bool enabled;

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<LargeTargets>()?.enabled ?? false;

  @override
  bool updateShouldNotify(LargeTargets old) => old.enabled != enabled;
}
