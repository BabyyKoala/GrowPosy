import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTextStyle {
  // Gunakan untuk Judul Halaman (Welcome, Register, dll)
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColor.textBlack,
  );

  // Gunakan untuk Nama Aplikasi / Logo Text
  static const TextStyle brandText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColor.primaryGreen,
    letterSpacing: 0.5,
  );

  // Gunakan untuk Teks Deskripsi / Sub-judul
  static const TextStyle bodyText = TextStyle(
    fontSize: 15,
    color: AppColor.textGrey,
    height: 1.5,
  );

  // Gunakan untuk Label Input Field (Email, Password)
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColor.textBlack,
  );
}
