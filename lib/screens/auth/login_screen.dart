import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  final AuthService _authService = AuthService();

  // 🔥 Warna Utama GrowPosy (Hijau Segar)
  final Color primaryGreen = const Color(0xFF00D15A);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // ⚙️ LOGIKA BACKEND (TIDAK ADA YANG DIUBAH)
  // ==========================================

  void handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null && mounted) {
        final role = await _authService.getRole();
        if (!mounted) return;

        if (role == 'ibu') {
          Navigator.pushReplacementNamed(context, '/home_ibu');
        } else if (role == 'kader') {
          Navigator.pushReplacementNamed(context, '/home_kader');
        } else {
          Navigator.pushReplacementNamed(context, '/role');
        }
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

  void handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        final role = await _authService.getRole();
        if (!mounted) return;

        if (role == 'ibu') {
          Navigator.pushReplacementNamed(context, '/home_ibu');
        } else if (role == 'kader') {
          Navigator.pushReplacementNamed(context, '/home_kader');
        } else {
          Navigator.pushReplacementNamed(context, '/role');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // 🎨 TAMPILAN UI MINIMALIS (TANPA ILUSTRASI)
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
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
                const SizedBox(height: 20),

                // 🔥 LOGO / NAMA APLIKASI
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

                const SizedBox(height: 40),

                // 🔥 JUDUL
                const Text(
                  "Selamat Datang",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Silakan masuk menggunakan email atau akun Google Anda.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 INPUT EMAIL
                const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Contoh: nama@email.com",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.person_outline),
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
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email wajib diisi";
                    if (!value.contains("@")) return "Format email tidak valid";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 🔥 INPUT PASSWORD & LUPA PASSWORD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/reset'),
                      child: Text(
                        "Lupa Password?",
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                    hintText: "Masukkan password Anda",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.lock_outline),
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
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password wajib diisi";
                    if (value.length < 6) return "Minimal 6 karakter";
                    return null;
                  },
                ),

                const SizedBox(height: 35),

                // 🔥 TOMBOL LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
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
                            "Masuk Sekarang",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔥 GARIS "ATAU MASUK DENGAN"
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "atau masuk dengan",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey[300], thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔥 TOMBOL GOOGLE
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.g_mobiledata,
                          size: 36,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 TEKS DAFTAR SEKARANG
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: TextSpan(
                        text: "Belum punya akun? ",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        children: [
                          TextSpan(
                            text: "Daftar Sekarang",
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

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
