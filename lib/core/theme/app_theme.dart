import 'package:flutter/material.dart';

import 'palette.dart';

/// Typefaces bundled in assets/fonts (no network needed at runtime).
abstract final class Fonts {
  /// Display: titles, numbers, the hero moments.
  static const display = 'Bricolage';

  /// Text: everything else.
  static const body = 'Figtree';
}

abstract final class Radii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

abstract final class Gap {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Horizontal page gutter.
  static const page = 20.0;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Palette.light, Brightness.light);
  static ThemeData dark() => _build(Palette.dark, Brightness.dark);

  static ThemeData _build(Palette p, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: p.green,
      onPrimary: p.onGreen,
      primaryContainer: p.greenTint,
      onPrimaryContainer: p.greenStrong,
      secondary: p.forest,
      onSecondary: p.onForest,
      secondaryContainer: p.surfaceAlt,
      onSecondaryContainer: p.ink,
      tertiary: p.blue,
      onTertiary: Colors.white,
      error: p.red,
      onError: Colors.white,
      errorContainer: p.redTint,
      onErrorContainer: p.red,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceAlt,
      surfaceContainerHighest: p.surfaceAlt,
      outline: p.line,
      outlineVariant: p.line,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: p.ink,
      onInverseSurface: p.surface,
      inversePrimary: p.greenTint,
    );

    final text = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      fontFamily: Fonts.body,
      textTheme: text,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: p.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.green,
          foregroundColor: p.onGreen,
          disabledBackgroundColor: p.surfaceAlt,
          disabledForegroundColor: p.inkFaint,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: BorderSide(color: p.line, width: 1.2),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.greenStrong,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.ink),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.green,
        foregroundColor: p.onGreen,
        elevation: 2,
        highlightElevation: 4,
        extendedTextStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: text.bodyMedium?.copyWith(color: p.inkMuted),
        floatingLabelStyle: text.bodyMedium?.copyWith(
          color: p.greenStrong,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: p.inkFaint),
        helperStyle: text.bodySmall?.copyWith(color: p.inkMuted),
        errorStyle: text.bodySmall?.copyWith(color: p.red),
        prefixIconColor: p.inkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.green, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: p.red, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.greenTint,
        disabledColor: p.surfaceAlt,
        side: BorderSide(color: p.line),
        labelStyle: text.labelMedium?.copyWith(color: p.ink),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: p.greenStrong),
        checkmarkColor: p.greenStrong,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(text.labelMedium),
          side: WidgetStatePropertyAll(BorderSide(color: p.line)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.md),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? p.greenTint : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) =>
                s.contains(WidgetState.selected) ? p.greenStrong : p.inkMuted,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.greenTint,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? p.greenStrong
                : p.inkMuted,
            size: 24,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall!.copyWith(
            color: s.contains(WidgetState.selected) ? p.ink : p.inkMuted,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surface,
        indicatorColor: p.greenTint,
        selectedIconTheme: IconThemeData(color: p.greenStrong),
        unselectedIconTheme: IconThemeData(color: p.inkMuted),
        selectedLabelTextStyle: text.labelMedium?.copyWith(
          color: p.ink,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: p.inkMuted),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.ink,
        unselectedLabelColor: p.inkMuted,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: p.green,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: p.line,
        tabAlignment: TabAlignment.start,
        overlayColor: WidgetStatePropertyAll(
          p.greenTint.withValues(alpha: 0.4),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.line,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.inkMuted),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: p.surface,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: p.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: p.line),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkMuted,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall?.copyWith(color: p.inkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: Gap.page),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onGreen : p.inkFaint,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.green : p.surfaceAlt,
        ),
        trackOutlineColor: WidgetStatePropertyAll(p.line),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? p.green : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(p.onGreen),
        side: BorderSide(color: p.inkFaint, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.green,
        linearTrackColor: p.surfaceAlt,
        circularTrackColor: p.surfaceAlt,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        textStyle: text.labelSmall?.copyWith(color: p.surface),
      ),
    );
  }

  static TextTheme _textTheme(Palette p) {
    TextStyle d(
      double size,
      FontWeight w, {
      double height = 1.15,
      double ls = -0.2,
    }) => TextStyle(
      fontFamily: Fonts.display,
      fontSize: size,
      fontWeight: w,
      height: height,
      letterSpacing: ls,
      color: p.ink,
    );
    TextStyle t(
      double size,
      FontWeight w, {
      double height = 1.4,
      Color? color,
      double ls = 0,
    }) => TextStyle(
      fontFamily: Fonts.body,
      fontSize: size,
      fontWeight: w,
      height: height,
      letterSpacing: ls,
      color: color ?? p.ink,
    );

    return TextTheme(
      displayLarge: d(48, FontWeight.w800, height: 1.0, ls: -1.2),
      displayMedium: d(38, FontWeight.w800, height: 1.05, ls: -0.9),
      displaySmall: d(30, FontWeight.w800, height: 1.08, ls: -0.6),
      headlineLarge: d(28, FontWeight.w800, ls: -0.5),
      headlineMedium: d(24, FontWeight.w700, ls: -0.4),
      headlineSmall: d(20, FontWeight.w700, ls: -0.3),
      titleLarge: d(19, FontWeight.w700, ls: -0.2),
      titleMedium: t(16, FontWeight.w700, height: 1.3),
      titleSmall: t(14.5, FontWeight.w700, height: 1.3),
      bodyLarge: t(16, FontWeight.w400, height: 1.5),
      bodyMedium: t(14.5, FontWeight.w400, height: 1.45),
      bodySmall: t(12.5, FontWeight.w500, height: 1.4, color: p.inkMuted),
      labelLarge: t(15, FontWeight.w700, height: 1.2),
      labelMedium: t(13, FontWeight.w600, height: 1.2),
      labelSmall: t(11.5, FontWeight.w600, height: 1.2, ls: 0.1),
    );
  }
}
