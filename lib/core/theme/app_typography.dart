import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography system for the Momentum productivity application.
///
/// Implements Material 3 typography standards with crisp font weights,
/// balanced line heights, and refined letter spacing.
///
/// Designed to provide maximum legibility across mobile, tablet, and desktop screens,
/// with specialized styles for timer readouts, task cards, and dashboard metrics.
abstract class AppTypography {
  // ---------------------------------------------------------------------------
  // Font Family Configuration
  // Uses clean system font stack with standard sans-serif fallback
  // ---------------------------------------------------------------------------
  static const String? fontFamily = null;
  static const List<String> fontFamilyFallback = [
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static const String monoFontFamily = 'monospace';

  // ---------------------------------------------------------------------------
  // Display Styles (Hero numbers, large promotional or welcome headers)
  // ---------------------------------------------------------------------------
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 45,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.22,
  );

  // ---------------------------------------------------------------------------
  // Headline Styles (Section headers, screen headers)
  // ---------------------------------------------------------------------------
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.33,
  );

  // ---------------------------------------------------------------------------
  // Title Styles (Card titles, dialog headings, list group headers)
  // ---------------------------------------------------------------------------
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ---------------------------------------------------------------------------
  // Body Styles (Long text, descriptions, general task content)
  // ---------------------------------------------------------------------------
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ---------------------------------------------------------------------------
  // Label Styles (Buttons, chips, tags, meta text, input labels)
  // ---------------------------------------------------------------------------
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ---------------------------------------------------------------------------
  // Specialized Momentum Styles (Timers, Metrics, Monospace)
  // ---------------------------------------------------------------------------
  /// Large countdown / stopwatch timer display (e.g. "25:00")
  static const TextStyle timerLarge = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    height: 1.1,
  );

  /// Medium timer readout for compact headers and floating bars
  static const TextStyle timerMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
  );

  /// Dashboard metric numbers (e.g. "94%", "18 Tasks")
  static const TextStyle statNumber = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Monospace font style for code blocks, durations, logs, and keyboard shortcuts
  static const TextStyle mono = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Material 3 TextTheme Builders
  // ---------------------------------------------------------------------------

  /// TextTheme populated for light backgrounds
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryLight),
    displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryLight),
    displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryLight),
    headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimaryLight),
    headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimaryLight),
    headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryLight),
    titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryLight),
    titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryLight),
    titleSmall: titleSmall.copyWith(color: AppColors.textSecondaryLight),
    bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryLight),
    bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryLight),
    bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryLight),
    labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryLight),
    labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryLight),
    labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryLight),
  );

  /// TextTheme populated for dark backgrounds
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
    displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
    displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDark),
    headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimaryDark),
    headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimaryDark),
    headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryDark),
    titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
    titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
    titleSmall: titleSmall.copyWith(color: AppColors.textSecondaryDark),
    bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDark),
    bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryDark),
    bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryDark),
    labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryDark),
    labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryDark),
    labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryDark),
  );
}
