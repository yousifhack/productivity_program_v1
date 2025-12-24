import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const radius = 18.0;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Correct type for current Flutter: CardThemeData
      cardTheme: const CardThemeData(
        elevation: 1.5,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),

      // Avoid deprecated withOpacity() by using withAlpha
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E3A8A),
        surface: Colors.white,
      ),
    );
  }
}
