import 'package:flutter/material.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String category;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.category,
  });

  // Fungsi pembantu untuk menentukan warna badge berdasarkan kategori
  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'nutrisi':
        return Colors.orange;
      case 'kesehatan':
        return Colors.blue;
      case 'tumbuh':
        return AppColor.errorRed;
      default:
        return AppColor.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _getCategoryColor(category);

    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColor.textBlack),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColor.textBlack,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Artikel disimpan!"),
                  backgroundColor: AppColor.primaryGreen,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColor.textBlack),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 GAMBAR HEADER ARTIKEL (Placeholder Ilustrasi)
              Container(
                width: double.infinity,
                height: 220,
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: catColor.withOpacity(0.5),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 BADGE KATEGORI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: catColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔥 JUDUL ARTIKEL
                    Text(
                      title,
                      style: AppTextStyle.heading1.copyWith(
                        fontSize: 26,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔥 INFO PENULIS & WAKTU BACA
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColor.primaryGreen,
                          child: Icon(
                            Icons.health_and_safety,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Tim Dokter GrowPosy",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColor.textBlack,
                              ),
                            ),
                            Text(
                              "Dipublikasikan hari ini",
                              style: TextStyle(
                                color: AppColor.textGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.borderGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColor.textGrey,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "5 Menit",
                                style: TextStyle(
                                  color: AppColor.textGrey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: AppColor.borderGrey),
                    ),

                    // 🔥 ISI KONTEN (Tipografi diatur agar nyaman dibaca)
                    const Text(
                      "Masa balita adalah masa keemasan (golden age) bagi pertumbuhan dan perkembangan anak. Pada masa ini, otak anak berkembang sangat pesat, sehingga asupan nutrisi yang tepat dan stimulasi yang sesuai usia sangat krusial.\n\n"
                      "Langkah-Langkah Penting yang Harus Diperhatikan:\n\n"
                      "1. Berikan ASI Eksklusif\nBerikan ASI secara eksklusif hingga bayi berusia 6 bulan. Setelah itu, perlahan perkenalkan Makanan Pendamping ASI (MPASI) yang kaya akan zat besi, protein hewani, dan vitamin.\n\n"
                      "2. Pantau Grafik KMS Secara Berkala\nJangan pernah ragu untuk datang ke Posyandu setiap bulan. Penimbangan berat badan dan pengukuran tinggi badan sangat penting untuk memastikan anak Anda tetap berada di zona hijau KMS.\n\n"
                      "3. Lengkapi Imunisasi Dasar\nImunisasi adalah perisai pelindung anak dari penyakit berbahaya. Pastikan anak mendapatkan vaksin dasar seperti Hepatitis, BCG, DPT, Polio, dan Campak sesuai jadwal usia mereka.\n\n"
                      "4. Stimulasi Motorik dan Kognitif\nAjak anak bermain, berbicara, dan membacakan buku cerita. Interaksi ini sangat baik untuk melatih kemampuan motorik kasar, motorik halus, dan kecerdasan bahasa.\n\n"
                      "Kesimpulan\nJika dalam pemantauan KMS kurva anak menunjukkan tren mendatar atau menurun, segera konsultasikan masalah ini kepada Kader Posyandu atau Bidan desa agar dapat ditindaklanjuti lebih awal.",
                      style: TextStyle(
                        fontSize: 16,
                        height:
                            1.8, // Line height sangat penting untuk artikel panjang
                        color: AppColor.textBlack,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
