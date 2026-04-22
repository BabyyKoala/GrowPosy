import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final codeController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();

  bool isLoading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA VERIFIKASI KODE
  // ==========================
  void onVerifyPressed() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan masukkan kode terlebih dahulu"),
          backgroundColor: AppColor.errorRed,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null)
        throw Exception("Sesi tidak valid, silakan login ulang.");

      // 1. Cek ke validan kode di Firestore
      bool isValid = await _firestore.verifyInviteCode(code);

      if (!isValid) {
        throw Exception(
          "Kode tidak valid atau sudah digunakan oleh Kader lain.",
        );
      }

      // 2. Tandai kode terpakai dan set role Kader ke akun ini
      await _firestore.useInviteCode(code, uid);
      await _firestore.setUserRole('kader');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verifikasi berhasil! Selamat datang, Kader."),
          backgroundColor: AppColor.primaryGreen,
        ),
      );

      // 3. Arahkan ke Dashboard Kader
      Navigator.pushReplacementNamed(context, '/home_kader');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: AppColor.errorRed,
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================
  // 🎨 TAMPILAN UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 ILUSTRASI ICON
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 48,
                  color: AppColor.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),

              // 🔥 HEADER TEKS
              const Text("Verifikasi Kode", style: AppTextStyle.heading1),
              const SizedBox(height: 8),
              const Text(
                "Masukkan kode undangan yang diberikan oleh Kepala Puskesmas untuk mengakses dashboard Kader.",
                style: AppTextStyle.bodyText,
              ),
              const SizedBox(height: 40),

              // 🔥 INPUT KODE
              const Text("Kode Akses", style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              CustomTextField(
                controller: codeController,
                hintText: "Contoh: KADER-SIAGA-2026",
                prefixIcon: Icons.vpn_key_outlined,
              ),

              const SizedBox(height: 40),

              // 🔥 TOMBOL VERIFIKASI
              CustomButton(
                text: "Verifikasi Sekarang",
                onPressed: onVerifyPressed,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
