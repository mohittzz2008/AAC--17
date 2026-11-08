import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// ROVER COMMAND Dark Material 3 theme configuration.
abstract final class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.gold,
      secondary: AppColors.gold,
      error: AppColors.burgundy,
      onSurface: AppColors.white,
      onPrimary: AppColors.black,
      outline: AppColors.raisedSurface,
      outlineVariant: AppColors.raisedSurface,
      surfaceContainerLowest: AppColors.black,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.raisedSurface,
      surfaceContainerHighest: AppColors.raisedSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      focusColor: AppColors.gold.withValues(alpha: 0.25),
      hoverColor: AppColors.raisedSurface.withValues(alpha: 0.4),
      fontFamily: AppTypography.interfaceFontFamily,
      fontFamilyFallback: AppTypography.interfaceFontFallbacks,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.white),
        titleTextStyle: AppTypography.appTitle,
      ),

      // Card Theme (14dp radius, 1px raisedSurface border)
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.raisedSurface, width: 1),
        ),
      ),

      // Elevated Button Theme (Gold fill, black bold text)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          elevation: 0,
          textStyle: AppTypography.interfaceBase.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold, width: 1),
          textStyle: AppTypography.interfaceBase.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          textStyle: AppTypography.interfaceBase.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTypography.interfaceBase.copyWith(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
        labelStyle: AppTypography.interfaceBase.copyWith(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.raisedSurface, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.raisedSurface, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.burgundy, width: 1.5),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.secondaryText,
        selectedLabelStyle: AppTypography.navLabelSelected,
        unselectedLabelStyle: AppTypography.navLabelUnselected,
        elevation: 0,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: const IconThemeData(color: AppColors.gold),
        unselectedIconTheme: const IconThemeData(color: AppColors.secondaryText),
        selectedLabelTextStyle: AppTypography.navLabelSelected,
        unselectedLabelTextStyle: AppTypography.navLabelUnselected,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.raisedSurface,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.white,
        size: 24,
      ),
    );
  }
}

