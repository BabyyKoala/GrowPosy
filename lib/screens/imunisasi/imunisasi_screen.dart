import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 🔥 Import Service & Model
import '../../services/firestore_service.dart';
import '../../models/child_model.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class ImunisasiScreen extends StatefulWidget {
  const ImunisasiScreen({super.key});

  @override
  State<ImunisasiScreen> createState() => _ImunisasiScreenState();
}

class _ImunisasiScreenState extends State<ImunisasiScreen> {
  final FirestoreService firestore = FirestoreService();
  int _selectedChildIndex = 0;

  // ==========================================
  // 📚 MASTER JADWAL IMUNISASI KEMENKES RI
  // (Sesuai dengan Dropdown di AddGrowthScreen)
  // ==========================================
  final List<Map<String, String>> masterJadwal = [
    {"usia": "0 Bulan", "vaksin": "Hepatitis B0"},
    {"usia": "1 Bulan", "vaksin": "BCG"},
    {"usia": "1 Bulan", "vaksin": "Polio 1"},
    {"usia": "2 Bulan", "vaksin": "DPT-HB-Hib 1"},
    {"usia": "2 Bulan", "vaksin": "Polio 2"},
    {"usia": "3 Bulan", "vaksin": "DPT-HB-Hib 2"},
    {"usia": "3 Bulan", "vaksin": "Polio 3"},
    {"usia": "4 Bulan", "vaksin": "DPT-HB-Hib 3"},
    {"usia": "4 Bulan", "vaksin": "Polio 4"},
    {"usia": "4 Bulan", "vaksin": "IPV"},
    {"usia": "9 Bulan", "vaksin": "Campak / MR"},
    {"usia": "6-11 Bulan", "vaksin": "Vitamin A (Biru)"},
    {"usia": "12-59 Bulan", "vaksin": "Vitamin A (Merah)"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Buku Imunisasi",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 1. PILIH ANAK
          _buildChildSelector(),

          // 🔥 2. HEADER INFO
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColor.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColor.primaryGreen,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Jadwal imunisasi disesuaikan dengan standar Kementerian Kesehatan RI. Data otomatis tersinkronisasi dari riwayat posyandu.",
                      style: TextStyle(
                        color: AppColor.primaryGreen,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔥 3. DAFTAR IMUNISASI BERDASARKAN ANAK YANG DIPILIH
          Expanded(
            child: StreamBuilder<List<ChildModel>>(
              stream: firestore.getChildren(),
              builder: (context, childSnapshot) {
                if (childSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryGreen,
                    ),
                  );
                }

                if (!childSnapshot.hasData || childSnapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Belum ada data anak.\nSilakan tambahkan di Beranda.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.textGrey),
                    ),
                  );
                }

                // Ambil ID Anak yang sedang dipilih
                final validIndex =
                    _selectedChildIndex < childSnapshot.data!.length
                    ? _selectedChildIndex
                    : 0;
                final selectedChild = childSnapshot.data![validIndex];

                // Memantau Riwayat Pertumbuhan Anak Tersebut
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestore.getGrowth(selectedChild.id),
                  builder: (context, growthSnapshot) {
                    if (growthSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryGreen,
                        ),
                      );
                    }

                    final growthData = growthSnapshot.data ?? [];

                    // 💡 LOGIKA SINKRONISASI:
                    // Mencari semua imunisasi yang pernah diberikan beserta tanggalnya
                    Map<String, DateTime> riwayatImunisasi = {};
                    for (var doc in growthData) {
                      String imunisasiDiberikan = doc['imunisasi'] ?? '';
                      if (imunisasiDiberikan.isNotEmpty &&
                          imunisasiDiberikan != 'Tidak Ada') {
                        // Jika dalam 1 sesi ada banyak (misal dipisah koma), kita split.
                        // Tapi karena dropdown Anda memilih satu persatu, ini cukup.
                        riwayatImunisasi[imunisasiDiberikan] =
                            (doc['date'] as Timestamp).toDate();
                      }
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: masterJadwal.length,
                      itemBuilder: (context, index) {
                        final item = masterJadwal[index];
                        final namaVaksin = item['vaksin']!;

                        // Cek apakah vaksin ini ada di riwayat
                        final bool isDone = riwayatImunisasi.containsKey(
                          namaVaksin,
                        );
                        final DateTime? tanggalDiberikan =
                            riwayatImunisasi[namaVaksin];

                        final String status = isDone ? "Selesai" : "Belum";
                        final String tanggalStr = isDone
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(tanggalDiberikan!)
                            : "-";

                        return _buildImunisasiCard(
                          usia: item['usia']!,
                          vaksin: namaVaksin,
                          status: status,
                          tanggal: tanggalStr,
                          isDone: isDone,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🎨 WIDGET SELECTOR ANAK (Diambil dari Beranda)
  // ==========================================
  Widget _buildChildSelector() {
    return StreamBuilder<List<ChildModel>>(
      stream: firestore.getChildren(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox.shrink();

        final children = snapshot.data!;
        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 24),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              bool isSelected = _selectedChildIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedChildIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primaryGreen
                          : AppColor.borderGrey,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColor.primaryGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      child.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColor.textBlack,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==========================================
  // 🎨 WIDGET KARTU IMUNISASI
  // ==========================================
  Widget _buildImunisasiCard({
    required String usia,
    required String vaksin,
    required String status,
    required String tanggal,
    required bool isDone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDone ? AppColor.primaryGreen.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? AppColor.primaryGreen.withOpacity(0.5)
              : AppColor.borderGrey,
          width: isDone ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isDone)
            BoxShadow(
              color: AppColor.primaryGreen.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔵 IKON STATUS
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColor.primaryGreen
                  : AppColor.borderGrey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_rounded : Icons.vaccines_rounded,
              color: isDone ? Colors.white : AppColor.textGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // 🔵 DETAIL KONTEN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Usia $usia",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDone
                            ? AppColor.primaryGreen
                            : AppColor.textBlack,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColor.primaryGreen.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDone ? AppColor.primaryGreen : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  vaksin,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColor.textBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDone ? AppColor.textGrey : Colors.transparent,
                    ),
                    if (isDone) const SizedBox(width: 6),
                    Text(
                      isDone ? "Diberikan pada: $tanggal" : "Belum diberikan",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone ? AppColor.textGrey : AppColor.borderGrey,
                        fontStyle: isDone ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
