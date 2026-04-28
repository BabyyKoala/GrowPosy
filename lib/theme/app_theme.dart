import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_text_style.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true, // Mengaktifkan desain Material 3 modern
      primaryColor: AppColor.primaryGreen,
      scaffoldBackgroundColor: AppColor.scaffoldBg,
      fontFamily:
          'Inter', // Rekomendasi: Gunakan font modern seperti 'Inter' atau 'Poppins'
      // 🎨 Pengaturan Warna Utama
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primaryGreen,
        primary: AppColor.primaryGreen,
        secondary: AppColor.infoBlue,
        error: AppColor.errorRed,
        surface: AppColor.bgWhite,
        background: AppColor.scaffoldBg,
      ),

      // 🔝 Pengaturan AppBar Global
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        scrolledUnderElevation:
            0, // Mencegah warna AppBar berubah saat discroll
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColor.textBlack),
        titleTextStyle:
            AppTextStyle.heading3, // Menggunakan gaya teks yang sudah dibuat
      ),

      // 🔘 Pengaturan Tombol (ElevatedButton) Global
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryGreen,
          foregroundColor: Colors.white, // Warna teks tombol
          elevation: 0, // Desain flat modern
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: AppTextStyle.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
        ),
      ),

      // ⚪ Pengaturan Tombol Tepi (OutlinedButton) Global
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColor.primaryGreen,
          side: const BorderSide(color: AppColor.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: AppTextStyle.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // 📝 Pengaturan Input Form (TextField) Global
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.surfaceWhite, // Warna abu sangat terang
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        hintStyle: AppTextStyle.bodyText.copyWith(
          color: AppColor.textLightGrey,
        ),
        labelStyle: AppTextStyle.inputLabel,

        // Border normal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColor.borderGrey, width: 1),
        ),
        // Border saat form aktif/fokus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.primaryGreen,
            width: 1.5,
          ),
        ),
        // Border saat error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColor.errorRed, width: 1),
        ),
      ),
    );
  }
}
