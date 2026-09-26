import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kite_ui/shadcn.dart';

/// Accents following the official Colorlib Kite UI design system.
enum KiteAccent {
  slate('Slate'),
  blue('Blue'),
  violet('Violet');

  const KiteAccent(this.label);
  final String label;

  ShadColorScheme scheme(Brightness b) => switch ((this, b)) {
        (KiteAccent.slate, Brightness.light) =>
          const ShadSlateColorScheme.light(),
        (KiteAccent.slate, Brightness.dark) =>
          const ShadSlateColorScheme.dark(),
        (KiteAccent.blue, Brightness.light) =>
          const ShadBlueColorScheme.light(),
        (KiteAccent.blue, Brightness.dark) => const ShadBlueColorScheme.dark(),
        (KiteAccent.violet, Brightness.light) =>
          const ShadVioletColorScheme.light(),
        (KiteAccent.violet, Brightness.dark) =>
          const ShadVioletColorScheme.dark(),
      };

  Color primaryColor(Brightness b) => scheme(b).primary;
}

class AppTheme {
  AppTheme._();

  static ShadThemeData shadTheme(KiteAccent accent, Brightness brightness) =>
      ShadThemeData(
        brightness: brightness,
        colorScheme: accent.scheme(brightness),
      );

  static ShadThemeData get shadLightTheme =>
      shadTheme(KiteAccent.slate, Brightness.light);

  static ShadThemeData get shadDarkTheme =>
      shadTheme(KiteAccent.slate, Brightness.dark);

  static ThemeData lightTheme([KiteAccent accent = KiteAccent.slate]) {
    final scheme = accent.scheme(Brightness.light);
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scheme.background,
      primaryColor: scheme.primary,
      colorScheme: ColorScheme.light(
        primary: scheme.primary,
        secondary: scheme.secondary,
        surface: scheme.card,
        error: scheme.destructive,
        onPrimary: scheme.primaryForeground,
        onSecondary: scheme.secondaryForeground,
        onSurface: scheme.foreground,
      ),
      cardTheme: CardThemeData(
        color: scheme.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.card,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.foreground),
        titleTextStyle: TextStyle(
          color: scheme.foreground,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.ring, width: 1.5),
        ),
        hintStyle: TextStyle(color: scheme.mutedForeground, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: scheme.foreground,
        displayColor: scheme.foreground,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme([KiteAccent accent = KiteAccent.slate]) {
    final scheme = accent.scheme(Brightness.dark);
    final baseTextTheme =
        GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scheme.background,
      primaryColor: scheme.primary,
      colorScheme: ColorScheme.dark(
        primary: scheme.primary,
        secondary: scheme.secondary,
        surface: scheme.card,
        error: scheme.destructive,
        onPrimary: scheme.primaryForeground,
        onSecondary: scheme.secondaryForeground,
        onSurface: scheme.foreground,
      ),
      cardTheme: CardThemeData(
        color: scheme.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.card,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: scheme.foreground),
        titleTextStyle: TextStyle(
          color: scheme.foreground,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.ring, width: 1.5),
        ),
        hintStyle: TextStyle(color: scheme.mutedForeground, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: scheme.foreground,
        displayColor: scheme.foreground,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
