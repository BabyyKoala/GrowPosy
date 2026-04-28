import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTextStyle {
  // 🏷️ Brand & Identitas
  static const TextStyle brandText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: AppColor.primaryGreen,
    letterSpacing: 0.5,
  );

  // 📰 Hierarki Judul (Headings)
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColor.textBlack,
    letterSpacing: -0.5, // Rapat agar lebih modern
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColor.textBlack,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColor.textBlack,
  );

  // 📝 Teks Paragraf (Body)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColor.textBlack,
    height: 1.5,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColor.textGrey,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColor.textGrey,
    height: 1.4,
  );

  // 🎛️ Elemen UI (Label, Button, Caption)
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600, // Semi-bold lebih bersih dari Bold murni
    color: AppColor.textBlack,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColor.textLightGrey,
    fontWeight: FontWeight.w500,
  );
}
