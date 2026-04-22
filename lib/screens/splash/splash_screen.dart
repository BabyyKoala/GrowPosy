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

class _SplashScreenState extends State<SplashScreen> {
  final FirestoreService _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ==========================
  // ⚙️ LOGIKA SESI
  // ==========================
  Future<void> _initializeApp() async {
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
      return '/';
    }
  }

  // ==========================
  // 🎨 TAMPILAN UI SPLASH SCREEN
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 Diubah ke putih agar logo baru menyatu dengan layar
      backgroundColor: AppColor.bgWhite,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔥 Memanggil Logo Utama Baru
            Image.asset(
              'assets/images/logo_utama.png',
              width: 220, // Ukuran bisa disesuaikan selera
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 50),

            // 🔥 Warna loading disesuaikan menjadi hijau
            const CircularProgressIndicator(
              color: AppColor.primaryGreen,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
