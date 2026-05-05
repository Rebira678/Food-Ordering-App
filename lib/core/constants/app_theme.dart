import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          surface: AppColors.lightCard,
          background: AppColors.lightBackground,
          onPrimary: AppColors.white,
          onBackground: AppColors.lightText,
          onSurface: AppColors.lightText,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        cardColor: AppColors.lightCard,
        textTheme: _buildTextTheme(AppColors.lightText),
        inputDecorationTheme: _inputDecoration(AppColors.lightCard, AppColors.lightIcon),
        elevatedButtonTheme: _buttonTheme(),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.lightCard,
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.lightText),
          titleTextStyle: GoogleFonts.outfit(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          surface: AppColors.darkCard,
          background: AppColors.darkBackground,
          onPrimary: AppColors.white,
          onBackground: AppColors.darkText,
          onSurface: AppColors.darkText,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCard,
        textTheme: _buildTextTheme(AppColors.darkText),
        inputDecorationTheme: _inputDecoration(AppColors.darkCard, AppColors.darkIcon),
        elevatedButtonTheme: _buttonTheme(),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkCard,
          labelTextStyle: MaterialStateProperty.all(
            GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.darkText),
          titleTextStyle: GoogleFonts.outfit(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  static TextTheme _buildTextTheme(Color color) => TextTheme(
        displayLarge: GoogleFonts.outfit(
            fontSize: 40, fontWeight: FontWeight.w900, color: color),
        headlineLarge: GoogleFonts.outfit(
            fontSize: 32, fontWeight: FontWeight.w800, color: color),
        headlineMedium: GoogleFonts.outfit(
            fontSize: 26, fontWeight: FontWeight.w800, color: color),
        titleLarge: GoogleFonts.outfit(
            fontSize: 22, fontWeight: FontWeight.w800, color: color),
        titleMedium: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w700, color: color),
        titleSmall: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w600, color: color),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w400, color: color),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: color),
        bodySmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w400,
            color: color.withOpacity(0.7)),
        labelLarge: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w700, color: color),
      );

  static InputDecorationTheme _inputDecoration(Color fill, Color hint) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        hintStyle: TextStyle(color: hint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  static ElevatedButtonThemeData _buttonTheme() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      );
}
