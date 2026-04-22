import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String name;
  final int age; // Dalam bulan (sesuai standar Posyandu)
  final String gender; // 'L' atau 'P'
  final DateTime? createdAt;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.createdAt,
  });

  // 🔥 Mengubah data dari Firestore (Map) menjadi Object Flutter
  factory ChildModel.fromMap(String id, Map<String, dynamic> data) {
    return ChildModel(
      id: id,
      name: data['name'] ?? 'Tanpa Nama',
      // Menggunakan 'num' untuk antisipasi jika Firebase mengirim double
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender'] ?? 'L',
      // Mengonversi Timestamp Firebase menjadi DateTime Flutter
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // 🔥 Mengubah Object Flutter menjadi Map untuk dikirim ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      // FieldValue.serverTimestamp() biasanya diset di Service,
      // tapi kita siapkan field-nya di sini jika perlu.
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // 🔥 Helper untuk mendapatkan label jenis kelamin yang rapi di UI
  String get genderLabel => gender == 'L' ? 'Laki-laki' : 'Perempuan';
}
