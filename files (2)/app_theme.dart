import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlodoTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceElevated = Color(0xFF1A1A26);
  static const Color border = Color(0xFF252535);
  static const Color borderBright = Color(0xFF353550);

  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonCyan = Color(0xFF06B6D4);
  static const Color neonGreen = Color(0xFF10B981);
  static const Color neonAmber = Color(0xFFF59E0B);
  static const Color neonRose = Color(0xFFF43F5E);

  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF8888A8);
  static const Color textMuted = Color(0xFF55556A);

  // Status colors
  static const Color statusTodo = Color(0xFF8888A8);
  static const Color statusInProgress = neonAmber;
  static const Color statusDone = neonGreen;

  // ── Status helpers ────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status) {
      case 'In Progress':
        return statusInProgress;
      case 'Done':
        return statusDone;
      default:
        return statusTodo;
    }
  }

  static IconData statusIcon(String status) {
    switch (status) {
      case 'In Progress':
        return Icons.autorenew_rounded;
      case 'Done':
        return Icons.check_circle_rounded;
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  // ── Typography ────────────────────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.syne(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.syne(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.syne(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.syne(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.dmMono(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textMuted,
          letterSpacing: 0.8,
        ),
      );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: neonPurple,
          secondary: neonCyan,
          surface: surface,
          error: neonRose,
        ),
        textTheme: textTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: neonPurple, width: 1.5),
          ),
          labelStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 13),
          hintStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.syne(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceElevated,
          selectedColor: neonPurple.withOpacity(0.2),
          side: const BorderSide(color: border),
          labelStyle: GoogleFonts.dmSans(fontSize: 12, color: textSecondary),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
}
