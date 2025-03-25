import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFE5E5E5), // Full white background
  // Additional surface controls
  cardColor: Color(0xFFE5E5E5),
  canvasColor: Color(0xFFE5E5E5),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFFE5E5E5),
  ),

  // AppBar (just in case you use one globally)
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFE5E5E5),
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    titleTextStyle: GoogleFonts.raleway(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),

  // Text Styles
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.raleway(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white, // for dark headers
    ),
    headlineMedium: GoogleFonts.raleway(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleMedium: GoogleFonts.raleway(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.black),
    bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.black),
    bodySmall: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
  ),

  // Icon
  iconTheme: const IconThemeData(color: Colors.grey),

  // Input Fields (optional: set fill to white if greyish tone bothers you)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFE5E5E5), // ← changed from grey.shade200 to white
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: GoogleFonts.inter(color: Colors.grey),
  ),

  // Color Scheme override
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.white,
    surface: Colors.white,
    brightness: Brightness.light,
  ).copyWith(primary: Colors.black, secondary: Colors.grey),
);
