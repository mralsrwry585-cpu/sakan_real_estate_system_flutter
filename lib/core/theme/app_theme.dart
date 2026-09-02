import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Builds the SAKAN [ThemeData] for light and dark, using the Almarai family
/// (weights 300/400/700/800 — the only weights Almarai ships). Extrabold (800)
/// headings are a defining trait of the Lovable design.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(SakanColors.light);
  static ThemeData get dark => _build(SakanColors.dark);

  static ThemeData _build(SakanColors c) {
    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.primary,
      onPrimary: c.primaryForeground,
      secondary: c.secondary,
      onSecondary: c.secondaryForeground,
      tertiary: c.gold,
      onTertiary: c.goldForeground,
      error: c.destructive,
      onError: c.destructiveForeground,
      surface: c.surface,
      onSurface: c.foreground,
      surfaceContainerHighest: c.muted,
      onSurfaceVariant: c.mutedForeground,
      outline: c.border,
      outlineVariant: c.input,
      primaryContainer: c.secondary,
      onPrimaryContainer: c.secondaryForeground,
    );

    final baseText = GoogleFonts.almaraiTextTheme(
      c.brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    ).apply(bodyColor: c.foreground, displayColor: c.foreground);

    final textTheme = baseText.copyWith(
      displayLarge: GoogleFonts.almarai(
          fontWeight: FontWeight.w800, fontSize: 32, color: c.foreground),
      displayMedium: GoogleFonts.almarai(
          fontWeight: FontWeight.w800, fontSize: 28, color: c.foreground),
      headlineMedium: GoogleFonts.almarai(
          fontWeight: FontWeight.w800, fontSize: 24, color: c.foreground),
      titleLarge: GoogleFonts.almarai(
          fontWeight: FontWeight.w800, fontSize: 20, color: c.foreground),
      titleMedium: GoogleFonts.almarai(
          fontWeight: FontWeight.w700, fontSize: 16, color: c.foreground),
      titleSmall: GoogleFonts.almarai(
          fontWeight: FontWeight.w700, fontSize: 14, color: c.foreground),
      bodyLarge: GoogleFonts.almarai(fontWeight: FontWeight.w400, fontSize: 15),
      bodyMedium: GoogleFonts.almarai(fontWeight: FontWeight.w400, fontSize: 14),
      bodySmall: GoogleFonts.almarai(
          fontWeight: FontWeight.w400, fontSize: 12, color: c.mutedForeground),
      labelLarge: GoogleFonts.almarai(
          fontWeight: FontWeight.w700, fontSize: 14, color: c.foreground),
      labelSmall: GoogleFonts.almarai(
          fontWeight: FontWeight.w700, fontSize: 11, color: c.mutedForeground),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      textTheme: textTheme,
      primaryColor: c.primary,
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.foreground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: GoogleFonts.almarai(
            fontWeight: FontWeight.w800, fontSize: 16, color: c.foreground),
        iconTheme: IconThemeData(color: c.foreground.tint(0.75)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: GoogleFonts.almarai(
            fontWeight: FontWeight.w400, color: c.mutedForeground, fontSize: 14),
        labelStyle: GoogleFonts.almarai(
            fontWeight: FontWeight.w700, color: c.foreground, fontSize: 13),
        prefixIconColor: c.mutedForeground,
        suffixIconColor: c.mutedForeground,
        border: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: c.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: c.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: c.destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brLg,
          borderSide: BorderSide(color: c.destructive, width: 2),
        ),
        errorStyle: GoogleFonts.almarai(color: c.destructive, fontSize: 11),
      ),
      cardTheme: CardThemeData(
        color: c.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        side: BorderSide(color: c.border),
        labelStyle: GoogleFonts.almarai(
            fontWeight: FontWeight.w700, fontSize: 12, color: c.foreground),
        shape: const StadiumBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.mutedForeground,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.brXxl),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.foreground,
        contentTextStyle:
            GoogleFonts.almarai(color: c.background, fontSize: 13),
        shape:
            const RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      iconTheme: IconThemeData(color: c.foreground),
    );
  }
}
