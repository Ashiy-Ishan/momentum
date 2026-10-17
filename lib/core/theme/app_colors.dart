import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFFC4A480);
  static const Color primaryLight = Color(0xFFDFCCB7);
  static const Color primaryDark = Color(0xFF8F7050);
  static const Color primaryHover = Color(0xFFB5936E);
  static const Color primaryContainerLight = Color(0xFFF7F2EB);
  static const Color primaryContainerDark = Color(0xFF1E1A15);
  static const Color onPrimary = Color(0xFF0C0E12);
  static const Color onPrimaryLight = Color(0xFF0C0E12);
  static const Color onPrimaryContainerLight = Color(0xFF4E3A24);
  static const Color onPrimaryContainerDark = Color(0xFFE8D9C8);

  static const Color secondary = Color(0xFF4E9B78);
  static const Color secondaryLight = Color(0xFF6FB896);
  static const Color secondaryDark = Color(0xFF357A5B);
  static const Color secondaryContainerLight = Color(0xFFEEF6F2);
  static const Color secondaryContainerDark = Color(0xFF11221B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainerLight = Color(0xFF1E4D38);
  static const Color onSecondaryContainerDark = Color(0xFFAFE0CA);

  static const Color tertiary = Color(0xFF5B82A6);
  static const Color tertiaryLight = Color(0xFF7FA3C5);
  static const Color tertiaryDark = Color(0xFF3F6385);
  static const Color tertiaryContainerLight = Color(0xFFEFF4F8);
  static const Color tertiaryContainerDark = Color(0xFF131D27);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainerLight = Color(0xFF223E56);
  static const Color onTertiaryContainerDark = Color(0xFFB8D5EB);

  static const Color platformYoutube = Color(0xFFBD5B5B);
  static const Color platformInstagram = Color(0xFFA06B82);
  static const Color platformTwitter = Color(0xFF6889A4);
  static const Color platformTwitterPlatinum = Color(0xFF94A3B8);
  static const Color platformBlog = Color(0xFFA87C5C);
  static const Color platformSubstack = platformBlog;
  static const Color platformLinkedIn = Color(0xFF5E7A96);
  static const Color platformTikTok = Color(0xFF788D98);
  static const Color platformGithub = Color(0xFF5D8568);

  static const Color youtube = platformYoutube;
  static const Color instagram = platformInstagram;
  static const Color twitter = platformTwitter;
  static const Color twitterPlatinum = platformTwitterPlatinum;
  static const Color blog = platformBlog;
  static const Color substack = platformSubstack;
  static const Color linkedin = platformLinkedIn;
  static const Color tiktok = platformTikTok;
  static const Color github = platformGithub;

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color cardBorderLight = borderLight;
  static const Color dividerLight = Color(0xFFE2E8F0);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  static const Color backgroundDark = Color(0xFF090B0F);
  static const Color surfaceDark = Color(0xFF10141C);
  static const Color surfaceVariantDark = Color(0xFF151B26);
  static const Color surfaceElevatedDark = Color(0xFF1B2332);
  static const Color cardDark = Color(0xFF151B26);
  static const Color dialogDark = Color(0xFF1B2332);
  static const Color borderDark = Color(0x18FFFFFF);
  static const Color borderSubtleDark = Color(0x10FFFFFF);
  static const Color cardBorderDark = borderDark;
  static const Color dividerDark = Color(0x18FFFFFF);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  static const Color statusPending = Color(0xFFC28D4E);
  static const Color statusPendingContainerLight = Color(0xFFFAF3EC);
  static const Color statusPendingContainerDark = Color(0xFF241D14);
  static const Color onStatusPendingLight = Color(0xFF66441D);
  static const Color onStatusPendingDark = Color(0xFFDEC5A2);

  static const Color statusDoing = Color(0xFF5B82A6);
  static const Color statusDoingContainerLight = Color(0xFFEFF5F9);
  static const Color statusDoingContainerDark = Color(0xFF131E2A);
  static const Color onStatusDoingLight = Color(0xFF284865);
  static const Color onStatusDoingDark = Color(0xFFA5C5DC);

  static const Color statusDone = Color(0xFF4E9B78);
  static const Color statusDoneContainerLight = Color(0xFFEEF6F2);
  static const Color statusDoneContainerDark = Color(0xFF11221B);
  static const Color onStatusDoneLight = Color(0xFF1E4D38);
  static const Color onStatusDoneDark = Color(0xFFAFE0CA);

  static const Color statusSkipped = Color(0xFF64748B);
  static const Color statusSkippedContainerLight = Color(0xFFF1F5F9);
  static const Color statusSkippedContainerDark = Color(0xFF161C26);
  static const Color onStatusSkippedLight = Color(0xFF334155);
  static const Color onStatusSkippedDark = Color(0xFF94A3B8);

  static const Color statusCancelled = Color(0xFFB85454);
  static const Color statusCancelledContainerLight = Color(0xFFFDF0F0);
  static const Color statusCancelledContainerDark = Color(0xFF261515);
  static const Color onStatusCancelledLight = Color(0xFF702727);
  static const Color onStatusCancelledDark = Color(0xFFE2A8A8);

  static const Color priorityLow = Color(0xFF64748B);
  static const Color priorityLowContainerLight = Color(0xFFF1F5F9);
  static const Color priorityLowContainerDark = Color(0xFF161C26);
  static const Color onPriorityLowLight = Color(0xFF334155);
  static const Color onPriorityLowDark = Color(0xFF94A3B8);

  static const Color priorityMedium = Color(0xFF5B82A6);
  static const Color priorityMediumContainerLight = Color(0xFFEFF5F9);
  static const Color priorityMediumContainerDark = Color(0xFF131E2A);
  static const Color onPriorityMediumLight = Color(0xFF284865);
  static const Color onPriorityMediumDark = Color(0xFFA5C5DC);

  static const Color priorityHigh = Color(0xFFC28D4E);
  static const Color priorityHighContainerLight = Color(0xFFFAF3EC);
  static const Color priorityHighContainerDark = Color(0xFF241D14);
  static const Color onPriorityHighLight = Color(0xFF66441D);
  static const Color onPriorityHighDark = Color(0xFFDEC5A2);

  static const Color priorityUrgent = Color(0xFFB85454);
  static const Color priorityUrgentContainerLight = Color(0xFFFDF0F0);
  static const Color priorityUrgentContainerDark = Color(0xFF261515);
  static const Color onPriorityUrgentLight = Color(0xFF702727);
  static const Color onPriorityUrgentDark = Color(0xFFE2A8A8);

  static const Color success = Color(0xFF4E9B78);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFEEF6F2);
  static const Color onSuccessContainer = Color(0xFF1E4D38);

  static const Color warning = Color(0xFFC28D4E);
  static const Color onWarning = Color(0xFF0C0E12);
  static const Color warningContainer = Color(0xFFFAF3EC);
  static const Color onWarningContainer = Color(0xFF66441D);

  static const Color error = Color(0xFFB85454);
  static const Color errorLight = Color(0xFFB85454);
  static const Color errorDark = Color(0xFFE2A8A8);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDF0F0);
  static const Color errorContainerLight = Color(0xFFFDF0F0);
  static const Color errorContainerDark = Color(0xFF261515);
  static const Color onErrorContainer = Color(0xFF702727);

  static const Color info = Color(0xFF5B82A6);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFEFF5F9);
  static const Color onInfoContainer = Color(0xFF284865);

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

  static Color chartColorAt(int index) {
    if (index < 0) index = -index;
    return chartColors[index % chartColors.length];
  }

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
