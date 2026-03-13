/// ============================================================
/// theme.dart — "Dark Industrial Glassmorphism" Design System
/// ============================================================
///
/// Defines the complete [ThemeData] consumed by [MaterialApp].
/// Uses [GoogleFonts.jetBrainsMono] for every text style to
/// achieve the technical, data-driven aesthetic described in the
/// design spec.  All colours are derived from [constants.dart].
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Convenience colour constants derived from hex values so they
/// can be used anywhere without constructing new [Color] objects.
class AppColors {
  AppColors._(); // non-instantiable

  static const Color background = Color(kBackgroundHex);
  static const Color surface = Color(kSurfaceHex);
  static const Color primary = Color(kPrimaryAccentHex);
  static const Color alertGreen = Color(kAlertGreenHex);
  static const Color alertRed = Color(kAlertRedHex);
  static const Color textPrimary = Color(kTextPrimaryHex);
  static const Color textSecondary = Color(kTextSecondaryHex);
  static const Color terminalBg = Color(kTerminalBgHex);
  static const Color terminalText = Color(kTerminalTextHex);
}

/// Builds and returns the dark industrial theme used app-wide.
///
/// The theme forces [Brightness.dark] and replaces every default
/// text style with JetBrains Mono so the UI feels like a real
/// control-room terminal.
ThemeData buildAppTheme() {
  // Base text theme using JetBrains Mono
  final textTheme = GoogleFonts.jetBrainsMonoTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,

    // ---------- Colour Scheme ----------
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.alertGreen,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.alertRed,
    ),

    // ---------- Typography ----------
    textTheme: textTheme,
    fontFamily: GoogleFonts.jetBrainsMono().fontFamily,

    // ---------- AppBar ----------
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    ),

    // ---------- Card / Surface ----------
    cardTheme: CardThemeData(
      color: AppColors.surface.withAlpha(200),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary.withAlpha(40),
        ),
      ),
    ),

    // ---------- Icon ----------
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 20,
    ),

    // ---------- Divider ----------
    dividerTheme: DividerThemeData(
      color: AppColors.primary.withAlpha(30),
      thickness: 1,
    ),

    // ---------- Switch ----------
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withAlpha(80);
        }
        return AppColors.surface;
      }),
    ),
  );
}
