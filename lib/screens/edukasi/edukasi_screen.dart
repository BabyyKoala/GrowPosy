import 'package:flutter/material.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

// 🔥 Import Layar Detail Artikel
import 'article_detail_screen.dart';

class EdukasiScreen extends StatelessWidget {
  const EdukasiScreen({super.key});

  // ==========================================
  // 📚 DATABASE ARTIKEL EDUKASI LENGKAP
  // ==========================================
  final List<Map<String, dynamic>> listArtikel = const [
    {
      "title": "Pencegahan Stunting Sejak 1000 Hari Pertama Kehidupan (HPK)",
      "category": "Gizi & Nutrisi",
      "time": "5 Min Read",
      "icon": Icons.restaurant_menu_rounded,
      "color": Colors.orange,
      "content":
          "Stunting adalah kondisi gagal tumbuh pada anak balita (bayi di bawah 5 tahun) akibat dari kekurangan gizi kronis sehingga anak terlalu pendek untuk usianya. Kekurangan gizi ini terjadi sejak bayi dalam kandungan pada masa awal setelah bayi lahir.\n\n"
          "Masa 1000 Hari Pertama Kehidupan (HPK) terdiri dari 270 hari masa kehamilan dan 730 hari pada 2 tahun pertama kehidupan bayi. Masa ini adalah periode emas atau 'window of opportunity' yang sangat krusial.\n\n"
          "Cara mencegah stunting di periode ini meliputi:\n"
          "1. Ibu hamil mengonsumsi makanan bergizi dan rutin meminum Tablet Tambah Darah (TTD).\n"
          "2. Memberikan Inisiasi Menyusu Dini (IMD) saat bayi baru lahir.\n"
          "3. Memberikan ASI Eksklusif selama 6 bulan penuh tanpa tambahan air putih atau makanan lain.\n"
          "4. Mulai memberikan Makanan Pendamping ASI (MPASI) yang kaya protein hewani sejak usia 6 bulan, sembari terus memberikan ASI hingga 2 tahun.\n\n"
          "Rutin membawa anak ke Posyandu setiap bulan juga sangat penting untuk memantau kurva pertumbuhan tinggi dan berat badan anak, sehingga risiko stunting dapat dideteksi sejak dini.",
      "source":
          "1. Kementerian Kesehatan Republik Indonesia. (2022). 'Buku Kesehatan Ibu dan Anak (KIA)'. Jakarta.\n"
          "2. World Health Organization (WHO). 'Stunting in a Nutshell'.\n"
          "3. Peraturan Presiden Republik Indonesia Nomor 72 Tahun 2021 tentang Percepatan Penurunan Stunting.",
    },
    {
      "title": "Jadwal Imunisasi Dasar Lengkap Kemenkes RI 2024",
      "category": "Vaksinasi",
      "time": "4 Min Read",
      "icon": Icons.vaccines_rounded,
      "color": Colors.blue,
      "content":
          "Imunisasi adalah proses untuk membuat sistem kekebalan tubuh balita menjadi kuat terhadap suatu penyakit infeksi yang berbahaya. Kelalaian dalam memberikan imunisasi dapat menyebabkan balita rentan terhadap cacat permanen bahkan kematian akibat wabah.\n\n"
          "Berikut adalah jadwal imunisasi dasar lengkap yang diwajibkan oleh Pemerintah:\n\n"
          "• Usia 0 Bulan: Hepatitis B0 (diberikan kurang dari 24 jam setelah lahir).\n"
          "• Usia 1 Bulan: BCG (mencegah Tuberkulosis) dan Polio 1.\n"
          "• Usia 2 Bulan: DPT-HB-Hib 1 (mencegah Difteri, Pertusis, Tetanus) dan Polio 2.\n"
          "• Usia 3 Bulan: DPT-HB-Hib 2 dan Polio 3.\n"
          "• Usia 4 Bulan: DPT-HB-Hib 3, Polio 4, dan IPV (Polio suntik).\n"
          "• Usia 9 Bulan: Campak / Rubella (MR).\n\n"
          "Apabila anak terlambat menerima salah satu imunisasi, Ibu tidak perlu mengulang dari awal. Segera bawa anak ke fasilitas kesehatan terdekat untuk melakukan 'Imunisasi Kejar' (Catch-up Immunization). Reaksi demam ringan setelah imunisasi adalah hal yang wajar sebagai tanda antibodi tubuh sedang bekerja.",
      "source":
          "1. Ikatan Dokter Anak Indonesia (IDAI). (2023). 'Jadwal Imunisasi Anak Umur 0-18 Tahun'. Jakarta.\n"
          "2. Peraturan Menteri Kesehatan RI Nomor 12 Tahun 2017 tentang Penyelenggaraan Imunisasi.",
    },
    {
      "title": "Panduan MPASI yang Benar untuk Bayi Usia 6-12 Bulan",
      "category": "Tumbuh Kembang",
      "time": "6 Min Read",
      "icon": Icons.child_care_rounded,
      "color": AppColor.primaryGreen,
      "content":
          "Makanan Pendamping ASI (MPASI) mulai diberikan saat bayi berusia tepat 6 bulan. Pada usia ini, ASI saja sudah tidak lagi mencukupi kebutuhan kalori dan zat besi harian bayi yang semakin besar.\n\n"
          "Kunci sukses pemberian MPASI terletak pada 4 strategi:\n\n"
          "1. Tepat Waktu: Diberikan saat ASI saja sudah tidak cukup (usia 6 bulan).\n"
          "2. Cukup Kandungan Gizi (Adekuat): MPASI harus mengandung makronutrien dan mikronutrien, khususnya Protein Hewani (daging sapi, ati ayam, telur, ikan) dan Zat Besi untuk mencegah anemia.\n"
          "3. Aman dan Higienis: Alat masak harus bersih, mencuci tangan sebelum menyuapi, dan memisahkan talenan mentah dan matang.\n"
          "4. Diberikan dengan Cara yang Benar (Responsive Feeding): Ibu harus peka terhadap tanda lapar dan kenyang anak. Jangan memaksa anak menghabiskan makanan jika ia sudah memalingkan wajah atau menutup mulut.\n\n"
          "Tekstur makanan harus dinaikkan secara bertahap. Usia 6-8 bulan menggunakan tekstur saring halus (puree/mashed), 9-11 bulan tekstur cincang kasar (minced/chopped) yang bisa dipegang anak (finger food), dan usia 12 bulan ke atas sudah bisa ikut makanan keluarga.",
      "source":
          "1. World Health Organization (WHO). (2023). 'Guiding principles for complementary feeding of the breastfed child'.\n"
          "2. Ikatan Dokter Anak Indonesia (IDAI). (2018). 'Rekomendasi Praktik Pemberian Makan Berbasis Bukti pada Bayi dan Batita di Indonesia'.",
    },
    {
      "title": "Mengenali 'Red Flags' (Tanda Bahaya) Perkembangan Anak",
      "category": "Psikologi & Motorik",
      "time": "5 Min Read",
      "icon": Icons.directions_run_rounded,
      "color": Colors.purple,
      "content":
          "Setiap anak memang memiliki kecepatan tumbuh kembang yang berbeda-beda. Namun, ada batas waktu maksimal di mana seorang anak harus sudah bisa menguasai kemampuan tertentu. Batas ini disebut dengan 'Red Flags' atau tanda bahaya.\n\n"
          "Orang tua perlu segera berkonsultasi dengan Dokter Spesialis Anak jika menemukan Red Flags berikut pada balitanya:\n\n"
          "Motorik Kasar:\n"
          "• Usia 4 Bulan: Belum bisa menegakkan kepala saat ditengkurapkan.\n"
          "• Usia 9 Bulan: Belum bisa duduk sendiri tanpa pegangan.\n"
          "• Usia 18 Bulan: Belum bisa berjalan sendiri.\n\n"
          "Motorik Halus & Sosial:\n"
          "• Usia 6 Bulan: Tidak ada senyum sosial, tidak merespons saat dipanggil namanya, atau tidak melakukan kontak mata.\n"
          "• Usia 12 Bulan: Belum bisa menunjuk benda menggunakan telunjuk atau melambai (dadah).\n\n"
          "Bahasa (Speech Delay):\n"
          "• Usia 12 Bulan: Tidak ada babbling (mengoceh 'ba-ba-ba' / 'ma-ma-ma').\n"
          "• Usia 16 Bulan: Belum ada satu kata pun yang bermakna.\n\n"
          "Semakin cepat Red Flags dideteksi, semakin efektif intervensi (seperti fisioterapi atau terapi wicara) yang bisa dilakukan untuk mengejar ketertinggalan anak.",
      "source":
          "1. Centers for Disease Control and Prevention (CDC). (2022). 'Developmental Milestones'.\n"
          "2. Ikatan Dokter Anak Indonesia (IDAI). 'Kapan Orangtua Harus Waspada Terhadap Keterlambatan Perkembangan Anak?'.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColor.bgWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Pusat Edukasi",
          style: TextStyle(
            color: AppColor.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Text(
                "Artikel Kesehatan Anak",
                style: AppTextStyle.heading1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Text(
                "Informasi terpercaya untuk mendukung tumbuh kembang balita Anda.",
                style: AppTextStyle.bodyText,
              ),
            ),

            // 🔥 LIST ARTIKEL
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: listArtikel.length,
                itemBuilder: (context, index) {
                  final artikel = listArtikel[index];
                  return _buildArticleCard(context, artikel);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🎨 WIDGET KARTU ARTIKEL LIST
  // ==========================================
  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // 🔥 Navigasi ke Halaman Detail sambil membawa seluruh data lengkap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              title: data['title'],
              category: data['category'],
              time: data['time'],
              icon: data['icon'],
              color: data['color'],
              content: data['content'],
              source: data['source'], // Melempar referensi ke layar detail
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // KOTAK IKON
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: (data['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(data['icon'], color: data['color'], size: 36),
              ),
            ),
            const SizedBox(width: 16),

            // TEKS KONTEN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['category'].toString().toUpperCase(),
                    style: TextStyle(
                      color: data['color'],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textBlack,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColor.textGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['time'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColor.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
