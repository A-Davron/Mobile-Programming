import 'package:flutter/material.dart';

/// Every colour, text size, radius and spacing value in the app lives in this
/// file. Screens read them through Theme.of(context) (or the AppSpace /
/// AppRadius constants) and never write a Color(0xFF…) or a font size.
///
/// The values follow the Figma design credited in design_credit.dart: the
/// Material 3 baseline colours, the M3 type scale and its corner radii.
abstract final class _Palette {
  // Material 3 baseline colour scheme, as used in the Material 3 Design Kit.
  static const primary = Color(0xFF6750A4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFEADDFF);
  static const onPrimaryContainer = Color(0xFF21005D);
  static const secondary = Color(0xFF625B71);
  static const background = Color(0xFFFEF7FF);
  static const card = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFF3EDF7);
  static const surfaceContainerHigh = Color(0xFFECE6F0);
  static const secondaryContainer = Color(0xFFE8DEF8);
  static const onSecondaryContainer = Color(0xFF4A4459);
  static const outline = Color(0xFFCAC4D0);
  static const text = Color(0xFF1D1B20);
  static const textMuted = Color(0xFF49454F);
  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFF9DEDC);
}

/// Spacing scale from the design (4-point grid).
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Side padding for every screen, so text never touches the edge.
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 20, vertical: md);
}

/// Corner radii from the design.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _Palette.primary).copyWith(
      primary: _Palette.primary,
      onPrimary: _Palette.onPrimary,
      primaryContainer: _Palette.primaryContainer,
      onPrimaryContainer: _Palette.onPrimaryContainer,
      secondary: _Palette.secondary,
      secondaryContainer: _Palette.secondaryContainer,
      onSecondaryContainer: _Palette.onSecondaryContainer,
      surfaceContainer: _Palette.surfaceContainer,
      surfaceContainerHigh: _Palette.surfaceContainerHigh,
      surface: _Palette.background,
      surfaceContainerLowest: _Palette.card,
      surfaceContainerHighest: _Palette.outline,
      onSurface: _Palette.text,
      onSurfaceVariant: _Palette.textMuted,
      outline: _Palette.textMuted,
      outlineVariant: _Palette.outline,
      error: _Palette.error,
      errorContainer: _Palette.errorContainer,
    );

    const base = TextTheme(
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, height: 1.15),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.2),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, height: 28 / 22),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45),
      bodySmall: TextStyle(fontSize: 12, height: 16 / 12, letterSpacing: 0.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
    final text = base.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    // M3 buttons are fully rounded.
    const buttonShape = StadiumBorder();
    const buttonSize = Size(64, 48);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: text.labelLarge,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: buttonShape, textStyle: text.labelLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: text.labelLarge?.copyWith(color: scheme.onSecondaryContainer),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.xs),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant,
        circularTrackColor: scheme.outlineVariant,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    );
  }
}
