import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

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
    checkSession();
  }

  Future<void> checkSession() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    try {
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      final role = await _firestore.getUserRole();

      if (!mounted) return;

      if (role == 'ibu') {
        Navigator.pushReplacementNamed(context, '/home_ibu');
      } else if (role == 'kader') {
        Navigator.pushReplacementNamed(context, '/home_kader');
      } else {
        Navigator.pushReplacementNamed(context, '/role');
      }
    } catch (e) {
      // 🔥 fallback kalau firestore error
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
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
