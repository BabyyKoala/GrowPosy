import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final codeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  // 🔥 Warna Sinkron dengan Login
  final Color primaryGreen = const Color(0xFF00D15A);

  void onVerifyPressed() async {
    if (codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan kode terlebih dahulu")),
      );
      return;
    }

    setState(() => isLoading = true);

    // 🔥 Memanggil fungsi yang sudah kita buat di AuthService
    bool success = await _authService.verifyInviteCode(codeController.text);

    setState(() => isLoading = false);

    if (success) {
      // Jika sukses, cek role-nya apa untuk menentukan arah Home
      final role = await _authService.getRole();
      if (mounted) {
        if (role == 'kader') {
          Navigator.pushReplacementNamed(context, '/home_kader');
        } else {
          Navigator.pushReplacementNamed(context, '/home_ibu');
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kode tidak valid atau sudah digunakan"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Verifikasi Kode", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Masukkan kode undangan yang diberikan oleh petugas Posyandu.", 
                 style: TextStyle(color: Colors.grey[600], fontSize: 15)),
            const SizedBox(height: 40),
            
            // Input Kode
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: "Contoh: KADER-SIAGA",
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Tombol Verifikasi
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onVerifyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verifikasi Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}