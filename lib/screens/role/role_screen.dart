import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final FirestoreService _firestore = FirestoreService();
  final codeController = TextEditingController();

  String? selectedRole;
  bool isLoading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA PENYIMPANAN ROLE
  // ==========================
  void handleSaveRole() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih peran Anda terlebih dahulu."),
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

      // 🔥 Keamanan: Jika Kader, wajib verifikasi kode terlebih dahulu
      if (selectedRole == 'kader') {
        final code = codeController.text.trim();
        if (code.isEmpty) {
          throw Exception("Kode verifikasi kader wajib diisi.");
        }

        bool isValid = await _firestore.verifyInviteCode(code);
        if (!isValid) {
          throw Exception("Kode kader tidak valid atau sudah digunakan.");
        }

        // Tandai kode sebagai terpakai oleh akun Google ini
        await _firestore.useInviteCode(code, uid);
      }

      // 🔥 Update role di Firestore
      await _firestore.setUserRole(selectedRole!);

      if (!mounted) return;

      // 🔥 Arahkan ke dashboard yang tepat
      if (selectedRole == 'ibu') {
        Navigator.pushReplacementNamed(context, '/home_ibu');
      } else {
        Navigator.pushReplacementNamed(context, '/home_kader');
      }
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
  // 🎨 WIDGET KARTU PILIHAN
  // ==========================
  Widget _buildRoleCard({
    required String roleValue,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    // Mengecek apakah kartu ini sedang dipilih
    final isSelected = selectedRole == roleValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = roleValue;
          // Kosongkan input kode jika user berpindah pilihan
          if (roleValue != 'kader') codeController.clear();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryGreen.withOpacity(0.08)
              : AppColor.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColor.primaryGreen : AppColor.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primaryGreen : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColor.bgWhite : AppColor.textGrey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColor.primaryGreen
                          : AppColor.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColor.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColor.primaryGreen),
          ],
        ),
      ),
    );
  }

  // ==========================
  // 🎨 TAMPILAN UTAMA (UI)
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      48, // Memastikan tombol selalu bisa di bawah
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // 🔥 HEADER
                      const Text(
                        "Satu Langkah Lagi!",
                        style: AppTextStyle.heading1,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Karena Anda masuk menggunakan Google, silakan pilih peran Anda untuk melanjutkan ke aplikasi GrowPosy.",
                        style: AppTextStyle.bodyText,
                      ),
                      const SizedBox(height: 40),

                      // 🔥 KARTU IBU
                      _buildRoleCard(
                        roleValue: 'ibu',
                        title: 'Ibu / Orang Tua',
                        subtitle:
                            'Pantau tumbuh kembang anak Anda dengan mudah.',
                        icon: Icons.child_care,
                      ),

                      const SizedBox(height: 16),

                      // 🔥 KARTU KADER
                      _buildRoleCard(
                        roleValue: 'kader',
                        title: 'Kader Posyandu',
                        subtitle: 'Kelola data anak dan operasional posyandu.',
                        icon: Icons.admin_panel_settings_outlined,
                      ),

                      // 🔥 FORM KODE KADER (Hanya muncul jika Kader dipilih)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: selectedRole == 'kader'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Kode Verifikasi Kader",
                                      style: AppTextStyle.inputLabel,
                                    ),
                                    const SizedBox(height: 8),
                                    CustomTextField(
                                      controller: codeController,
                                      hintText: "Masukkan kode dari Puskesmas",
                                      prefixIcon: Icons.vpn_key_outlined,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const Spacer(),
                      const SizedBox(height: 40),

                      // 🔥 TOMBOL LANJUTKAN
                      CustomButton(
                        text: "Lanjutkan ke Aplikasi",
                        onPressed: handleSaveRole,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
