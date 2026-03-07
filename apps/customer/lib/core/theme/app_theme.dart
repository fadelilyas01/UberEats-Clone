import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Color Palette
class AppColors {
  // Primary
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);

  // Secondary (Success)
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);

  // Accent (Warning)
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);

  // Error
  static const error = Color(0xFFEF4444);

  // Backgrounds
  static const background = Color(0xFF0A0E1A);
  static const backgroundLight = Color(0xFF0F1629);
  static const surface = Color(0xFF141B2D);
  static const surfaceLight = Color(0xFF1A2235);
  static const card = Color(0xFF1C2438);
  static const cardHover = Color(0xFF232D45);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFADB5C6);
  static const textMuted = Color(0xFF64748B);

  // Gradients
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSecondary = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientAccent = LinearGradient(
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientOrange = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBlue = LinearGradient(
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App Theme Configuration
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.background,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
          displayMedium: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
          displaySmall: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
          headlineMedium: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          titleLarge: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
          titleMedium: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
          bodyLarge:
              GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
          bodyMedium:
              GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          bodySmall:
              GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0x0DFFFFFF))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.card,
          elevation: 0,
        ),
      );
}

/// Responsive Breakpoints
class Responsive {
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static T value<T>(BuildContext context,
      {required T phone, T? tablet, T? desktop}) {
    if (isDesktop(context)) return desktop ?? tablet ?? phone;
    if (isTablet(context)) return tablet ?? phone;
    return phone;
  }
}
