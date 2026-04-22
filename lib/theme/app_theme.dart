import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      primaryColor: AppColor.primaryGreen,
      scaffoldBackgroundColor: AppColor.bgWhite,
      fontFamily: 'Roboto', // Ganti jika kamu pakai font khusus di pubspec
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.textBlack),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primaryGreen,
        primary: AppColor.primaryGreen,
      ),
    );
  }
}
