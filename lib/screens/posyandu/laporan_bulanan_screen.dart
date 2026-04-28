import 'dart:io'; 
import 'package:csv/csv.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:share_plus/share_plus.dart'; 
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LaporanBulananScreen extends StatefulWidget {
  const LaporanBulananScreen({super.key});

  @override
  State<LaporanBulananScreen> createState() => _LaporanBulananScreenState();
}

class _LaporanBulananScreenState extends State<LaporanBulananScreen> {
  final FirestoreService _firestore = FirestoreService();
  bool isExporting = false;
  bool isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) {
        setState(() {
          isLocaleInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLocaleInitialized) {
      return const Scaffold(
        backgroundColor: AppColor.bgWhite,
        body: Center(
          child: CircularProgressIndicator(color: AppColor.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        title: const Text("Rekapitulasi Bulanan"),
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColor.textBlack),
        titleTextStyle: const TextStyle(
          color: AppColor.textBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestore.getAllChildrenForKader(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColor.primaryGreen));
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Gagal memuat data laporan."));
          }

          final children = snapshot.data!;
          final totalLakiLaki = children.where((c) => c['gender'] == 'L').length;
          final totalPerempuan = children.where((c) => c['gender'] == 'P').length;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.analytics_rounded, size: 40, color: AppColor.primaryGreen),
                      const SizedBox(height: 12),
                      Text(
                        "Laporan Posyandu",
                        style: AppTextStyle.heading1.copyWith(fontSize: 18),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()), 
                        style: AppTextStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                const Text("Statistik Wilayah", style: AppTextStyle.heading1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard("Laki-laki", totalLakiLaki, Colors.blue, Icons.male_rounded),
                    const SizedBox(width: 16),
                    _buildStatCard("Perempuan", totalPerempuan, Colors.pink, Icons.female_rounded),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard("Total Balita Terdaftar", children.length, AppColor.primaryGreen, Icons.groups_rounded, isFullWidth: true),
                
                const SizedBox(height: 40),

                const Text("Unduh Data Master", style: AppTextStyle.heading1),
                const SizedBox(height: 8),
                const Text("Data akan disiapkan dalam format Excel (.CSV) dan siap dibagikan.", style: AppTextStyle.bodyText),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isExporting ? null : () => _exportToCSV(children),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: isExporting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.table_view_rounded, color: Colors.white),
                    label: Text(
                      isExporting ? "Menyiapkan File..." : "Unduh Laporan (Excel/CSV)",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon, {bool isFullWidth = false}) {
    return Expanded(
      flex: isFullWidth ? 0 : 1,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColor.borderGrey),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(count.toString(), style: AppTextStyle.heading1.copyWith(color: AppColor.textBlack)),
            Text(title, style: AppTextStyle.bodyText.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🔥 FUNGSI EKSPOR CSV NYATA (DIPERBARUI UNTUK MENGAMBIL SUB-KOLEKSI)
  // ==========================================
  void _exportToCSV(List<Map<String, dynamic>> data) async {
    setState(() => isExporting = true);

    try {
      List<List<dynamic>> rows = [];
      // Tambahkan kolom Imunisasi sekalian jika dibutuhkan
      rows.add([
        "No",
        "Nama Anak",
        "Jenis Kelamin",
        "Usia (Bulan)",
        "Berat Badan Terakhir (kg)",
        "Tinggi Badan Terakhir (cm)",
        "Imunisasi Terakhir"
      ]);

      for (int i = 0; i < data.length; i++) {
        final child = data[i];
        final childId = child['id'];
        final userId = child['userId']; // ID Ibu (Parent Document)
        
        // Memformat jenis kelamin
        String genderStr = "-";
        if (child['gender'] == 'L') genderStr = "Laki-laki";
        if (child['gender'] == 'P') genderStr = "Perempuan";

        String umur = child['age']?.toString() ?? '-';
        String beratBadan = '-';
        String tinggiBadan = '-';
        String imunisasi = '-';

        // 🔥 PERBAIKAN: Mengambil data pertumbuhan TERAKHIR dari sub-koleksi 'growth'
        // Kita gunakan fungsi getLastGrowthData yang sudah Anda siapkan di firestore_service!
        if (userId != null && childId != null && userId.isNotEmpty && childId.isNotEmpty) {
           final growthData = await _firestore.getLastGrowthData(userId, childId);
           
           if (growthData != null) {
              beratBadan = growthData['weight']?.toString() ?? '-';
              tinggiBadan = growthData['height']?.toString() ?? '-';
              imunisasi = growthData['imunisasi']?.toString() ?? '-';
           } else {
              // Jika data growth kosong, ambil data saat lahir sebagai cadangan (jika ada)
              beratBadan = child['birthWeight']?.toString() ?? '-';
              tinggiBadan = child['birthHeight']?.toString() ?? '-';
           }
        }

        rows.add([
          i + 1,
          child['name'] ?? '-',
          genderStr,
          umur,
          beratBadan,
          tinggiBadan,
          imunisasi, // Menambahkan info imunisasi
        ]);
      }

      String csvData = csv.encode(rows);

      final directory = await getApplicationDocumentsDirectory();
      final String bulanIni = DateFormat('MMM_yyyy').format(DateTime.now());
      final String filePath = '${directory.path}/Laporan_Posyandu_$bulanIni.csv';

      final File file = File(filePath);
      await file.writeAsString(csvData);

      if (!mounted) return;
      setState(() => isExporting = false);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Berikut adalah lampiran Laporan Bulanan Posyandu.',
      );

    } catch (e) {
      if (!mounted) return;
      setState(() => isExporting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengunduh laporan: $e"),
          backgroundColor: AppColor.errorRed,
        ),
      );
    }
  }
}