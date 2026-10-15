import 'package:flutter/material.dart';

/// Comprehensive color system for the Momentum productivity application.
///
/// Palette Philosophy:
/// - Primary: Deep Indigo palette conveying deep focus, clarity, and professionalism.
/// - Secondary: Vibrant Teal & Emerald palette representing streaks, success, and completion.
/// - Tertiary: Violet & Purple accents for creative and high-priority contexts.
/// - Neutral & Surfaces: Carefully balanced slate surfaces with rich contrast in both
///   light and dark themes (avoiding flat washed-out grey).
/// - Status & Priority: Standardized semantic colors for tasks, habits, and deadlines.
/// - Chart & Labels: 12 high-contrast, accessible hues for categories and visualizations.
abstract class AppColors {
  // ---------------------------------------------------------------------------
  // Primary Palette (Deep Indigo / Focus)
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 700
  static const Color primaryHover = Color(0xFF4338CA); // Indigo 700
  static const Color primaryContainerLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color primaryContainerDark = Color(0xFF1E1B4B); // Indigo 950
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainerLight = Color(0xFF312E81); // Indigo 900
  static const Color onPrimaryContainerDark = Color(0xFFE0E7FF); // Indigo 100

  // ---------------------------------------------------------------------------
  // Secondary Palette (Teal & Emerald / Completion & Momentum)
  // ---------------------------------------------------------------------------
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF0F766E); // Teal 700
  static const Color secondaryContainerLight = Color(0xFFCCFBF1); // Teal 100
  static const Color secondaryContainerDark = Color(0xFF134E4A); // Teal 900
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainerLight = Color(0xFF115E59); // Teal 800
  static const Color onSecondaryContainerDark = Color(0xFF99F6E4); // Teal 200

  // ---------------------------------------------------------------------------
  // Tertiary Palette (Violet / Creative Flow)
  // ---------------------------------------------------------------------------
  static const Color tertiary = Color(0xFF8B5CF6); // Violet 500
  static const Color tertiaryLight = Color(0xFFA78BFA); // Violet 400
  static const Color tertiaryDark = Color(0xFF6D28D9); // Violet 700
  static const Color tertiaryContainerLight = Color(0xFFEDE9FE); // Violet 100
  static const Color tertiaryContainerDark = Color(0xFF4C1D95); // Violet 900
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainerLight = Color(0xFF5B21B6);
  static const Color onTertiaryContainerDark = Color(0xFFDDD6FE);

  // ---------------------------------------------------------------------------
  // Light Mode Surfaces & Neutrals
  // ---------------------------------------------------------------------------
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Light Mode Text
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabledLight = Color(0xFFCBD5E1); // Slate 300

  // ---------------------------------------------------------------------------
  // Dark Mode Surfaces & Neutrals
  // ---------------------------------------------------------------------------
  static const Color backgroundDark = Color(0xFF0B0F19); // Rich Slate Navy
  static const Color surfaceDark = Color(0xFF151C2C); // Slate Card 850
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceElevatedDark = Color(0xFF243048);
  static const Color cardDark = Color(0xFF151C2C);
  static const Color dialogDark = Color(0xFF151C2C);
  static const Color borderDark = Color(0xFF28354D);
  static const Color borderSubtleDark = Color(0xFF1E293B);
  static const Color dividerDark = Color(0xFF232D42);

  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500
  static const Color textDisabledDark = Color(0xFF475569); // Slate 600

  // ---------------------------------------------------------------------------
  // Task Status Colors
  // Pending (Amber), Doing (Blue), Done (Green), Skipped (Grey), Cancelled (Red)
  // ---------------------------------------------------------------------------
  static const Color statusPending = Color(0xFFF59E0B); // Amber 500
  static const Color statusPendingContainerLight = Color(0xFFFEF3C7);
  static const Color statusPendingContainerDark = Color(0xFF451A03);
  static const Color onStatusPendingLight = Color(0xFF92400E);
  static const Color onStatusPendingDark = Color(0xFFFCD34D);

  static const Color statusDoing = Color(0xFF3B82F6); // Blue 500
  static const Color statusDoingContainerLight = Color(0xFFDBEAFE);
  static const Color statusDoingContainerDark = Color(0xFF1E3A8A);
  static const Color onStatusDoingLight = Color(0xFF1E40AF);
  static const Color onStatusDoingDark = Color(0xFF93C5FD);

  static const Color statusDone = Color(0xFF10B981); // Emerald 500 (Green)
  static const Color statusDoneContainerLight = Color(0xFFD1FAE5);
  static const Color statusDoneContainerDark = Color(0xFF064E3B);
  static const Color onStatusDoneLight = Color(0xFF065F46);
  static const Color onStatusDoneDark = Color(0xFF6EE7B7);

  static const Color statusSkipped = Color(0xFF6B7280); // Slate Grey 500
  static const Color statusSkippedContainerLight = Color(0xFFF3F4F6);
  static const Color statusSkippedContainerDark = Color(0xFF374151);
  static const Color onStatusSkippedLight = Color(0xFF374151);
  static const Color onStatusSkippedDark = Color(0xFFD1D5DB);

  static const Color statusCancelled = Color(0xFFEF4444); // Red 500
  static const Color statusCancelledContainerLight = Color(0xFFFEE2E2);
  static const Color statusCancelledContainerDark = Color(0xFF7F1D1D);
  static const Color onStatusCancelledLight = Color(0xFF991B1B);
  static const Color onStatusCancelledDark = Color(0xFFFCA5A5);

  // ---------------------------------------------------------------------------
  // Priority Colors
  // Low (Slate), Medium (Blue), High (Orange), Urgent (Red)
  // ---------------------------------------------------------------------------
  static const Color priorityLow = Color(0xFF64748B); // Slate 500
  static const Color priorityLowContainerLight = Color(0xFFF1F5F9);
  static const Color priorityLowContainerDark = Color(0xFF334155);
  static const Color onPriorityLowLight = Color(0xFF334155);
  static const Color onPriorityLowDark = Color(0xFFCBD5E1);

  static const Color priorityMedium = Color(0xFF0284C7); // Sky Blue 600
  static const Color priorityMediumContainerLight = Color(0xFFE0F2FE);
  static const Color priorityMediumContainerDark = Color(0xFF075985);
  static const Color onPriorityMediumLight = Color(0xFF0369A1);
  static const Color onPriorityMediumDark = Color(0xFF7DD3FC);

  static const Color priorityHigh = Color(0xFFF97316); // Orange 500
  static const Color priorityHighContainerLight = Color(0xFFFFEDD5);
  static const Color priorityHighContainerDark = Color(0xFF7C2D12);
  static const Color onPriorityHighLight = Color(0xFFC2410C);
  static const Color onPriorityHighDark = Color(0xFFFDBA74);

  static const Color priorityUrgent = Color(0xFFDC2626); // Crimson Red 600
  static const Color priorityUrgentContainerLight = Color(0xFFFEE2E2);
  static const Color priorityUrgentContainerDark = Color(0xFF7F1D1D);
  static const Color onPriorityUrgentLight = Color(0xFF991B1B);
  static const Color onPriorityUrgentDark = Color(0xFFFCA5A5);

  // ---------------------------------------------------------------------------
  // Semantic Colors
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfoContainer = Color(0xFF1E40AF);

  // ---------------------------------------------------------------------------
  // Chart & Label Colors (12 Distinct High-Contrast Colors)
  // ---------------------------------------------------------------------------
  static const Color chartIndigo = Color(0xFF6366F1);
  static const Color chartTeal = Color(0xFF14B8A6);
  static const Color chartRose = Color(0xFFF43F5E);
  static const Color chartAmber = Color(0xFFF59E0B);
  static const Color chartPurple = Color(0xFF8B5CF6);
  static const Color chartCyan = Color(0xFF06B6D4);
  static const Color chartEmerald = Color(0xFF10B981);
  static const Color chartOrange = Color(0xFFF97316);
  static const Color chartPink = Color(0xFFEC4899);
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartLime = Color(0xFF84CC16);
  static const Color chartViolet = Color(0xFFA855F7);

  static const List<Color> chartColors = [
    chartIndigo,
    chartTeal,
    chartRose,
    chartAmber,
    chartPurple,
    chartCyan,
    chartEmerald,
    chartOrange,
    chartPink,
    chartBlue,
    chartLime,
    chartViolet,
  ];

  /// Returns a chart color cycling through the available palette.
  static Color chartColorAt(int index) {
    if (index < 0) index = -index;
    return chartColors[index % chartColors.length];
  }

  /// Resolves the color representing a task status.
  static Color forStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return statusPending;
      case 'doing':
      case 'in_progress':
      case 'inprogress':
        return statusDoing;
      case 'done':
      case 'completed':
        return statusDone;
      case 'skipped':
        return statusSkipped;
      case 'cancelled':
      case 'canceled':
        return statusCancelled;
      default:
        return statusPending;
    }
  }

  /// Resolves the container color representing a task status for given brightness.
  static Color statusContainerFor(String status, {bool isDark = false}) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return isDark
            ? statusPendingContainerDark
            : statusPendingContainerLight;
      case 'doing':
      case 'in_progress':
      case 'inprogress':
        return isDark ? statusDoingContainerDark : statusDoingContainerLight;
      case 'done':
      case 'completed':
        return isDark ? statusDoneContainerDark : statusDoneContainerLight;
      case 'skipped':
        return isDark
            ? statusSkippedContainerDark
            : statusSkippedContainerLight;
      case 'cancelled':
      case 'canceled':
        return isDark
            ? statusCancelledContainerDark
            : statusCancelledContainerLight;
      default:
        return isDark
            ? statusPendingContainerDark
            : statusPendingContainerLight;
    }
  }

  /// Resolves the color representing a task priority.
  static Color forPriority(String priority) {
    switch (priority.toLowerCase().trim()) {
      case 'low':
        return priorityLow;
      case 'medium':
        return priorityMedium;
      case 'high':
        return priorityHigh;
      case 'urgent':
        return priorityUrgent;
      default:
        return priorityMedium;
    }
  }

  /// Resolves the container color representing a task priority for given brightness.
  static Color priorityContainerFor(String priority, {bool isDark = false}) {
    switch (priority.toLowerCase().trim()) {
      case 'low':
        return isDark ? priorityLowContainerDark : priorityLowContainerLight;
      case 'medium':
        return isDark
            ? priorityMediumContainerDark
            : priorityMediumContainerLight;
      case 'high':
        return isDark ? priorityHighContainerDark : priorityHighContainerLight;
      case 'urgent':
        return isDark
            ? priorityUrgentContainerDark
            : priorityUrgentContainerLight;
      default:
        return isDark
            ? priorityMediumContainerDark
            : priorityMediumContainerLight;
    }
  }
}
