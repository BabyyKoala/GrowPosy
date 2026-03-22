import 'package:flutter/material.dart';
import '../../services/session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstTime = await SessionService.isFirstTime();
    final isLoggedIn = await SessionService.isLoggedIn();
    final role = await SessionService.getRole();

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (isLoggedIn) {
      if (role == 'ibu') {
        Navigator.pushReplacementNamed(context, '/home_ibu');
      } else if (role == 'kader') {
        Navigator.pushReplacementNamed(context, '/home_kader');
      } else {
        Navigator.pushReplacementNamed(context, '/role');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "GrowPosy",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
