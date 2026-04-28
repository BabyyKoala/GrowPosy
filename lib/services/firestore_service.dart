import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/child_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Helper: Mendapatkan ID User yang sedang login
  String get _currentUid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("Sesi telah habis. Silakan login ulang.");
    return uid;
  }

  // ==========================
  // 👤 USER CRUD
  // ==========================
  Future<void> createUser({
    required String uid,
    required String email,
    required String role,
    String name = '',
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error createUser: $e");
      throw Exception("Gagal membuat profil pengguna.");
    }
  }

  Future<String?> getUserRole() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'];
    } catch (e) {
      debugPrint("Error getUserRole: $e");
      return null;
    }
  }

  Future<void> setUserRole(String role) async {
    await _db.collection('users').doc(_currentUid).update({'role': role});
  }

  // ==========================
  // 👶 CHILD CRUD (PROFIL ANAK)
  // ==========================

  // 🔥 UPGRADE: Menambahkan Parameter Kelahiran agar sinkron dengan UI AddChildScreen
  Future<void> addChild({
    required String userId,
    required String name,
    required DateTime birthDate, // Parameter baru
    required int age,
    required String gender,
    double? birthWeight, // Parameter baru
    double? birthHeight, // Parameter baru
  }) async {
    try {
      await _db.collection('users').doc(userId).collection('children').add({
        'userId': userId,
        'name': name,
        'birthDate': Timestamp.fromDate(birthDate), // Simpan sebagai Timestamp
        'age': age,
        'gender': gender,
        'birthWeight': birthWeight,
        'birthHeight': birthHeight,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error addChild: $e");
      throw Exception("Gagal menyimpan data anak.");
    }
  }

  // Khusus Ibu: Mengambil daftar anaknya sendiri
  Stream<List<ChildModel>> getChildren() {
    return _db
        .collection('users')
        .doc(_currentUid)
        .collection('children')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChildModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Khusus Kader: Mengambil seluruh data anak dari semua Ibu
  Stream<List<Map<String, dynamic>>> getAllChildrenForKader() {
    return _db
        .collectionGroup('children')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final userId = doc.reference.parent.parent?.id ?? '';
            return {'id': doc.id, 'userId': userId, ...doc.data()};
          }).toList();
        });
  }

  Stream<int> getTotalAllChildren() {
    return _db
        .collectionGroup('children')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ==========================
  // 📈 GROWTH TRACKING & MEDICAL RECORD (KMS)
  // ==========================

  Future<void> addGrowth({
    required String userId,
    required String childId,
    required double weight,
    required double height,
    required String imunisasi,
  }) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('growth')
          .add({
            'weight': weight,
            'height': height,
            'imunisasi': imunisasi,
            'date': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint("Error addGrowth: $e");
      throw Exception("Gagal menyimpan data KMS.");
    }
  }

  // 🔥 UPGRADE: Menambahkan parameter opsional [targetUserId] agar Kader bisa melihat grafik anak dari Ibu lain
  Stream<List<Map<String, dynamic>>> getGrowth(
    String childId, {
    String? targetUserId,
  }) {
    final uid =
        targetUserId ??
        _currentUid; // Gunakan UID yang dikirim, atau UID Ibu yang login
    return _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .collection('growth')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 🔥 UPGRADE: Mengizinkan parameter [targetUserId] untuk daftar Kader
  Stream<double?> getLastWeight(String childId, {String? targetUserId}) {
    final uid = targetUserId ?? _currentUid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .collection('growth')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final data = snapshot.docs.first.data();
          return (data['weight'] ?? 0).toDouble();
        });
  }

  Future<double?> getLastWeightGlobal(String userId, String childId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('children')
        .doc(childId)
        .collection('growth')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return (snapshot.docs.first.data()['weight'] as num).toDouble();
  }

  Future<Map<String, dynamic>?> getLastGrowthData(
    String userId,
    String childId,
  ) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId)
          .collection('growth')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    } catch (e) {
      debugPrint("Error getLastGrowthData: $e");
      return null;
    }
  }

  // ==================================================
  // 🎟️ INVITE CODE SYSTEM (KADER)
  // ==================================================

  Future<bool> verifyInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    try {
      final result = await _db
          .collection('invite_codes')
          .where('code', isEqualTo: cleanCode)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error memverifikasi kode: $e");
      return false;
    }
  }

  Future<void> useInviteCode(String code, String uid) async {
    final cleanCode = code.trim().toUpperCase();
    try {
      final query = await _db
          .collection('invite_codes')
          .where('code', isEqualTo: cleanCode)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _db.collection('invite_codes').doc(docId).update({
          'usedBy': FieldValue.arrayUnion([uid]),
          'lastUsedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception("Gagal mencatat penggunaan kode: $e");
    }
  }

  // ==========================================
  // 📅 MANAJEMEN JADWAL POSYANDU
  // ==========================================
  Future<void> addJadwal(Map<String, dynamic> data) async {
    try {
      await _db.collection('jadwal').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error addJadwal: $e");
      throw Exception("Gagal menambah jadwal Posyandu.");
    }
  }

  Stream<List<Map<String, dynamic>>> getJadwal() {
    return _db
        .collection('jadwal')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  // ==========================================
  // 📢 SISTEM PENGUMUMAN (BROADCAST)
  // ==========================================
  Future<void> sendPengumuman(String pesan) async {
    try {
      await _db.collection('pengumuman').add({
        'pesan': pesan,
        'senderId': _currentUid, // ID Kader yang mengirim
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error sendPengumuman: $e");
      throw Exception("Gagal mengirim pengumuman. Periksa koneksi Anda.");
    }
  }

  // Fungsi untuk mengambil pengumuman (Nanti bisa dipanggil di layar Beranda Ibu)
  Stream<List<Map<String, dynamic>>> getPengumuman() {
    return _db
        .collection('pengumuman')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}