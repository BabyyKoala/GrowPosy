import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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
      await _authService.resetPassword(email);

      if (!mounted) return;

      showSuccessDialog();
    } catch (e) {
      showMessage(e.toString());
    }

    setState(() => isLoading = false);
  }

  // ==========================
  // 🔥 UI FEEDBACK
  // ==========================
  void showMessage(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Berhasil"),
        content: const Text(
          "Link reset password sudah dikirim ke email.\n\nSilakan cek inbox atau folder spam.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back ke login
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ==========================
  // 🔥 UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              "Masukkan email untuk reset password",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleReset,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Kirim Email Reset"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
