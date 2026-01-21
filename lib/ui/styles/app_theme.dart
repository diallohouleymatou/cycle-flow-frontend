import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // 🎨 Color Palette (WCAG AA Compliant)
  // ---------------------------------------------------------------------------

  // Brand Colors
  static const Color primaryBrand = Color(0xFF523D90);
  static const Color primaryBrandLight = Color(0xFF6750A4);
  static const Color secondaryBrand = Color(0xFF4A4458);
  static const Color tertiaryBrand = Color(0xFF633B48);

  // Neutral Surfaces
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F7);
  static const Color textMain = Color(0xFF121212);
  static const Color textSub = Color(0xFF424242);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Semantic Colors
  static const Color surfacePeriod = Color(0xFFFFEBEE);
  static const Color accentPeriod = Color(0xFFD32F2F);
  static const Color surfaceFollicular = Color(0xFFE0F2F1);
  static const Color accentFollicular = Color(0xFF00796B);
  static const Color surfaceOvulation = Color(0xFFFFFDE7);
  static const Color accentOvulation = Color(0xFFF57F17);
  static const Color surfaceLuteal = Color(0xFFF3E5F5);
  static const Color accentLuteal = Color(0xFF7B1FA2);

  // Dark Palette (Improved for Contrast)
  static const Color backgroundDark = Color(0xFF121212); // True Black/Dark Grey
  static const Color surfaceDark = Color(0xFF2C2C2C); // Lighter grey for Cards
  static const Color surfaceDarkElevated = Color(0xFF383838); // Even lighter for modals
  
  static const Color primaryDark = Color(0xFFD0BCFF);
  static const Color textMainDark = Color(0xFFF2F2F2); // Off-white
  static const Color textSubDark = Color(0xFFC7C7C7); // Light Grey

  // ---------------------------------------------------------------------------
  // 🔤 Typography
  // ---------------------------------------------------------------------------

  static TextTheme _textTheme(TextTheme base, Color mainColor, Color subColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.nunito(fontSize: 57, fontWeight: FontWeight.w800, color: mainColor, height: 1.1),
      displayMedium: GoogleFonts.nunito(fontSize: 45, fontWeight: FontWeight.w800, color: mainColor, height: 1.1),
      displaySmall: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.bold, color: mainColor, height: 1.2),
      
      headlineLarge: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.bold, color: mainColor, height: 1.2),
      headlineMedium: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold, color: mainColor, height: 1.2),
      headlineSmall: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor, height: 1.3),

      titleLarge: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w700, color: mainColor),
      titleMedium: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: mainColor, letterSpacing: 0.1),
      titleSmall: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: mainColor, letterSpacing: 0.1),

      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, color: mainColor, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: mainColor, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: subColor, height: 1.5),

      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: mainColor),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: mainColor),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: subColor, letterSpacing: 0.5),
    );
  }

  // ---------------------------------------------------------------------------
  // 🎭 Theme Definitions
  // ---------------------------------------------------------------------------

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryBrand,
      secondary: secondaryBrand,
      tertiary: tertiaryBrand,
      surface: backgroundLight,
      surfaceTint: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textMain,
      outline: dividerColor,
    ),
    scaffoldBackgroundColor: backgroundLight,
    dividerColor: dividerColor,
    textTheme: _textTheme(ThemeData.light().textTheme, textMain, textSub),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
      iconTheme: IconThemeData(color: textMain),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    iconTheme: const IconThemeData(color: textMain),

    // ... (rest of light theme inputs/buttons same as before) ...
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryBrand, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: textSub, fontFamily: 'Inter', fontSize: 16),
      hintStyle: TextStyle(color: textSub.withOpacity(0.7), fontFamily: 'Inter'),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      secondary: secondaryBrand,
      tertiary: tertiaryBrand,
      surface: surfaceDark, // Uses the Lighter Grey for cards defaults
      background: backgroundDark,
      onPrimary: textMain,
      onSurface: textMainDark,
      outline: Color(0xFF49454F),
    ),
    scaffoldBackgroundColor: backgroundDark,
    dividerColor: const Color(0xFF49454F),

    textTheme: _textTheme(ThemeData.dark().textTheme, textMainDark, textSubDark),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(color: textMainDark, fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
      iconTheme: IconThemeData(color: textMainDark),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF404040), width: 1), // Lighter border for visibility
      ),
      color: surfaceDark, // Explicitly set card color
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDarkElevated, // Slightly lighter than card
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF404040))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF404040))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryDark, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: textSubDark, fontFamily: 'Inter'),
      floatingLabelStyle: TextStyle(color: primaryDark, fontFamily: 'Inter', fontWeight: FontWeight.w600),
    ),

    iconTheme: const IconThemeData(color: primaryDark),
    
    // Fix BottomSheet to match
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      modalBackgroundColor: surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}