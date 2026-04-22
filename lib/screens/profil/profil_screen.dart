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
              await AuthService().logout();
              if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 120,
          ), // Padding bawah untuk Floating Navbar
          child: Column(
            children: [
              // 🔥 AVATAR & INFO AKUN
              const SizedBox(height: 20),
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
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColor.borderGrey,
                      backgroundImage: AssetImage(
                        'assets/images/avatar_ibu.png',
                      ), // Pastikan file ini ada, atau ganti dengan icon
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColor.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Akun Pengguna", style: AppTextStyle.heading1),
              const SizedBox(height: 4),
              Text(
                user?.email ?? "Email tidak tersedia",
                style: AppTextStyle.bodyText,
              ),

              const SizedBox(height: 40),

              // 🔥 MENU PENGATURAN
              _buildProfileMenu(
                Icons.person_outline_rounded,
                "Informasi Pribadi",
                () {},
              ),
              _buildProfileMenu(
                Icons.notifications_active_outlined,
                "Pengaturan Notifikasi",
                () {},
              ),
              _buildProfileMenu(
                Icons.security_outlined,
                "Keamanan & Kata Sandi",
                () {},
              ),
              _buildProfileMenu(
                Icons.help_outline_rounded,
                "Pusat Bantuan",
                () {},
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
