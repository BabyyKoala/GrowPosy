import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // ==========================
  // 🔥 REGISTER EMAIL (DIPERBAIKI)
  // ==========================
  Future<User?> register({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone, // Parameter baru
    String? address, // Parameter baru
    int? childrenCount, // Parameter baru
    String? posyanduName, // Parameter baru
    String? inviteCode,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = cred.user;

      if (user != null) {
        // Simpan semua profil lengkap ke Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': role,
          'name': name,
          'phone': phone,
          'address': address ?? '',
          'childrenCount': childrenCount ?? 0,
          'posyanduName': posyanduName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // (Logika update status inviteCode untuk kader bisa ditaruh di sini atau di fungsi terpisah)
      }
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ==========================
  // 🔥 VERIFIKASI KODE UNDANGAN (DIPERBAIKI)
  // ==========================
  /// Fungsi ini HANYA mengecek apakah kodenya ada dan belum dipakai.
  /// Tidak lagi melakukan update database di sini.
  Future<bool> verifyInviteCode(String rawCode) async {
    try {
      final cleanCode = rawCode.trim().toUpperCase();
      debugPrint("Mengecek validitas kode: '$cleanCode'");

      final isValid = await _firestore.verifyInviteCode(cleanCode);
      return isValid;
    } catch (e) {
      debugPrint("ERROR VERIFY CODE: $e");
      return false;
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
  // 🔥 LOGIN GOOGLE (DIPERBAIKI)
  // ==========================
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint("Mencoba memanggil Google Sign In...");

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception("Dibatalkan oleh pengguna");
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Jika user baru → buat di firestore
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.createUser(
          uid: user!.uid,
          email: user.email ?? '',
          // Default role untuk Google Sign-In kita set sebagai 'unassigned'.
          // Nantinya kamu harus mengarahkan mereka ke RoleScreen untuk memilih.
          role: 'unassigned',
        );
      }

      return user;
    } catch (e) {
      debugPrint("ERROR GOOGLE SIGN IN: $e");
      throw Exception("Gagal masuk dengan Google. Silakan coba lagi.");
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
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // ==========================
  // 🔥 GET ROLE
  // ==========================
  Future<String?> getRole() async {
    return await _firestore.getUserRole();
  }

  // ==========================
  // 🔥 ERROR HANDLER
  // ==========================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
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
}
