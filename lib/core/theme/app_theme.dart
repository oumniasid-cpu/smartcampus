import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Colors extracted from your palette image ──────────────────────────────
  static const _primaryColor   = Color(0xFF00193B); // Deep Navy
  static const _secondaryColor = Color(0xFF0061D4); // Vibrant Blue
  static const _tertiaryColor  = Color(0xFFDCAE32); // Gold/Tertiary
  static const _neutralColor   = Color(0xFFF8F9FA); // Off-white Background
  static const _fieldBg        = Colors.white;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _neutralColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor,
          surface: _neutralColor,
          brightness: Brightness.light,
        ),
        
        appBarTheme: const AppBarTheme(
          centerTitle: true, 
          elevation: 0,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
        
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        
        // ── Forced White Input Theme ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _fieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _secondaryColor, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
          labelStyle: const TextStyle(color: _primaryColor),
        ),

        // Text Button color (Forgot Password, etc.)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _secondaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          secondary: _secondaryColor,
          tertiary: _tertiaryColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade800),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}