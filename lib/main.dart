import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔥 SEKARANG INI WAJIB AKTIF!
import 'firebase_options.dart';

// 🔥 Import Tema Global
import 'theme/app_theme.dart';
import 'theme/app_color.dart';

// 🔥 Import Screens
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_code_screen.dart';
import 'screens/role/role_screen.dart';

import 'screens/home/ibu_home_screen.dart';
import 'screens/home/home_kader_screen.dart';
import 'screens/child/add_child_screen.dart';

void main() async {
  // Memastikan binding Flutter sudah siap (Wajib untuk Firebase & SystemChrome)
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 1. Kunci Layar agar selalu Portrait (Berdiri)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🔥 2. Atur warna Status Bar di bagian atas HP agar elegan & modern
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:
          Colors.transparent, // Transparan agar menyatu dengan AppBar
      statusBarIconBrightness:
          Brightness.dark, // Ikon jam/baterai berwarna gelap
      systemNavigationBarColor: AppColor.bgWhite, // Warna navbar bawah
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 🔥 3. Firebase Resmi Menyala!
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowPosy',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" merah
      theme: AppTheme.light, // 🔥 Menggunakan tema profesional yang baru dibuat
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/reset': (context) => const ResetPasswordScreen(),
        '/verify': (context) => const VerifyCodeScreen(),
        '/role': (context) => const RoleScreen(),
        '/home_ibu': (context) => const HomeIbuScreen(),
        '/home_kader': (context) => const HomeKaderScreen(),
        '/add_child': (context) => const AddChildScreen(),
      },
    );
  }
}
