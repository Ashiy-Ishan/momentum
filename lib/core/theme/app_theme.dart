import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Complete Material 3 themes for the Momentum application.
///
/// Palette Philosophy: "Solar Obsidian & Auroral Jade"
/// - Editorial precision craft aesthetic (Linear, Raycast, Amie)
/// - Primary: Solar Amber & Radiant Gold for sharp luminous focus
/// - Secondary: Auroral Jade & Emerald for momentum, streaks, and completion
/// - Tertiary: Electric Cyan for time tracking, deep focus, and metrics
/// - Dark Mode: Deep space titanium obsidian (#080B11), elevated tactical surface (#0F1523),
///   tactile card surface (#141C2E) with precision hairline borders rgba(255, 255, 255, 0.08),
///   and elevated dialogs (#182238).
/// - Light Mode: Architectural crisp ivory & slate (#F8FAFC, #FFFFFF, #F1F5F9)
///   with deep graphite obsidian text (#0A0F1D) and warm solar amber accents.
class AppTheme {
  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================
  static ThemeData lightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.onPrimaryContainerLight,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainerLight,
      onSecondaryContainer: AppColors.onSecondaryContainerLight,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainerLight,
      onTertiaryContainer: AppColors.tertiaryDark,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderLight,
      shadow: Color(0x0F0A0F1D),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: AppTypography.lightTextTheme,

      // 1. AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight, size: 24),
      ),

      // 2. Card Theme - Tactile hairline border via colorScheme.outlineVariant
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardLight,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
      ),

      // 3. Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariantLight,
        contentPadding: AppSpacing.inputPadding,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiaryLight,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        floatingLabelStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // 4. Elevated Button Theme - Solar Amber with obsidian contrast
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceVariantLight,
          disabledForegroundColor: AppColors.textDisabledLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14.0,
          ),
          shape: AppRadius.shapeMd,
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // 5. Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.primaryDark,
          disabledForegroundColor: AppColors.textDisabledLight,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14.0,
          ),
          shape: AppRadius.shapeMd,
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // 6. Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: AppRadius.shapeMd,
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // 7. Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        selectedColor: AppColors.primaryContainerLight,
        disabledColor: AppColors.surfaceVariantLight,
        deleteIconColor: AppColors.textSecondaryLight,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimaryContainerLight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        elevation: 0,
        pressElevation: 0,
      ),

      // 8. Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dialogLight,
        surfaceTintColor: Colors.transparent,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),

      // 9. Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textTertiaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // 10. Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primaryDark,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textTertiaryLight,
          size: 24,
        ),
        selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textTertiaryLight,
        ),
        labelType: NavigationRailLabelType.all,
        elevation: 0,
        useIndicator: true,
        indicatorColor: AppColors.primaryContainerLight,
      ),

      // 11. Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rightLg),
      ),

      // 12. SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: AppRadius.shapeSm,
        elevation: 4.0,
      ),

      // 13. Floating Action Button Theme - Solar Amber with obsidian contrast
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2.0,
        focusElevation: 4.0,
        hoverElevation: 4.0,
        highlightElevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      ),

      // 14. Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textTertiaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainerLight;
          }
          return AppColors.surfaceVariantLight;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return colorScheme.outlineVariant;
        }),
      ),

      // 15. Checkbox Theme - Auroral Jade accent
      checkboxTheme: CheckboxThemeData(
        shape: AppRadius.shapeXs,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.secondary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
      ),

      // 16. Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1.0,
        space: 1.0,
      ),

      // 17. TabBar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.textSecondaryLight,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colorScheme.outlineVariant,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelLarge,
      ),

      // 18. ListTile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: AppSpacing.listTilePadding,
        shape: AppRadius.shapeSm,
        iconColor: AppColors.textSecondaryLight,
        textColor: AppColors.textPrimaryLight,
      ),
    );
  }

  // ===========================================================================
  // DARK THEME ("Solar Obsidian & Auroral Jade")
  // ===========================================================================
  static ThemeData darkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.statusCancelledContainerDark,
      onErrorContainer: AppColors.onStatusCancelledDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.borderDark,
      shadow: Color(0x66000000),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: AppTypography.darkTextTheme,

      // 1. AppBar Theme - Deep space titanium obsidian surface
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1.0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark, size: 24),
      ),

      // 2. Card Theme - Tactile card surface with hairline border rgba(255, 255, 255, 0.08)
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
      ),

      // 3. Input Decoration Theme - Tactical dark surface with precision hairline border
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: AppSpacing.inputPadding,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        floatingLabelStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // 4. Elevated Button Theme - Solar Gold with deep titanium obsidian text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.surfaceVariantDark,
          disabledForegroundColor: AppColors.textDisabledDark,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14.0,
          ),
          shape: AppRadius.shapeMd,
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // 5. Outlined Button Theme - Hairline tactical border
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppColors.primaryLight,
          disabledForegroundColor: AppColors.textDisabledDark,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14.0,
          ),
          shape: AppRadius.shapeMd,
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // 6. Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: AppRadius.shapeMd,
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // 7. Chip Theme - Tactical surface with hairline border
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primaryContainerDark,
        disabledColor: AppColors.surfaceDark,
        deleteIconColor: AppColors.textSecondaryDark,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimaryContainerDark,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        elevation: 0,
        pressElevation: 0,
      ),

      // 8. Dialog Theme - Elevated dialog surface (#182238)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dialogDark,
        surfaceTintColor: Colors.transparent,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      // 9. Bottom Navigation Bar Theme - Elevated tactical surface
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // 10. Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.textTertiaryDark,
          size: 24,
        ),
        selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        labelType: NavigationRailLabelType.all,
        elevation: 0,
        useIndicator: true,
        indicatorColor: AppColors.primaryContainerDark,
      ),

      // 11. Drawer Theme - Elevated tactical surface
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rightLg),
      ),

      // 12. SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevatedDark,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: AppRadius.shapeSm,
        elevation: 6.0,
      ),

      // 13. Floating Action Button Theme - Solar Gold with obsidian contrast
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 2.0,
        focusElevation: 4.0,
        hoverElevation: 4.0,
        highlightElevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      ),

      // 14. Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiaryDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryContainerDark;
          }
          return AppColors.surfaceVariantDark;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return colorScheme.outlineVariant;
        }),
      ),

      // 15. Checkbox Theme - Auroral Jade accent
      checkboxTheme: CheckboxThemeData(
        shape: AppRadius.shapeXs,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.secondary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.backgroundDark),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
      ),

      // 16. Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1.0,
        space: 1.0,
      ),

      // 17. TabBar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryDark,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colorScheme.outlineVariant,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelLarge,
      ),

      // 18. ListTile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: AppSpacing.listTilePadding,
        shape: AppRadius.shapeSm,
        iconColor: AppColors.textSecondaryDark,
        textColor: AppColors.textPrimaryDark,
      ),
    );
  }
}
