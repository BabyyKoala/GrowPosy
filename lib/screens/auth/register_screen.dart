import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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
  bool isPasswordHidden = true; // Fitur tombol mata password

  // 🔥 Warna Utama GrowPosy (Hijau Segar)
  final Color primaryGreen = const Color(0xFF00D15A);

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
      // Validasi Khusus Kader
      if (selectedRole == 'kader') {
        if (codeController.text != "POSYANDU123") {
          throw Exception("Kode kader salah");
        }
      }

      final user = await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: selectedRole,
        name: nameController.text.trim(),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan masuk."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/'); // Kembali ke Login
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => isLoading = false);
  }

  // ==========================
  // 🎨 HELPER DESAIN INPUT (Biar kode rapi)
  // ==========================
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGreen, width: 2),
      ),
    );
  }

  // Builder untuk Label Form
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  // ==========================
  // 🎨 TAMPILAN UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                // 🔥 HEADER
                Row(
                  children: [
                    Icon(Icons.spa, size: 36, color: primaryGreen),
                    const SizedBox(width: 10),
                    Text(
                      "GrowPosy",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: primaryGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Lengkapi data diri Anda di bawah ini untuk bergabung bersama GrowPosy.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),

                // 🔥 PILIH ROLE
                _buildLabel("Mendaftar Sebagai"),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  decoration: _buildInputDecoration(
                    "Pilih Peran",
                    Icons.group_outlined,
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

                // 🔥 NAMA LENGKAP
                _buildLabel("Nama Lengkap"),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    "Masukkan nama lengkap",
                    Icons.person_outline,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nama wajib diisi" : null,
                ),

                // 🔥 EMAIL
                _buildLabel("Alamat Email"),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    "Contoh: nama@email.com",
                    Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email wajib diisi";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return "Format email tidak valid";
                    }
                    return null;
                  },
                ),

                // 🔥 NO HP
                _buildLabel("Nomor Handphone"),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    "Contoh: 08123456789",
                    Icons.phone_outlined,
                  ),
                  validator: (v) => v == null || v.length < 10
                      ? "No HP minimal 10 angka"
                      : null,
                ),

                // 🔥 PASSWORD DENGAN ICON MATA
                _buildLabel("Password"),
                TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    hintText: "Buat password (minimal 6 karakter)",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryGreen, width: 2),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? "Minimal 6 karakter" : null,
                ),

                // ==========================
                // 🔥 FORM KHUSUS IBU
                // ==========================
                if (selectedRole == 'ibu') ...[
                  _buildLabel("Alamat Lengkap"),
                  TextFormField(
                    controller: addressController,
                    decoration: _buildInputDecoration(
                      "Masukkan alamat domisili",
                      Icons.home_outlined,
                    ),
                  ),
                  _buildLabel("Jumlah Anak"),
                  TextFormField(
                    controller: childrenCountController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration(
                      "Contoh: 1",
                      Icons.child_care,
                    ),
                  ),
                ],

                // ==========================
                // 🔥 FORM KHUSUS KADER
                // ==========================
                if (selectedRole == 'kader') ...[
                  _buildLabel("Nama Posyandu"),
                  TextFormField(
                    controller: posyanduController,
                    decoration: _buildInputDecoration(
                      "Contoh: Posyandu Melati 1",
                      Icons.local_hospital_outlined,
                    ),
                  ),
                  _buildLabel("Kode Verifikasi Kader"),
                  TextFormField(
                    controller: codeController,
                    decoration: _buildInputDecoration(
                      "Masukkan kode khusus kader",
                      Icons.admin_panel_settings_outlined,
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // 🔥 TOMBOL DAFTAR
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Daftar Sekarang",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔥 TEKS SUDAH PUNYA AKUN
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pop(context), // Kembali ke Halaman Login
                    child: RichText(
                      text: TextSpan(
                        text: "Sudah punya akun? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Masuk di sini",
                            style: TextStyle(
                              color: primaryGreen,
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
