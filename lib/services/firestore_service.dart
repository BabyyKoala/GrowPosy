import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child_model.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _currentUid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User tidak terautentikasi");
    return uid;
  }

  // ==========================
  // 🔥 USER CRUD
  // ==========================
  Future<void> createUser({
    required String uid,
    required String email,
    required String role,
    String name = '',
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

  Future<void> setUserRole(String role) async {
    await _db.collection('users').doc(_currentUid).update({'role': role});
  }

  // ==========================
  // 🔥 CHILD CRUD (IBU)
  // ==========================
  Future<void> addChild({
    required String name,
    required int age,
    required String gender,
  }) async {
    await _db.collection('users').doc(_currentUid).collection('children').add({
      'name': name,
      'age': age,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

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

  // ==========================
  // 🔥 DATA ANAK GLOBAL (KADER)
  // ==========================
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
  // 🔥 GROWTH TRACKING
  // ==========================
  Future<void> addGrowth({
    required String userId,
    required String childId,
    required double weight,
    required double height,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('children')
        .doc(childId)
        .collection('growth')
        .add({
          'weight': weight,
          'height': height,
          'date': FieldValue.serverTimestamp(),
        });
  }

  Stream<List<Map<String, dynamic>>> getGrowth(String childId) {
    return _db
        .collection('users')
        .doc(_currentUid)
        .collection('children')
        .doc(childId)
        .collection('growth')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<double?> getLastWeight(String childId) {
    return _db
        .collection('users')
        .doc(_currentUid)
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

  // ==================================================
  // 🔥 INVITE CODE SYSTEM (KADER) - MULTI-USE VERSION
  // ==================================================

  Future<bool> verifyInviteCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    try {
      // Hanya mengecek apakah kode tersebut ADA di database
      // Tidak lagi mengecek status isUsed
      final result = await _db
          .collection('invite_codes')
          .where('code', isEqualTo: cleanCode)
          .limit(1) // Optimasi performa: batasi pencarian 1 dokumen saja
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error saat memverifikasi kode: $e");
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

        // Menggunakan FieldValue.arrayUnion untuk mengumpulkan daftar UID
        // Ini tidak akan menimpa UID sebelumnya, melainkan menambahkannya ke dalam daftar
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
    await _db.collection('jadwal').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getJadwal() {
    return _db
        .collection('jadwal')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}
