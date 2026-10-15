import 'package:flutter/material.dart';

/// Comprehensive color system for the Momentum productivity application.
///
/// Palette Philosophy: "Solar Obsidian & Auroral Jade"
/// Inspired by high-precision editorial craft tools (Linear, Raycast, Amie)
/// fused with warm solar brass/amber and electric auroral jade.
///
/// Surfaces:
/// - Dark Surfaces: Deep space titanium obsidian (#080B11), elevated tactical surface (#0F1523),
///   tactile card surface (#141C2E), precision hairline borders rgba(255, 255, 255, 0.08),
///   and elevated dialogs (#182238).
/// - Light Surfaces: Crisp architectural ivory & slate (#F8FAFC, #FFFFFF, #F1F5F9)
///   paired with deep graphite obsidian text (#0A0F1D) and warm solar amber accents.
/// - Primary: Solar Amber & Radiant Gold (#F59E0B) for sharp, luminous visual focus.
/// - Secondary: Auroral Jade & Emerald (#10B981) for momentum, streaks, and completion.
/// - Tertiary: Electric Cyan (#06B6D4) for time tracking, deep focus sessions, and analytics.
/// - Platforms: Authentic creator & tool brand colors (YouTube, Instagram, Twitter/X, Blog, LinkedIn, TikTok).
abstract class AppColors {
  // ---------------------------------------------------------------------------
  // Primary Palette (Solar Amber & Radiant Gold)
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFFF59E0B); // Solar Gold / Amber 500
  static const Color primaryLight = Color(0xFFFBBF24); // Amber 400
  static const Color primaryDark = Color(0xFFD97706); // Amber 600
  static const Color primaryHover = Color(0xFFD97706); // Amber 600
  static const Color primaryContainerLight = Color(0xFFFEF3C7); // Amber 100
  static const Color primaryContainerDark = Color(0xFF2D1C03); // Warm Solar Deep Bronze
  static const Color onPrimary = Color(0xFF080B11); // Deep Titanium Obsidian for optimal contrast
  static const Color onPrimaryLight = Color(0xFF080B11);
  static const Color onPrimaryContainerLight = Color(0xFF78350F); // Amber 900
  static const Color onPrimaryContainerDark = Color(0xFFFDE68A); // Amber 200

  // ---------------------------------------------------------------------------
  // Secondary Palette (Auroral Jade & Emerald / Momentum & Success)
  // ---------------------------------------------------------------------------
  static const Color secondary = Color(0xFF10B981); // Emerald Jade 500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald 400
  static const Color secondaryDark = Color(0xFF059669); // Emerald 600
  static const Color secondaryContainerLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color secondaryContainerDark = Color(0xFF042F24); // Deep Auroral Jade
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainerLight = Color(0xFF065F46); // Emerald 800
  static const Color onSecondaryContainerDark = Color(0xFFA7F3D0); // Emerald 200

  // ---------------------------------------------------------------------------
  // Tertiary Palette (Electric Cyan / Focus & Time)
  // ---------------------------------------------------------------------------
  static const Color tertiary = Color(0xFF06B6D4); // Cyan 500
  static const Color tertiaryLight = Color(0xFF22D3EE); // Cyan 400
  static const Color tertiaryDark = Color(0xFF0891B2); // Cyan 600
  static const Color tertiaryContainerLight = Color(0xFFCFFAFE); // Cyan 100
  static const Color tertiaryContainerDark = Color(0xFF083344); // Cyan 950
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainerLight = Color(0xFF155E75); // Cyan 800
  static const Color onTertiaryContainerDark = Color(0xFFA5F3FC); // Cyan 200

  // ---------------------------------------------------------------------------
  // Authentic Platform Brand Colors (Creator & Content Ecosystem)
  // ---------------------------------------------------------------------------
  static const Color platformYoutube = Color(0xFFFF0033); // YouTube Studio Red
  static const Color platformInstagram = Color(0xFFE1306C); // Instagram Sunset
  static const Color platformTwitter = Color(0xFF38BDF8); // Sky / X
  static const Color platformTwitterPlatinum = Color(0xFFE2E8F0); // X Platinum
  static const Color platformBlog = Color(0xFFF97316); // Warm Craft Terracotta
  static const Color platformLinkedIn = Color(0xFF0A66C2); // LinkedIn Cyan
  static const Color platformTikTok = Color(0xFF00F2FE); // Neon Cyan

  // Convenient brand aliases
  static const Color youtube = platformYoutube;
  static const Color instagram = platformInstagram;
  static const Color twitter = platformTwitter;
  static const Color twitterPlatinum = platformTwitterPlatinum;
  static const Color blog = platformBlog;
  static const Color linkedin = platformLinkedIn;
  static const Color tiktok = platformTikTok;

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
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Light Mode Text
  static const Color textPrimaryLight = Color(0xFF0A0F1D); // Deep graphite obsidian
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400
  static const Color textDisabledLight = Color(0xFFCBD5E1); // Slate 300

  // ---------------------------------------------------------------------------
  // Dark Mode Surfaces & Neutrals ("Solar Obsidian & Auroral Jade")
  // ---------------------------------------------------------------------------
  static const Color backgroundDark = Color(0xFF080B11); // Deep space titanium obsidian
  static const Color surfaceDark = Color(0xFF0F1523); // Elevated tactical surface
  static const Color surfaceVariantDark = Color(0xFF141C2E); // Tactile card surface
  static const Color surfaceElevatedDark = Color(0xFF182238); // Elevated dialog surface
  static const Color cardDark = Color(0xFF141C2E); // Tactile card surface
  static const Color dialogDark = Color(0xFF182238); // Elevated dialog
  static const Color borderDark = Color(0x14FFFFFF); // Precision hairline border rgba(255, 255, 255, 0.08)
  static const Color borderSubtleDark = Color(0x14FFFFFF); // Precision hairline border
  static const Color dividerDark = Color(0x14FFFFFF); // Precision hairline divider

  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500
  static const Color textDisabledDark = Color(0xFF475569); // Slate 600

  // ---------------------------------------------------------------------------
  // Task Status Colors
  // Pending (Amber), Doing (Cyan), Done (Emerald Jade), Skipped (Slate), Cancelled (Crimson)
  // ---------------------------------------------------------------------------
  static const Color statusPending = Color(0xFFF59E0B); // Solar Amber 500
  static const Color statusPendingContainerLight = Color(0xFFFEF3C7);
  static const Color statusPendingContainerDark = Color(0xFF2D1C03);
  static const Color onStatusPendingLight = Color(0xFF92400E);
  static const Color onStatusPendingDark = Color(0xFFFDE68A);

  static const Color statusDoing = Color(0xFF06B6D4); // Electric Cyan 500
  static const Color statusDoingContainerLight = Color(0xFFCFFAFE);
  static const Color statusDoingContainerDark = Color(0xFF083344);
  static const Color onStatusDoingLight = Color(0xFF155E75);
  static const Color onStatusDoingDark = Color(0xFFA5F3FC);

  static const Color statusDone = Color(0xFF10B981); // Auroral Jade 500
  static const Color statusDoneContainerLight = Color(0xFFD1FAE5);
  static const Color statusDoneContainerDark = Color(0xFF042F24);
  static const Color onStatusDoneLight = Color(0xFF065F46);
  static const Color onStatusDoneDark = Color(0xFFA7F3D0);

  static const Color statusSkipped = Color(0xFF64748B); // Slate Grey 500
  static const Color statusSkippedContainerLight = Color(0xFFF1F5F9);
  static const Color statusSkippedContainerDark = Color(0xFF1E293B);
  static const Color onStatusSkippedLight = Color(0xFF334155);
  static const Color onStatusSkippedDark = Color(0xFFCBD5E1);

  static const Color statusCancelled = Color(0xFFEF4444); // Crimson Red 500
  static const Color statusCancelledContainerLight = Color(0xFFFEE2E2);
  static const Color statusCancelledContainerDark = Color(0xFF450A0A);
  static const Color onStatusCancelledLight = Color(0xFF991B1B);
  static const Color onStatusCancelledDark = Color(0xFFFCA5A5);

  // ---------------------------------------------------------------------------
  // Priority Colors
  // Low (Slate), Medium (Cyan), High (Solar Amber), Urgent (Crimson Red)
  // ---------------------------------------------------------------------------
  static const Color priorityLow = Color(0xFF64748B); // Slate 500
  static const Color priorityLowContainerLight = Color(0xFFF1F5F9);
  static const Color priorityLowContainerDark = Color(0xFF1E293B);
  static const Color onPriorityLowLight = Color(0xFF334155);
  static const Color onPriorityLowDark = Color(0xFFCBD5E1);

  static const Color priorityMedium = Color(0xFF06B6D4); // Electric Cyan
  static const Color priorityMediumContainerLight = Color(0xFFCFFAFE);
  static const Color priorityMediumContainerDark = Color(0xFF083344);
  static const Color onPriorityMediumLight = Color(0xFF155E75);
  static const Color onPriorityMediumDark = Color(0xFFA5F3FC);

  static const Color priorityHigh = Color(0xFFF59E0B); // Solar Amber 500
  static const Color priorityHighContainerLight = Color(0xFFFEF3C7);
  static const Color priorityHighContainerDark = Color(0xFF2D1C03);
  static const Color onPriorityHighLight = Color(0xFF92400E);
  static const Color onPriorityHighDark = Color(0xFFFDE68A);

  static const Color priorityUrgent = Color(0xFFEF4444); // Crimson Red 500
  static const Color priorityUrgentContainerLight = Color(0xFFFEE2E2);
  static const Color priorityUrgentContainerDark = Color(0xFF450A0A);
  static const Color onPriorityUrgentLight = Color(0xFF991B1B);
  static const Color onPriorityUrgentDark = Color(0xFFFCA5A5);

  // ---------------------------------------------------------------------------
  // Semantic Colors
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF10B981); // Auroral Jade
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B); // Solar Amber
  static const Color onWarning = Color(0xFF080B11);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  static const Color info = Color(0xFF06B6D4); // Electric Cyan
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCFFAFE);
  static const Color onInfoContainer = Color(0xFF155E75);

  // ---------------------------------------------------------------------------
  // Chart & Label Colors (12 Distinct High-Contrast Colors)
  // ---------------------------------------------------------------------------
  static const Color chartAmber = Color(0xFFF59E0B);
  static const Color chartEmerald = Color(0xFF10B981);
  static const Color chartCyan = Color(0xFF06B6D4);
  static const Color chartRose = Color(0xFFF43F5E);
  static const Color chartOrange = Color(0xFFF97316);
  static const Color chartPurple = Color(0xFF8B5CF6);
  static const Color chartSky = Color(0xFF38BDF8);
  static const Color chartTeal = Color(0xFF14B8A6);
  static const Color chartPink = Color(0xFFEC4899);
  static const Color chartLime = Color(0xFF84CC16);
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartIndigo = Color(0xFF6366F1);
  static const Color chartViolet = Color(0xFFA855F7);

  static const List<Color> chartColors = [
    chartAmber,
    chartEmerald,
    chartCyan,
    chartRose,
    chartOrange,
    chartPurple,
    chartSky,
    chartTeal,
    chartPink,
    chartLime,
    chartBlue,
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
        return platformBlog;
      case 'linkedin':
        return platformLinkedIn;
      case 'tiktok':
        return platformTikTok;
      default:
        return primary;
    }
  }
}
