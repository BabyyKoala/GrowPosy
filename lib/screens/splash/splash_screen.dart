import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../services/session_service.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 🔥 PERBAIKAN: Menambahkan SingleTickerProviderStateMixin untuk Animasi
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();

  // Variabel Animasi
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ⚙️ SETUP ANIMASI
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Durasi animasi 1.5 detik
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Mulai animasi
    _animationController.forward();

    // Jalankan inisialisasi aplikasi
    _initializeApp();
  }

  @override
  void dispose() {
    // 🔥 PENTING: Selalu dispose controller animasi agar tidak memory leak
    _animationController.dispose();
    super.dispose();
  }

  // ==========================
  // ⚙️ LOGIKA SESI
  // ==========================
  Future<void> _initializeApp() async {
    // Future.wait memastikan splash screen tampil minimal 2 detik (untuk melihat animasi)
    // Sembari mengecek data login/sesi di latar belakang.
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _determineNextRoute(),
    ]);

    if (!mounted) return;

    final nextRoute = results[1] as String;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  Future<String> _determineNextRoute() async {
    try {
      final isFirstTime = await SessionService.isFirstTime();
      if (isFirstTime) return '/onboarding';

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '/';

      final role = await _firestore.getUserRole();
      if (role == 'ibu') return '/home_ibu';
      if (role == 'kader') return '/home_kader';

      return '/role';
    } catch (e) {
      debugPrint("Error at Splash: $e");
      return '/'; // Kembali ke login jika terjadi error
    }
  }

  // ==========================
  // 🎨 TAMPILAN UI SPLASH SCREEN
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      body: Stack(
        children: [
          // 🌟 BAGIAN TENGAH: Logo dengan Animasi Scale & Fade
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/logo_utama.png',
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 🌟 BAGIAN BAWAH: Loading Indicator & Info Versi
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Agar column mengikuti tinggi konten
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: AppColor.primaryGreen,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "GrowPosy v1.0.0", // 🔥 Info versi sesuai pubspec.yaml Anda
                    style: TextStyle(
                      color: AppColor.textGrey.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
