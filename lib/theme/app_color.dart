import 'package:flutter/material.dart';

class AppColor {
  // 🟢 Warna Utama (Brand Identity)
  static const Color primaryGreen = Color(0xFF00D15A);
  static const Color primaryDark = Color(0xFF00A045);
  static const Color primaryLight = Color(
    0xFFE5F9ED,
  ); // Cocok untuk background card aktif

  // ⚪ Warna Netral / Permukaan
  static const Color bgWhite = Colors.white;
  static const Color surfaceWhite = Color(
    0xFFFAFAFA,
  ); // Sedikit abu untuk efek depth
  static const Color scaffoldBg = Color(0xFFF8F9FA);

  // ⚫ Warna Teks & Border (Monochrome)
  static const Color textBlack = Color(
    0xFF1E293B,
  ); // Slate-800, lebih lembut dari pure black
  static const Color textGrey = Color(0xFF64748B); // Slate-500
  static const Color textLightGrey = Color(0xFF94A3B8); // Slate-400
  static const Color borderGrey = Color(0xFFE2E8F0); // Slate-200
  static const Color dividerGrey = Color(0xFFF1F5F9); // Slate-100

  // 🔴🟡🔵 Warna Status (Feedback)
  static const Color errorRed = Color(0xFFEF4444); // Red-500
  static const Color errorLight = Color(0xFFFEE2E2); // Red-100
  static const Color warningOrange = Color(0xFFF59E0B); // Amber-500
  static const Color infoBlue = Color(0xFF3B82F6); // Blue-500
  static const Color successGreen = Color(0xFF10B981); // Emerald-500
}
