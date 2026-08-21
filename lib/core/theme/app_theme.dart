import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: AppColors.primaryGreen,
        primaryContainer: AppColors.deepAccent,
        secondary: AppColors.ink,
        secondaryContainer: AppColors.darkGrey,
        tertiary: AppColors.deepAccent,
        tertiaryContainer: AppColors.lightGrey,
        appBarColor: AppColors.primaryGreen,
        error: AppColors.error,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      scaffoldBackground: AppColors.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 12.0,
        elevatedButtonSchemeColor: SchemeColor.onPrimary,
        elevatedButtonSecondarySchemeColor: SchemeColor.primary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsBorderSchemeColor: SchemeColor.primary,
        segmentedButtonSchemeColor: SchemeColor.primary,
        segmentedButtonBorderSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarBackgroundSchemeColor: SchemeColor.surface,
        navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
        navigationBarIndicatorOpacity: 0.2,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }

  static ThemeData get dark {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: AppColors.primaryGreen,
        primaryContainer: AppColors.midnightGreen,
        secondary: Colors.white,
        secondaryContainer: AppColors.darkGrey,
        tertiary: AppColors.deepAccent,
        tertiaryContainer: AppColors.ink,
        appBarColor: AppColors.midnightGreen,
        error: AppColors.error,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      scaffoldBackground: AppColors.darkBackground,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 12.0,
        elevatedButtonSchemeColor: SchemeColor.onPrimary,
        elevatedButtonSecondarySchemeColor: SchemeColor.primary,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }
}
