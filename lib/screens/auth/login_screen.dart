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
  // ⚙️ LOGIKA BACKEND
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
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_ibu',
            (route) => false,
          );
        } else if (role == 'kader') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_kader',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
        }
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

  void handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        final role = await _authService.getRole();
        if (!mounted) return;

        if (role == 'ibu') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_ibu',
            (route) => false,
          );
        } else if (role == 'kader') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_kader',
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/role', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColor.errorRed,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // 🎨 TAMPILAN UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
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

                Image.asset(
                  'assets/images/logo_teks.png',
                  height: 35,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                const Text("Selamat Datang", style: AppTextStyle.heading1),
                const SizedBox(height: 8),
                const Text(
                  "Silakan masuk menggunakan email atau akun Google Anda.",
                  style: AppTextStyle.bodyText,
                ),

                const SizedBox(height: 40),

                const Text("Email", style: AppTextStyle.inputLabel),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: emailController,
                  hintText: "Contoh: nama@email.com",
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email wajib diisi";
                    }
                    if (!value.contains("@")) return "Format email tidak valid";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

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
                    if (value == null || value.isEmpty) {
                      return "Password wajib diisi";
                    }
                    if (value.length < 6) return "Minimal 6 karakter";
                    return null;
                  },
                ),

                const SizedBox(height: 35),

                CustomButton(
                  text: "Masuk Sekarang",
                  onPressed: handleLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                const Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColor.borderGrey, thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "atau masuk dengan",
                        style: TextStyle(
                          color: AppColor.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColor.borderGrey, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔥 PERBAIKAN: Menggunakan Row agar Logo dan Teks berdampingan di tengah
                SizedBox(
                  width: double.infinity,
                  height: 56, 
                  child: OutlinedButton(
                    onPressed: isLoading ? null : handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColor.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColor.primaryGreen,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => const Text(
                                  "G",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12), // Memberikan jarak yang pas antara logo dan teks
                              const Text(
                                "Google",
                                style: TextStyle(
                                  color: AppColor.textBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 40),

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