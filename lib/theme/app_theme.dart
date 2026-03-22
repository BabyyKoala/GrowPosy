import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  );
}
