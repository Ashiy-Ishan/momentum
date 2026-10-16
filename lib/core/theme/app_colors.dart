import 'package:flutter/material.dart';

/// Comprehensive color system for the Momentum productivity application.
///
/// Palette Philosophy: "Architectural Obsidian Titanium & Warm Platinum Bronze"
/// Inspired by high-precision editorial craft tools (Linear, Raycast, Teenage Engineering)
/// with subtle, muted duo-tones, tactical dark surfaces, and clean ivory light surfaces.
///
/// Surfaces:
/// - Dark Surfaces: Deep obsidian titanium (#090B0F), elevated tactical surface (#10141C),
///   tactile card surface (#151B26), precision hairline borders rgba(255, 255, 255, 0.09),
///   and elevated dialogs (#1B2332).
/// - Light Surfaces: Crisp architectural ivory & slate (#F8FAFC, #FFFFFF, #F1F5F9)
///   paired with deep graphite obsidian text (#0F172A).
/// - Primary: Refined Warm Platinum Bronze (#C4A480) for sharp, luminous visual focus.
/// - Secondary: Refined Sage & Muted Jade (#4E9B78) for momentum, streaks, and completion.
/// - Tertiary: Subtle Steel Blue (#5B82A6) for time tracking, deep focus sessions, and analytics.
/// - Platforms: Understated, muted tinted neutrals (Rosewood, Mauve, Slate Steel, Sepia, Moss).
abstract class AppColors {
  // ---------------------------------------------------------------------------
  // Primary Palette (Architectural Warm Platinum & Muted Bronze)
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFFC4A480); // Refined Warm Platinum Bronze
  static const Color primaryLight = Color(0xFFDFCCB7); // Soft Warm Platinum
  static const Color primaryDark = Color(0xFF8F7050); // Muted Architectural Bronze
  static const Color primaryHover = Color(0xFFB5936E); // Soft Bronze Hover
  static const Color primaryContainerLight = Color(0xFFF7F2EB); // Clean Ivory Platinum
  static const Color primaryContainerDark = Color(0xFF1E1A15); // Subtle Deep Bronze Obsidian
  static const Color onPrimary = Color(0xFF0C0E12); // Deep Titanium Obsidian for optimal contrast
  static const Color onPrimaryLight = Color(0xFF0C0E12);
  static const Color onPrimaryContainerLight = Color(0xFF4E3A24); // Muted Bronze Text
  static const Color onPrimaryContainerDark = Color(0xFFE8D9C8); // Soft Platinum Text

  // ---------------------------------------------------------------------------
  // Secondary Palette (Refined Sage & Muted Jade / Momentum & Completion)
  // ---------------------------------------------------------------------------
  static const Color secondary = Color(0xFF4E9B78); // Refined Sage / Soft Muted Jade
  static const Color secondaryLight = Color(0xFF6FB896); // Soft Sage Tint
  static const Color secondaryDark = Color(0xFF357A5B); // Forest Slate
  static const Color secondaryContainerLight = Color(0xFFEEF6F2); // Subtle Sage Mist
  static const Color secondaryContainerDark = Color(0xFF11221B); // Deep Obsidian Sage
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainerLight = Color(0xFF1E4D38);
  static const Color onSecondaryContainerDark = Color(0xFFAFE0CA);

  // ---------------------------------------------------------------------------
  // Tertiary Palette (Subtle Steel Blue / Focus & Time)
  // ---------------------------------------------------------------------------
  static const Color tertiary = Color(0xFF5B82A6); // Subtle Steel Blue
  static const Color tertiaryLight = Color(0xFF7FA3C5); // Soft Steel Tint
  static const Color tertiaryDark = Color(0xFF3F6385); // Muted Deep Slate Blue
  static const Color tertiaryContainerLight = Color(0xFFEFF4F8); // Steel Mist
  static const Color tertiaryContainerDark = Color(0xFF131D27); // Obsidian Slate Blue
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainerLight = Color(0xFF223E56);
  static const Color onTertiaryContainerDark = Color(0xFFB8D5EB);

  // ---------------------------------------------------------------------------
  // Subtle & Muted Platform Brand Colors (Creator & Content Ecosystem)
  // Replaced loud neon colors with understated, cohesive tinted slate/neutrals
  // ---------------------------------------------------------------------------
  static const Color platformYoutube = Color(0xFFBD5B5B); // Subtle Muted Rosewood / Crimson
  static const Color platformInstagram = Color(0xFFA06B82); // Subtle Muted Mauve / Dusky Plum
  static const Color platformTwitter = Color(0xFF6889A4); // Subtle Slate Steel
  static const Color platformTwitterPlatinum = Color(0xFF94A3B8); // Architectural Platinum
  static const Color platformBlog = Color(0xFFA87C5C); // Warm Sepia / Muted Parchment
  static const Color platformSubstack = platformBlog;
  static const Color platformLinkedIn = Color(0xFF5E7A96); // Refined Dusky Slate Blue
  static const Color platformTikTok = Color(0xFF788D98); // Cool Graphite Slate Tint
  static const Color platformGithub = Color(0xFF5D8568); // Subtle Muted Moss / Sage

  // Convenient brand aliases
  static const Color youtube = platformYoutube;
  static const Color instagram = platformInstagram;
  static const Color twitter = platformTwitter;
  static const Color twitterPlatinum = platformTwitterPlatinum;
  static const Color blog = platformBlog;
  static const Color substack = platformSubstack;
  static const Color linkedin = platformLinkedIn;
  static const Color tiktok = platformTikTok;
  static const Color github = platformGithub;

  // ---------------------------------------------------------------------------
  // Light Mode Surfaces & Neutrals (Architectural Crisp Ivory & Slate)
  // ---------------------------------------------------------------------------
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color cardBorderLight = borderLight;
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Light Mode Text
  static const Color textPrimaryLight = Color(0xFF0F172A); // Deep slate obsidian
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabledLight = Color(0xFFCBD5E1); // Slate 300

  // ---------------------------------------------------------------------------
  // Dark Mode Surfaces & Neutrals (Obsidian Titanium & Sleek Graphite)
  // ---------------------------------------------------------------------------
  static const Color backgroundDark = Color(0xFF090B0F); // Deep space obsidian titanium
  static const Color surfaceDark = Color(0xFF10141C); // Tactical dark surface
  static const Color surfaceVariantDark = Color(0xFF151B26); // Tactile card surface
  static const Color surfaceElevatedDark = Color(0xFF1B2332); // Elevated dialog surface
  static const Color cardDark = Color(0xFF151B26); // Tactile card surface
  static const Color dialogDark = Color(0xFF1B2332); // Elevated dialog
  static const Color borderDark = Color(0x18FFFFFF); // Precision hairline border rgba(255, 255, 255, 0.09)
  static const Color borderSubtleDark = Color(0x10FFFFFF); // Subtle hairline border
  static const Color cardBorderDark = borderDark;
  static const Color dividerDark = Color(0x18FFFFFF); // Hairline divider

  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500
  static const Color textDisabledDark = Color(0xFF475569); // Slate 600

  // ---------------------------------------------------------------------------
  // Task Status Colors (Understated & Elegant)
  // Pending (Warm Ochre), Doing (Steel Blue), Done (Muted Sage), Skipped (Slate), Cancelled (Soft Crimson)
  // ---------------------------------------------------------------------------
  static const Color statusPending = Color(0xFFC28D4E); // Refined Warm Ochre
  static const Color statusPendingContainerLight = Color(0xFFFAF3EC);
  static const Color statusPendingContainerDark = Color(0xFF241D14);
  static const Color onStatusPendingLight = Color(0xFF66441D);
  static const Color onStatusPendingDark = Color(0xFFDEC5A2);

  static const Color statusDoing = Color(0xFF5B82A6); // Subtle Steel Blue
  static const Color statusDoingContainerLight = Color(0xFFEFF5F9);
  static const Color statusDoingContainerDark = Color(0xFF131E2A);
  static const Color onStatusDoingLight = Color(0xFF284865);
  static const Color onStatusDoingDark = Color(0xFFA5C5DC);

  static const Color statusDone = Color(0xFF4E9B78); // Soft Muted Sage
  static const Color statusDoneContainerLight = Color(0xFFEEF6F2);
  static const Color statusDoneContainerDark = Color(0xFF11221B);
  static const Color onStatusDoneLight = Color(0xFF1E4D38);
  static const Color onStatusDoneDark = Color(0xFFAFE0CA);

  static const Color statusSkipped = Color(0xFF64748B); // Muted Slate
  static const Color statusSkippedContainerLight = Color(0xFFF1F5F9);
  static const Color statusSkippedContainerDark = Color(0xFF161C26);
  static const Color onStatusSkippedLight = Color(0xFF334155);
  static const Color onStatusSkippedDark = Color(0xFF94A3B8);

  static const Color statusCancelled = Color(0xFFB85454); // Soft Muted Crimson
  static const Color statusCancelledContainerLight = Color(0xFFFDF0F0);
  static const Color statusCancelledContainerDark = Color(0xFF261515);
  static const Color onStatusCancelledLight = Color(0xFF702727);
  static const Color onStatusCancelledDark = Color(0xFFE2A8A8);

  // ---------------------------------------------------------------------------
  // Priority Colors (Understated & Elegant)
  // Low (Slate), Medium (Steel Blue), High (Warm Ochre), Urgent (Soft Muted Crimson)
  // ---------------------------------------------------------------------------
  static const Color priorityLow = Color(0xFF64748B); // Muted Slate
  static const Color priorityLowContainerLight = Color(0xFFF1F5F9);
  static const Color priorityLowContainerDark = Color(0xFF161C26);
  static const Color onPriorityLowLight = Color(0xFF334155);
  static const Color onPriorityLowDark = Color(0xFF94A3B8);

  static const Color priorityMedium = Color(0xFF5B82A6); // Subtle Steel Blue
  static const Color priorityMediumContainerLight = Color(0xFFEFF5F9);
  static const Color priorityMediumContainerDark = Color(0xFF131E2A);
  static const Color onPriorityMediumLight = Color(0xFF284865);
  static const Color onPriorityMediumDark = Color(0xFFA5C5DC);

  static const Color priorityHigh = Color(0xFFC28D4E); // Refined Warm Ochre
  static const Color priorityHighContainerLight = Color(0xFFFAF3EC);
  static const Color priorityHighContainerDark = Color(0xFF241D14);
  static const Color onPriorityHighLight = Color(0xFF66441D);
  static const Color onPriorityHighDark = Color(0xFFDEC5A2);

  static const Color priorityUrgent = Color(0xFFB85454); // Soft Muted Crimson
  static const Color priorityUrgentContainerLight = Color(0xFFFDF0F0);
  static const Color priorityUrgentContainerDark = Color(0xFF261515);
  static const Color onPriorityUrgentLight = Color(0xFF702727);
  static const Color onPriorityUrgentDark = Color(0xFFE2A8A8);

  // ---------------------------------------------------------------------------
  // Semantic Colors
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF4E9B78); // Soft Muted Sage
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFEEF6F2);
  static const Color onSuccessContainer = Color(0xFF1E4D38);

  static const Color warning = Color(0xFFC28D4E); // Refined Warm Ochre
  static const Color onWarning = Color(0xFF0C0E12);
  static const Color warningContainer = Color(0xFFFAF3EC);
  static const Color onWarningContainer = Color(0xFF66441D);

  static const Color error = Color(0xFFB85454); // Soft Muted Crimson
  static const Color errorLight = Color(0xFFB85454);
  static const Color errorDark = Color(0xFFE2A8A8);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDF0F0);
  static const Color errorContainerLight = Color(0xFFFDF0F0);
  static const Color errorContainerDark = Color(0xFF261515);
  static const Color onErrorContainer = Color(0xFF702727);

  static const Color info = Color(0xFF5B82A6); // Subtle Steel Blue
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFEFF5F9);
  static const Color onInfoContainer = Color(0xFF284865);

  // ---------------------------------------------------------------------------
  // Chart & Label Colors (Refined, Cohesive Muted Architectural Palette)
  // ---------------------------------------------------------------------------
  static const Color chartPlatinum = Color(0xFFC4A480);
  static const Color chartBronze = Color(0xFFA87C5C);
  static const Color chartSage = Color(0xFF4E9B78);
  static const Color chartSteel = Color(0xFF5B82A6);
  static const Color chartOchre = Color(0xFFC28D4E);
  static const Color chartMauve = Color(0xFFA06B82);
  static const Color chartSlate = Color(0xFF64748B);
  static const Color chartMoss = Color(0xFF5D8568);
  static const Color chartRosewood = Color(0xFFBD5B5B);
  static const Color chartSkySlate = Color(0xFF6889A4);
  static const Color chartDuskyPlum = Color(0xFF7E7B92);
  static const Color chartGraphite = Color(0xFF94A3B8);

  // Backward-compatibility aliases for legacy chart access
  static const Color chartAmber = chartOchre;
  static const Color chartEmerald = chartSage;
  static const Color chartCyan = chartSteel;
  static const Color chartRose = chartRosewood;
  static const Color chartOrange = chartBronze;
  static const Color chartPurple = chartDuskyPlum;
  static const Color chartSky = chartSkySlate;
  static const Color chartTeal = chartMoss;
  static const Color chartPink = chartMauve;
  static const Color chartLime = chartSage;
  static const Color chartBlue = chartSteel;
  static const Color chartIndigo = chartSteel;
  static const Color chartViolet = chartDuskyPlum;

  static const List<Color> chartColors = [
    chartPlatinum,
    chartSage,
    chartSteel,
    chartOchre,
    chartMauve,
    chartBronze,
    chartSlate,
    chartRosewood,
    chartMoss,
    chartSkySlate,
    chartDuskyPlum,
    chartGraphite,
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

  /// Resolves platform brand color by name.
  static Color forPlatform(String platform) {
    switch (platform.toLowerCase().trim()) {
      case 'youtube':
        return platformYoutube;
      case 'instagram':
        return platformInstagram;
      case 'twitter':
      case 'x':
        return platformTwitter;
      case 'blog':
      case 'substack':
        return platformBlog;
      case 'linkedin':
        return platformLinkedIn;
      case 'tiktok':
        return platformTikTok;
      case 'github':
        return platformGithub;
      default:
        return primary;
    }
  }
}
