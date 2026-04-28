import 'package:flutter/material.dart';

// 🔥 Import Sistem Tema
import '../../theme/app_color.dart';
import '../../theme/app_text_style.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String content;
  final IconData icon;
  final Color color;
  final String source;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.content,
    required this.icon,
    required this.color,
    required this.source, // Wajib diisi dari layar sebelumnya
  });

  @override
  Widget build(BuildContext context) {
    // Kita langsung menggunakan 'color' yang dilempar dari layar sebelumnya
    final catColor = color;

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
                  content: Text("Artikel disimpan ke Bookmark!"),
                  backgroundColor: AppColor.primaryGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColor.textBlack),
            onPressed: () {
              // TODO: Implementasi logika share eksternal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fitur bagikan sedang dikembangkan"),
                  backgroundColor: Colors.indigo,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 GAMBAR HEADER ARTIKEL (Menggunakan icon dinamis)
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
                    icon, // Berubah sesuai artikel yang diklik
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

                    // 🔥 JUDUL ARTIKEL DINAMIS
                    Text(
                      title, // Berubah sesuai artikel yang diklik
                      style: AppTextStyle.heading1.copyWith(
                        fontSize: 26,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔥 INFO PENULIS & WAKTU BACA DINAMIS
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
                              "Ditinjau secara medis",
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
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColor.textGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                time, // Waktu baca dinamis
                                style: const TextStyle(
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

                    // 🔥 ISI KONTEN DINAMIS
                    // Diganti menggunakan SelectableText agar user bisa copy teks jika perlu
                    SelectableText(
                      content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: AppColor.textBlack,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 40),

                    // 🔥 FITUR BARU: KOTAK SUMBER REFERENSI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Colors.blue,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Sumber Referensi Medis Valid",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            source, // Menampilkan teks sumber yang dikirim dari EdukasiScreen
                            style: const TextStyle(
                              color: AppColor.textGrey,
                              fontSize: 13,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ), // Ruang ekstra di bawah agar nyaman di-scroll
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
