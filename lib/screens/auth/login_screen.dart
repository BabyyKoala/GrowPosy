import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

// 🔥 Import Sistem Tema & Custom Widgets
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

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
          backgroundColor: AppColor.errorRed, // Menggunakan AppColor
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
            backgroundColor: AppColor.errorRed, // Menggunakan AppColor
          ),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // 🎨 TAMPILAN UI (PEMBARUAN LOGO)
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite, // Tersentralisasi
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
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

                // 🔥 PEMBARUAN: LOGO TEKS GROWPOSY
                Image.asset(
                  'assets/images/logo_teks.png',
                  height: 35,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                // 🔥 JUDUL
                const Text("Selamat Datang", style: AppTextStyle.heading1),
                const SizedBox(height: 8),
                const Text(
                  "Silakan masuk menggunakan email atau akun Google Anda.",
                  style: AppTextStyle.bodyText,
                ),

                const SizedBox(height: 40),

                // 🔥 INPUT EMAIL
                const Text("Email", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: emailController,
                  hintText: "Contoh: nama@email.com",
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
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
                    const Text("Password", style: AppTextStyle.inputLabel),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/reset'),
                      child: const Text(
                        "Lupa Password?",
                        style: TextStyle(
                          color: AppColor.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: passwordController,
                  hintText: "Masukkan password Anda",
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
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Password wajib diisi";
                    if (value.length < 6) return "Minimal 6 karakter";
                    return null;
                  },
                ),

                const SizedBox(height: 35),

                // 🔥 TOMBOL LOGIN
                CustomButton(
                  text: "Masuk Sekarang",
                  onPressed: handleLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // 🔥 GARIS "ATAU MASUK DENGAN"
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColor.borderGrey, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "atau masuk dengan",
                        style: TextStyle(
                          color: AppColor.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColor.borderGrey, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔥 TOMBOL GOOGLE
                CustomButton(
                  text: "Google",
                  onPressed: handleGoogleLogin,
                  isLoading: isLoading,
                  isOutlined: true,
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 36,
                    color: AppColor.errorRed,
                  ),
                ),

                const SizedBox(height: 40),

                // 🔥 TEKS DAFTAR SEKARANG
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: const TextSpan(
                        text: "Belum punya akun? ",
                        style: TextStyle(
                          color: AppColor.textGrey,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Daftar Sekarang",
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

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
