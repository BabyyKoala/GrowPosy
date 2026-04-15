import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final FirestoreService firestore = FirestoreService();
  final codeController = TextEditingController();
  bool isLoading = false;

  final Color primaryGreen = const Color(0xFF00D15A);

  // 🔥 LOGIKA BACKEND (Tetap sama, hanya tambah UI Feedback)
  Future<void> selectIbu() async {
    setState(() => isLoading = true);
    await firestore.setUserRole('ibu');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home_ibu');
  }

  Future<void> selectKader() async {
    final code = codeController.text.trim().toUpperCase(); // Tambahkan Uppercase otomatis

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode wajib diisi untuk Kader"))
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final isValid = await firestore.verifyInviteCode(code);
      if (!isValid) {
        setState(() => isLoading = false);
        _showErrorSnackBar("Kode tidak valid atau sudah digunakan");
        return;
      }

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await firestore.setUserRole('kader');
      await firestore.useInviteCode(code, uid);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home_kader');
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("Terjadi kesalahan koneksi");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Pilih Peran Anda",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 10),
              Text(
                "Sesuaikan akses aplikasi dengan posisi Anda di Posyandu.",
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // 🏥 CARD UNTUK IBU
              _buildRoleCard(
                title: "Ibu / Orang Tua",
                subtitle: "Pantau tumbuh kembang anak Anda secara rutin.",
                icon: Icons.family_restroom_rounded,
                color: primaryGreen,
                onTap: isLoading ? null : selectIbu,
              ),

              const SizedBox(height: 20),

              // 🛡️ CARD UNTUK KADER
              _buildRoleCard(
                title: "Kader Posyandu",
                subtitle: "Kelola data balita dan buat laporan wilayah.",
                icon: Icons.admin_panel_settings_rounded,
                color: Colors.blue,
                onTap: isLoading ? null : _showKaderCodeDialog, // Klik ini muncul dialog kode
              ),
              
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 WIDGET: CARD ROLE MODERN
  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // 🔥 DIALOG INPUT KODE (Biar Tampilan Bersih)
  void _showKaderCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Verifikasi Kader"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan kode khusus untuk mengaktifkan fitur Kader.", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Contoh: KADER-SIAGA",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              selectKader();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text("Verifikasi"),
          ),
        ],
      ),
    );
  }
}