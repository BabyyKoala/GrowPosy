import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/role/role_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/ibu_home_screen.dart';
import 'screens/home/kader_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/reset': (context) => const ResetPasswordScreen(),
        '/role': (context) => const RoleScreen(),
        '/home_ibu': (context) => const HomeIbuScreen(),
        '/home_kader': (context) => const HomeKaderScreen(),
      },
    );
  }
}
