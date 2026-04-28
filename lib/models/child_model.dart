import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id;
  final String userId; // 🔥 CRITICAL: ID Ibu dari anak ini (Wajib ada)
  final String name;
  final DateTime? birthDate; // 🔥 STANDAR POSYANDU: Tanggal Lahir
  final int
  age; // Usia statis (Tetap dipertahankan untuk kompatibilitas data lama)
  final String gender; // 'L' atau 'P'
  final DateTime? createdAt;

  ChildModel({
    required this.id,
    required this.userId,
    required this.name,
    this.birthDate,
    required this.age,
    required this.gender,
    this.createdAt,
  });

  // ==========================================
  // 🔥 MENGUBAH FIRESTORE MAP -> OBJECT FLUTTER
  // ==========================================
  factory ChildModel.fromMap(String id, Map<String, dynamic> data) {
    return ChildModel(
      id: id,
      userId:
          data['userId']?.toString() ?? '', // Pastikan terbaca sebagai String
      name: data['name']?.toString() ?? 'Tanpa Nama',

      // Ambil tanggal lahir jika ada
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,

      // Menggunakan 'num' untuk antisipasi jika Firebase mengirim format desimal
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender']?.toString() ?? 'L',

      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ==========================================
  // 🔥 MENGUBAH OBJECT FLUTTER -> FIRESTORE MAP
  // ==========================================
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      // Simpan sebagai Timestamp Firebase, bukan String
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'age': age,
      'gender': gender,
      // Jika data baru dibuat, gunakan serverTimestamp agar akurat dengan jam server
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // ==========================================
  // 🛠️ HELPER FUNCTIONS (Logika Bisnis UI)
  // ==========================================

  // 1. Mendapatkan label jenis kelamin yang rapi di UI
  String get genderLabel => gender == 'L' ? 'Laki-laki' : 'Perempuan';

  // 2. 🔥 Menghitung Usia Dinamis (Berdasarkan Tanggal Lahir & Waktu Sekarang)
  // Ini sangat berguna untuk grafik KMS agar usia bulan selalu akurat!
  int get calculatedAgeInMonths {
    if (birthDate == null)
      return age; // Fallback ke usia statis jika tgl lahir kosong

    final now = DateTime.now();
    int months =
        (now.year - birthDate!.year) * 12 + now.month - birthDate!.month;

    // Jika belum melewati tanggal lahir di bulan ini, kurangi 1 bulan
    if (now.day < birthDate!.day) {
      months--;
    }

    return months < 0 ? 0 : months; // Tidak mungkin minus
  }

  // ==========================================
  // 🔄 FUNGSI COPY WITH (Standard Profesional)
  // Digunakan saat kita ingin mengedit sebagian data tanpa merusak objek aslinya
  // ==========================================
  ChildModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? birthDate,
    int? age,
    String? gender,
    DateTime? createdAt,
  }) {
    return ChildModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 🐛 Mempermudah Debugging di Terminal (Print object langsung terbaca)
  @override
  String toString() {
    return 'ChildModel(id: $id, name: $name, age: $calculatedAgeInMonths bulan)';
  }
}
