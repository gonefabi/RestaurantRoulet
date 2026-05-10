import 'package:flutter/material.dart';

/// Zentrale Theme-Definition. Wird von [RestaurantRouletteApp] gesetzt.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF007BFF);
  static const Color accent = Color(0xFFFFA500);
  static const Color background = Color(0xFFF5F5F7);
  static const Color text = Color(0xFF212121);
  static const Color card = Colors.white;

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: card,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary,
        thumbColor: primary,
      ),
    );
  }
}
