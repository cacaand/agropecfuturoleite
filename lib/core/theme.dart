import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand green
  static const green900 = Color(0xFF0D3B20);
  static const green800 = Color(0xFF145228);
  static const green700 = Color(0xFF1A6B34);
  static const green600 = Color(0xFF228842);
  static const green500 = Color(0xFF2AA653);
  static const green400 = Color(0xFF48C272);
  static const green100 = Color(0xFFD4F5E2);
  static const green50  = Color(0xFFEAF9F0);

  // Amber
  static const amber700 = Color(0xFF92520A);
  static const amber500 = Color(0xFFB87212);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber50  = Color(0xFFFFFBEB);

  // Red
  static const red600  = Color(0xFFDC2626);
  static const red100  = Color(0xFFFEE2E2);
  static const red50   = Color(0xFFFEF2F2);

  // Blue
  static const blue600 = Color(0xFF1D6FA4);
  static const blue100 = Color(0xFFDBEAFA);
  static const blue50  = Color(0xFFEFF6FF);

  // Purple
  static const purple600 = Color(0xFF6D28D9);
  static const purple100 = Color(0xFFEDE9FE);

  // Neutral
  static const gray900 = Color(0xFF111827);
  static const gray800 = Color(0xFF1F2937);
  static const gray700 = Color(0xFF374151);
  static const gray600 = Color(0xFF4B5563);
  static const gray500 = Color(0xFF6B7280);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray50  = Color(0xFFF9FAFB);
  static const white   = Color(0xFFFFFFFF);

  // Sidebar
  static const sidebar  = Color(0xFF0F2419);
  static const sidebarH = Color(0xFF1A3D28);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green700,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.gray50,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gray200, width: 0.5),
        ),
        color: AppColors.white,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.gray900, fontSize: 18, fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppColors.gray700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.green600, width: 1.5),
        ),
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.gray500),
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green700,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.green700),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.green700,
        labelStyle: GoogleFonts.inter(fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.gray200, space: 0),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.sidebar,
        indicatorColor: AppColors.green700,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, color: Colors.white70),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green500,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B1A12),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF1E3A2A), width: 0.5),
        ),
        color: const Color(0xFF0F2318),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
