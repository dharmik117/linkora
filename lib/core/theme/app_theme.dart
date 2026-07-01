import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Funky GenZ Colors
  static const Color primaryBackground = Color(0xFF0D0D0D); // Deep dark
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color accentNeonGreen = Color(0xFF00FF66);
  static const Color accentElectricOrange = Color(0xFFFF5E00);
  static const Color accentSoftPurple = Color(0xFF9D84FF);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryBackground,
      primaryColor: accentNeonGreen,
      colorScheme: const ColorScheme.dark(
        primary: accentNeonGreen,
        secondary: accentElectricOrange,
        surface: surfaceColor,
        background: primaryBackground,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: accentNeonGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentNeonGreen,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
