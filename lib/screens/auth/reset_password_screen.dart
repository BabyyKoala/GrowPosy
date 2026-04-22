import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void handleReset() async {
    final email = emailController.text.trim();

    // ==========================
    // 🔥 VALIDASI EMAIL
    // ==========================
    if (email.isEmpty) {
      showMessage("Email wajib diisi");
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      showMessage("Format email tidak valid");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Memanggil fungsi dari AuthService yang memicu Firebase sendPasswordResetEmail
      await _authService.resetPassword(email);

      if (!mounted) return;

      showSuccessDialog();
    } catch (e) {
      showMessage(e.toString().replaceAll("Exception: ", ""));
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================
  // 🔥 UI FEEDBACK
  // ==========================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColor.errorRed),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus menekan tombol OK
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColor.primaryGreen,
              size: 28,
            ),
            SizedBox(width: 8),
            Text("Berhasil", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Link reset password telah dikirim ke email Anda.\n\nSilakan cek kotak masuk (inbox) atau folder spam untuk membuat password baru.",
          style: TextStyle(color: AppColor.textBlack, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke halaman Login
            },
            child: const Text(
              "Kembali ke Login",
              style: TextStyle(
                color: AppColor.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // 🔥 TAMPILAN UI (REFACTORED)
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 🔥 HEADER
              const Text("Lupa Password?", style: AppTextStyle.heading1),
              const SizedBox(height: 8),
              const Text(
                "Masukkan alamat email yang terdaftar pada akun GrowPosy Anda. Kami akan mengirimkan instruksi untuk mengatur ulang password.",
                style: AppTextStyle.bodyText,
              ),
              const SizedBox(height: 40),

              // 🔥 INPUT EMAIL
              const Text("Alamat Email", style: AppTextStyle.inputLabel),
              const SizedBox(height: 8),
              CustomTextField(
                controller: emailController,
                hintText: "Contoh: nama@email.com",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 40),

              // 🔥 TOMBOL KIRIM
              CustomButton(
                text: "Kirim Email Reset",
                onPressed: handleReset,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
