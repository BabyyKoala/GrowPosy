import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/child_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 CREATE USER
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
    });
  }

  // 🔥 GET ROLE
  Future<String?> getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();

    return doc.data()?['role'];
  }

  // 🔥 ADD CHILD
  Future<void> addChild({
    required String name,
    required int age,
    required String gender,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection('users').doc(uid).collection('children').add({
      'name': name,
      'age': age,
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 GET CHILDREN
  Stream<List<ChildModel>> getChildren() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('users')
        .doc(uid)
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
  // 🔥 GET ALL CHILDREN (KADER)
  // ==========================
  Stream<List<Map<String, dynamic>>> getAllChildrenForKader() {
    return _db.collection('users').snapshots().asyncMap((usersSnapshot) async {
      List<Map<String, dynamic>> allChildren = [];

      for (var userDoc in usersSnapshot.docs) {
        final childrenSnapshot = await userDoc.reference
            .collection('children')
            .get();

        for (var childDoc in childrenSnapshot.docs) {
          allChildren.add({
            'id': childDoc.id,
            'userId': userDoc.id,
            ...childDoc.data(),
          });
        }
      }

      return allChildren;
    });
  }

  // ==========================
  // 🔥 GET LAST WEIGHT GENERIC
  // ==========================
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

  // ==========================
  // 🔥 GROWTH (NEW FEATURE)
  // ==========================

  Future<void> addGrowth({
    required String childId,
    required double weight,
    required double height,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection('users')
        .doc(uid)
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
    final uid = FirebaseAuth.instance.currentUser!.uid;

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

  // ==========================
  // 🔥 LAST WEIGHT (NEW)
  // ==========================

  Stream<double?> getLastWeight(String childId) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

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

  // ==========================
  // 🔥 VERIFY INVITE CODE
  // ==========================
  Future<bool> verifyInviteCode(String code) async {
    final result = await _db
        .collection('invite_codes')
        .where('code', isEqualTo: code)
        .where('isUsed', isEqualTo: false)
        .get();

    return result.docs.isNotEmpty;
  }

  // ==========================
  // 🔥 USE INVITE CODE
  // ==========================
  Future<void> useInviteCode(String code, String uid) async {
    final query = await _db
        .collection('invite_codes')
        .where('code', isEqualTo: code)
        .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;

      await _db.collection('invite_codes').doc(docId).update({
        'isUsed': true,
        'usedBy': uid,
      });
    }
  }

  // ==========================
  // 🔥 SET ROLE USER
  // ==========================
  Future<void> setUserRole(String role) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection('users').doc(uid).update({'role': role});
  }
}
