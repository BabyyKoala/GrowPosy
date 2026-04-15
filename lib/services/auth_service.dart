import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // ==========================
  // 🔥 REGISTER EMAIL
  // ==========================
  Future<User?> register({
    required String email,
    required String password,
    required String role,
    String name = '',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _firestore.createUser(
          uid: user.uid,
          email: email,
          role: role,
          name: name,
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // ==========================
  // 🔥 LOGIN EMAIL
  // ==========================
  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // ==========================
  // 🔥 LOGIN GOOGLE
  // ==========================
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint("Mencoba memanggil Google Sign In..."); // Muncul di terminal

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // 🔥 Jika pop-up tertutup/dibatalkan, lempar eror agar UI bereaksi
        throw Exception("Dibatalkan oleh pengguna");
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // 🔥 jika user baru → buat di firestore
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.createUser(
          uid: user!.uid,
          email: user.email ?? '',
          role: '',
        );
      }

      return user;
    } catch (e) {
      // 🔥 KUNCI PENTING: Tangkap dan tampilkan pesan eror aslinya!
      debugPrint("ERROR GOOGLE SIGN IN: $e");
      throw Exception(e.toString());
    }
  }

  // ==========================
  // 🔥 RESET PASSWORD
  // ==========================
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // ==========================
  // 🔥 LOGOUT
  // ==========================
  Future<void> logout() async {
    await _auth.signOut(); // Keluar dari Firebase
    await GoogleSignIn()
        .signOut(); // 🔥 Tambahkan ini agar pop-up Google muncul lagi saat login
  }

  // ==========================
  // 🔥 ERROR HANDLER
  // ==========================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential': // (Aturan Firebase Terbaru)
        return 'Email atau password salah';
      case 'user-not-found': // (Bisa tetap dibiarkan untuk berjaga-jaga)
        return 'Email tidak terdaftar';
      case 'wrong-password': // (Bisa tetap dibiarkan untuk berjaga-jaga)
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah (min 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }

  Future<String?> getRole() async {
    return await _firestore.getUserRole();
  }
}
