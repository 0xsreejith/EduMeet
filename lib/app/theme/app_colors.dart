import 'package:flutter/material.dart';

/// Design tokens extracted directly from Google Stitch Project:
/// "Virtual Classroom App Design" (EdTech Warmth)
abstract class AppColors {
  // Primary - Warm Indigo
  static const Color primary = Color(0xFF4648D4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF6063EE);
  static const Color onPrimaryContainer = Color(0xFFFFFBFF);
  static const Color primaryFixed = Color(0xFFE1E0FF);
  static const Color onPrimaryFixed = Color(0xFF07006C);
  static const Color onPrimaryFixedVariant = Color(0xFF2F2EBE);
  static const Color primaryFixedDim = Color(0xFFC0C1FF);
  static const Color inversePrimary = Color(0xFFC0C1FF);

  // Secondary - Warm Amber / Coral
  static const Color secondary = Color(0xFF9D4300);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFD761A);
  static const Color onSecondaryContainer = Color(0xFF5C2400);
  static const Color secondaryFixed = Color(0xFFFFDBCA);
  static const Color onSecondaryFixed = Color(0xFF341100);
  static const Color onSecondaryFixedVariant = Color(0xFF783200);
  static const Color secondaryFixedDim = Color(0xFFFFB690);

  // Tertiary - Supportive Emerald Green
  static const Color tertiary = Color(0xFF006C49);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF00885D);
  static const Color onTertiaryContainer = Color(0xFF000703);
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color onTertiaryFixed = Color(0xFF002113);
  static const Color onTertiaryFixedVariant = Color(0xFF005236);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);

  // Neutrals & Surfaces
  static const Color surface = Color(0xFFF7F9FB);
  static const Color background = Color(0xFFF7F9FB);
  static const Color onBackground = Color(0xFF191C1E);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceVariant = Color(0xFFE0E3E5);
  static const Color surfaceTint = Color(0xFF494BD6);

  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF464554);
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);

  // Outlines & Borders
  static const Color outline = Color(0xFF767586);
  static const Color outlineVariant = Color(0xFFC7C4D7);

  // Errors & Alerts
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Custom Ambient Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F4648D4),
    blurRadius: 10,
    offset: Offset(0, 4),
  );

  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow floatingShadow = BoxShadow(
    color: Color(0x1F4648D4),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
}

