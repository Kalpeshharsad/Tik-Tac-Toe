import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Electric Grid Color Palette ────────────────────────────────────────────
class KColors {
  // Surfaces
  static const Color surface = Color(0xFF0C0E10);
  static const Color surfaceDim = Color(0xFF0C0E10);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF111416);
  static const Color surfaceContainer = Color(0xFF171A1C);
  static const Color surfaceContainerHigh = Color(0xFF1D2022);
  static const Color surfaceContainerHighest = Color(0xFF232629);
  static const Color surfaceBright = Color(0xFF292C2F);
  static const Color surfaceVariant = Color(0xFF232629);

  // Primary (Electric Cyan)
  static const Color primary = Color(0xFF81ECFF);
  static const Color primaryDim = Color(0xFF00D4EC);
  static const Color primaryContainer = Color(0xFF00E3FD);
  static const Color primaryFixed = Color(0xFF00E3FD);
  static const Color onPrimary = Color(0xFF005762);
  static const Color onPrimaryContainer = Color(0xFF004D57);

  // Secondary (Neon Orange)
  static const Color secondary = Color(0xFFFD9000);
  static const Color secondaryDim = Color(0xFFEA8400);
  static const Color secondaryContainer = Color(0xFF8E4E00);
  static const Color onSecondary = Color(0xFF462400);

  // Tertiary (Mint Green)
  static const Color tertiary = Color(0xFFB5FFC2);
  static const Color tertiaryDim = Color(0xFF24F07E);
  static const Color tertiaryContainer = Color(0xFF3FFF8B);
  static const Color tertiaryFixed = Color(0xFF3FFF8B);
  static const Color onTertiary = Color(0xFF006731);
  static const Color onTertiaryContainer = Color(0xFF005D2C);

  // Neutral / Text
  static const Color onSurface = Color(0xFFEEEEF0);
  static const Color onBackground = Color(0xFFEEEEF0);
  static const Color onSurfaceVariant = Color(0xFFAAABAD);

  // Error
  static const Color error = Color(0xFFFF716C);
  static const Color errorContainer = Color(0xFF9F0519);
  static const Color onErrorContainer = Color(0xFFFFA8A3);

  // Outline
  static const Color outline = Color(0xFF747578);
  static const Color outlineVariant = Color(0xFF46484A);

  // Background
  static const Color background = Color(0xFF0C0E10);
}

// ─── Gradients ───────────────────────────────────────────────────────────────
class KGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [KColors.primary, KColors.primaryContainer],
  );

  static const LinearGradient secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [KColors.secondary, KColors.secondaryDim],
  );

  static const LinearGradient tertiary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [KColors.tertiary, KColors.tertiaryFixed],
  );

  static RadialGradient celebration = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [
      KColors.primaryContainer.withOpacity(0.15),
      KColors.surface,
    ],
  );
}

// ─── Border Radius Tokens ─────────────────────────────────────────────────────
class KRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double full = 9999.0;

  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));
}

// ─── App Theme ────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final pjs = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: KColors.primary,
        onPrimary: KColors.onPrimary,
        primaryContainer: KColors.primaryContainer,
        onPrimaryContainer: KColors.onPrimaryContainer,
        secondary: KColors.secondary,
        onSecondary: KColors.onSecondary,
        secondaryContainer: KColors.secondaryContainer,
        tertiary: KColors.tertiary,
        onTertiary: KColors.onTertiary,
        tertiaryContainer: KColors.tertiaryContainer,
        onTertiaryContainer: KColors.onTertiaryContainer,
        error: KColors.error,
        errorContainer: KColors.errorContainer,
        onErrorContainer: KColors.onErrorContainer,
        surface: KColors.surface,
        onSurface: KColors.onSurface,
        surfaceContainerHighest: KColors.surfaceContainerHighest,
        surfaceContainerHigh: KColors.surfaceContainerHigh,
        surfaceContainer: KColors.surfaceContainer,
        surfaceContainerLow: KColors.surfaceContainerLow,
        surfaceContainerLowest: KColors.surfaceContainerLowest,
        outline: KColors.outline,
        outlineVariant: KColors.outlineVariant,
      ),
      scaffoldBackgroundColor: KColors.surface,
      textTheme: pjs.copyWith(
        displayLarge: pjs.displayLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: KColors.onSurface,
          letterSpacing: -1.5,
        ),
        headlineLarge: pjs.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: KColors.onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: pjs.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: KColors.onSurface,
        ),
        titleMedium: pjs.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: KColors.onSurface,
        ),
        bodyMedium: pjs.bodyMedium?.copyWith(
          color: KColors.onSurfaceVariant,
        ),
        labelSmall: pjs.labelSmall?.copyWith(
          color: KColors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: const CardThemeData(
        color: KColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: KRadius.lgRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.tertiary,
          foregroundColor: KColors.onTertiary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: KRadius.mdRadius),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KColors.surfaceContainerLow,
        selectedItemColor: KColors.primary,
        unselectedItemColor: Color(0xFF64748B),
      ),
    );
  }
}
