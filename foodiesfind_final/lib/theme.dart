import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFF1F1F1),
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.raleway(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
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
  iconTheme: const IconThemeData(color: Colors.grey),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade200,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: GoogleFonts.inter(color: Colors.grey),
  ),
);
