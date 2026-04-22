import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // 🔥 IBU
  final addressController = TextEditingController();
  final childrenCountController = TextEditingController();

  // 🔥 KADER
  final posyanduController = TextEditingController();
  final codeController = TextEditingController();

  String selectedRole = 'ibu';
  bool isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    childrenCountController.dispose();
    posyanduController.dispose();
    codeController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA BACKEND (TIDAK DIUBAH)
  // ==========================
  void handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      if (selectedRole == 'kader') {
        bool isCodeValid = await _authService.verifyInviteCode(
          codeController.text,
        );
        if (!isCodeValid) {
          throw Exception("Kode kader tidak valid atau sudah digunakan");
        }
      }

      // 🔥 Mengirim SEMUA data ke AuthService
      final user = await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: selectedRole == 'ibu' ? addressController.text.trim() : null,
        childrenCount: selectedRole == 'ibu'
            ? int.tryParse(childrenCountController.text.trim()) ?? 0
            : null,
        posyanduName: selectedRole == 'kader'
            ? posyanduController.text.trim()
            : null,
        inviteCode: selectedRole == 'kader' ? codeController.text.trim() : null,
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan masuk."),
            backgroundColor: AppColor.primaryGreen,
          ),
        );
        Navigator.pushReplacementNamed(context, '/'); // Kembali ke Login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: AppColor.errorRed,
        ),
      );
    }
    setState(() => isLoading = false);
  }

  // ==========================
  // 🎨 TAMPILAN UI (PEMBARUAN LOGO)
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 PEMBARUAN: LOGO TEKS GROWPOSY
                Image.asset(
                  'assets/images/logo_teks.png',
                  height: 45,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),
                const Text("Buat Akun Baru", style: AppTextStyle.heading1),
                const SizedBox(height: 8),
                const Text(
                  "Lengkapi data diri Anda di bawah ini untuk bergabung bersama GrowPosy.",
                  style: AppTextStyle.bodyText,
                ),
                const SizedBox(height: 30),

                // 🔥 PILIH ROLE
                const Text("Mendaftar Sebagai", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColor.textGrey,
                  ),
                  decoration: InputDecoration(
                    hintText: "Pilih Peran",
                    hintStyle: const TextStyle(color: AppColor.textGrey),
                    prefixIcon: const Icon(
                      Icons.group_outlined,
                      color: AppColor.textGrey,
                    ),
                    filled: true,
                    fillColor: AppColor.bgWhite,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.borderGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.borderGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'ibu',
                      child: Text("Ibu / Orang Tua"),
                    ),
                    DropdownMenuItem(
                      value: 'kader',
                      child: Text("Kader Posyandu"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRole = value!);
                  },
                ),
                const SizedBox(height: 20),

                // 🔥 NAMA LENGKAP
                const Text("Nama Lengkap", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: nameController,
                  hintText: "Masukkan nama lengkap",
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 20),

                // 🔥 EMAIL
                const Text("Alamat Email", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: emailController,
                  hintText: "Contoh: nama@email.com",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email wajib diisi";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return "Format email tidak valid";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 🔥 NO HP
                const Text("Nomor Handphone", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: phoneController,
                  hintText: "Contoh: 08123456789",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.length < 10
                      ? "No HP minimal 10 angka"
                      : null,
                ),
                const SizedBox(height: 20),

                // 🔥 PASSWORD
                const Text("Password", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Buat password (minimal 6 karakter)",
                  prefixIcon: Icons.lock_outline,
                  isPassword: isPasswordHidden,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColor.textGrey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? "Minimal 6 karakter" : null,
                ),
                const SizedBox(height: 20),

                // ==========================
                // 🔥 FORM KHUSUS IBU
                // ==========================
                if (selectedRole == 'ibu') ...[
                  const Text("Alamat Lengkap", style: AppTextStyle.inputLabel),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: addressController,
                    hintText: "Masukkan alamat domisili",
                    prefixIcon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 20),

                  const Text("Jumlah Anak", style: AppTextStyle.inputLabel),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: childrenCountController,
                    hintText: "Contoh: 1",
                    prefixIcon: Icons.child_care,
                    keyboardType: TextInputType.number,
                  ),
                ],

                // ==========================
                // 🔥 FORM KHUSUS KADER
                // ==========================
                if (selectedRole == 'kader') ...[
                  const Text("Nama Posyandu", style: AppTextStyle.inputLabel),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: posyanduController,
                    hintText: "Contoh: Posyandu Melati 1",
                    prefixIcon: Icons.local_hospital_outlined,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Kode Verifikasi Kader",
                    style: AppTextStyle.inputLabel,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: codeController,
                    hintText: "Masukkan kode khusus kader",
                    prefixIcon: Icons.admin_panel_settings_outlined,
                  ),
                ],

                const SizedBox(height: 40),

                // 🔥 TOMBOL DAFTAR
                CustomButton(
                  text: "Daftar Sekarang",
                  onPressed: handleRegister,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 30),

                // 🔥 TEKS SUDAH PUNYA AKUN
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(
                          color: AppColor.textGrey,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Masuk di sini",
                            style: TextStyle(
                              color: AppColor.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
