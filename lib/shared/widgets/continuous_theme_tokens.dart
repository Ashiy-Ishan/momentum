import 'package:flutter/material.dart';

abstract final class ContinuousPalette {
  static const Color darkBlack = Color(0xFF000000);
  static const Color darkNavy = Color(0xFF14213D);
  static const Color darkAmber = Color(0xFFFCA311);
  static const Color darkGrey = Color(0xFFE5E5E5);
  static const Color darkWhite = Color(0xFFFFFFFF);

  static const List<String> darkTeamHexSwatches = [
    '#000000',
    '#14213D',
    '#FCA311',
    '#E5E5E5',
    '#FFFFFF',
  ];

  static const Color light100 = Color(0xFFF8F9FA);
  static const Color light200 = Color(0xFFE9ECEF);
  static const Color light300 = Color(0xFFDEE2E6);
  static const Color light400 = Color(0xFFCED4DA);
  static const Color light500 = Color(0xFFADB5BD);
  static const Color light600 = Color(0xFF6C757D);
  static const Color light700 = Color(0xFF495057);
  static const Color light800 = Color(0xFF343A40);
  static const Color light900 = Color(0xFF212529);

  static const List<String> lightTeamHexSwatches = [
    '#F8F9FA',
    '#E9ECEF',
    '#DEE2E6',
    '#CED4DA',
    '#ADB5BD',
    '#6C757D',
    '#495057',
    '#343A40',
    '#212529',
  ];

  static const List<String> allPresetSwatches = [
    ...darkTeamHexSwatches,
    ...lightTeamHexSwatches,
  ];

  static Color scaffoldBackground(bool isDark) => isDark ? darkBlack : light100;
  static Color sidebarBackground(bool isDark) => isDark ? darkNavy : light100;
  static Color appBarBackground(bool isDark) => isDark ? darkNavy : light100;
  static Color cardSurface(bool isDark) => isDark ? darkNavy : light200;
  static Color elevatedSurface(bool isDark) => isDark ? darkNavy : light100;
  static Color inputBackground(bool isDark) => isDark ? darkBlack : light200;

  static Color cardBorder(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.18) : light400;

  static Color borderSubtle(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.12) : light300;

  static Color divider(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.12) : light300;

  static Color activePillBackground(bool isDark) => isDark ? darkAmber : light900;
  static Color activePillForeground(bool isDark) => isDark ? darkBlack : light100;
  static Color inactiveNavItem(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.75) : light600;

  static Color bottomBarBackground(bool isDark) => isDark ? darkNavy : light100;
  static Color bottomBarBorder(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.20) : light400;
  static Color bottomBarSelected(bool isDark) => isDark ? darkAmber : light900;
  static Color bottomBarUnselected(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.65) : light600;

  static Color titleText(bool isDark) => isDark ? darkWhite : light900;
  static Color bodyText(bool isDark) => isDark ? darkGrey : light700;
  static Color subtitleText(bool isDark) => isDark ? darkGrey : light700;
  static Color mutedText(bool isDark) =>
      isDark ? darkGrey.withValues(alpha: 0.7) : light600;

  static Color progressTrack(bool isDark) => isDark ? darkBlack : light300;
  static Color progressFill(bool isDark) => isDark ? darkAmber : light900;
  static Color progressFillSecondary(bool isDark) => isDark ? darkAmber : darkAmber;

  static Color primaryButtonBackground(bool isDark) =>
      isDark ? darkAmber : light900;
  static Color primaryButtonForeground(bool isDark) =>
      isDark ? darkBlack : light100;

  static Color secondaryButtonBackground(bool isDark) =>
      isDark ? darkBlack : light300;
  static Color secondaryButtonForeground(bool isDark) =>
      isDark ? darkWhite : light800;
}
