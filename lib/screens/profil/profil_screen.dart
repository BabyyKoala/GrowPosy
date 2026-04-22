import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

// 🔥 Import Tema Global
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // ==========================================
  // LOGIKA LOGOUT
  // ==========================================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Sesi Anda akan diakhiri dan kembali ke halaman Login.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: AppColor.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Tutup dialog dulu
              Navigator.pop(context);

              // 2. Tampilkan loading sebentar (opsional tapi bagus untuk UX)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Sedang mengeluarkan akun..."),
                  duration: Duration(seconds: 1),
                ),
              );

              // 3. Proses Logout
              await AuthService().logout();
              if (!mounted) return;

              // 4. Arahkan ke halaman utama/login
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FEEDBACK UNTUK MENU YANG BELUM ADA HALAMANNYA
  // ==========================================
  void _handleMenuClick(String menuName) {
    // TODO: Ganti Navigator.push jika halaman sudah kamu buat.
    // Sementara ini, kita beri feedback Snackbar agar tombol tidak terkesan "mati"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Membuka menu $menuName..."),
        backgroundColor: AppColor.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Mengambil nama, jika kosong fallback ke "Pengguna GrowPosy"
    final String displayName = user?.displayName ?? "Pengguna GrowPosy";
    final String displayEmail = user?.email ?? "Email tidak tersedia";

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 120, // Padding bawah untuk Floating Navbar
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔥 AVATAR & INFO AKUN
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.primaryGreen,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColor.primaryGreen.withOpacity(0.1),
                      // 🔥 Menggunakan Icon sebagai fallback yang aman agar aplikasi tidak crash
                      // jika file 'assets/images/avatar_ibu.png' belum ada di folder.
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: AppColor.primaryGreen,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleMenuClick("Ubah Foto Profil"),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔥 NAMA & EMAIL PENGGUNA
              Text(
                displayName,
                style: AppTextStyle.heading1.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(displayEmail, style: AppTextStyle.bodyText),

              const SizedBox(height: 40),

              // 🔥 MENU PENGATURAN
              _buildProfileMenu(
                Icons.person_outline_rounded,
                "Informasi Pribadi",
                () => _handleMenuClick("Informasi Pribadi"),
              ),
              _buildProfileMenu(
                Icons.notifications_active_outlined,
                "Pengaturan Notifikasi",
                () => _handleMenuClick("Pengaturan Notifikasi"),
              ),
              _buildProfileMenu(
                Icons.security_outlined,
                "Keamanan & Kata Sandi",
                () => _handleMenuClick("Keamanan & Kata Sandi"),
              ),
              _buildProfileMenu(
                Icons.help_outline_rounded,
                "Pusat Bantuan",
                () => _handleMenuClick("Pusat Bantuan"),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: AppColor.borderGrey),
              ),

              // 🔥 TOMBOL LOGOUT UTAMA
              ListTile(
                onTap: _showLogoutDialog,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColor.errorRed,
                  ),
                ),
                title: const Text(
                  "Keluar Akun",
                  style: TextStyle(
                    color: AppColor.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET BANTUAN UNTUK MENU
  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.bgWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.borderGrey),
          ),
          child: Icon(icon, color: AppColor.textBlack),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColor.textBlack,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColor.textGrey,
        ),
        onTap: onTap,
      ),
    );
  }
}
