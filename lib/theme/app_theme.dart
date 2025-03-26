// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
// import 'package:asffar_agency_app/theme/app_colors.dart';
// import 'package:asffar_agency_app/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Tajawal',
        ) ?? TextStyle(), // Fallback to an empty TextStyle if null
      ),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF009EE2),
        secondary: Color(0xFFF9D36E),
        background: Color(0xFF313131),
      ),
    );
  }
}