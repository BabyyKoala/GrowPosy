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

  // State untuk Notifikasi (Simulasi lokal)
  bool isJadwalNotifOn = true;
  bool isArtikelNotifOn = false;

  // ==========================================
  // 1. FITUR INFORMASI PRIBADI (UBAH NAMA FIREBASE)
  // ==========================================
  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: user?.displayName ?? "",
    );
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Ubah Nama Profil",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Masukkan nama baru...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
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
                onPressed: isSaving
                    ? null
                    : () async {
                        if (nameController.text.trim().isEmpty) return;
                        setStateDialog(() => isSaving = true);

                        try {
                          // 🔥 Update nama langsung ke Firebase Auth
                          await user?.updateDisplayName(
                            nameController.text.trim(),
                          );
                          await user?.reload();

                          if (!mounted) return;
                          setState(() {}); // Refresh UI layar Profil
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Nama profil berhasil diperbarui!"),
                              backgroundColor: AppColor.primaryGreen,
                            ),
                          );
                        } catch (e) {
                          setStateDialog(() => isSaving = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 2. FITUR PENGATURAN NOTIFIKASI
  // ==========================================
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pengaturan Notifikasi",
                    style: AppTextStyle.heading1,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    activeColor: AppColor.primaryGreen,
                    title: const Text(
                      "Jadwal Posyandu",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Pengingat H-1 kegiatan Posyandu",
                      style: TextStyle(fontSize: 12),
                    ),
                    value: isJadwalNotifOn,
                    onChanged: (bool value) {
                      setModalState(() => isJadwalNotifOn = value);
                      setState(() => isJadwalNotifOn = value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    activeColor: AppColor.primaryGreen,
                    title: const Text(
                      "Artikel Edukasi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Info kesehatan & MPASI mingguan",
                      style: TextStyle(fontSize: 12),
                    ),
                    value: isArtikelNotifOn,
                    onChanged: (bool value) {
                      setModalState(() => isArtikelNotifOn = value);
                      setState(() => isArtikelNotifOn = value);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 3. FITUR KEAMANAN (RESET PASSWORD FIREBASE)
  // ==========================================
  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Ubah Kata Sandi?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Kami akan mengirimkan link untuk mereset kata sandi ke email Anda. Lanjutkan?",
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
              Navigator.pop(context); // Tutup dialog
              try {
                if (user?.email != null) {
                  // 🔥 Kirim link reset password nyata dari Firebase
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: user!.email!,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Link reset kata sandi telah dikirim ke email Anda!",
                      ),
                      backgroundColor: Colors.indigo,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal mengirim email: $e"),
                    backgroundColor: AppColor.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Kirim Link",
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
  // 4. FITUR PUSAT BANTUAN (FAQ)
  // ==========================================
  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6, // Setengah layar
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pusat Bantuan", style: AppTextStyle.heading1),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    ExpansionTile(
                      title: Text(
                        "Bagaimana cara menambah data anak?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Buka tab Beranda, geser menu profil anak ke kanan, lalu klik tombol 'Tambah'.",
                            style: TextStyle(color: AppColor.textGrey),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        "Kenapa grafik KMS kosong?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Grafik KMS akan terisi otomatis setelah Kader memasukkan data penimbangan bulan ini di aplikasi mereka.",
                            style: TextStyle(color: AppColor.textGrey),
                          ),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Text(
                        "Hubungi Admin Posyandu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            "Jika ada kendala aplikasi, silakan hubungi Bidan atau Admin Posyandu di desa Anda.",
                            style: TextStyle(color: AppColor.textGrey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Sedang mengeluarkan akun..."),
                  duration: Duration(seconds: 1),
                ),
              );
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
    final String displayName =
        user?.displayName != null && user!.displayName!.isNotEmpty
        ? user!.displayName!
        : "Pengguna GrowPosy";
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
            bottom: 120,
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
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: AppColor.primaryGreen,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
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

              // 🔥 MENU PENGATURAN (SUDAH DIHUBUNGKAN KE FUNGSI NYATA)
              _buildProfileMenu(
                Icons.person_outline_rounded,
                "Informasi Pribadi",
                _showEditProfileDialog,
              ),
              _buildProfileMenu(
                Icons.notifications_active_outlined,
                "Pengaturan Notifikasi",
                _showNotificationSettings,
              ),
              _buildProfileMenu(
                Icons.security_outlined,
                "Keamanan & Kata Sandi",
                _showSecurityDialog,
              ),
              _buildProfileMenu(
                Icons.help_outline_rounded,
                "Pusat Bantuan",
                _showHelpCenter,
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
