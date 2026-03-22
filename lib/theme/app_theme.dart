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
  static LinearGradient primary(ColorScheme colors) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [colors.primary, colors.primaryContainer.withValues(alpha: 0.7)],
  );

  static LinearGradient secondary(ColorScheme colors) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [colors.secondary, colors.secondaryContainer.withValues(alpha: 0.7)],
  );

  static LinearGradient tertiary(ColorScheme colors) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [colors.tertiary, colors.tertiaryContainer.withValues(alpha: 0.7)],
  );

  static RadialGradient celebration(ColorScheme colors) => RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [
      colors.primaryContainer.withValues(alpha: 0.15),
      colors.surface,
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
  static ThemeData getTheme(Brightness brightness, Color primaryAccent) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
    final pjs = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);

    final surfaceColor = isDark ? KColors.surface : const Color(0xFFF8FAFC);
    final onSurfaceColor = isDark ? KColors.onSurface : const Color(0xFF0F172A);
    final onSurfaceVariantColor = isDark ? KColors.onSurfaceVariant : const Color(0xFF64748B);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: brightness,
        primary: primaryAccent,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        error: KColors.error,
      ).copyWith(
        surfaceContainerHighest: isDark ? KColors.surfaceContainerHighest : const Color(0xFFE2E8F0),
        surfaceContainerHigh: isDark ? KColors.surfaceContainerHigh : const Color(0xFFEDF2F7),
        surfaceContainer: isDark ? KColors.surfaceContainer : const Color(0xFFF1F5F9),
        surfaceContainerLow: isDark ? KColors.surfaceContainerLow : const Color(0xFFF8FAFC),
        surfaceContainerLowest: isDark ? KColors.surfaceContainerLowest : const Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: surfaceColor,
      textTheme: pjs.apply(
        bodyColor: onSurfaceColor,
        displayColor: onSurfaceColor,
      ).copyWith(
        displayLarge: pjs.displayLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: onSurfaceColor,
          letterSpacing: -1.5,
        ),
        headlineLarge: pjs.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: onSurfaceColor,
          letterSpacing: -0.5,
        ),
        headlineMedium: pjs.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: onSurfaceColor,
        ),
        titleMedium: pjs.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        bodyMedium: pjs.bodyMedium?.copyWith(
          color: onSurfaceVariantColor,
        ),
        labelSmall: pjs.labelSmall?.copyWith(
          color: onSurfaceVariantColor,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? KColors.surfaceContainerLow : const Color(0xFFF1F5F9),
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: KRadius.lgRadius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: KRadius.mdRadius),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? KColors.surfaceContainerLow : Colors.white,
        selectedItemColor: primaryAccent,
        unselectedItemColor: const Color(0xFF94A3B8),
      ),
    );
  }
}
