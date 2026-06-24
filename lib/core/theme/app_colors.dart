import 'package:flutter/material.dart';

/// ANEUSO brand palette.
///
/// Official four-color brand set:
/// - [#450693] deep purple
/// - [#9B5DE0] primary purple
/// - [#D78FEE] light purple
/// - [#FDCFFA] soft pink
abstract final class AppColors {
  // Official brand palette
  static const Color primaryDeep = Color(0xFF450693);
  static const Color primary = Color(0xFF9B5DE0);
  static const Color primaryLight = Color(0xFFD78FEE);
  static const Color accentLight = Color(0xFFFDCFFA);

  static const List<Color> brandPalette = [
    primaryDeep,
    primary,
    primaryLight,
    accentLight,
  ];

  // Extended shades (derived / UI support)
  static const Color primaryDark = Color(0xFF3B0764);
  static const Color primaryMid = primaryDeep;
  static const Color primaryVariant = Color(0xFF8A39E1);
  static const Color accent = Color(0xFFA555EC);
  static const Color lilac = Color(0xFFE9D5FF);
  static const Color mist = Color(0xFFF5F0FF);

  // Surfaces
  static const Color scaffold = Color(0xFFF9F6FF);
  static const Color scaffoldGradientTop = Color(0xFFEDE4FF);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF3EBFF);
  static const Color surfaceGlass = Color(0xCCFFFFFF);
  static const Color border = Color(0xFFE4D4FF);
  static const Color borderSoft = Color(0xFFF0E6FF);

  // Text
  static const Color textPrimary = Color(0xFF2D1B4E);
  static const Color textSecondary = Color(0xFF7A6B8A);
  static const Color textMuted = Color(0xFF9B8DAA);
  static const Color textOnPrimary = Colors.white;

  // Semantic
  static const Color success = Color(0xFF7B4FD4);
  static const Color warning = Color(0xFFD78FEE);
  static const Color error = Color(0xFFE0567A);

  /// Accent colors for dashboard action tiles (cycles automatically).
  static const List<Color> tileAccents = [
    primaryMid,
    primaryVariant,
    accent,
    primary,
    primaryLight,
    primaryDeep,
    Color(0xFF7C3AED),
    Color(0xFF9333EA),
  ];

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primary, primaryLight],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: brandPalette,
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  static const LinearGradient heroGradient = brandGradient;

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [scaffoldGradientTop, mist, surface],
    stops: [0.0, 0.35, 0.75],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primaryMid, primary, primaryLight],
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primaryMid, primary, primaryLight],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryDeep, primary, primaryLight],
  );

  static const LinearGradient navBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surfaceMuted],
  );

  static BoxShadow softShadow([Color? color]) => BoxShadow(
        color: (color ?? primary).withValues(alpha: 0.18),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );

  static BoxShadow glowShadow([Color? color]) => BoxShadow(
        color: (color ?? primaryMid).withValues(alpha: 0.35),
        blurRadius: 24,
        spreadRadius: -4,
        offset: const Offset(0, 10),
      );
}
